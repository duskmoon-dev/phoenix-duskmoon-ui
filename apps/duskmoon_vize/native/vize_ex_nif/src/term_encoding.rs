use rustler::types::map::MapIterator;
use rustler::{Encoder, Env, Error, NifResult, Term};
use serde_json::{Map, Number, Value};

use crate::atoms;

pub(crate) struct EncodedLoc {
    start: usize,
    end: usize,
    start_line: usize,
    start_column: usize,
    end_line: usize,
    end_column: usize,
}

impl From<&vize_atelier_sfc::BlockLocation> for EncodedLoc {
    fn from(loc: &vize_atelier_sfc::BlockLocation) -> Self {
        Self {
            start: loc.start,
            end: loc.end,
            start_line: loc.start_line,
            start_column: loc.start_column,
            end_line: loc.end_line,
            end_column: loc.end_column,
        }
    }
}

impl Encoder for EncodedLoc {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::start().encode(env),
                atoms::end_().encode(env),
                atoms::start_line().encode(env),
                atoms::start_column().encode(env),
                atoms::end_line().encode(env),
                atoms::end_column().encode(env),
            ],
            &[
                self.start.encode(env),
                self.end.encode(env),
                self.start_line.encode(env),
                self.start_column.encode(env),
                self.end_line.encode(env),
                self.end_column.encode(env),
            ],
        )
        .unwrap()
    }
}

pub(crate) fn loc_to_term<'a>(env: Env<'a>, loc: &vize_atelier_sfc::BlockLocation) -> Term<'a> {
    EncodedLoc::from(loc).encode(env)
}

pub(crate) fn attrs_to_term<'a>(
    env: Env<'a>,
    attrs: &vize_carton::FxHashMap<std::borrow::Cow<'_, str>, std::borrow::Cow<'_, str>>,
) -> Term<'a> {
    let keys: Vec<Term<'a>> = attrs.keys().map(|k| k.as_ref().encode(env)).collect();
    let vals: Vec<Term<'a>> = attrs.values().map(|v| v.as_ref().encode(env)).collect();
    if keys.is_empty() {
        Term::map_new(env)
    } else {
        Term::map_from_arrays(env, &keys, &vals).unwrap()
    }
}

struct EncodedSfcError<'a> {
    message: &'a str,
    code: Option<&'a str>,
}

impl<'a> From<&'a vize_atelier_sfc::SfcError> for EncodedSfcError<'a> {
    fn from(err: &'a vize_atelier_sfc::SfcError) -> Self {
        Self {
            message: err.message.as_str(),
            code: err.code.as_deref(),
        }
    }
}

impl Encoder for EncodedSfcError<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let mut keys = vec![atoms::message().encode(env)];
        let mut vals: Vec<Term<'a>> = vec![self.message.encode(env)];
        if let Some(code) = self.code {
            keys.push(atoms::code().encode(env));
            vals.push(code.encode(env));
        }
        Term::map_from_arrays(env, &keys, &vals).unwrap()
    }
}

pub(crate) struct EncodedLintDiagnostic<'a> {
    pub(crate) message: &'a str,
    pub(crate) name: &'a str,
}

impl Encoder for EncodedLintDiagnostic<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[atoms::message().encode(env), atoms::name().encode(env)],
            &[self.message.encode(env), self.name.encode(env)],
        )
        .unwrap()
    }
}

pub(crate) fn nil_term<'a>(env: Env<'a>) -> Term<'a> {
    rustler::types::atom::nil().encode(env)
}

pub(crate) fn ok_term<'a, T: Encoder>(env: Env<'a>, payload: T) -> Term<'a> {
    (atoms::ok(), payload).encode(env)
}

pub(crate) fn error_term<'a, T: Encoder>(env: Env<'a>, payload: T) -> Term<'a> {
    (atoms::error(), payload).encode(env)
}

pub(crate) fn encode_json_value<'a>(env: Env<'a>, value: &Value) -> Term<'a> {
    match value {
        Value::Null => nil_term(env),
        Value::Bool(value) => value.encode(env),
        Value::Number(number) => {
            if let Some(value) = number.as_i64() {
                value.encode(env)
            } else if let Some(value) = number.as_u64() {
                value.encode(env)
            } else if let Some(value) = number.as_f64() {
                value.encode(env)
            } else {
                nil_term(env)
            }
        }
        Value::String(value) => value.encode(env),
        Value::Array(items) => {
            let terms: Vec<Term<'a>> = items
                .iter()
                .map(|item| encode_json_value(env, item))
                .collect();
            terms.encode(env)
        }
        Value::Object(map) => {
            let keys: Vec<Term<'a>> = map.keys().map(|key| key.encode(env)).collect();
            let values: Vec<Term<'a>> = map
                .values()
                .map(|value| encode_json_value(env, value))
                .collect();

            if keys.is_empty() {
                Term::map_new(env)
            } else {
                Term::map_from_arrays(env, &keys, &values).unwrap()
            }
        }
    }
}

pub(crate) fn decode_json_value(term: Term<'_>) -> NifResult<Value> {
    if term.is_empty_list() {
        return Ok(Value::Array(vec![]));
    }

    if term.is_list() {
        let items = term.decode::<Vec<Term>>()?;
        return items
            .into_iter()
            .map(decode_json_value)
            .collect::<NifResult<Vec<_>>>()
            .map(Value::Array);
    }

    if term.is_map() {
        let mut map = Map::new();
        let iterator = MapIterator::new(term).ok_or(Error::BadArg)?;

        for (key, value) in iterator {
            map.insert(
                key.decode::<std::string::String>()?,
                decode_json_value(value)?,
            );
        }

        return Ok(Value::Object(map));
    }

    if let Ok(value) = term.decode::<bool>() {
        return Ok(Value::Bool(value));
    }

    if let Ok(value) = term.decode::<i64>() {
        return Ok(Value::Number(value.into()));
    }

    if let Ok(value) = term.decode::<u64>() {
        return Ok(Value::Number(value.into()));
    }

    if let Ok(value) = term.decode::<f64>() {
        if let Some(number) = Number::from_f64(value) {
            return Ok(Value::Number(number));
        }
    }

    if let Ok(value) = term.decode::<std::string::String>() {
        return Ok(Value::String(value));
    }

    if term == nil_term(term.get_env()) {
        return Ok(Value::Null);
    }

    Err(Error::BadArg)
}

struct EncodedTemplateBlock<'a>(&'a vize_atelier_sfc::SfcTemplateBlock<'a>);

impl Encoder for EncodedTemplateBlock<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::content().encode(env),
                atoms::lang().encode(env),
                atoms::loc().encode(env),
                atoms::attrs().encode(env),
            ],
            &[
                self.0.content.as_ref().encode(env),
                self.0.lang.as_deref().encode(env),
                loc_to_term(env, &self.0.loc),
                attrs_to_term(env, &self.0.attrs),
            ],
        )
        .unwrap()
    }
}

struct EncodedScriptBlock<'a>(&'a vize_atelier_sfc::SfcScriptBlock<'a>);

impl Encoder for EncodedScriptBlock<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::content().encode(env),
                atoms::lang().encode(env),
                atoms::setup().encode(env),
                atoms::loc().encode(env),
                atoms::attrs().encode(env),
            ],
            &[
                self.0.content.as_ref().encode(env),
                self.0.lang.as_deref().encode(env),
                self.0.setup.encode(env),
                loc_to_term(env, &self.0.loc),
                attrs_to_term(env, &self.0.attrs),
            ],
        )
        .unwrap()
    }
}

struct EncodedStyleBlock<'a>(&'a vize_atelier_sfc::SfcStyleBlock<'a>);

impl Encoder for EncodedStyleBlock<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::content().encode(env),
                atoms::lang().encode(env),
                atoms::scoped().encode(env),
                atoms::module().encode(env),
                atoms::loc().encode(env),
                atoms::attrs().encode(env),
            ],
            &[
                self.0.content.as_ref().encode(env),
                self.0.lang.as_deref().encode(env),
                self.0.scoped.encode(env),
                self.0.module.as_deref().encode(env),
                loc_to_term(env, &self.0.loc),
                attrs_to_term(env, &self.0.attrs),
            ],
        )
        .unwrap()
    }
}

struct EncodedCustomBlock<'a>(&'a vize_atelier_sfc::SfcCustomBlock<'a>);

impl Encoder for EncodedCustomBlock<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::block_type().encode(env),
                atoms::content().encode(env),
                atoms::loc().encode(env),
                atoms::attrs().encode(env),
            ],
            &[
                self.0.block_type.as_ref().encode(env),
                self.0.content.as_ref().encode(env),
                loc_to_term(env, &self.0.loc),
                attrs_to_term(env, &self.0.attrs),
            ],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedParseSfcResult<'a> {
    pub(crate) descriptor: &'a vize_atelier_sfc::SfcDescriptor<'a>,
}

impl Encoder for EncodedParseSfcResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let template_term = self
            .descriptor
            .template
            .as_ref()
            .map(|template| EncodedTemplateBlock(template).encode(env))
            .unwrap_or_else(|| nil_term(env));
        let script_term = self
            .descriptor
            .script
            .as_ref()
            .map(|script| EncodedScriptBlock(script).encode(env))
            .unwrap_or_else(|| nil_term(env));
        let script_setup_term = self
            .descriptor
            .script_setup
            .as_ref()
            .map(|script| EncodedScriptBlock(script).encode(env))
            .unwrap_or_else(|| nil_term(env));
        let styles_term: Vec<Term<'a>> = self
            .descriptor
            .styles
            .iter()
            .map(|style| EncodedStyleBlock(style).encode(env))
            .collect();
        let custom_blocks_term: Vec<Term<'a>> = self
            .descriptor
            .custom_blocks
            .iter()
            .map(|block| EncodedCustomBlock(block).encode(env))
            .collect();

        Term::map_from_arrays(
            env,
            &[
                atoms::template().encode(env),
                atoms::script().encode(env),
                atoms::script_setup().encode(env),
                atoms::styles().encode(env),
                atoms::custom_blocks().encode(env),
            ],
            &[
                template_term,
                script_term,
                script_setup_term,
                styles_term.encode(env),
                custom_blocks_term.encode(env),
            ],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedCompileSfcResult<'a> {
    pub(crate) result: &'a vize_atelier_sfc::SfcCompileResult,
    pub(crate) code_override: Option<&'a str>,
    pub(crate) template_hash: Option<vize_carton::CompactString>,
    pub(crate) style_hash: Option<vize_carton::CompactString>,
    pub(crate) script_hash: Option<vize_carton::CompactString>,
}

struct EncodedMacroArtifact<'a>(&'a vize_atelier_sfc::SfcMacroArtifact);

impl Encoder for EncodedMacroArtifact<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let mut keys = vec![
            atoms::kind().encode(env),
            atoms::name().encode(env),
            atoms::source().encode(env),
            atoms::content().encode(env),
            atoms::start().encode(env),
            atoms::end_().encode(env),
        ];
        let mut vals: Vec<Term<'a>> = vec![
            self.0.kind.as_str().encode(env),
            self.0.name.as_str().encode(env),
            self.0.source.as_str().encode(env),
            self.0.content.as_str().encode(env),
            self.0.start.encode(env),
            self.0.end.encode(env),
        ];
        if let Some(ref module_code) = self.0.module_code {
            keys.push(atoms::code().encode(env));
            vals.push(module_code.as_str().encode(env));
        }
        Term::map_from_arrays(env, &keys, &vals).unwrap()
    }
}

impl Encoder for EncodedCompileSfcResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let errors: Vec<Term<'a>> = self
            .result
            .errors
            .iter()
            .map(|error| EncodedSfcError::from(error).encode(env))
            .collect();
        let warnings: Vec<Term<'a>> = self
            .result
            .warnings
            .iter()
            .map(|warning| EncodedSfcError::from(warning).encode(env))
            .collect();
        let macro_artifacts: Vec<Term<'a>> = self
            .result
            .macro_artifacts
            .iter()
            .map(|a| EncodedMacroArtifact(a).encode(env))
            .collect();

        let code = self.code_override.unwrap_or(self.result.code.as_str());

        Term::map_from_arrays(
            env,
            &[
                atoms::code().encode(env),
                atoms::css().encode(env),
                atoms::errors().encode(env),
                atoms::warnings().encode(env),
                atoms::template_hash().encode(env),
                atoms::style_hash().encode(env),
                atoms::script_hash().encode(env),
                atoms::macro_artifacts().encode(env),
            ],
            &[
                code.encode(env),
                self.result.css.as_deref().encode(env),
                errors.encode(env),
                warnings.encode(env),
                self.template_hash.as_deref().encode(env),
                self.style_hash.as_deref().encode(env),
                self.script_hash.as_deref().encode(env),
                macro_artifacts.encode(env),
            ],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedTemplateCompileResult<'a> {
    pub(crate) code: &'a str,
    pub(crate) preamble: &'a str,
    pub(crate) helpers: Vec<&'a str>,
}

impl Encoder for EncodedTemplateCompileResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[
                atoms::code().encode(env),
                atoms::preamble().encode(env),
                atoms::helpers().encode(env),
            ],
            &[
                self.code.encode(env),
                self.preamble.encode(env),
                self.helpers.encode(env),
            ],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedSsrCompileResult<'a> {
    pub(crate) code: &'a str,
    pub(crate) preamble: &'a str,
}

impl Encoder for EncodedSsrCompileResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        Term::map_from_arrays(
            env,
            &[atoms::code().encode(env), atoms::preamble().encode(env)],
            &[self.code.encode(env), self.preamble.encode(env)],
        )
        .unwrap()
    }
}

fn encode_css_exports<'a>(
    env: Env<'a>,
    exports: Option<
        &vize_carton::FxHashMap<vize_carton::CompactString, vize_atelier_sfc::css::CssModuleExport>,
    >,
) -> Term<'a> {
    match exports {
        Some(exports) if exports.is_empty() => nil_term(env),
        Some(exports) => {
            let keys: Vec<Term<'a>> = exports.keys().map(|key| key.as_str().encode(env)).collect();
            let values: Vec<Term<'a>> = exports
                .values()
                .map(|value| value.name.as_str().encode(env))
                .collect();
            Term::map_from_arrays(env, &keys, &values).unwrap()
        }
        None => nil_term(env),
    }
}

pub(crate) struct EncodedCssAstResult<'a> {
    pub(crate) result: &'a vize_atelier_sfc::CssAstResult,
}

impl Encoder for EncodedCssAstResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let errors: Vec<&str> = self
            .result
            .errors
            .iter()
            .map(|value| value.as_str())
            .collect();
        let warnings: Vec<&str> = self
            .result
            .warnings
            .iter()
            .map(|value| value.as_str())
            .collect();
        let ast = self
            .result
            .ast
            .as_ref()
            .map(|value| encode_json_value(env, value))
            .unwrap_or_else(|| nil_term(env));

        Term::map_from_arrays(
            env,
            &[
                atoms::ast().encode(env),
                atoms::errors().encode(env),
                atoms::warnings().encode(env),
            ],
            &[ast, errors.encode(env), warnings.encode(env)],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedCssCompileResult<'a> {
    pub(crate) result: &'a vize_atelier_sfc::CssCompileResult,
}

impl Encoder for EncodedCssCompileResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let css_vars: Vec<&str> = self
            .result
            .css_vars
            .iter()
            .map(|value| value.as_str())
            .collect();
        let errors: Vec<&str> = self
            .result
            .errors
            .iter()
            .map(|value| value.as_str())
            .collect();
        let warnings: Vec<&str> = self
            .result
            .warnings
            .iter()
            .map(|value| value.as_str())
            .collect();

        Term::map_from_arrays(
            env,
            &[
                atoms::code().encode(env),
                atoms::css_vars().encode(env),
                atoms::errors().encode(env),
                atoms::warnings().encode(env),
                atoms::exports().encode(env),
            ],
            &[
                self.result.code.as_str().encode(env),
                css_vars.encode(env),
                errors.encode(env),
                warnings.encode(env),
                encode_css_exports(env, self.result.exports.as_ref()),
            ],
        )
        .unwrap()
    }
}

pub(crate) struct EncodedBundleCssResult<'a> {
    pub(crate) result: &'a vize_atelier_sfc::CssCompileResult,
}

impl Encoder for EncodedBundleCssResult<'_> {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        let errors: Vec<&str> = self
            .result
            .errors
            .iter()
            .map(|value| value.as_str())
            .collect();
        let warnings: Vec<&str> = self
            .result
            .warnings
            .iter()
            .map(|value| value.as_str())
            .collect();

        Term::map_from_arrays(
            env,
            &[
                atoms::code().encode(env),
                atoms::errors().encode(env),
                atoms::warnings().encode(env),
                atoms::exports().encode(env),
            ],
            &[
                self.result.code.as_str().encode(env),
                errors.encode(env),
                warnings.encode(env),
                encode_css_exports(env, self.result.exports.as_ref()),
            ],
        )
        .unwrap()
    }
}
