use rustler::{Encoder, Env, Term};
use vize_atelier_vapor::ir::*;

use crate::atoms;
use crate::html_inject::{
    build_elem_to_tag, inject_attr, inject_before_close, parse_tag_tree,
    replace_first_space_in_content, PROP_MARKER, STRUCT_MARKER, TEXT_MARKER,
};
use crate::ir_encoding::{encode_ir_prop, encode_simple_expr};
use crate::term_encoding::nil_term;

fn encode_slot_values<'a>(env: Env<'a>, kind: Term<'a>, values: Term<'a>) -> Term<'a> {
    term_map!(env, {
        atoms::kind() => kind,
        atoms::values() => values,
    })
}

fn encode_slot_value<'a>(
    env: Env<'a>,
    kind: Term<'a>,
    expr: &vize_atelier_core::SimpleExpressionNode,
) -> Term<'a> {
    term_map!(env, {
        atoms::kind() => kind,
        atoms::value() => encode_simple_expr(env, expr),
    })
}

fn encode_split_block<'a, 'b>(
    env: Env<'a>,
    block: &'b BlockIRNode<'b>,
    ir: &'b RootIRNode<'b>,
) -> Term<'a> {
    let (statics, slots) = process_block(env, block, ir);
    let statics_term: Vec<Term<'a>> = statics
        .iter()
        .map(|static_part| static_part.as_str().encode(env))
        .collect();

    term_map!(env, {
        atoms::statics() => statics_term,
        atoms::slots() => slots,
    })
}

fn encode_slot_if_split<'a, 'b>(
    env: Env<'a>,
    if_node: &'b IfIRNode<'b>,
    ir: &'b RootIRNode<'b>,
) -> Term<'a> {
    let negative = match &if_node.negative {
        Some(NegativeBranch::Block(block)) => encode_split_block(env, block, ir),
        Some(NegativeBranch::If(nested)) => encode_slot_if_split(env, nested, ir),
        None => nil_term(env),
    };

    term_map!(env, {
        atoms::kind() => atoms::if_node(),
        atoms::condition() => encode_simple_expr(env, &if_node.condition),
        atoms::positive() => encode_split_block(env, &if_node.positive, ir),
        atoms::negative() => negative,
    })
}

fn encode_slot_for_split<'a, 'b>(
    env: Env<'a>,
    for_node: &'b ForIRNode<'b>,
    ir: &'b RootIRNode<'b>,
) -> Term<'a> {
    term_map!(env, {
        atoms::kind() => atoms::for_node(),
        atoms::source() => encode_simple_expr(env, &for_node.source),
        atoms::value() => for_node
            .value
            .as_ref()
            .map(|value| encode_simple_expr(env, value))
            .unwrap_or_else(|| nil_term(env)),
        atoms::key_prop() => for_node
            .key_prop
            .as_ref()
            .map(|key_prop| encode_simple_expr(env, key_prop))
            .unwrap_or_else(|| nil_term(env)),
        atoms::render() => encode_split_block(env, &for_node.render, ir),
    })
}

fn encode_slot_component<'a>(env: Env<'a>, node: &CreateComponentIRNode) -> Term<'a> {
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
        atoms::value() => kind_atom,
    })
}

fn split_on_markers(html: &str) -> Vec<String> {
    let mut statics = Vec::new();
    let mut current = String::new();
    let mut rest = html;

    loop {
        let prop_pos = rest.find(PROP_MARKER);
        let text_pos = rest.find(TEXT_MARKER);
        let struct_pos = rest.find(STRUCT_MARKER);
        let next = [prop_pos, text_pos, struct_pos]
            .iter()
            .filter_map(|position| *position)
            .min();

        match next {
            None => {
                current.push_str(rest);
                break;
            }
            Some(position) => {
                current.push_str(&rest[..position]);
                statics.push(std::mem::take(&mut current));

                if Some(position) == prop_pos {
                    rest = &rest[position + PROP_MARKER.len()..];
                } else if Some(position) == text_pos {
                    rest = &rest[position + TEXT_MARKER.len()..];
                } else {
                    rest = &rest[position + STRUCT_MARKER.len()..];
                }
            }
        }
    }

    statics.push(current);
    statics
}

#[cfg(test)]
mod tests {
    use super::{split_on_markers, PROP_MARKER, STRUCT_MARKER, TEXT_MARKER};

    #[test]
    fn split_on_markers_preserves_segment_order() {
        let html = format!(
            "<div>{}middle{}tail{}</div>",
            PROP_MARKER, TEXT_MARKER, STRUCT_MARKER
        );

        assert_eq!(
            split_on_markers(&html),
            vec![
                "<div>".to_string(),
                "middle".to_string(),
                "tail".to_string(),
                "</div>".to_string()
            ]
        );
    }

    #[test]
    fn split_on_markers_handles_marker_free_html() {
        assert_eq!(
            split_on_markers("<div>plain</div>"),
            vec!["<div>plain</div>".to_string()]
        );
    }
}

pub(crate) fn process_block<'a, 'b>(
    env: Env<'a>,
    block: &'b BlockIRNode<'b>,
    ir: &'b RootIRNode<'b>,
) -> (Vec<String>, Vec<Term<'a>>) {
    let template_html: String = block
        .returns
        .iter()
        .map(|&elem_id| {
            let template_idx = ir
                .element_template_map
                .get(&elem_id)
                .copied()
                .unwrap_or(elem_id);
            ir.templates
                .get(template_idx)
                .map(|template| template.as_str())
                .unwrap_or("")
        })
        .collect();

    let mut html = template_html;
    let mut tags = parse_tag_tree(&html);
    let elem_to_tag = build_elem_to_tag(&block.returns, &block.operation, &tags);
    let mut slots: Vec<Term<'a>> = Vec::new();

    for op in &block.operation {
        if let OperationNode::SetEvent(event) = op {
            if let Some(&tag_pos) = elem_to_tag.get(&event.element) {
                let event_name = event.key.content.as_str();
                let handler = event
                    .value
                    .as_ref()
                    .map(|value| value.content.as_str())
                    .unwrap_or(event_name);
                let attr = format!(" phx-{}=\"{}\"", event_name, handler);
                inject_attr(&mut html, &mut tags, tag_pos, &attr);
            }
        }
    }

    let all_effects: Vec<_> = block
        .effect
        .iter()
        .flat_map(|effect| effect.operations.iter())
        .collect();

    let mut prop_effects = Vec::new();
    let mut text_effects = Vec::new();
    let mut html_effects = Vec::new();

    for operation in &all_effects {
        match operation {
            OperationNode::SetProp(prop) => prop_effects.push(prop),
            OperationNode::SetText(text) => text_effects.push(text),
            OperationNode::SetHtml(html_node) => html_effects.push(html_node),
            _ => {}
        }
    }

    prop_effects.sort_by_key(|prop| prop.element);

    for prop in &prop_effects {
        if let Some(&tag_pos) = elem_to_tag.get(&prop.element) {
            let attr_name = prop.prop.key.content.as_str();
            let marker = format!(" {}=\"{}\"", attr_name, PROP_MARKER);
            inject_attr(&mut html, &mut tags, tag_pos, &marker);

            let values: Vec<Term<'a>> = prop
                .prop
                .values
                .iter()
                .map(|value| encode_simple_expr(env, value))
                .collect();
            slots.push(encode_slot_values(
                env,
                atoms::set_prop().encode(env),
                values.encode(env),
            ));
        }
    }

    for op in &block.operation {
        if let OperationNode::Directive(dir) = op {
            if let Some(&tag_pos) = elem_to_tag.get(&dir.element) {
                match dir.name.as_str() {
                    "vShow" => {
                        let marker = format!(" style=\"{}\"", PROP_MARKER);
                        inject_attr(&mut html, &mut tags, tag_pos, &marker);
                        if let Some(vize_atelier_core::ExpressionNode::Simple(simple)) =
                            &dir.dir.exp
                        {
                            slots.push(encode_slot_value(env, atoms::v_show().encode(env), simple));
                        }
                    }
                    "model" => {
                        let value_marker = format!(" value=\"{}\"", PROP_MARKER);
                        inject_attr(&mut html, &mut tags, tag_pos, &value_marker);
                        if let Some(vize_atelier_core::ExpressionNode::Simple(simple)) =
                            &dir.dir.exp
                        {
                            slots.push(encode_slot_value(
                                env,
                                atoms::v_model().encode(env),
                                simple,
                            ));
                            let handler_name = format!("{}_changed", simple.content.as_str());
                            let change_attr = format!(" phx-change=\"{}\"", handler_name);
                            inject_attr(&mut html, &mut tags, tag_pos, &change_attr);
                        }
                    }
                    _ => {}
                }
            }
        }
    }

    for text in &text_effects {
        if let Some(&tag_pos) = elem_to_tag.get(&text.element) {
            replace_first_space_in_content(&mut html, &mut tags, tag_pos, TEXT_MARKER);
        }

        let values: Vec<Term<'a>> = text
            .values
            .iter()
            .map(|value| encode_simple_expr(env, value))
            .collect();
        slots.push(encode_slot_values(
            env,
            atoms::set_text().encode(env),
            values.encode(env),
        ));
    }

    for html_effect in &html_effects {
        if let Some(&tag_pos) = elem_to_tag.get(&html_effect.element) {
            replace_first_space_in_content(&mut html, &mut tags, tag_pos, TEXT_MARKER);
        }
        slots.push(encode_slot_value(
            env,
            atoms::set_html().encode(env),
            &html_effect.value,
        ));
    }

    for operation in &block.operation {
        match operation {
            OperationNode::If(if_node) => {
                if let Some(parent_id) = if_node.parent {
                    if let Some(&tag_pos) = elem_to_tag.get(&parent_id) {
                        inject_before_close(&mut html, &mut tags, tag_pos, STRUCT_MARKER);
                    }
                } else {
                    html.push_str(STRUCT_MARKER);
                }
                slots.push(encode_slot_if_split(env, if_node, ir));
            }
            OperationNode::For(for_node) => {
                if let Some(parent_id) = for_node.parent {
                    if let Some(&tag_pos) = elem_to_tag.get(&parent_id) {
                        inject_before_close(&mut html, &mut tags, tag_pos, STRUCT_MARKER);
                    }
                } else {
                    html.push_str(STRUCT_MARKER);
                }
                slots.push(encode_slot_for_split(env, for_node, ir));
            }
            OperationNode::CreateComponent(component) => {
                if let Some(parent_id) = component.parent {
                    if let Some(&tag_pos) = elem_to_tag.get(&parent_id) {
                        inject_before_close(&mut html, &mut tags, tag_pos, STRUCT_MARKER);
                    }
                } else {
                    html.push_str(STRUCT_MARKER);
                }
                slots.push(encode_slot_component(env, component));
            }
            _ => {}
        }
    }

    (split_on_markers(&html), slots)
}
