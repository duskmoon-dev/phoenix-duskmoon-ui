use rustler::{Encoder, Env, Term};
use vize_atelier_vapor::ir::IRProp;

use crate::atoms;

pub(crate) fn encode_simple_expr<'a>(
    env: Env<'a>,
    expr: &vize_atelier_core::SimpleExpressionNode,
) -> Term<'a> {
    if expr.is_static {
        rustler::types::tuple::make_tuple(
            env,
            &[
                atoms::static_().encode(env),
                expr.content.as_str().encode(env),
            ],
        )
    } else {
        expr.content.as_str().encode(env)
    }
}

pub(crate) fn encode_ir_prop<'a>(env: Env<'a>, prop: &IRProp) -> Term<'a> {
    let values: Vec<Term<'a>> = prop
        .values
        .iter()
        .map(|value| encode_simple_expr(env, value))
        .collect();

    term_map!(env, {
        atoms::key() => encode_simple_expr(env, &prop.key),
        atoms::values() => values,
        atoms::is_component() => prop.is_component,
    })
}
