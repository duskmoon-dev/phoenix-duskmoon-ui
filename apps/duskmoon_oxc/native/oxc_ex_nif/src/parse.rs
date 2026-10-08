use std::path::PathBuf;

use oxc_allocator::Allocator;
use oxc_codegen::{Codegen, CodegenOptions, CodegenReturn};
use oxc_minifier::{CompressOptions, MangleOptions, Minifier, MinifierOptions};
use oxc_parser::{ParseOptions, Parser};
use oxc_semantic::SemanticBuilder;
use oxc_span::SourceType;
use oxc_transformer::{EnvOptions, JsxRuntime, TransformOptions, Transformer};
use rustler::{Binary, Encoder, Env, Error, NifResult, OwnedBinary, SerdeTerm, Term};
use serde::de::{self, Visitor};
use serde::Serialize;
use serde_json::value::RawValue;
use std::fmt;
use std::path::Path;

use crate::atoms;
use crate::error::{error_to_term, format_errors};
use crate::options::{MinifyInput, TransformInput};

fn parser_options() -> ParseOptions {
    ParseOptions {
        parse_regular_expression: true,
        ..ParseOptions::default()
    }
}

fn encode_ok<'a, T: Serialize>(env: Env<'a>, value: T) -> NifResult<Term<'a>> {
    Ok((atoms::ok(), SerdeTerm(value)).encode(env))
}

#[derive(Clone, Copy)]
struct BeamScalar<'a> {
    env: Env<'a>,
}

impl<'a> BeamScalar<'a> {
    fn decode(self, raw: &str) -> Result<Term<'a>, serde_json::Error> {
        // JavaScript strings can contain lone UTF-16 surrogates. Deserialize
        // those as WTF-8 bytes, rather than requiring a Rust UTF-8 String.
        let mut deserializer = serde_json::Deserializer::from_str(raw);

        if raw.starts_with('"') {
            de::Deserializer::deserialize_bytes(&mut deserializer, self)
        } else if matches!(raw.as_bytes().first(), Some(b'-' | b'0'..=b'9')) {
            // With arbitrary_precision enabled, deserialize_any represents
            // decimals through a private map. Number handles that internally;
            // only ordinary integer/float terms should cross the BEAM boundary.
            let number: serde_json::Number = serde_json::from_str(raw)?;
            if let Some(value) = number.as_u64() {
                return self.visit_u64(value);
            }
            if let Some(value) = number.as_i64() {
                return self.visit_i64(value);
            }
            number
                .as_f64()
                .ok_or_else(|| de::Error::custom("JSON number out of range"))
                .and_then(|value| self.visit_f64(value))
        } else {
            de::Deserializer::deserialize_any(&mut deserializer, self)
        }
    }
}

impl<'de, 'a> Visitor<'de> for BeamScalar<'a> {
    type Value = Term<'a>;

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("a JSON scalar")
    }

    fn visit_unit<E>(self) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(Option::<u8>::None.encode(self.env))
    }

    fn visit_none<E>(self) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        self.visit_unit()
    }

    fn visit_bool<E>(self, value: bool) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_i64<E>(self, value: i64) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_u64<E>(self, value: u64) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_f64<E>(self, value: f64) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_str<E>(self, value: &str) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_string<E>(self, value: String) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        Ok(value.encode(self.env))
    }

    fn visit_bytes<E>(self, value: &[u8]) -> Result<Self::Value, E>
    where
        E: de::Error,
    {
        let mut binary = OwnedBinary::new(value.len())
            .ok_or_else(|| de::Error::custom("failed to allocate JSON string binary"))?;
        binary.as_mut_slice().copy_from_slice(value);
        Ok(binary.release(self.env).encode(self.env))
    }
}

struct JsonCursor<'j> {
    remaining: &'j str,
}

impl<'j> JsonCursor<'j> {
    fn peek(&mut self) -> Option<u8> {
        self.remaining = self.remaining.trim_start_matches([' ', '\t', '\r', '\n']);
        self.remaining.as_bytes().first().copied()
    }

    fn consume(&mut self, byte: u8) -> bool {
        if self.peek() == Some(byte) {
            self.remaining = &self.remaining[1..];
            true
        } else {
            false
        }
    }

    fn require(&mut self, byte: u8) -> Result<(), String> {
        if self.consume(byte) {
            Ok(())
        } else {
            Err(format!("Expected '{}' in ESTree JSON", char::from(byte)))
        }
    }

    fn scalar(&mut self) -> Result<&'j str, String> {
        // Containers are handled by heap-backed frames below. RawValue only
        // scans a scalar here, preserving escapes without recursive traversal.
        if matches!(self.peek(), Some(b'[' | b'{')) {
            return Err("Expected a JSON scalar".to_string());
        }
        let mut stream =
            serde_json::Deserializer::from_str(self.remaining).into_iter::<&RawValue>();
        let raw = stream
            .next()
            .ok_or_else(|| "Unexpected end of ESTree JSON".to_string())?
            .map_err(|error| error.to_string())?;
        self.remaining = &self.remaining[stream.byte_offset()..];
        Ok(raw.get())
    }

    fn key(&mut self) -> Result<String, String> {
        let key = serde_json::from_str(self.scalar()?).map_err(|error| error.to_string())?;
        self.require(b':')?;
        Ok(key)
    }
}

enum JsonFrame<'a> {
    Array(Vec<Term<'a>>),
    Object { map: Term<'a>, key: String },
}

fn json_str_to_term<'a>(env: Env<'a>, json: &str) -> Result<Term<'a>, String> {
    // AST depth must not become native stack depth: generated expressions can
    // exceed the dirty scheduler's stack. Keep both traversal state and decoded
    // children on the heap, and all Env/Term access on this scheduler thread.
    let mut cursor = JsonCursor { remaining: json };
    let mut frames = Vec::new();
    loop {
        let mut term = if cursor.consume(b'[') {
            if !cursor.consume(b']') {
                frames.push(JsonFrame::Array(Vec::new()));
                continue;
            }
            Vec::<Term<'a>>::new().encode(env)
        } else if cursor.consume(b'{') {
            let map = Term::map_new(env);
            if !cursor.consume(b'}') {
                frames.push(JsonFrame::Object {
                    map,
                    key: cursor.key()?,
                });
                continue;
            }
            map
        } else {
            BeamScalar { env }
                .decode(cursor.scalar()?)
                .map_err(|error| error.to_string())?
        };

        loop {
            match frames.pop() {
                Some(JsonFrame::Array(mut values)) => {
                    values.push(term);
                    if cursor.consume(b']') {
                        term = values.encode(env);
                        continue;
                    }
                    cursor.require(b',')?;
                    frames.push(JsonFrame::Array(values));
                }
                Some(JsonFrame::Object { map, key }) => {
                    let map = map
                        .map_put(key, term)
                        .map_err(|_| "Failed to encode JSON object as BEAM map".to_string())?;
                    if cursor.consume(b'}') {
                        term = map;
                        continue;
                    }
                    cursor.require(b',')?;
                    frames.push(JsonFrame::Object {
                        map,
                        key: cursor.key()?,
                    });
                }
                None => {
                    if cursor.peek().is_some() {
                        return Err("Trailing characters in ESTree JSON".to_string());
                    }
                    return Ok(term);
                }
            }
            break;
        }
    }
}

pub fn source_from_term<'a>(term: Term<'a>) -> NifResult<Binary<'a>> {
    term.decode_as_binary()
}

pub fn binary_to_str<'a, 'b>(binary: &'b Binary<'a>) -> NifResult<&'b str> {
    std::str::from_utf8(binary).map_err(|_| Error::BadArg)
}

#[derive(Serialize)]
struct CodeWithSourcemap {
    code: String,
    sourcemap: String,
}

pub fn build_transform_options(
    jsx_runtime: &str,
    jsx_factory: &str,
    jsx_fragment: &str,
    import_source: &str,
    target: &str,
) -> TransformOptions {
    let mut options = TransformOptions::default();
    options.jsx.runtime = match jsx_runtime {
        "classic" => JsxRuntime::Classic,
        _ => JsxRuntime::Automatic,
    };
    if !jsx_factory.is_empty() {
        options.jsx.pragma = Some(jsx_factory.to_string());
    }
    if !jsx_fragment.is_empty() {
        options.jsx.pragma_frag = Some(jsx_fragment.to_string());
    }
    if !import_source.is_empty() {
        options.jsx.import_source = Some(import_source.to_string());
    }
    if !target.is_empty() {
        if let Ok(env) = EnvOptions::from_target(target) {
            options.env = env;
        }
    }
    options
}

// -- Shared transform logic used by both `transform` and `transform_many` --

pub enum TransformOutput {
    Code(String),
    CodeWithMap { code: String, sourcemap: String },
    Error(Vec<String>),
}

impl TransformOutput {
    pub fn to_term<'a>(&self, env: Env<'a>) -> Term<'a> {
        match self {
            TransformOutput::Code(code) => (atoms::ok(), code.as_str()).encode(env),
            TransformOutput::CodeWithMap { code, sourcemap } => (
                atoms::ok(),
                SerdeTerm(CodeWithSourcemap {
                    code: code.clone(),
                    sourcemap: sourcemap.clone(),
                }),
            )
                .encode(env),
            TransformOutput::Error(errors) => crate::error::error_to_term(env, errors)
                .unwrap_or_else(|_| atoms::error().encode(env)),
        }
    }
}

pub fn transform_source(source: &str, filename: &str, opts: &TransformInput) -> TransformOutput {
    let allocator = Allocator::default();
    let source_type = SourceType::from_path(filename).unwrap_or_default();
    let path = Path::new(filename);

    let ret = Parser::new(&allocator, source, source_type)
        .with_options(parser_options())
        .parse();

    if !ret.errors.is_empty() {
        return TransformOutput::Error(format_errors(&ret.errors));
    }

    let mut program = ret.program;
    let scoping = SemanticBuilder::new()
        .build(&program)
        .semantic
        .into_scoping();

    let options = build_transform_options(
        &opts.jsx_runtime,
        &opts.jsx_factory,
        &opts.jsx_fragment,
        &opts.import_source,
        &opts.target,
    );
    let result =
        Transformer::new(&allocator, path, &options).build_with_scoping(scoping, &mut program);

    if !result.errors.is_empty() {
        return TransformOutput::Error(format_errors(&result.errors));
    }

    if opts.sourcemap {
        let CodegenReturn { code, map, .. } = Codegen::new()
            .with_options(CodegenOptions {
                source_map_path: Some(PathBuf::from(filename)),
                ..CodegenOptions::default()
            })
            .build(&program);

        match map {
            Some(map) => TransformOutput::CodeWithMap {
                code,
                sourcemap: map.to_json_string(),
            },
            None => TransformOutput::Code(code),
        }
    } else {
        let CodegenReturn { code, .. } = Codegen::new().build(&program);
        TransformOutput::Code(code)
    }
}

// -- NIF entry points --

#[rustler::nif(schedule = "DirtyCpu")]
pub fn parse<'a>(env: Env<'a>, source_term: Term<'a>, filename: &str) -> NifResult<Term<'a>> {
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let allocator = Allocator::default();
    let source_type = SourceType::from_path(filename).unwrap_or_default();
    let ret = Parser::new(&allocator, source, source_type)
        .with_options(parser_options())
        .parse();

    if !ret.errors.is_empty() {
        return error_to_term(env, &format_errors(&ret.errors));
    }

    let json_str = ret.program.to_estree_ts_json(false);
    let term = match json_str_to_term(env, &json_str) {
        Ok(term) => term,
        Err(error) => {
            return error_to_term(env, &[format!("Failed to decode ESTree JSON: {error}")]);
        }
    };
    Ok((atoms::ok(), term).encode(env))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn valid(source_term: Term<'_>, filename: &str) -> NifResult<bool> {
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let allocator = Allocator::default();
    let source_type = SourceType::from_path(filename).unwrap_or_default();
    let ret = Parser::new(&allocator, source, source_type).parse();
    Ok(ret.errors.is_empty())
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn transform<'a>(
    env: Env<'a>,
    source_term: Term<'a>,
    filename: &str,
    opts_term: Term<'a>,
) -> NifResult<Term<'a>> {
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let opts = TransformInput::from_term(opts_term);
    Ok(transform_source(source, filename, &opts).to_term(env))
}

#[rustler::nif(schedule = "DirtyCpu")]
pub fn minify<'a>(
    env: Env<'a>,
    source_term: Term<'a>,
    filename: &str,
    opts_term: Term<'a>,
) -> NifResult<Term<'a>> {
    let source_binary = source_from_term(source_term)?;
    let source = binary_to_str(&source_binary)?;
    let opts = MinifyInput::from_term(opts_term);
    let allocator = Allocator::default();
    let source_type = SourceType::from_path(filename).unwrap_or_default();

    let ret = Parser::new(&allocator, source, source_type)
        .with_options(parser_options())
        .parse();

    if !ret.errors.is_empty() {
        return error_to_term(env, &format_errors(&ret.errors));
    }

    let mut program = ret.program;
    let result = Minifier::new(MinifierOptions {
        mangle: opts.mangle.then(MangleOptions::default),
        compress: Some(CompressOptions::default()),
    })
    .minify(&allocator, &mut program);

    let CodegenReturn { code, .. } = Codegen::new()
        .with_options(CodegenOptions::minify())
        .with_scoping(result.scoping)
        .build(&program);

    encode_ok(env, code)
}
