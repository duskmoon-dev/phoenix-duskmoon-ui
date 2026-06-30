use rayon::prelude::*;
use rustler::{Encoder, Env, NifResult, Term};

use crate::options::TransformInput;
use crate::parse::{binary_to_str, source_from_term, transform_source, TransformOutput};

#[rustler::nif(schedule = "DirtyCpu")]
pub fn transform_many<'a>(
    env: Env<'a>,
    inputs: Vec<(Term<'a>, String)>,
    opts_term: Term<'a>,
) -> NifResult<Term<'a>> {
    let opts = TransformInput::from_term(opts_term);
    let inputs = inputs
        .into_iter()
        .map(|(source_term, filename)| {
            let source_binary = source_from_term(source_term)?;
            let source = binary_to_str(&source_binary)?.to_owned();
            Ok((source, filename))
        })
        .collect::<NifResult<Vec<_>>>()?;

    let outputs: Vec<TransformOutput> = inputs
        .par_iter()
        .map(|(source, filename)| transform_source(source, filename, &opts))
        .collect();

    let terms: Vec<Term<'a>> = outputs
        .into_iter()
        .map(|output| output.to_term(env))
        .collect();

    Ok(terms.encode(env))
}
