use std::collections::HashMap;

use oxc_diagnostics::OxcDiagnostic;
use rustler::{Encoder, Env, NifResult, SerdeTerm, Term};

use crate::atoms;

pub fn format_errors(errors: &[OxcDiagnostic]) -> Vec<String> {
    errors.iter().map(ToString::to_string).collect()
}

pub fn error_to_term<'a>(env: Env<'a>, messages: &[String]) -> NifResult<Term<'a>> {
    let errors: Vec<HashMap<&str, String>> = messages
        .iter()
        .map(|message| {
            let mut map = HashMap::with_capacity(1);
            map.insert("message", message.clone());
            map
        })
        .collect();
    Ok((atoms::error(), SerdeTerm(errors)).encode(env))
}
