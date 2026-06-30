use std::path::PathBuf;

use oxc_allocator::Allocator;
use oxc_codegen::{Codegen, CodegenOptions, CodegenReturn};
use oxc_minifier::{CompressOptions, MangleOptions, Minifier, MinifierOptions};
use oxc_parser::{ParseOptions, Parser};
use oxc_semantic::SemanticBuilder;
use oxc_span::SourceType;
use oxc_transformer::{EnvOptions, JsxRuntime, TransformOptions, Transformer};
use rustler::{Binary, Encoder, Env, Error, NifResult, SerdeTerm, Term};
use serde::de::{self, DeserializeSeed, MapAccess, SeqAccess, Visitor};
use serde::Serialize;
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
struct BeamTermSeed<'a> {
    env: Env<'a>,
}

impl<'de, 'a> DeserializeSeed<'de> for BeamTermSeed<'a> {
    type Value = Term<'a>;

    fn deserialize<D>(self, deserializer: D) -> Result<Self::Value, D::Error>
    where
        D: de::Deserializer<'de>,
    {
        deserializer.deserialize_any(self)
    }
}

impl<'de, 'a> Visitor<'de> for BeamTermSeed<'a> {
    type Value = Term<'a>;

    fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
        formatter.write_str("a JSON value")
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

    fn visit_seq<A>(self, mut seq: A) -> Result<Self::Value, A::Error>
    where
        A: SeqAccess<'de>,
    {
        let mut values = Vec::with_capacity(seq.size_hint().unwrap_or(0));
        while let Some(value) = seq.next_element_seed(self)? {
            values.push(value);
        }
        Ok(values.encode(self.env))
    }

    fn visit_map<A>(self, mut map_access: A) -> Result<Self::Value, A::Error>
    where
        A: MapAccess<'de>,
    {
        let mut map = Term::map_new(self.env);
        while let Some(key) = map_access.next_key::<String>()? {
            let value = map_access.next_value_seed(self)?;
            map = map
                .map_put(key, value)
                .map_err(|_| de::Error::custom("failed to encode JSON object as BEAM map"))?;
        }
        Ok(map)
    }
}

fn json_str_to_term<'a>(env: Env<'a>, json: &str) -> Result<Term<'a>, serde_json::Error> {
    let mut deserializer = serde_json::Deserializer::from_str(json);
    deserializer.disable_recursion_limit();
    BeamTermSeed { env }.deserialize(&mut deserializer)
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
