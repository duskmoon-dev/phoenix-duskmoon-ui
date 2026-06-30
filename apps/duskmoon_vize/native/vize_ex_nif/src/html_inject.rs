pub(crate) const PROP_MARKER: &str = "\x00PROP\x00";
pub(crate) const STRUCT_MARKER: &str = "\x00STRUCT\x00";
pub(crate) const TEXT_MARKER: &str = "\x00TEXT\x00";

#[derive(Debug, Clone)]
pub(crate) struct TagEntry {
    pub(crate) pos: usize,
    pub(crate) parent: Option<usize>,
    pub(crate) child_index: usize,
    pub(crate) open_start: usize,
    pub(crate) open_end: usize,
    pub(crate) close_start: Option<usize>,
}

fn is_void_element(tag: &str) -> bool {
    matches!(
        tag,
        "area"
            | "base"
            | "br"
            | "col"
            | "embed"
            | "hr"
            | "img"
            | "input"
            | "link"
            | "meta"
            | "param"
            | "source"
            | "track"
            | "wbr"
    )
}

fn skip_comment(bytes: &[u8], i: &mut usize) {
    *i += 4;
    while *i + 2 < bytes.len() {
        if bytes[*i] == b'-' && bytes[*i + 1] == b'-' && bytes[*i + 2] == b'>' {
            *i += 3;
            return;
        }
        *i += 1;
    }
    *i = bytes.len();
}

fn skip_declaration(bytes: &[u8], i: &mut usize) {
    *i += 2;
    while *i < bytes.len() && bytes[*i] != b'>' {
        *i += 1;
    }
    if *i < bytes.len() {
        *i += 1;
    }
}

pub(crate) fn parse_tag_tree(html: &str) -> Vec<TagEntry> {
    let bytes = html.as_bytes();
    let len = bytes.len();
    let mut entries: Vec<TagEntry> = Vec::new();
    let mut stack: Vec<usize> = Vec::new();
    let mut i = 0;

    while i < len {
        if bytes[i] != b'<' {
            i += 1;
            continue;
        }

        if i + 3 < len && &bytes[i..i + 4] == b"<!--" {
            skip_comment(bytes, &mut i);
            continue;
        }

        if i + 1 < len && (bytes[i + 1] == b'!' || bytes[i + 1] == b'?') {
            skip_declaration(bytes, &mut i);
            continue;
        }

        if i + 1 < len && bytes[i + 1] == b'/' {
            let start = i;
            i += 2;
            while i < len && bytes[i] != b'>' {
                i += 1;
            }
            if i < len {
                i += 1;
            }
            if let Some(top) = stack.pop() {
                entries[top].close_start = Some(start);
            }
            continue;
        }

        let open_start = i;
        i += 1;
        let name_start = i;
        while i < len && bytes[i] != b' ' && bytes[i] != b'>' && bytes[i] != b'/' {
            i += 1;
        }
        let tag_name = String::from_utf8_lossy(&bytes[name_start..i]).to_string();

        let mut self_closing = false;
        let mut quote = None;
        while i < len {
            match quote {
                Some(current_quote) if bytes[i] == current_quote => {
                    quote = None;
                }
                Some(_) => {}
                None if bytes[i] == b'"' || bytes[i] == b'\'' => {
                    quote = Some(bytes[i]);
                }
                None if bytes[i] == b'/' && i + 1 < len && bytes[i + 1] == b'>' => {
                    self_closing = true;
                }
                None if bytes[i] == b'>' => {
                    break;
                }
                None => {}
            }
            i += 1;
        }
        if i < len {
            i += 1;
        }
        let open_end = i;

        let parent = stack.last().copied();
        let child_index = if let Some(parent_pos) = parent {
            entries
                .iter()
                .filter(|entry| entry.parent == Some(parent_pos))
                .count()
        } else {
            entries
                .iter()
                .filter(|entry| entry.parent.is_none())
                .count()
        };

        let pos = entries.len();
        entries.push(TagEntry {
            pos,
            parent,
            child_index,
            open_start,
            open_end,
            close_start: None,
        });

        if !self_closing && !is_void_element(&tag_name) {
            stack.push(pos);
        }
    }

    entries
}

pub(crate) fn build_elem_to_tag(
    returns: &[usize],
    operations: &[vize_atelier_vapor::ir::OperationNode],
    tags: &[TagEntry],
) -> std::collections::HashMap<usize, usize> {
    let mut map = std::collections::HashMap::new();

    for (idx, &elem_id) in returns.iter().enumerate() {
        let root_tags: Vec<_> = tags.iter().filter(|tag| tag.parent.is_none()).collect();
        if let Some(tag) = root_tags.get(idx) {
            map.insert(elem_id, tag.pos);
        }
    }

    loop {
        let prev_size = map.len();
        for op in operations {
            match op {
                vize_atelier_vapor::ir::OperationNode::ChildRef(node) => {
                    if let Some(&parent_tag_pos) = map.get(&node.parent_id) {
                        let children: Vec<_> = tags
                            .iter()
                            .filter(|tag| tag.parent == Some(parent_tag_pos))
                            .collect();
                        if let Some(child) = children.get(node.offset) {
                            map.insert(node.child_id, child.pos);
                        }
                    }
                }
                vize_atelier_vapor::ir::OperationNode::NextRef(node) => {
                    if let Some(&prev_tag_pos) = map.get(&node.prev_id) {
                        if let Some(prev_entry) = tags.get(prev_tag_pos) {
                            let siblings: Vec<_> = tags
                                .iter()
                                .filter(|tag| tag.parent == prev_entry.parent)
                                .collect();
                            let target_idx = prev_entry.child_index + node.offset;
                            if let Some(sibling) = siblings.get(target_idx) {
                                map.insert(node.child_id, sibling.pos);
                            }
                        }
                    }
                }
                _ => {}
            }
        }
        if map.len() == prev_size {
            break;
        }
    }

    map
}

fn attr_insert_at(html: &str, entry: &TagEntry) -> usize {
    let bytes = html.as_bytes();
    if entry.open_end >= 2 && bytes[entry.open_end - 2] == b'/' {
        let slash_at = entry.open_end - 2;
        if slash_at > 0 && bytes[slash_at - 1] == b' ' {
            slash_at - 1
        } else {
            slash_at
        }
    } else {
        entry.open_end - 1
    }
}

fn shift_offset(offset: &mut usize, replaced_end: usize, delta: isize) {
    if *offset >= replaced_end {
        *offset = (*offset as isize + delta) as usize;
    }
}

pub(crate) fn replace_range(
    html: &mut String,
    tags: &mut [TagEntry],
    start: usize,
    old_len: usize,
    replacement: &str,
) {
    let replaced_end = start + old_len;
    let delta = replacement.len() as isize - old_len as isize;
    html.replace_range(start..replaced_end, replacement);

    if delta == 0 {
        return;
    }

    for entry in tags.iter_mut() {
        shift_offset(&mut entry.open_start, replaced_end, delta);
        shift_offset(&mut entry.open_end, replaced_end, delta);
        if let Some(close_start) = &mut entry.close_start {
            shift_offset(close_start, replaced_end, delta);
        }
    }
}

pub(crate) fn replace_first_space_in_content(
    html: &mut String,
    tags: &mut [TagEntry],
    tag_pos: usize,
    replacement: &str,
) -> bool {
    let Some(entry) = tags.get(tag_pos) else {
        return false;
    };

    let content_start = entry.open_end;
    let content_end = entry.close_start.unwrap_or(content_start);
    let Some(relative_pos) = html[content_start..content_end].find(' ') else {
        return false;
    };

    replace_range(html, tags, content_start + relative_pos, 1, replacement);
    true
}

pub(crate) fn inject_attr(html: &mut String, tags: &mut [TagEntry], tag_pos: usize, attr: &str) {
    if let Some(entry) = tags.get(tag_pos) {
        let insert_at = attr_insert_at(html, entry);
        replace_range(html, tags, insert_at, 0, attr);
    }
}

pub(crate) fn inject_before_close(
    html: &mut String,
    tags: &mut [TagEntry],
    tag_pos: usize,
    content: &str,
) {
    if let Some(entry) = tags.get(tag_pos) {
        let insert_at = entry.close_start.unwrap_or(entry.open_end);
        replace_range(html, tags, insert_at, 0, content);
    }
}

#[cfg(test)]
mod tests {
    use super::{inject_attr, inject_before_close, parse_tag_tree, replace_first_space_in_content};
    use proptest::prelude::*;

    #[test]
    fn parse_tag_tree_tracks_nested_and_void_elements() {
        let html = "<div><img src=\"x\"><input /><span></span></div>";
        let tags = parse_tag_tree(html);

        assert_eq!(tags.len(), 4);
        assert_eq!(tags[0].parent, None);
        assert_eq!(tags[1].parent, Some(0));
        assert_eq!(tags[2].parent, Some(0));
        assert_eq!(tags[3].parent, Some(0));
        assert_eq!(tags[1].close_start, None);
        assert_eq!(tags[2].close_start, None);
        assert_eq!(tags[3].close_start, Some(html.find("</span>").unwrap()));
        assert_eq!(tags[1].child_index, 0);
        assert_eq!(tags[2].child_index, 1);
        assert_eq!(tags[3].child_index, 2);
    }

    #[test]
    fn parse_tag_tree_ignores_angle_brackets_inside_quoted_attributes() {
        let html = r#"<div data-text=\"1 > 0\"><span data-note='a > b'></span></div>"#;
        let tags = parse_tag_tree(html);

        assert_eq!(tags.len(), 2);
        assert_eq!(tags[0].parent, None);
        assert_eq!(tags[1].parent, Some(0));
        assert_eq!(tags[1].close_start, Some(html.find("</span>").unwrap()));
    }

    #[test]
    fn parse_tag_tree_skips_comments_and_preserves_sibling_roots() {
        let html = "<div>one</div><!-- ignored --><span>two</span>";
        let tags = parse_tag_tree(html);

        assert_eq!(tags.len(), 2);
        assert_eq!(tags[0].parent, None);
        assert_eq!(tags[1].parent, None);
        assert_eq!(tags[0].child_index, 0);
        assert_eq!(tags[1].child_index, 1);
    }

    #[test]
    fn inject_helpers_keep_offsets_in_sync() {
        let mut html = String::from("<div><span></span></div>");
        let mut tags = parse_tag_tree(&html);

        inject_attr(&mut html, &mut tags, 1, " class=\"pill\"");
        inject_before_close(&mut html, &mut tags, 0, "!");

        assert_eq!(html, "<div><span class=\"pill\"></span>!</div>");
        assert_eq!(tags[0].close_start, Some(html.find("</div>").unwrap()));
        assert_eq!(tags[1].close_start, Some(html.find("</span>").unwrap()));
    }

    #[test]
    fn inject_attr_preserves_self_closing_syntax() {
        let mut html = String::from("<div><input /></div>");
        let mut tags = parse_tag_tree(&html);

        inject_attr(&mut html, &mut tags, 1, " class=\"field\"");

        assert_eq!(html, "<div><input class=\"field\" /></div>");
        assert_eq!(tags[1].close_start, None);
    }

    #[test]
    fn replace_first_space_in_content_updates_offsets_without_reparse() {
        let mut html = String::from("<div> <span>ok</span></div>");
        let mut tags = parse_tag_tree(&html);

        assert!(replace_first_space_in_content(
            &mut html, &mut tags, 0, "__TEXT__"
        ));

        assert_eq!(html, "<div>__TEXT__<span>ok</span></div>");
        assert_eq!(tags[0].close_start, Some(html.find("</div>").unwrap()));
        assert_eq!(tags[1].open_start, html.find("<span>").unwrap());
        assert_eq!(tags[1].close_start, Some(html.find("</span>").unwrap()));
    }

    proptest! {
        #[test]
        fn parse_tag_tree_handles_random_quoted_angle_brackets(
            text in "[A-Za-z0-9 ><_=/-]{0,24}",
            note in "[A-Za-z0-9 ><_=/-]{0,24}"
        ) {
            let html = format!(r#"<div data-text=\"{}\"><span data-note='{}'></span></div>"#, text, note);
            let tags = parse_tag_tree(&html);

            prop_assert_eq!(tags.len(), 2);
            prop_assert_eq!(tags[0].parent, None);
            prop_assert_eq!(tags[1].parent, Some(0));
            prop_assert_eq!(tags[1].close_start, html.find("</span>"));
        }

        #[test]
        fn inject_attr_keeps_self_closing_tags_well_formed(name in "[a-z]{1,8}") {
            let mut html = String::from("<div><input /></div>");
            let mut tags = parse_tag_tree(&html);
            let attr = format!(" {}=\"x\"", name);

            inject_attr(&mut html, &mut tags, 1, &attr);

            let misplaced_attr = format!("/ {}=", name);

            prop_assert!(html.contains("<input "));
            prop_assert!(html.contains(" />"));
            prop_assert!(!html.contains(&misplaced_attr));
            prop_assert_eq!(tags[1].close_start, None);
        }

        #[test]
        fn replace_first_space_preserves_tag_boundaries(prefix in "[A-Za-z0-9]{0,8}") {
            let mut html = format!("<div>{} <span>ok</span></div>", prefix);
            let mut tags = parse_tag_tree(&html);

            let replaced = replace_first_space_in_content(&mut html, &mut tags, 0, "__MARK__");

            prop_assert!(replaced);
            prop_assert_eq!(tags.len(), 2);
            prop_assert_eq!(tags[1].open_start, html.find("<span>").unwrap());
            prop_assert_eq!(tags[1].close_start, html.find("</span>"));
            prop_assert_eq!(tags[0].close_start, html.find("</div>"));
        }
    }
}
