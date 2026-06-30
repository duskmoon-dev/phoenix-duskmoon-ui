use std::cell::Cell;

use oxc_allocator::{Allocator, Box as OxcBox, Vec as OxcVec};
use oxc_ast::{ast::*, AstBuilder, NONE};
use oxc_codegen::{Codegen, CodegenReturn};
use oxc_span::{SourceType, SPAN};
use oxc_str::Str as OxcStr;
use oxc_syntax::{
    node::NodeId,
    number::{BigintBase, NumberBase},
    operator::{
        AssignmentOperator, BinaryOperator, LogicalOperator, UnaryOperator, UpdateOperator,
    },
};
use rustler::{Encoder, Env, NifResult, Term};

use crate::atoms;
use crate::error::error_to_term;

mod a {
    rustler::atoms! {
        r#type = "type",
        block, body, expression, argument, arguments, left, right, operator,
        test, consequent, alternate, init, update, object, callee,
        optional, computed, name, value, raw, cooked, tail,
        declarations, kind, id, params, rest, generator,
        async_field = "async", await_field = "await",
        source, specifiers, imported, exported, local, declaration,
        properties, elements, key, shorthand, method, quasis, expressions,
        tag, quasi, prefix, delegate, label, cases, handler, param,
        finalizer, discriminant, super_class = "superClass",
        meta, property, regex, pattern, flags, bigint,
        static_field = "static",

        // node types
        program, expression_statement, block_statement, return_statement,
        variable_declaration, function_declaration, class_declaration,
        if_statement, for_statement, for_in_statement, for_of_statement,
        while_statement, do_while_statement, switch_statement, try_statement,
        throw_statement, break_statement, continue_statement,
        labeled_statement, empty_statement, debugger_statement, with_statement,
        import_declaration, export_named_declaration,
        export_default_declaration, export_all_declaration,

        identifier, identifier_reference, literal,
        numeric_literal, string_literal, boolean_literal, null_literal,
        big_int_literal, reg_exp_literal,
        binary_expression, logical_expression, unary_expression,
        update_expression, assignment_expression, conditional_expression,
        call_expression, new_expression,
        member_expression, static_member_expression, computed_member_expression,
        chain_expression, object_expression, array_expression,
        arrow_function_expression, function_expression, class_expression,
        template_literal, tagged_template_expression,
        sequence_expression, this_expression,
        super_expr = "super",
        await_expression, yield_expression, import_expression,
        meta_property, parenthesized_expression,
        spread_element, rest_element,
        object_pattern, array_pattern, assignment_pattern,
        import_specifier, import_default_specifier, import_namespace_specifier,
        export_specifier,
        method_definition, property_definition, static_block,
    }
}

type R<T> = Result<T, String>;

fn err<T>(msg: impl Into<String>) -> R<T> {
    Err(msg.into())
}

include!("generated_term_helpers.rs");
include!("generated_ast_decoders.rs");

fn nid() -> Cell<NodeId> {
    Cell::new(NodeId::DUMMY)
}

fn oxc_s<'a>(b: AstBuilder<'a>, s: &str) -> OxcStr<'a> {
    b.str(s)
}

fn ident_name<'a>(b: AstBuilder<'a>, s: &str) -> IdentifierName<'a> {
    b.identifier_name(SPAN, b.ident(s))
}

fn str_lit<'a>(b: AstBuilder<'a>, s: &str) -> StringLiteral<'a> {
    b.string_literal(SPAN, b.str(s), None)
}

fn opt_binding_id<'a>(b: AstBuilder<'a>, term: Term) -> Option<BindingIdentifier<'a>> {
    opt(term, a::id()).map(|t| {
        let n = str_val(t, a::name());
        b.binding_identifier(SPAN, b.ident(&n))
    })
}

fn static_member<'a>(
    b: AstBuilder<'a>,
    object: Expression<'a>,
    prop: &str,
    optional: bool,
) -> Expression<'a> {
    Expression::StaticMemberExpression(b.alloc(b.static_member_expression(
        SPAN,
        object,
        ident_name(b, prop),
        optional,
    )))
}

fn computed_member<'a>(
    b: AstBuilder<'a>,
    object: Expression<'a>,
    prop: Expression<'a>,
    optional: bool,
) -> Expression<'a> {
    Expression::ComputedMemberExpression(
        b.alloc(b.computed_member_expression(SPAN, object, prop, optional)),
    )
}

// ── NIF entry point ──

#[rustler::nif(schedule = "DirtyCpu")]
pub fn codegen<'a>(env: Env<'a>, ast: Term<'a>) -> NifResult<Term<'a>> {
    let allocator = Allocator::default();
    let b = AstBuilder::new(&allocator);

    let input = decode_program_input(ast)?;

    match build_program(b, input.body) {
        Ok(program) => {
            let CodegenReturn { code, .. } = Codegen::new().build(&program);
            Ok((atoms::ok(), code).encode(env))
        }
        Err(msg) => error_to_term(env, &[msg]),
    }
}

// ── Program ──

fn build_program<'a>(b: AstBuilder<'a>, body_terms: Vec<Term>) -> R<Program<'a>> {
    let body = build_stmts(b, body_terms)?;
    Ok(b.program(SPAN, SourceType::mjs(), "", b.vec(), None, b.vec(), body))
}

// ── Statements ──

fn build_stmt<'a>(b: AstBuilder<'a>, term: Term) -> R<Statement<'a>> {
    let ty = type_atom(term).ok_or_else(|| "Missing :type on statement".to_string())?;

    if ty == a::expression_statement() {
        return Ok(b.statement_expression(
            SPAN,
            build_expr(b, get(term, a::expression()).ok_or("Missing :expression")?)?,
        ));
    }
    if ty == a::block_statement() {
        return Ok(b.statement_block(SPAN, build_stmts(b, list_val(term, a::body()))?));
    }
    if ty == a::return_statement() {
        return Ok(b.statement_return(SPAN, opt_expr(b, term, a::argument())?));
    }
    if ty == a::throw_statement() {
        return Ok(b.statement_throw(
            SPAN,
            build_expr(b, get(term, a::argument()).ok_or("Missing :argument")?)?,
        ));
    }
    if ty == a::empty_statement() {
        return Ok(b.statement_empty(SPAN));
    }
    if ty == a::debugger_statement() {
        return Ok(b.statement_debugger(SPAN));
    }

    if ty == a::variable_declaration() {
        return Ok(Statement::from(build_var_decl(b, term)?));
    }
    if ty == a::function_declaration() {
        return Ok(Statement::from(build_fn_decl(b, term)?));
    }
    if ty == a::class_declaration() {
        return Ok(Statement::from(build_class_decl(b, term)?));
    }

    if ty == a::if_statement() {
        let input = decode_if_statement_input(term)?;
        let test = build_expr(b, input.test)?;
        let cons = build_stmt(b, input.consequent)?;
        let alt = match input.alternate {
            Some(t) if !is_nil(t) => Some(build_stmt(b, t)?),
            _ => None,
        };
        return Ok(b.statement_if(SPAN, test, cons, alt));
    }
    if ty == a::for_statement() {
        let init = match opt(term, a::init()) {
            Some(t) if type_eq(t, a::variable_declaration()) => Some(
                ForStatementInit::VariableDeclaration(build_var_decl_boxed(b, t)?),
            ),
            Some(t) => Some(ForStatementInit::from(build_expr(b, t)?)),
            None => None,
        };
        let test = opt_expr(b, term, a::test())?;
        let update = opt_expr(b, term, a::update())?;
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_for(SPAN, init, test, update, body));
    }
    if ty == a::for_in_statement() {
        let left = build_for_left(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let right = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_for_in(SPAN, left, right, body));
    }
    if ty == a::for_of_statement() {
        let aw = bool_val(term, a::await_field());
        let left = build_for_left(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let right = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_for_of(SPAN, aw, left, right, body));
    }
    if ty == a::while_statement() {
        let test = build_expr(b, get(term, a::test()).ok_or("Missing :test")?)?;
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_while(SPAN, test, body));
    }
    if ty == a::do_while_statement() {
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        let test = build_expr(b, get(term, a::test()).ok_or("Missing :test")?)?;
        return Ok(b.statement_do_while(SPAN, body, test));
    }
    if ty == a::switch_statement() {
        let disc = build_expr(
            b,
            get(term, a::discriminant()).ok_or("Missing :discriminant")?,
        )?;
        let cases_list = list_val(term, a::cases());
        let mut cases = b.vec_with_capacity(cases_list.len());
        for c in &cases_list {
            let test = opt_expr(b, *c, a::test())?;
            let cons = build_stmts(b, list_val(*c, a::consequent()))?;
            cases.push(b.switch_case(SPAN, test, cons));
        }
        return Ok(b.statement_switch(SPAN, disc, cases));
    }
    if ty == a::try_statement() {
        let block_term = opt(term, a::block())
            .or_else(|| opt(term, a::body()))
            .ok_or("Missing try body")?;
        let block = build_block(b, block_term)?;
        let handler = match opt(term, a::handler()) {
            Some(h) => {
                let param = match opt(h, a::param()) {
                    Some(p) => Some(CatchParameter {
                        node_id: nid(),
                        span: SPAN,
                        pattern: build_binding_pat(b, p)?,
                        type_annotation: None,
                    }),
                    None => None,
                };
                let hbody = build_block(b, get(h, a::body()).ok_or("Missing catch body")?)?;
                Some(b.catch_clause(SPAN, param, hbody))
            }
            None => None,
        };
        let finalizer = match opt(term, a::finalizer()) {
            Some(f) => Some(build_block(b, f)?),
            None => None,
        };
        return Ok(b.statement_try(SPAN, block, handler, finalizer));
    }
    if ty == a::break_statement() {
        return Ok(b.statement_break(SPAN, opt_label(b, term)));
    }
    if ty == a::continue_statement() {
        return Ok(b.statement_continue(SPAN, opt_label(b, term)));
    }
    if ty == a::labeled_statement() {
        let lt = get(term, a::label()).ok_or("Missing :label")?;
        let label = LabelIdentifier {
            node_id: nid(),
            span: SPAN,
            name: b.ident(&str_val(lt, a::name())),
        };
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_labeled(SPAN, label, body));
    }
    if ty == a::with_statement() {
        let obj = build_expr(b, get(term, a::object()).ok_or("Missing :object")?)?;
        let body = build_stmt(b, get(term, a::body()).ok_or("Missing :body")?)?;
        return Ok(b.statement_with(SPAN, obj, body));
    }
    if ty == a::import_declaration() {
        return Ok(Statement::from(build_import(b, term)?));
    }
    if ty == a::export_named_declaration() {
        return Ok(Statement::from(build_export_named(b, term)?));
    }
    if ty == a::export_default_declaration() {
        return Ok(Statement::from(build_export_default(b, term)?));
    }
    if ty == a::export_all_declaration() {
        return Ok(Statement::from(build_export_all(b, term)?));
    }

    err(format!("Unsupported statement: {}", type_str(term)))
}

fn build_stmts<'a>(b: AstBuilder<'a>, list: Vec<Term>) -> R<OxcVec<'a, Statement<'a>>> {
    let mut out = b.vec_with_capacity(list.len());
    for t in &list {
        out.push(build_stmt(b, *t)?);
    }
    Ok(out)
}

fn build_block<'a>(b: AstBuilder<'a>, term: Term) -> R<BlockStatement<'a>> {
    Ok(BlockStatement {
        node_id: nid(),
        span: SPAN,
        body: build_stmts(b, list_val(term, a::body()))?,
        scope_id: Default::default(),
    })
}

// ── Expressions ──

fn build_expr<'a>(b: AstBuilder<'a>, term: Term) -> R<Expression<'a>> {
    let ty = type_atom(term).ok_or_else(|| "Missing :type on expression".to_string())?;

    if ty == a::identifier() || ty == a::identifier_reference() {
        let n = str_val(term, a::name());
        return Ok(b.expression_identifier(SPAN, b.ident(&n)));
    }
    if ty == a::literal() {
        return build_generic_lit(b, term);
    }
    if ty == a::numeric_literal() {
        return Ok(b.expression_numeric_literal(
            SPAN,
            f64_val(term, a::value()),
            None,
            NumberBase::Decimal,
        ));
    }
    if ty == a::string_literal() {
        let s = str_val(term, a::value());
        return Ok(b.expression_string_literal(SPAN, oxc_s(b, &s), None));
    }
    if ty == a::boolean_literal() {
        return Ok(b.expression_boolean_literal(SPAN, bool_val(term, a::value())));
    }
    if ty == a::null_literal() {
        return Ok(b.expression_null_literal(SPAN));
    }
    if ty == a::big_int_literal() {
        let v = str_val(term, a::value());
        return Ok(b.expression_big_int_literal(SPAN, oxc_s(b, &v), None, BigintBase::Decimal));
    }
    if ty == a::reg_exp_literal() {
        return build_regexp(b, term);
    }

    if ty == a::binary_expression() {
        let l = build_expr(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let op = parse_bin_op(&str_val(term, a::operator()))?;
        let r = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        return Ok(b.expression_binary(SPAN, l, op, r));
    }
    if ty == a::logical_expression() {
        let l = build_expr(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let op = parse_log_op(&str_val(term, a::operator()))?;
        let r = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        return Ok(b.expression_logical(SPAN, l, op, r));
    }
    if ty == a::unary_expression() {
        let op = parse_unary_op(&str_val(term, a::operator()))?;
        return Ok(b.expression_unary(
            SPAN,
            op,
            build_expr(b, get(term, a::argument()).ok_or("Missing :argument")?)?,
        ));
    }
    if ty == a::update_expression() {
        let op = parse_update_op(&str_val(term, a::operator()))?;
        let prefix = bool_val(term, a::prefix());
        let arg = build_simple_target(b, get(term, a::argument()).ok_or("Missing :argument")?)?;
        return Ok(b.expression_update(SPAN, op, prefix, arg));
    }
    if ty == a::assignment_expression() {
        let op = parse_assign_op(&str_val(term, a::operator()))?;
        let l = build_assign_target(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let r = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        return Ok(b.expression_assignment(SPAN, op, l, r));
    }
    if ty == a::conditional_expression() {
        let test = build_expr(b, get(term, a::test()).ok_or("Missing :test")?)?;
        let cons = build_expr(b, get(term, a::consequent()).ok_or("Missing :consequent")?)?;
        let alt = build_expr(b, get(term, a::alternate()).ok_or("Missing :alternate")?)?;
        return Ok(b.expression_conditional(SPAN, test, cons, alt));
    }
    if ty == a::call_expression() {
        let callee = build_expr(b, get(term, a::callee()).ok_or("Missing :callee")?)?;
        let args = build_args(b, list_val(term, a::arguments()))?;
        return Ok(b.expression_call(SPAN, callee, NONE, args, bool_val(term, a::optional())));
    }
    if ty == a::new_expression() {
        let callee = build_expr(b, get(term, a::callee()).ok_or("Missing :callee")?)?;
        let args = build_args(b, list_val(term, a::arguments()))?;
        return Ok(b.expression_new(SPAN, callee, NONE, args));
    }
    if ty == a::member_expression() || ty == a::static_member_expression() {
        return build_member(b, term);
    }
    if ty == a::computed_member_expression() {
        let obj = build_expr(b, get(term, a::object()).ok_or("Missing :object")?)?;
        let prop = build_expr(
            b,
            get(term, a::expression())
                .or_else(|| get(term, a::property()))
                .ok_or("Missing prop")?,
        )?;
        return Ok(computed_member(b, obj, prop, bool_val(term, a::optional())));
    }
    if ty == a::chain_expression() {
        let inner = get(term, a::expression()).ok_or("Missing chain :expression")?;
        return build_chain(b, inner);
    }
    if ty == a::object_expression() {
        return Ok(b.expression_object(SPAN, build_obj_props(b, list_val(term, a::properties()))?));
    }
    if ty == a::array_expression() {
        let elems_list = list_val(term, a::elements());
        let mut elems = b.vec_with_capacity(elems_list.len());
        for e in &elems_list {
            if is_nil(*e) {
                elems.push(ArrayExpressionElement::Elision(b.alloc(Elision {
                    node_id: nid(),
                    span: SPAN,
                })));
            } else if type_eq(*e, a::spread_element()) {
                let arg = build_expr(b, get(*e, a::argument()).ok_or("Missing spread :argument")?)?;
                elems.push(ArrayExpressionElement::SpreadElement(
                    b.alloc(b.spread_element(SPAN, arg)),
                ));
            } else {
                elems.push(ArrayExpressionElement::from(build_expr(b, *e)?));
            }
        }
        return Ok(b.expression_array(SPAN, elems));
    }
    if ty == a::arrow_function_expression() {
        let is_async = bool_val(term, a::async_field());
        let is_expr = bool_val(term, a::expression());
        let params = build_params(b, term)?;
        let body_term = get(term, a::body()).ok_or("Missing arrow body")?;
        let body = if is_expr && !type_eq(body_term, a::block_statement()) {
            let expr = build_expr(b, body_term)?;
            b.function_body(SPAN, b.vec(), b.vec1(b.statement_expression(SPAN, expr)))
        } else {
            build_fn_body(b, body_term)?
        };
        return Ok(b.expression_arrow_function(SPAN, is_expr, is_async, NONE, params, NONE, body));
    }
    if ty == a::function_expression() {
        let id = opt_binding_id(b, term);
        let params = build_params(b, term)?;
        let body = build_fn_body(b, get(term, a::body()).ok_or("Missing fn body")?)?;
        return Ok(b.expression_function(
            SPAN,
            FunctionType::FunctionExpression,
            id,
            bool_val(term, a::generator()),
            bool_val(term, a::async_field()),
            false,
            NONE,
            NONE,
            params,
            NONE,
            Some(b.alloc(body)),
        ));
    }
    if ty == a::class_expression() {
        let id = opt_binding_id(b, term);
        let sc = opt_expr(b, term, a::super_class())?;
        let body = build_class_body(b, get(term, a::body()).ok_or("Missing class body")?)?;
        return Ok(b.expression_class(
            SPAN,
            ClassType::ClassExpression,
            b.vec(),
            id,
            NONE,
            sc,
            NONE,
            b.vec(),
            body,
            false,
            false,
        ));
    }
    if ty == a::template_literal() {
        return build_template(b, term);
    }
    if ty == a::tagged_template_expression() {
        let tag = build_expr(b, get(term, a::tag()).ok_or("Missing :tag")?)?;
        let qt = get(term, a::quasi()).ok_or("Missing :quasi")?;
        let quasis = build_quasis(b, list_val(qt, a::quasis()))?;
        let exprs = build_exprs(b, list_val(qt, a::expressions()))?;
        return Ok(b.expression_tagged_template(
            SPAN,
            tag,
            NONE,
            b.template_literal(SPAN, quasis, exprs),
        ));
    }
    if ty == a::sequence_expression() {
        return Ok(b.expression_sequence(SPAN, build_exprs(b, list_val(term, a::expressions()))?));
    }
    if ty == a::this_expression() {
        return Ok(b.expression_this(SPAN));
    }
    if ty == a::super_expr() {
        return Ok(Expression::Super(b.alloc(Super {
            node_id: nid(),
            span: SPAN,
        })));
    }
    if ty == a::await_expression() {
        return Ok(b.expression_await(
            SPAN,
            build_expr(b, get(term, a::argument()).ok_or("Missing :argument")?)?,
        ));
    }
    if ty == a::yield_expression() {
        return Ok(b.expression_yield(
            SPAN,
            bool_val(term, a::delegate()),
            opt_expr(b, term, a::argument())?,
        ));
    }
    if ty == a::import_expression() {
        return Ok(b.expression_import(
            SPAN,
            build_expr(b, get(term, a::source()).ok_or("Missing :source")?)?,
            None,
            None,
        ));
    }
    if ty == a::meta_property() {
        let m = ident_name(b, &str_val(get(term, a::meta()).unwrap_or(term), a::name()));
        let p = ident_name(
            b,
            &str_val(get(term, a::property()).unwrap_or(term), a::name()),
        );
        return Ok(b.expression_meta_property(SPAN, m, p));
    }
    if ty == a::parenthesized_expression() {
        return Ok(b.expression_parenthesized(
            SPAN,
            build_expr(b, get(term, a::expression()).ok_or("Missing :expression")?)?,
        ));
    }

    err(format!("Unsupported expression: {}", type_str(term)))
}

fn opt_expr<'a>(b: AstBuilder<'a>, term: Term, key: rustler::Atom) -> R<Option<Expression<'a>>> {
    match opt(term, key) {
        Some(t) => Ok(Some(build_expr(b, t)?)),
        None => Ok(None),
    }
}

fn build_exprs<'a>(b: AstBuilder<'a>, list: Vec<Term>) -> R<OxcVec<'a, Expression<'a>>> {
    let mut out = b.vec_with_capacity(list.len());
    for t in &list {
        out.push(build_expr(b, *t)?);
    }
    Ok(out)
}

// ── Literals ──

fn build_generic_lit<'a>(b: AstBuilder<'a>, term: Term) -> R<Expression<'a>> {
    if let Some(rx) = opt(term, a::regex()) {
        return build_regexp_from(b, rx);
    }
    if opt(term, a::bigint()).is_some() {
        let v = str_val(term, a::bigint());
        return Ok(b.expression_big_int_literal(SPAN, oxc_s(b, &v), None, BigintBase::Decimal));
    }
    match get(term, a::value()) {
        None => Ok(b.expression_null_literal(SPAN)),
        Some(t) if is_nil(t) => Ok(b.expression_null_literal(SPAN)),
        Some(t) => {
            if let Ok(v) = t.decode::<bool>() {
                return Ok(b.expression_boolean_literal(SPAN, v));
            }
            if let Ok(v) = t.decode::<f64>() {
                return Ok(b.expression_numeric_literal(SPAN, v, None, NumberBase::Decimal));
            }
            if let Ok(v) = t.decode::<i64>() {
                return Ok(b.expression_numeric_literal(SPAN, v as f64, None, NumberBase::Decimal));
            }
            if let Ok(v) = t.decode::<String>() {
                return Ok(b.expression_string_literal(SPAN, oxc_s(b, &v), None));
            }
            Ok(b.expression_null_literal(SPAN))
        }
    }
}

fn build_regexp<'a>(b: AstBuilder<'a>, term: Term) -> R<Expression<'a>> {
    build_regexp_from(b, get(term, a::regex()).unwrap_or(term))
}

fn build_regexp_from<'a>(b: AstBuilder<'a>, rx: Term) -> R<Expression<'a>> {
    let pat = str_val(rx, a::pattern());
    let fl = str_val(rx, a::flags());
    Ok(Expression::RegExpLiteral(b.alloc(RegExpLiteral {
        node_id: nid(),
        span: SPAN,
        raw: None,
        regex: RegExp {
            pattern: RegExpPattern {
                text: oxc_s(b, &pat),
                pattern: None,
            },
            flags: parse_regex_flags(&fl),
        },
    })))
}

// ── Member / Chain ──

fn build_member<'a>(b: AstBuilder<'a>, term: Term) -> R<Expression<'a>> {
    let obj = build_expr(b, get(term, a::object()).ok_or("Missing :object")?)?;
    let optional = bool_val(term, a::optional());
    if bool_val(term, a::computed()) {
        let prop = build_expr(b, get(term, a::property()).ok_or("Missing :property")?)?;
        Ok(computed_member(b, obj, prop, optional))
    } else {
        let pn = str_val(
            get(term, a::property()).ok_or("Missing :property")?,
            a::name(),
        );
        Ok(static_member(b, obj, &pn, optional))
    }
}

fn build_chain<'a>(b: AstBuilder<'a>, inner: Term) -> R<Expression<'a>> {
    let inner_ty = type_atom(inner).ok_or("Missing chain inner type")?;
    let elem = if inner_ty == a::call_expression() {
        let callee = build_expr(b, get(inner, a::callee()).ok_or("Missing :callee")?)?;
        let args = build_args(b, list_val(inner, a::arguments()))?;
        ChainElement::CallExpression(b.alloc(CallExpression {
            node_id: nid(),
            span: SPAN,
            callee,
            type_arguments: None,
            arguments: args,
            optional: bool_val(inner, a::optional()),
            pure: false,
        }))
    } else {
        let obj = build_expr(b, get(inner, a::object()).ok_or("Missing :object")?)?;
        let optional = bool_val(inner, a::optional());
        if bool_val(inner, a::computed()) {
            let prop = build_expr(b, get(inner, a::property()).ok_or("Missing :property")?)?;
            ChainElement::ComputedMemberExpression(
                b.alloc(b.computed_member_expression(SPAN, obj, prop, optional)),
            )
        } else {
            let pn = str_val(
                get(inner, a::property()).ok_or("Missing :property")?,
                a::name(),
            );
            ChainElement::StaticMemberExpression(b.alloc(b.static_member_expression(
                SPAN,
                obj,
                ident_name(b, &pn),
                optional,
            )))
        }
    };
    Ok(b.expression_chain(SPAN, elem))
}

// ── Template literals ──

fn build_template<'a>(b: AstBuilder<'a>, term: Term) -> R<Expression<'a>> {
    let quasis = build_quasis(b, list_val(term, a::quasis()))?;
    let exprs = build_exprs(b, list_val(term, a::expressions()))?;
    Ok(b.expression_template_literal(SPAN, quasis, exprs))
}

fn build_quasis<'a>(b: AstBuilder<'a>, list: Vec<Term>) -> R<OxcVec<'a, TemplateElement<'a>>> {
    let mut out = b.vec_with_capacity(list.len());
    for q in &list {
        let vt = get(*q, a::value()).unwrap_or(*q);
        let raw = str_val(vt, a::raw());
        let cooked = opt(vt, a::cooked()).and_then(|t| t.decode::<String>().ok());
        let tail = bool_val(*q, a::tail());
        out.push(b.template_element(
            SPAN,
            TemplateElementValue {
                raw: oxc_s(b, &raw),
                cooked: cooked.as_deref().map(|s| oxc_s(b, s)),
            },
            tail,
            false,
        ));
    }
    Ok(out)
}

// ── Declarations ──

fn build_var_decl<'a>(b: AstBuilder<'a>, term: Term) -> R<Declaration<'a>> {
    let kind = match str_val(term, a::kind()).as_str() {
        "let" => VariableDeclarationKind::Let,
        "var" => VariableDeclarationKind::Var,
        "using" => VariableDeclarationKind::Using,
        "await_using" | "await using" => VariableDeclarationKind::AwaitUsing,
        _ => VariableDeclarationKind::Const,
    };
    let dl = list_val(term, a::declarations());
    let mut decls = b.vec_with_capacity(dl.len());
    for d in &dl {
        let id = build_binding_pat(b, get(*d, a::id()).ok_or("Missing declarator :id")?)?;
        let init = opt_expr(b, *d, a::init())?;
        decls.push(b.variable_declarator(SPAN, kind, id, NONE, init, false));
    }
    Ok(b.declaration_variable(SPAN, kind, decls, false))
}

fn build_var_decl_boxed<'a>(
    b: AstBuilder<'a>,
    term: Term,
) -> R<OxcBox<'a, VariableDeclaration<'a>>> {
    let kind = match str_val(term, a::kind()).as_str() {
        "let" => VariableDeclarationKind::Let,
        "var" => VariableDeclarationKind::Var,
        "using" => VariableDeclarationKind::Using,
        "await_using" | "await using" => VariableDeclarationKind::AwaitUsing,
        _ => VariableDeclarationKind::Const,
    };
    let dl = list_val(term, a::declarations());
    let mut decls = b.vec_with_capacity(dl.len());
    for d in &dl {
        let id = build_binding_pat(b, get(*d, a::id()).ok_or("Missing declarator :id")?)?;
        let init = opt_expr(b, *d, a::init())?;
        decls.push(b.variable_declarator(SPAN, kind, id, NONE, init, false));
    }
    Ok(b.alloc(b.variable_declaration(SPAN, kind, decls, false)))
}

fn build_fn_decl<'a>(b: AstBuilder<'a>, term: Term) -> R<Declaration<'a>> {
    let id = opt_binding_id(b, term);
    let params = build_params(b, term)?;
    let body = build_fn_body(b, get(term, a::body()).ok_or("Missing fn body")?)?;
    Ok(b.declaration_function(
        SPAN,
        FunctionType::FunctionDeclaration,
        id,
        bool_val(term, a::generator()),
        bool_val(term, a::async_field()),
        false,
        NONE,
        NONE,
        params,
        NONE,
        Some(b.alloc(body)),
    ))
}

fn build_class_decl<'a>(b: AstBuilder<'a>, term: Term) -> R<Declaration<'a>> {
    let id = opt_binding_id(b, term);
    let sc = opt_expr(b, term, a::super_class())?;
    let body = build_class_body(b, get(term, a::body()).ok_or("Missing class body")?)?;
    Ok(b.declaration_class(
        SPAN,
        ClassType::ClassDeclaration,
        b.vec(),
        id,
        NONE,
        sc,
        NONE,
        b.vec(),
        body,
        false,
        false,
    ))
}

// ── Class body ──

fn build_class_body<'a>(b: AstBuilder<'a>, term: Term) -> R<ClassBody<'a>> {
    let bl = list_val(term, a::body());
    let mut elems = b.vec_with_capacity(bl.len());
    for e in &bl {
        let ty = type_atom(*e).ok_or("Missing class element type")?;
        if ty == a::method_definition() {
            let kind_s = str_val(*e, a::kind());
            let kind = match kind_s.as_str() {
                "constructor" => MethodDefinitionKind::Constructor,
                "get" => MethodDefinitionKind::Get,
                "set" => MethodDefinitionKind::Set,
                _ => MethodDefinitionKind::Method,
            };
            let key = build_prop_key(b, get(*e, a::key()).ok_or("Missing method key")?)?;
            let is_static = bool_val(*e, a::static_field());
            let is_computed = bool_val(*e, a::computed());
            let vt = get(*e, a::value()).ok_or("Missing method value")?;
            let params = build_params(b, vt)?;
            let body = build_fn_body(b, get(vt, a::body()).ok_or("Missing method body")?)?;
            let func = Function {
                node_id: nid(),
                span: SPAN,
                r#type: FunctionType::FunctionExpression,
                id: None,
                generator: bool_val(vt, a::generator()),
                r#async: bool_val(vt, a::async_field()),
                declare: false,
                type_parameters: None,
                this_param: None,
                params: b.alloc(params),
                return_type: None,
                body: Some(b.alloc(body)),
                scope_id: Default::default(),
                pure: false,
                pife: false,
            };
            elems.push(ClassElement::MethodDefinition(b.alloc(
                b.method_definition(
                    SPAN,
                    MethodDefinitionType::MethodDefinition,
                    b.vec(),
                    key,
                    func,
                    kind,
                    is_computed,
                    is_static,
                    false,
                    false,
                    None,
                ),
            )));
        } else if ty == a::property_definition() {
            let key = build_prop_key(b, get(*e, a::key()).ok_or("Missing property key")?)?;
            let val = opt_expr(b, *e, a::value())?;
            elems.push(ClassElement::PropertyDefinition(b.alloc(
                b.property_definition(
                    SPAN,
                    PropertyDefinitionType::PropertyDefinition,
                    b.vec(),
                    key,
                    NONE,
                    val,
                    bool_val(*e, a::computed()),
                    bool_val(*e, a::static_field()),
                    false,
                    false,
                    false,
                    false,
                    false,
                    None,
                ),
            )));
        } else if ty == a::static_block() {
            let body = build_stmts(b, list_val(*e, a::body()))?;
            elems.push(ClassElement::StaticBlock(b.alloc(StaticBlock {
                node_id: nid(),
                span: SPAN,
                body,
                scope_id: Default::default(),
            })));
        } else {
            return err(format!("Unsupported class element: {}", type_str(*e)));
        }
    }
    Ok(b.class_body(SPAN, elems))
}

// ── Module declarations ──

fn build_import<'a>(b: AstBuilder<'a>, term: Term) -> R<ModuleDeclaration<'a>> {
    let src = str_val(
        get(term, a::source()).ok_or("Missing import :source")?,
        a::value(),
    );
    let sl = str_lit(b, &src);
    let specs_list = list_val(term, a::specifiers());
    let specifiers = if specs_list.is_empty() {
        if get(term, a::specifiers()).is_none_or(|t| is_nil(t)) {
            None
        } else {
            Some(b.vec())
        }
    } else {
        let mut specs = b.vec_with_capacity(specs_list.len());
        for s in &specs_list {
            let ty = type_atom(*s).ok_or("Missing specifier type")?;
            if ty == a::import_specifier() {
                let imp_name = str_val(get(*s, a::imported()).unwrap_or(*s), a::name());
                let loc_name = str_val(get(*s, a::local()).unwrap_or(*s), a::name());
                let imported = ModuleExportName::IdentifierName(ident_name(b, &imp_name));
                let local = b.binding_identifier(SPAN, b.ident(&loc_name));
                specs.push(ImportDeclarationSpecifier::ImportSpecifier(b.alloc(
                    b.import_specifier(SPAN, imported, local, ImportOrExportKind::Value),
                )));
            } else if ty == a::import_default_specifier() {
                let loc_name = str_val(get(*s, a::local()).unwrap_or(*s), a::name());
                specs.push(ImportDeclarationSpecifier::ImportDefaultSpecifier(b.alloc(
                    b.import_default_specifier(
                        SPAN,
                        b.binding_identifier(SPAN, b.ident(&loc_name)),
                    ),
                )));
            } else if ty == a::import_namespace_specifier() {
                let loc_name = str_val(get(*s, a::local()).unwrap_or(*s), a::name());
                specs.push(ImportDeclarationSpecifier::ImportNamespaceSpecifier(
                    b.alloc(b.import_namespace_specifier(
                        SPAN,
                        b.binding_identifier(SPAN, b.ident(&loc_name)),
                    )),
                ));
            } else {
                return err(format!("Unsupported import specifier: {}", type_str(*s)));
            }
        }
        Some(specs)
    };
    Ok(ModuleDeclaration::ImportDeclaration(b.alloc(
        b.import_declaration(SPAN, specifiers, sl, None, NONE, ImportOrExportKind::Value),
    )))
}

fn build_export_named<'a>(b: AstBuilder<'a>, term: Term) -> R<ModuleDeclaration<'a>> {
    let declaration = match opt(term, a::declaration()) {
        Some(t) => {
            let ty = type_atom(t).ok_or("Missing export decl type")?;
            Some(if ty == a::variable_declaration() {
                build_var_decl(b, t)?
            } else if ty == a::function_declaration() {
                build_fn_decl(b, t)?
            } else if ty == a::class_declaration() {
                build_class_decl(b, t)?
            } else {
                return err(format!("Unsupported export declaration: {}", type_str(t)));
            })
        }
        None => None,
    };
    let sl = list_val(term, a::specifiers());
    let mut specifiers = b.vec_with_capacity(sl.len());
    for s in &sl {
        let loc = str_val(get(*s, a::local()).unwrap_or(*s), a::name());
        let exp = str_val(get(*s, a::exported()).unwrap_or(*s), a::name());
        specifiers.push(b.export_specifier(
            SPAN,
            ModuleExportName::IdentifierName(ident_name(b, &loc)),
            ModuleExportName::IdentifierName(ident_name(b, &exp)),
            ImportOrExportKind::Value,
        ));
    }
    let source = opt(term, a::source()).map(|t| str_lit(b, &str_val(t, a::value())));
    Ok(ModuleDeclaration::ExportNamedDeclaration(b.alloc(
        b.export_named_declaration(
            SPAN,
            declaration,
            specifiers,
            source,
            ImportOrExportKind::Value,
            NONE,
        ),
    )))
}

fn build_export_default<'a>(b: AstBuilder<'a>, term: Term) -> R<ModuleDeclaration<'a>> {
    let dt = get(term, a::declaration()).ok_or("Missing default export declaration")?;
    let ty = type_atom(dt).ok_or("Missing declaration type")?;
    let kind = if ty == a::function_declaration() {
        let id = opt_binding_id(b, dt);
        let params = build_params(b, dt)?;
        let body = build_fn_body(b, get(dt, a::body()).ok_or("Missing fn body")?)?;
        let func = Function {
            node_id: nid(),
            span: SPAN,
            r#type: FunctionType::FunctionDeclaration,
            id,
            generator: bool_val(dt, a::generator()),
            r#async: bool_val(dt, a::async_field()),
            declare: false,
            type_parameters: None,
            this_param: None,
            params: b.alloc(params),
            return_type: None,
            body: Some(b.alloc(body)),
            scope_id: Default::default(),
            pure: false,
            pife: false,
        };
        ExportDefaultDeclarationKind::FunctionDeclaration(b.alloc(func))
    } else if ty == a::class_declaration() {
        let id = opt_binding_id(b, dt);
        let sc = opt_expr(b, dt, a::super_class())?;
        let body = build_class_body(b, get(dt, a::body()).ok_or("Missing class body")?)?;
        let class = Class {
            node_id: nid(),
            span: SPAN,
            r#type: ClassType::ClassDeclaration,
            decorators: b.vec(),
            id,
            type_parameters: None,
            super_class: sc,
            super_type_arguments: None,
            implements: b.vec(),
            body: b.alloc(body),
            r#abstract: false,
            declare: false,
            scope_id: Default::default(),
        };
        ExportDefaultDeclarationKind::ClassDeclaration(b.alloc(class))
    } else {
        ExportDefaultDeclarationKind::from(build_expr(b, dt)?)
    };
    Ok(ModuleDeclaration::ExportDefaultDeclaration(
        b.alloc(b.export_default_declaration(SPAN, kind)),
    ))
}

fn build_export_all<'a>(b: AstBuilder<'a>, term: Term) -> R<ModuleDeclaration<'a>> {
    let src = str_val(
        get(term, a::source()).ok_or("Missing export :source")?,
        a::value(),
    );
    let exported = opt(term, a::exported())
        .map(|t| ModuleExportName::IdentifierName(ident_name(b, &str_val(t, a::name()))));
    Ok(ModuleDeclaration::ExportAllDeclaration(b.alloc(
        b.export_all_declaration(
            SPAN,
            exported,
            str_lit(b, &src),
            NONE,
            ImportOrExportKind::Value,
        ),
    )))
}

// ── Patterns ──

fn build_binding_pat<'a>(b: AstBuilder<'a>, term: Term) -> R<BindingPattern<'a>> {
    let ty = type_atom(term).ok_or("Missing pattern type")?;
    if ty == a::identifier() {
        let n = str_val(term, a::name());
        return Ok(b.binding_pattern_binding_identifier(SPAN, b.ident(&n)));
    }
    if ty == a::object_pattern() {
        let pl = list_val(term, a::properties());
        let mut props = b.vec_with_capacity(pl.len());
        let mut rest = None;
        for p in &pl {
            if type_eq(*p, a::rest_element()) {
                let arg =
                    build_binding_pat(b, get(*p, a::argument()).ok_or("Missing rest :argument")?)?;
                rest = Some(b.alloc(BindingRestElement {
                    node_id: nid(),
                    span: SPAN,
                    argument: arg,
                }));
            } else {
                let key = build_prop_key(b, get(*p, a::key()).ok_or("Missing property :key")?)?;
                let val =
                    build_binding_pat(b, get(*p, a::value()).ok_or("Missing property :value")?)?;
                props.push(BindingProperty {
                    node_id: nid(),
                    span: SPAN,
                    key,
                    value: val,
                    shorthand: bool_val(*p, a::shorthand()),
                    computed: bool_val(*p, a::computed()),
                });
            }
        }
        return Ok(b.binding_pattern_object_pattern(SPAN, props, rest));
    }
    if ty == a::array_pattern() {
        let el = list_val(term, a::elements());
        let mut elems = b.vec_with_capacity(el.len());
        let mut rest = None;
        for e in &el {
            if is_nil(*e) {
                elems.push(None);
            } else if type_eq(*e, a::rest_element()) {
                let arg =
                    build_binding_pat(b, get(*e, a::argument()).ok_or("Missing rest :argument")?)?;
                rest = Some(b.alloc(BindingRestElement {
                    node_id: nid(),
                    span: SPAN,
                    argument: arg,
                }));
            } else {
                elems.push(Some(build_binding_pat(b, *e)?));
            }
        }
        return Ok(b.binding_pattern_array_pattern(SPAN, elems, rest));
    }
    if ty == a::assignment_pattern() {
        let left = build_binding_pat(b, get(term, a::left()).ok_or("Missing :left")?)?;
        let right = build_expr(b, get(term, a::right()).ok_or("Missing :right")?)?;
        return Ok(b.binding_pattern_assignment_pattern(SPAN, left, right));
    }
    err(format!("Unsupported binding pattern: {}", type_str(term)))
}

fn build_assign_target<'a>(b: AstBuilder<'a>, term: Term) -> R<AssignmentTarget<'a>> {
    let ty = type_atom(term).ok_or("Missing target type")?;
    if ty == a::identifier() || ty == a::identifier_reference() {
        let n = str_val(term, a::name());
        return Ok(AssignmentTarget::AssignmentTargetIdentifier(b.alloc(
            IdentifierReference {
                node_id: nid(),
                span: SPAN,
                name: b.ident(&n),
                reference_id: Default::default(),
            },
        )));
    }
    if ty == a::member_expression()
        || ty == a::static_member_expression()
        || ty == a::computed_member_expression()
    {
        let obj = build_expr(b, get(term, a::object()).ok_or("Missing :object")?)?;
        let optional = bool_val(term, a::optional());
        if bool_val(term, a::computed()) || ty == a::computed_member_expression() {
            let prop = build_expr(
                b,
                get(term, a::property())
                    .or_else(|| get(term, a::expression()))
                    .ok_or("Missing prop")?,
            )?;
            return Ok(AssignmentTarget::ComputedMemberExpression(
                b.alloc(b.computed_member_expression(SPAN, obj, prop, optional)),
            ));
        }
        let pn = str_val(
            get(term, a::property()).ok_or("Missing :property")?,
            a::name(),
        );
        return Ok(AssignmentTarget::StaticMemberExpression(b.alloc(
            b.static_member_expression(SPAN, obj, ident_name(b, &pn), optional),
        )));
    }
    err(format!("Unsupported assignment target: {}", type_str(term)))
}

fn build_simple_target<'a>(b: AstBuilder<'a>, term: Term) -> R<SimpleAssignmentTarget<'a>> {
    let ty = type_atom(term).ok_or("Missing target type")?;
    if ty == a::identifier() || ty == a::identifier_reference() {
        let n = str_val(term, a::name());
        return Ok(SimpleAssignmentTarget::AssignmentTargetIdentifier(b.alloc(
            IdentifierReference {
                node_id: nid(),
                span: SPAN,
                name: b.ident(&n),
                reference_id: Default::default(),
            },
        )));
    }
    if ty == a::member_expression()
        || ty == a::static_member_expression()
        || ty == a::computed_member_expression()
    {
        let obj = build_expr(b, get(term, a::object()).ok_or("Missing :object")?)?;
        let optional = bool_val(term, a::optional());
        if bool_val(term, a::computed()) || ty == a::computed_member_expression() {
            let prop = build_expr(
                b,
                get(term, a::property())
                    .or_else(|| get(term, a::expression()))
                    .ok_or("Missing prop")?,
            )?;
            return Ok(SimpleAssignmentTarget::ComputedMemberExpression(
                b.alloc(b.computed_member_expression(SPAN, obj, prop, optional)),
            ));
        }
        let pn = str_val(
            get(term, a::property()).ok_or("Missing :property")?,
            a::name(),
        );
        return Ok(SimpleAssignmentTarget::StaticMemberExpression(b.alloc(
            b.static_member_expression(SPAN, obj, ident_name(b, &pn), optional),
        )));
    }
    err(format!("Unsupported simple target: {}", type_str(term)))
}

// ── Helpers ──

fn build_params<'a>(b: AstBuilder<'a>, term: Term) -> R<FormalParameters<'a>> {
    let pl = list_val(term, a::params());
    let mut items = b.vec_with_capacity(pl.len());
    let mut rest = None;
    for p in &pl {
        if type_eq(*p, a::rest_element()) {
            let arg =
                build_binding_pat(b, get(*p, a::argument()).ok_or("Missing rest :argument")?)?;
            let rest_elem = BindingRestElement {
                node_id: nid(),
                span: SPAN,
                argument: arg,
            };
            rest = Some(b.alloc(FormalParameterRest {
                node_id: nid(),
                span: SPAN,
                decorators: b.vec(),
                rest: rest_elem,
                type_annotation: None,
            }));
        } else {
            let pat = build_binding_pat(b, *p)?;
            items.push(FormalParameter {
                node_id: nid(),
                span: SPAN,
                decorators: b.vec(),
                pattern: pat,
                type_annotation: None,
                initializer: None,
                optional: false,
                accessibility: None,
                readonly: false,
                r#override: false,
            });
        }
    }
    Ok(b.formal_parameters(SPAN, FormalParameterKind::FormalParameter, items, rest))
}

fn build_fn_body<'a>(b: AstBuilder<'a>, term: Term) -> R<FunctionBody<'a>> {
    Ok(b.function_body(SPAN, b.vec(), build_stmts(b, list_val(term, a::body()))?))
}

fn build_for_left<'a>(b: AstBuilder<'a>, term: Term) -> R<ForStatementLeft<'a>> {
    if type_eq(term, a::variable_declaration()) {
        Ok(ForStatementLeft::VariableDeclaration(build_var_decl_boxed(
            b, term,
        )?))
    } else {
        Ok(ForStatementLeft::from(build_assign_target(b, term)?))
    }
}

fn opt_label<'a>(b: AstBuilder<'a>, term: Term) -> Option<LabelIdentifier<'a>> {
    opt(term, a::label()).map(|t| {
        let n = str_val(t, a::name());
        LabelIdentifier {
            node_id: nid(),
            span: SPAN,
            name: b.ident(&n),
        }
    })
}

fn build_prop_key<'a>(b: AstBuilder<'a>, term: Term) -> R<PropertyKey<'a>> {
    let ty = type_atom(term).ok_or("Missing key type")?;
    if ty == a::identifier() {
        return Ok(PropertyKey::StaticIdentifier(
            b.alloc(ident_name(b, &str_val(term, a::name()))),
        ));
    }
    if ty == a::literal() || ty == a::string_literal() {
        let vt = get(term, a::value());
        if let Some(t) = vt {
            if let Ok(s) = t.decode::<String>() {
                return Ok(PropertyKey::StringLiteral(b.alloc(str_lit(b, &s))));
            }
            if let Ok(n) = t.decode::<f64>() {
                return Ok(PropertyKey::NumericLiteral(b.alloc(NumericLiteral {
                    node_id: nid(),
                    span: SPAN,
                    value: n,
                    raw: None,
                    base: NumberBase::Decimal,
                })));
            }
            if let Ok(n) = t.decode::<i64>() {
                return Ok(PropertyKey::NumericLiteral(b.alloc(NumericLiteral {
                    node_id: nid(),
                    span: SPAN,
                    value: n as f64,
                    raw: None,
                    base: NumberBase::Decimal,
                })));
            }
        }
    }
    if ty == a::numeric_literal() {
        return Ok(PropertyKey::NumericLiteral(b.alloc(NumericLiteral {
            node_id: nid(),
            span: SPAN,
            value: f64_val(term, a::value()),
            raw: None,
            base: NumberBase::Decimal,
        })));
    }
    Ok(PropertyKey::from(build_expr(b, term)?))
}

fn build_obj_props<'a>(
    b: AstBuilder<'a>,
    list: Vec<Term>,
) -> R<OxcVec<'a, ObjectPropertyKind<'a>>> {
    let mut out = b.vec_with_capacity(list.len());
    for p in &list {
        if type_eq(*p, a::spread_element()) {
            let arg = build_expr(b, get(*p, a::argument()).ok_or("Missing spread :argument")?)?;
            out.push(ObjectPropertyKind::SpreadProperty(
                b.alloc(b.spread_element(SPAN, arg)),
            ));
        } else {
            let key = build_prop_key(b, get(*p, a::key()).ok_or("Missing :key")?)?;
            let val = build_expr(b, get(*p, a::value()).ok_or("Missing :value")?)?;
            let kind_s = str_val(*p, a::kind());
            let kind = match kind_s.as_str() {
                "get" => PropertyKind::Get,
                "set" => PropertyKind::Set,
                _ => PropertyKind::Init,
            };
            out.push(ObjectPropertyKind::ObjectProperty(b.alloc(
                b.object_property(
                    SPAN,
                    kind,
                    key,
                    val,
                    bool_val(*p, a::method()),
                    bool_val(*p, a::shorthand()),
                    bool_val(*p, a::computed()),
                ),
            )));
        }
    }
    Ok(out)
}

fn build_args<'a>(b: AstBuilder<'a>, list: Vec<Term>) -> R<OxcVec<'a, Argument<'a>>> {
    let mut out = b.vec_with_capacity(list.len());
    for a_term in &list {
        if type_eq(*a_term, a::spread_element()) {
            let arg = build_expr(
                b,
                get(*a_term, a::argument()).ok_or("Missing spread :argument")?,
            )?;
            out.push(Argument::SpreadElement(
                b.alloc(b.spread_element(SPAN, arg)),
            ));
        } else {
            out.push(Argument::from(build_expr(b, *a_term)?));
        }
    }
    Ok(out)
}

// ── Operators ──

fn parse_bin_op(op: &str) -> R<BinaryOperator> {
    Ok(match op {
        "==" => BinaryOperator::Equality,
        "!=" => BinaryOperator::Inequality,
        "===" => BinaryOperator::StrictEquality,
        "!==" => BinaryOperator::StrictInequality,
        "<" => BinaryOperator::LessThan,
        "<=" => BinaryOperator::LessEqualThan,
        ">" => BinaryOperator::GreaterThan,
        ">=" => BinaryOperator::GreaterEqualThan,
        "+" => BinaryOperator::Addition,
        "-" => BinaryOperator::Subtraction,
        "*" => BinaryOperator::Multiplication,
        "/" => BinaryOperator::Division,
        "%" => BinaryOperator::Remainder,
        "**" => BinaryOperator::Exponential,
        "<<" => BinaryOperator::ShiftLeft,
        ">>" => BinaryOperator::ShiftRight,
        ">>>" => BinaryOperator::ShiftRightZeroFill,
        "|" => BinaryOperator::BitwiseOR,
        "^" => BinaryOperator::BitwiseXOR,
        "&" => BinaryOperator::BitwiseAnd,
        "in" => BinaryOperator::In,
        "instanceof" => BinaryOperator::Instanceof,
        _ => return err(format!("Unknown binary operator: {op}")),
    })
}

fn parse_log_op(op: &str) -> R<LogicalOperator> {
    Ok(match op {
        "||" => LogicalOperator::Or,
        "&&" => LogicalOperator::And,
        "??" => LogicalOperator::Coalesce,
        _ => return err(format!("Unknown logical operator: {op}")),
    })
}

fn parse_unary_op(op: &str) -> R<UnaryOperator> {
    Ok(match op {
        "+" => UnaryOperator::UnaryPlus,
        "-" => UnaryOperator::UnaryNegation,
        "!" => UnaryOperator::LogicalNot,
        "~" => UnaryOperator::BitwiseNot,
        "typeof" => UnaryOperator::Typeof,
        "void" => UnaryOperator::Void,
        "delete" => UnaryOperator::Delete,
        _ => return err(format!("Unknown unary operator: {op}")),
    })
}

fn parse_update_op(op: &str) -> R<UpdateOperator> {
    Ok(match op {
        "++" => UpdateOperator::Increment,
        "--" => UpdateOperator::Decrement,
        _ => return err(format!("Unknown update operator: {op}")),
    })
}

fn parse_assign_op(op: &str) -> R<AssignmentOperator> {
    Ok(match op {
        "=" => AssignmentOperator::Assign,
        "+=" => AssignmentOperator::Addition,
        "-=" => AssignmentOperator::Subtraction,
        "*=" => AssignmentOperator::Multiplication,
        "/=" => AssignmentOperator::Division,
        "%=" => AssignmentOperator::Remainder,
        "**=" => AssignmentOperator::Exponential,
        "<<=" => AssignmentOperator::ShiftLeft,
        ">>=" => AssignmentOperator::ShiftRight,
        ">>>=" => AssignmentOperator::ShiftRightZeroFill,
        "|=" => AssignmentOperator::BitwiseOR,
        "^=" => AssignmentOperator::BitwiseXOR,
        "&=" => AssignmentOperator::BitwiseAnd,
        "||=" => AssignmentOperator::LogicalOr,
        "&&=" => AssignmentOperator::LogicalAnd,
        "??=" => AssignmentOperator::LogicalNullish,
        _ => return err(format!("Unknown assignment operator: {op}")),
    })
}

fn parse_regex_flags(flags: &str) -> RegExpFlags {
    let mut r = RegExpFlags::empty();
    for ch in flags.chars() {
        r |= match ch {
            'g' => RegExpFlags::G,
            'i' => RegExpFlags::I,
            'm' => RegExpFlags::M,
            's' => RegExpFlags::S,
            'u' => RegExpFlags::U,
            'y' => RegExpFlags::Y,
            'd' => RegExpFlags::D,
            'v' => RegExpFlags::V,
            _ => RegExpFlags::empty(),
        };
    }
    r
}
