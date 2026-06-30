use lightningcss::dependencies::{Dependency, DependencyOptions};
use lightningcss::printer::PrinterOptions;
use lightningcss::stylesheet::{
    ParserFlags as CssParserFlags, ParserOptions as CssParserOptions, StyleSheet,
};
use rustler::{Atom, Encoder, Env, NifResult, Term};
use rustler_match_spec::{MatchEvent, Selector, ValueRef};
use vize_atelier_core::options::{
    CodegenMode, CodegenOptions, ParserOptions, TemplateSyntaxMode, TransformOptions,
};
use vize_atelier_core::parser::{parse, parse_with_options};
use vize_atelier_core::transform::transform;
use vize_atelier_sfc::compile_script::typescript::transform_typescript_to_js;
use vize_atelier_sfc::croquis::{analyze_sfc_descriptor, SfcCroquisOptions};
use vize_atelier_sfc::script::analyze_script_setup_to_summary;
use vize_atelier_sfc::{
    bundle_css, compile_css, compile_sfc, parse_css_ast, parse_sfc, print_css_ast,
    CssCompileOptions, CssTargets, SfcCompileOptions, SfcParseOptions,
};
use vize_atelier_ssr::compile_ssr;
use vize_atelier_vapor::{
    compile_vapor, compile_vapor_with_template_syntax_and_diagnostics, ir::*, transform_to_ir,
    VaporCompilerOptions,
};
use vize_carton::Bump;

#[macro_use]
mod macros;
mod html_inject;
mod ir_encoding;
mod term_encoding;
mod vapor_split;

use crate::ir_encoding::{encode_ir_prop, encode_simple_expr};
use crate::term_encoding::{
    decode_json_value, error_term, nil_term, ok_term, EncodedBundleCssResult,
    EncodedCompileSfcResult, EncodedCssAstResult, EncodedCssCompileResult, EncodedLintDiagnostic,
    EncodedParseSfcResult, EncodedSsrCompileResult, EncodedTemplateCompileResult,
};
use crate::vapor_split::process_block;

mod atoms {
    rustler::atoms! {
        ok,
        error,

        // SFC descriptor fields
        template,
        script,
        script_setup,
        styles,
        custom_blocks,
        content,
        lang,
        scoped,
        module,
        setup,
        attrs,
        block_type,
        loc,
        start,
        end_ = "end",
        start_line,
        start_column,
        end_line,
        end_column,
        url,
        css_url,

        // Compile result fields
        code,
        stats,
        bindings,
        emits,
        models,
        used_components,
        used_directives,
        undefined_refs,
        component_usages,
        template_expressions,
        required,
        context,
        handler,
        events,
        has_spread_attrs,
        is_dynamic,
        range,
        css,
        errors,
        warnings,
        diagnostics,
        recoverable,
        location,
        template_hash,
        style_hash,
        script_hash,
        macro_artifacts,
        message,
        preamble,
        helpers,
        templates,

        // Vapor IR fields
        root,
        block,
        operations,
        effects,
        returns,
        element,
        key,
        values,
        value,
        condition,
        positive,
        negative,
        source,
        index,
        render,
        once,
        parent,
        anchor,
        key_prop,
        tag,
        props,
        slots,
        name,
        fallback,
        delegate,
        effect,
        modifiers,
        camel,
        prop_modifier,
        is_component,
        components,
        directives,
        kind,
        asset,
        dynamic_slots,
        child_id,
        parent_id,
        offset,
        line,
        column,

        // CSS result fields
        ast,
        map,
        css_vars,
        exports,
        minify,
        targets,
        scope_id,
        filename_opt,
        custom_media,

        // Expression tags
        static_,
        element_template_map,

        // IR node type atoms
        set_prop,
        set_dynamic_props,
        set_text,
        set_event,
        set_html,
        set_template_ref,
        insert_node,
        prepend_node,
        directive,
        if_node,
        for_node,
        create_component,
        slot_outlet,
        get_text_child,
        child_ref,
        next_ref,

        // Split result fields
        statics,

        // Declaration .d.ts fields
        dts,

        // Directive kinds
        v_show,
        v_model,

        // Component kinds
        regular,
        teleport,
        keep_alive,
        suspense,
        dynamic,
    }
}

// ── SFC Parsing ──

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_sfc_nif<'a>(env: Env<'a>, source: &str) -> NifResult<Term<'a>> {
    let opts = SfcParseOptions::default();
    match parse_sfc(source, opts) {
        Ok(descriptor) => Ok(ok_term(
            env,
            EncodedParseSfcResult {
                descriptor: &descriptor,
            },
        )),
        Err(e) => Ok(error_term(env, format!("{e:?}"))),
    }
}

// ── SFC Analysis ──

#[rustler::nif(schedule = "DirtyCpu")]
fn analyze_sfc_nif<'a>(env: Env<'a>, source: &str, mode: &str) -> NifResult<Term<'a>> {
    let parse_opts = SfcParseOptions {
        filename: "component.vue".into(),
        ..Default::default()
    };

    let descriptor = match parse_sfc(source, parse_opts) {
        Ok(descriptor) => descriptor,
        Err(error) => return Ok(error_term(env, error.message.as_str())),
    };

    let allocator = Bump::new();
    let template_ast = descriptor.template.as_ref().map(|template| {
        let (root, _errors) = parse_with_options(
            &allocator,
            template.content.as_ref(),
            ParserOptions::default(),
        );
        root
    });

    let options = match mode {
        "lint" => SfcCroquisOptions::for_lint(),
        "compile" => SfcCroquisOptions::for_compile(),
        "declaration" => SfcCroquisOptions::for_declaration(),
        _ => SfcCroquisOptions::full(),
    };

    let croquis = analyze_sfc_descriptor(&descriptor, template_ast.as_ref(), options);
    let stats = croquis.stats();

    let bindings: Vec<Term<'a>> = croquis
        .bindings
        .iter()
        .map(|(name, binding_type)| {
            term_map!(env, {
                atoms::name() => name,
                atoms::kind() => format!("{:?}", binding_type),
            })
        })
        .collect();

    let props: Vec<Term<'a>> = croquis
        .get_props()
        .map(|(name, required)| {
            term_map!(env, {
                atoms::name() => name,
                atoms::required() => required,
            })
        })
        .collect();

    let emits: Vec<&str> = croquis.get_emits().collect();
    let models: Vec<&str> = croquis.get_models().collect();
    let used_components: Vec<&str> = croquis.used_components.iter().map(|s| s.as_str()).collect();
    let used_directives: Vec<&str> = croquis.used_directives.iter().map(|s| s.as_str()).collect();

    let undefined_refs: Vec<Term<'a>> = croquis
        .undefined_refs
        .iter()
        .map(|reference| {
            term_map!(env, {
                atoms::name() => reference.name.as_str(),
                atoms::offset() => reference.offset,
                atoms::context() => reference.context.as_str(),
            })
        })
        .collect();

    let component_usages: Vec<Term<'a>> = croquis
        .component_usages
        .iter()
        .map(|usage| {
            let props: Vec<Term<'a>> = usage
                .props
                .iter()
                .map(|prop| {
                    term_map!(env, {
                        atoms::name() => prop.name.as_str(),
                        atoms::value() => prop.value.as_ref().map(|v| v.as_str()),
                        atoms::is_dynamic() => prop.is_dynamic,
                    })
                })
                .collect();
            let events: Vec<Term<'a>> = usage
                .events
                .iter()
                .map(|event| {
                    term_map!(env, {
                        atoms::name() => event.name.as_str(),
                        atoms::handler() => event.handler.as_ref().map(|h| h.as_str()),
                    })
                })
                .collect();

            term_map!(env, {
                atoms::name() => usage.name.as_str(),
                atoms::props() => props,
                atoms::events() => events,
                atoms::has_spread_attrs() => usage.has_spread_attrs,
            })
        })
        .collect();

    let template_expressions: Vec<Term<'a>> = croquis
        .template_expressions
        .iter()
        .map(|expression| {
            term_map!(env, {
                atoms::source() => expression.content.as_str(),
                atoms::kind() => expression.kind.as_str(),
                atoms::range() => term_map!(env, {
                    atoms::start() => expression.start,
                    atoms::end_() => expression.end,
                }),
            })
        })
        .collect();

    let result = term_map!(env, {
        atoms::stats() => term_map!(env, {
            atoms::bindings() => stats.binding_count,
            atoms::props() => stats.prop_count,
            atoms::emits() => stats.emit_count,
            atoms::models() => stats.model_count,
            atoms::used_components() => stats.used_components,
            atoms::used_directives() => stats.used_directives,
            atoms::undefined_refs() => stats.undefined_ref_count,
        }),
        atoms::bindings() => bindings,
        atoms::props() => props,
        atoms::emits() => emits,
        atoms::models() => models,
        atoms::used_components() => used_components,
        atoms::used_directives() => used_directives,
        atoms::undefined_refs() => undefined_refs,
        atoms::component_usages() => component_usages,
        atoms::template_expressions() => template_expressions,
    });

    Ok(ok_term(env, result))
}

// ── SFC Compilation ──

#[rustler::nif(schedule = "DirtyCpu")]
#[allow(clippy::too_many_arguments)]
fn compile_sfc_nif<'a>(
    env: Env<'a>,
    source: &str,
    filename: &str,
    scope_id: &str,
    vapor: bool,
    ssr: bool,
    custom_renderer: bool,
    strip_types: bool,
) -> NifResult<Term<'a>> {
    let mut parse_opts = SfcParseOptions::default();
    if !filename.is_empty() {
        parse_opts.filename = filename.into();
    }

    let descriptor = match parse_sfc(source, parse_opts) {
        Ok(d) => d,
        Err(e) => return Ok(error_term(env, format!("{e:?}"))),
    };

    let mut compile_opts = SfcCompileOptions {
        vapor,
        template: vize_atelier_sfc::TemplateCompileOptions {
            ssr,
            custom_renderer,
            ..Default::default()
        },
        ..Default::default()
    };
    if !scope_id.is_empty() {
        compile_opts.scope_id = Some(scope_id.into());
    }
    if !filename.is_empty() {
        compile_opts.script.id = Some(filename.into());
    }

    match compile_sfc(&descriptor, compile_opts) {
        Ok(result) => {
            let stripped;
            let code_override = if strip_types {
                stripped = transform_typescript_to_js(result.code.as_str());
                Some(stripped.as_str())
            } else {
                None
            };

            Ok(ok_term(
                env,
                EncodedCompileSfcResult {
                    result: &result,
                    code_override,
                    template_hash: descriptor.template_hash(),
                    style_hash: descriptor.style_hash(),
                    script_hash: descriptor.script_hash(),
                },
            ))
        }
        Err(e) => Ok(error_term(env, e.message.as_str())),
    }
}

// ── Template Compilation ──

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_template_nif<'a>(
    env: Env<'a>,
    source: &str,
    mode: &str,
    ssr: bool,
) -> NifResult<Term<'a>> {
    let allocator = Bump::new();
    let (mut root, errors) = parse(&allocator, source);

    if !errors.is_empty() {
        let msgs: Vec<std::string::String> = errors.iter().map(|e| e.message.to_string()).collect();
        return Ok(error_term(env, msgs));
    }

    let is_module = mode == "module";
    let transform_opts = TransformOptions {
        prefix_identifiers: is_module,
        ssr,
        ..Default::default()
    };
    transform(&allocator, &mut root, transform_opts, None);

    let codegen_opts = CodegenOptions {
        mode: if is_module {
            CodegenMode::Module
        } else {
            CodegenMode::Function
        },
        ssr,
        ..Default::default()
    };
    let result = vize_atelier_core::codegen::generate(&root, codegen_opts);

    let helpers: Vec<&str> = root.helpers.iter().map(|h| h.name()).collect();

    Ok(ok_term(
        env,
        EncodedTemplateCompileResult {
            code: result.code.as_str(),
            preamble: result.preamble.as_str(),
            helpers,
        },
    ))
}

// ── SSR Compilation ──

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_ssr_nif<'a>(env: Env<'a>, source: &str) -> NifResult<Term<'a>> {
    let allocator = Bump::new();
    let (_root, errors, result) = compile_ssr(&allocator, source);

    if !errors.is_empty() {
        let msgs: Vec<std::string::String> = errors.iter().map(|e| e.message.to_string()).collect();
        return Ok(error_term(env, msgs));
    }

    Ok(ok_term(
        env,
        EncodedSsrCompileResult {
            code: result.code.as_str(),
            preamble: result.preamble.as_str(),
        },
    ))
}

// ── Vapor Compilation ──

fn encode_position<'a>(env: Env<'a>, position: &vize_atelier_core::Position) -> Term<'a> {
    term_map!(env, {
        atoms::offset() => position.offset,
        atoms::line() => position.line,
        atoms::column() => position.column,
    })
}

fn encode_source_location<'a>(
    env: Env<'a>,
    location: &vize_atelier_core::SourceLocation,
) -> Term<'a> {
    term_map!(env, {
        atoms::start() => encode_position(env, &location.start),
        atoms::end_() => encode_position(env, &location.end),
        atoms::source() => location.source.as_str(),
    })
}

fn encode_compiler_error<'a>(env: Env<'a>, error: &vize_atelier_core::CompilerError) -> Term<'a> {
    term_map!(env, {
        atoms::code() => format!("{:?}", error.code),
        atoms::message() => error.message.as_str(),
        atoms::recoverable() => error.is_recoverable(),
        atoms::location() => error
            .loc
            .as_ref()
            .map(|location| encode_source_location(env, location))
            .unwrap_or_else(|| nil_term(env)),
    })
}

fn template_syntax_mode(value: &str) -> TemplateSyntaxMode {
    match value {
        "quirks" => TemplateSyntaxMode::Quirks,
        _ => TemplateSyntaxMode::Standard,
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn compile_vapor_nif<'a>(
    env: Env<'a>,
    source: &str,
    ssr: bool,
    diagnostics: bool,
    template_syntax: &str,
) -> NifResult<Term<'a>> {
    let allocator = Bump::new();
    let opts = VaporCompilerOptions {
        ssr,
        ..Default::default()
    };
    let syntax = template_syntax_mode(template_syntax);

    if diagnostics || syntax.is_quirks() {
        let (result, parser_diagnostics) =
            compile_vapor_with_template_syntax_and_diagnostics(&allocator, source, opts, syntax);

        let mut diagnostic_terms: Vec<Term<'a>> = parser_diagnostics
            .iter()
            .map(|diagnostic| encode_compiler_error(env, diagnostic))
            .collect();

        if !result.error_messages.is_empty() {
            let mut errors: Vec<Term<'a>> = result
                .error_messages
                .iter()
                .map(|message| {
                    term_map!(env, {
                        atoms::message() => message.as_str(),
                        atoms::recoverable() => false,
                    })
                })
                .collect();
            diagnostic_terms.append(&mut errors);
            return Ok(error_term(env, diagnostic_terms));
        }

        let templates: Vec<&str> = result.templates.iter().map(|s| s.as_str()).collect();
        let map = term_map!(env, {
            atoms::code() => result.code.as_str(),
            atoms::templates() => templates,
            atoms::diagnostics() => diagnostic_terms,
        });

        return Ok(ok_term(env, map));
    }

    let result = compile_vapor(&allocator, source, opts);

    if !result.error_messages.is_empty() {
        let msgs: Vec<&str> = result.error_messages.iter().map(|s| s.as_str()).collect();
        return Ok(error_term(env, msgs));
    }

    let templates: Vec<&str> = result.templates.iter().map(|s| s.as_str()).collect();

    let map = Term::map_from_arrays(
        env,
        &[atoms::code().encode(env), atoms::templates().encode(env)],
        &[result.code.as_str().encode(env), templates.encode(env)],
    )
    .unwrap();

    Ok(ok_term(env, map))
}

// ── Vapor IR ──

fn encode_operation<'a>(env: Env<'a>, op: &OperationNode) -> Term<'a> {
    match op {
        OperationNode::SetProp(node) => {
            let prop = encode_ir_prop(env, &node.prop);
            term_map!(env, {
                atoms::kind() => atoms::set_prop(),
                atoms::element() => node.element,
                atoms::tag() => node.tag.as_str(),
                atoms::camel() => node.camel,
                atoms::prop_modifier() => node.prop_modifier,
                atoms::value() => prop,
            })
        }
        OperationNode::SetDynamicProps(node) => {
            let props: Vec<Term<'a>> = node
                .props
                .iter()
                .map(|prop| encode_simple_expr(env, prop))
                .collect();
            term_map!(env, {
                atoms::kind() => atoms::set_dynamic_props(),
                atoms::element() => node.element,
                atoms::props() => props,
            })
        }
        OperationNode::SetText(node) => {
            let values: Vec<Term<'a>> = node
                .values
                .iter()
                .map(|value| encode_simple_expr(env, value))
                .collect();
            term_map!(env, {
                atoms::kind() => atoms::set_text(),
                atoms::element() => node.element,
                atoms::values() => values,
            })
        }
        OperationNode::SetEvent(node) => term_map!(env, {
            atoms::kind() => atoms::set_event(),
            atoms::element() => node.element,
            atoms::key() => encode_simple_expr(env, &node.key),
            atoms::value() => node
                .value
                .as_ref()
                .map(|value| encode_simple_expr(env, value))
                .unwrap_or_else(|| nil_term(env)),
            atoms::delegate() => node.delegate,
            atoms::effect() => node.effect,
        }),
        OperationNode::SetHtml(node) => term_map!(env, {
            atoms::kind() => atoms::set_html(),
            atoms::element() => node.element,
            atoms::value() => encode_simple_expr(env, &node.value),
        }),
        OperationNode::SetTemplateRef(node) => term_map!(env, {
            atoms::kind() => atoms::set_template_ref(),
            atoms::element() => node.element,
            atoms::value() => encode_simple_expr(env, &node.value),
        }),
        OperationNode::InsertNode(node) => {
            let elements: Vec<usize> = node.elements.clone();
            term_map!(env, {
                atoms::kind() => atoms::insert_node(),
                atoms::element() => elements,
                atoms::parent() => node.parent,
                atoms::anchor() => node.anchor,
            })
        }
        OperationNode::PrependNode(node) => {
            let elements: Vec<usize> = node.elements.clone();
            term_map!(env, {
                atoms::kind() => atoms::prepend_node(),
                atoms::element() => elements,
                atoms::parent() => node.parent,
            })
        }
        OperationNode::If(if_node) => encode_if_node(env, if_node),
        OperationNode::For(for_node) => encode_for_node(env, for_node),
        OperationNode::CreateComponent(node) => {
            let props: Vec<Term<'a>> = node
                .props
                .iter()
                .map(|prop| encode_ir_prop(env, prop))
                .collect();
            let kind_atom = match node.kind {
                ComponentKind::Regular => atoms::regular(),
                ComponentKind::Teleport => atoms::teleport(),
                ComponentKind::KeepAlive => atoms::keep_alive(),
                ComponentKind::Suspense => atoms::suspense(),
                ComponentKind::Dynamic => atoms::dynamic(),
            };
            term_map!(env, {
                atoms::kind() => atoms::create_component(),
                atoms::tag() => node.tag.as_str(),
                atoms::props() => props,
                atoms::asset() => node.asset,
                atoms::once() => node.once,
                atoms::dynamic_slots() => node.dynamic_slots,
                atoms::parent() => node.parent,
                atoms::anchor() => node.anchor,
                atoms::value() => kind_atom,
            })
        }
        OperationNode::SlotOutlet(node) => term_map!(env, {
            atoms::kind() => atoms::slot_outlet(),
            atoms::name() => encode_simple_expr(env, &node.name),
            atoms::props() => node
                .props
                .iter()
                .map(|prop| encode_ir_prop(env, prop))
                .collect::<Vec<_>>(),
        }),
        OperationNode::Directive(node) => {
            let exp = node
                .dir
                .exp
                .as_ref()
                .map(|expr| match expr {
                    vize_atelier_core::ExpressionNode::Simple(simple) => {
                        encode_simple_expr(env, simple)
                    }
                    vize_atelier_core::ExpressionNode::Compound(compound) => {
                        let content: std::string::String = compound
                            .children
                            .iter()
                            .map(|child| match child {
                                vize_atelier_core::CompoundExpressionChild::Simple(simple) => {
                                    simple.content.to_string()
                                }
                                vize_atelier_core::CompoundExpressionChild::String(string) => {
                                    string.to_string()
                                }
                                _ => std::string::String::new(),
                            })
                            .collect();
                        content.as_str().encode(env)
                    }
                })
                .unwrap_or_else(|| nil_term(env));

            term_map!(env, {
                atoms::kind() => atoms::directive(),
                atoms::element() => node.element,
                atoms::name() => node.name.as_str(),
                atoms::tag() => node.tag.as_str(),
                atoms::value() => exp,
            })
        }
        OperationNode::GetTextChild(node) => term_map!(env, {
            atoms::kind() => atoms::get_text_child(),
            atoms::parent() => node.parent,
        }),
        OperationNode::ChildRef(node) => term_map!(env, {
            atoms::kind() => atoms::child_ref(),
            atoms::child_id() => node.child_id,
            atoms::parent_id() => node.parent_id,
            atoms::offset() => node.offset,
        }),
        OperationNode::NextRef(node) => term_map!(env, {
            atoms::kind() => atoms::next_ref(),
            atoms::child_id() => node.child_id,
            atoms::parent_id() => node.prev_id,
            atoms::offset() => node.offset,
        }),
    }
}

fn encode_block<'a>(env: Env<'a>, block: &BlockIRNode) -> Term<'a> {
    let operations: Vec<Term<'a>> = block
        .operation
        .iter()
        .map(|operation| encode_operation(env, operation))
        .collect();

    let effects: Vec<Term<'a>> = block
        .effect
        .iter()
        .map(|effect| {
            effect
                .operations
                .iter()
                .map(|operation| encode_operation(env, operation))
                .collect::<Vec<_>>()
                .encode(env)
        })
        .collect();

    let returns: Vec<usize> = block.returns.iter().copied().collect();

    term_map!(env, {
        atoms::operations() => operations,
        atoms::effects() => effects,
        atoms::returns() => returns,
    })
}

fn encode_if_node<'a>(env: Env<'a>, if_node: &IfIRNode) -> Term<'a> {
    let negative = match &if_node.negative {
        Some(NegativeBranch::Block(block)) => encode_block(env, block),
        Some(NegativeBranch::If(nested)) => encode_if_node(env, nested),
        None => nil_term(env),
    };

    term_map!(env, {
        atoms::kind() => atoms::if_node(),
        atoms::condition() => encode_simple_expr(env, &if_node.condition),
        atoms::positive() => encode_block(env, &if_node.positive),
        atoms::negative() => negative,
        atoms::once() => if_node.once,
        atoms::parent() => if_node.parent,
        atoms::anchor() => if_node.anchor,
    })
}

fn encode_for_node<'a>(env: Env<'a>, for_node: &ForIRNode) -> Term<'a> {
    term_map!(env, {
        atoms::kind() => atoms::for_node(),
        atoms::source() => encode_simple_expr(env, &for_node.source),
        atoms::value() => for_node
            .value
            .as_ref()
            .map(|value| encode_simple_expr(env, value))
            .unwrap_or_else(|| nil_term(env)),
        atoms::key() => for_node
            .key
            .as_ref()
            .map(|key| encode_simple_expr(env, key))
            .unwrap_or_else(|| nil_term(env)),
        atoms::index() => for_node
            .index
            .as_ref()
            .map(|index| encode_simple_expr(env, index))
            .unwrap_or_else(|| nil_term(env)),
        atoms::key_prop() => for_node
            .key_prop
            .as_ref()
            .map(|key_prop| encode_simple_expr(env, key_prop))
            .unwrap_or_else(|| nil_term(env)),
        atoms::render() => encode_block(env, &for_node.render),
        atoms::once() => for_node.once,
        atoms::parent() => for_node.parent,
        atoms::anchor() => for_node.anchor,
    })
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vapor_ir_nif<'a>(env: Env<'a>, source: &str) -> NifResult<Term<'a>> {
    let allocator = Bump::new();
    let parser_opts = ParserOptions::default();
    let (mut root, errors) = parse_with_options(&allocator, source, parser_opts);

    if !errors.is_empty() {
        let msgs: Vec<std::string::String> = errors.iter().map(|e| e.message.to_string()).collect();
        return Ok(error_term(env, msgs));
    }

    let transform_opts = TransformOptions {
        vapor: true,
        ..Default::default()
    };
    transform(&allocator, &mut root, transform_opts, None);

    let ir = transform_to_ir(&allocator, &root);

    let templates: Vec<&str> = ir.templates.iter().map(|s| s.as_str()).collect();
    let components: Vec<&str> = ir.component.iter().map(|s| s.as_str()).collect();
    let directives: Vec<&str> = ir.directive.iter().map(|s| s.as_str()).collect();

    let etm_keys: Vec<usize> = ir.element_template_map.keys().copied().collect();
    let etm_vals: Vec<usize> = etm_keys
        .iter()
        .map(|k| ir.element_template_map[k])
        .collect();
    let element_template_map: Vec<(usize, usize)> =
        etm_keys.into_iter().zip(etm_vals.into_iter()).collect();

    let map = Term::map_from_arrays(
        env,
        &[
            atoms::templates().encode(env),
            atoms::components().encode(env),
            atoms::directives().encode(env),
            atoms::block().encode(env),
            atoms::element_template_map().encode(env),
        ],
        &[
            templates.encode(env),
            components.encode(env),
            directives.encode(env),
            encode_block(env, &ir.block),
            element_template_map.encode(env),
        ],
    )
    .unwrap();

    Ok(ok_term(env, map))
}

// ── Linting ──

#[rustler::nif(schedule = "DirtyCpu")]
fn lint_nif<'a>(env: Env<'a>, source: &str, filename: &str) -> NifResult<Term<'a>> {
    use vize_patina::Linter;

    let linter = Linter::default();
    let result = linter.lint_sfc(source, filename);
    let diagnostics: Vec<Term<'a>> = result
        .diagnostics
        .iter()
        .map(|d| {
            EncodedLintDiagnostic {
                message: d.message.as_str(),
                name: d.rule_name,
            }
            .encode(env)
        })
        .collect();

    Ok(ok_term(env, diagnostics))
}

// ── CSS Compilation ──

fn css_targets(chrome: i64, firefox: i64, safari: i64) -> Option<CssTargets> {
    if chrome >= 0 || firefox >= 0 || safari >= 0 {
        Some(CssTargets {
            chrome: if chrome >= 0 {
                Some(chrome as u32)
            } else {
                None
            },
            firefox: if firefox >= 0 {
                Some(firefox as u32)
            } else {
                None
            },
            safari: if safari >= 0 {
                Some(safari as u32)
            } else {
                None
            },
            ..Default::default()
        })
    } else {
        None
    }
}

fn css_parser_options<'a>(
    filename: &'a str,
    custom_media: bool,
    css_modules: bool,
) -> CssParserOptions<'a, 'a> {
    let mut flags = CssParserFlags::NESTING | CssParserFlags::DEEP_SELECTOR_COMBINATOR;
    if custom_media {
        flags |= CssParserFlags::CUSTOM_MEDIA;
    }

    let css_modules_config = if css_modules {
        Some(lightningcss::css_modules::Config {
            pattern: lightningcss::css_modules::Pattern::default(),
            ..Default::default()
        })
    } else {
        None
    };

    CssParserOptions {
        filename: if filename.is_empty() {
            "style.css".into()
        } else {
            filename.into()
        },
        flags,
        css_modules: css_modules_config,
        ..Default::default()
    }
}

fn find_line_bounds(source: &str, line: u32) -> Option<(usize, usize)> {
    let mut current_line = 1_u32;
    let mut line_start = 0_usize;

    for (index, byte) in source.bytes().enumerate() {
        if byte == b'\n' {
            if current_line == line {
                return Some((line_start, index));
            }
            current_line += 1;
            line_start = index + 1;
        }
    }

    if current_line == line {
        Some((line_start, source.len()))
    } else {
        None
    }
}

fn find_url_range(source: &str, line: u32, column: u32, url: &str) -> Option<(usize, usize)> {
    let (line_start, line_end) = find_line_bounds(source, line)?;
    let line_source = &source[line_start..line_end];
    let target_column = column as usize;

    let match_start = line_source
        .match_indices(url)
        .map(|(index, _)| index)
        .min_by_key(|index| index.abs_diff(target_column))?;

    let start = line_start + match_start;
    Some((start, start + url.len()))
}

struct CssUrlEvent {
    url: String,
    start: usize,
    end: usize,
    start_line: u32,
    start_column: u32,
    end_line: u32,
    end_column: u32,
}

impl<'a> MatchEvent<'a> for &'a CssUrlEvent {
    fn tag(&self) -> Atom {
        atoms::css_url()
    }

    fn arity(&self) -> usize {
        8
    }

    fn positional_field(&self, index: usize) -> Option<ValueRef<'a>> {
        match index {
            1 => Some(ValueRef::Str(self.url.as_str())),
            2 => Some(ValueRef::U64(self.start as u64)),
            3 => Some(ValueRef::U64(self.end as u64)),
            4 => Some(ValueRef::U64(self.start_line.into())),
            5 => Some(ValueRef::U64(self.start_column.into())),
            6 => Some(ValueRef::U64(self.end_line.into())),
            7 => Some(ValueRef::U64(self.end_column.into())),
            _ => None,
        }
    }

    fn field(&self, name: Atom) -> Option<ValueRef<'a>> {
        if name == atoms::url() {
            Some(ValueRef::Str(self.url.as_str()))
        } else if name == atoms::start() {
            Some(ValueRef::U64(self.start as u64))
        } else if name == atoms::end_() {
            Some(ValueRef::U64(self.end as u64))
        } else if name == atoms::start_line() {
            Some(ValueRef::U64(self.start_line.into()))
        } else if name == atoms::start_column() {
            Some(ValueRef::U64(self.start_column.into()))
        } else if name == atoms::end_line() {
            Some(ValueRef::U64(self.end_line.into()))
        } else if name == atoms::end_column() {
            Some(ValueRef::U64(self.end_column.into()))
        } else {
            None
        }
    }
}

#[rustler::nif(schedule = "DirtyCpu")]
fn select_css_nif<'a>(
    env: Env<'a>,
    source: &str,
    filename: &str,
    custom_media: bool,
    css_modules: bool,
    selector_term: Term<'a>,
) -> NifResult<Term<'a>> {
    let selector = Selector::from_term(selector_term)?;

    let stylesheet = match StyleSheet::parse(
        source,
        css_parser_options(filename, custom_media, css_modules),
    ) {
        Ok(stylesheet) => stylesheet,
        Err(error) => return Ok(error_term(env, vec![format!("CSS parse error: {error}")])),
    };

    let result = match stylesheet.to_css(PrinterOptions {
        analyze_dependencies: Some(DependencyOptions {
            remove_imports: false,
        }),
        ..Default::default()
    }) {
        Ok(result) => result,
        Err(error) => return Ok(error_term(env, vec![format!("CSS print error: {error:?}")])),
    };

    let mut events = Vec::new();

    for dependency in result.dependencies.unwrap_or_default() {
        let Dependency::Url(dependency) = dependency else {
            continue;
        };

        let Some((start, end)) = find_url_range(
            source,
            dependency.loc.start.line,
            dependency.loc.start.column,
            &dependency.url,
        ) else {
            return Ok(error_term(
                env,
                vec![format!(
                    "Could not locate CSS URL range for {}",
                    dependency.url
                )],
            ));
        };

        events.push(CssUrlEvent {
            url: dependency.url.to_string(),
            start,
            end,
            start_line: dependency.loc.start.line,
            start_column: dependency.loc.start.column,
            end_line: dependency.loc.end.line,
            end_column: dependency.loc.end.column,
        });
    }

    let mut urls = Vec::new();

    for event in &events {
        selector.run_event(env, &event, &mut urls)?;
    }

    Ok(ok_term(env, urls))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn parse_css_ast_nif<'a>(
    env: Env<'a>,
    source: &str,
    filename: &str,
    custom_media: bool,
    css_modules: bool,
) -> NifResult<Term<'a>> {
    let options = CssCompileOptions {
        filename: if filename.is_empty() {
            None
        } else {
            Some(filename.into())
        },
        custom_media,
        css_modules,
        ..Default::default()
    };

    let result = parse_css_ast(source, &options);

    Ok(ok_term(env, EncodedCssAstResult { result: &result }))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn print_css_ast_nif<'a>(
    env: Env<'a>,
    ast: Term<'a>,
    minify: bool,
    chrome: i64,
    firefox: i64,
    safari: i64,
) -> NifResult<Term<'a>> {
    let ast = match decode_json_value(ast) {
        Ok(ast) => ast,
        Err(_) => {
            let result = vize_atelier_sfc::CssCompileResult {
                code: Default::default(),
                map: None,
                css_vars: vec![],
                errors: vec!["Invalid CSS AST term".into()],
                warnings: vec![],
                exports: None,
            };

            return Ok(ok_term(env, EncodedCssCompileResult { result: &result }));
        }
    };

    let options = CssCompileOptions {
        minify,
        targets: css_targets(chrome, firefox, safari),
        ..Default::default()
    };

    let result = print_css_ast(ast, &options);

    Ok(ok_term(env, EncodedCssCompileResult { result: &result }))
}

#[rustler::nif(schedule = "DirtyCpu")]
#[allow(clippy::too_many_arguments)]
fn compile_css_nif<'a>(
    env: Env<'a>,
    source: &str,
    minify: bool,
    scoped: bool,
    scope_id_str: &str,
    filename: &str,
    chrome: i64,
    firefox: i64,
    safari: i64,
    css_modules: bool,
) -> NifResult<Term<'a>> {
    let targets = if chrome >= 0 || firefox >= 0 || safari >= 0 {
        Some(CssTargets {
            chrome: if chrome >= 0 {
                Some(chrome as u32)
            } else {
                None
            },
            firefox: if firefox >= 0 {
                Some(firefox as u32)
            } else {
                None
            },
            safari: if safari >= 0 {
                Some(safari as u32)
            } else {
                None
            },
            ..Default::default()
        })
    } else {
        None
    };

    let options = CssCompileOptions {
        scope_id: if scope_id_str.is_empty() {
            None
        } else {
            Some(scope_id_str.into())
        },
        scoped,
        minify,
        source_map: false,
        targets,
        filename: if filename.is_empty() {
            None
        } else {
            Some(filename.into())
        },
        custom_media: false,
        css_modules,
    };

    let result = compile_css(source, &options);

    Ok(ok_term(env, EncodedCssCompileResult { result: &result }))
}

// ── CSS Bundling ──

#[rustler::nif(schedule = "DirtyCpu")]
fn bundle_css_nif<'a>(
    env: Env<'a>,
    entry_path: &str,
    minify: bool,
    chrome: i64,
    firefox: i64,
    safari: i64,
    css_modules: bool,
) -> NifResult<Term<'a>> {
    let targets = if chrome >= 0 || firefox >= 0 || safari >= 0 {
        Some(CssTargets {
            chrome: if chrome >= 0 {
                Some(chrome as u32)
            } else {
                None
            },
            firefox: if firefox >= 0 {
                Some(firefox as u32)
            } else {
                None
            },
            safari: if safari >= 0 {
                Some(safari as u32)
            } else {
                None
            },
            ..Default::default()
        })
    } else {
        None
    };

    let options = CssCompileOptions {
        minify,
        targets,
        css_modules,
        ..Default::default()
    };

    let result = bundle_css(entry_path, &options);

    Ok(ok_term(env, EncodedBundleCssResult { result: &result }))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn vapor_split_nif<'a>(env: Env<'a>, source: &str) -> NifResult<Term<'a>> {
    let allocator = Bump::new();
    let parser_opts = ParserOptions::default();
    let (mut root, errors) = parse_with_options(&allocator, source, parser_opts);

    if !errors.is_empty() {
        let msgs: std::vec::Vec<std::string::String> =
            errors.iter().map(|e| e.message.to_string()).collect();
        return Ok(error_term(env, msgs));
    }

    let transform_opts = TransformOptions {
        vapor: true,
        ..Default::default()
    };
    transform(&allocator, &mut root, transform_opts, None);

    let ir = transform_to_ir(&allocator, &root);

    let (statics, slots) = process_block(env, &ir.block, &ir);

    let statics_term: std::vec::Vec<Term<'a>> =
        statics.iter().map(|s| s.as_str().encode(env)).collect();
    let templates: std::vec::Vec<&str> = ir.templates.iter().map(|s| s.as_str()).collect();
    let element_template_map: std::vec::Vec<(usize, usize)> = ir
        .element_template_map
        .iter()
        .map(|(&k, &v)| (k, v))
        .collect();

    let result = Term::map_from_arrays(
        env,
        &[
            atoms::statics().encode(env),
            atoms::slots().encode(env),
            atoms::templates().encode(env),
            atoms::element_template_map().encode(env),
        ],
        &[
            statics_term.encode(env),
            slots.encode(env),
            templates.encode(env),
            element_template_map.encode(env),
        ],
    )
    .unwrap();

    Ok(ok_term(env, result))
}

// ── Declaration .d.ts Generation ──

#[rustler::nif(schedule = "DirtyCpu")]
fn generate_dts_nif<'a>(env: Env<'a>, source: &str, filename: &str) -> NifResult<Term<'a>> {
    let parse_opts = SfcParseOptions {
        filename: if filename.is_empty() {
            "component.vue".into()
        } else {
            filename.into()
        },
        ..Default::default()
    };

    let descriptor = match parse_sfc(source, parse_opts) {
        Ok(d) => d,
        Err(e) => return Ok(error_term(env, format!("{e:?}"))),
    };

    let plain_script = descriptor.script.as_ref().map(|s| s.content.as_ref());
    let setup_script = descriptor.script_setup.as_ref().map(|s| s.content.as_ref());

    let summary = match setup_script {
        Some(content) => analyze_script_setup_to_summary(content),
        None => vize_croquis::Croquis::new(),
    };

    let output = match (plain_script, setup_script) {
        (Some(plain), Some(setup)) => {
            vize_croquis::declaration_ts::generate_declaration_ts_with_split_scripts(
                &summary, plain, setup,
            )
        }
        (_, Some(setup)) => {
            vize_croquis::declaration_ts::generate_declaration_ts(&summary, Some(setup))
        }
        (Some(plain), None) => {
            vize_croquis::declaration_ts::generate_declaration_ts(&summary, Some(plain))
        }
        (None, None) => vize_croquis::declaration_ts::generate_declaration_ts(&summary, None),
    };

    let result = term_map!(env, {
        atoms::dts() => output.content.as_str(),
    });

    Ok(ok_term(env, result))
}

rustler::init!("Elixir.Vize.Native");
