# Component Reference

Full attribute and slot reference for all phoenix_duskmoon components (v9.0.1).
Organized by category. Each entry lists the function name, key attributes
(with defaults and allowed values), and slots.

## Table of Contents

- [Action](#action)
- [Data Display](#data-display)
- [Data Entry](#data-entry)
- [Feedback](#feedback)
- [Navigation](#navigation)
- [Layout](#layout)
- [Icon](#icon)
- [CSS Art](#css-art)

---

## Action

### `dm_btn/1` — Button

Three clauses: standard, confirm dialog, noise effect.

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | nil, primary, secondary, accent, info, success, warning, error, ghost, link, outline |
| `size` | string | nil | nil, xs, sm, md, lg |
| `shape` | string | nil | nil, square, circle |
| `loading` | boolean | false | |
| `disabled` | boolean | false | |
| `noise` | boolean | false | Activates noise-effect button |
| `content` | string | "" | Button text (for noise variant) |
| `confirm` | string | "" | Confirmation message (activates dialog variant) |
| `confirm_title` | string | "" | Dialog title |
| `confirm_text` | string | "Yes" | Confirm button text |
| `cancel_text` | string | "Cancel" | Cancel button text |
| `confirm_class` | any | nil | |
| `cancel_class` | any | nil | |
| `show_cancel_action` | boolean | true | |
| `confirm_dialog_label` | string | "Confirmation" | Accessible fallback label for confirm dialog when no title is set |

Slots: `inner_block` (required), `prefix`, `suffix`, `confirm_action`

Global attrs: includes `phx-click`, `phx-target`, `phx-value-id`, `phx-disable-with`, `name`, `value`, `type`, `form`

Hook: Uses `WebComponentHook` when `phx-click` is present.

### `dm_link/1` — Link

| Attr | Type | Default | Notes |
|------|------|---------|-------|
| `navigate` | string | — | LiveView navigate |
| `patch` | string | — | LiveView patch |
| `href` | any | — | Standard href |
| `replace` | boolean | false | |
| `method` | string | "get" | |
| `csrf_token` | any | true | |

Slots: `inner_block` (required)

Global attrs: includes `download`, `hreflang`, `referrerpolicy`, `rel`, `target`, `type`, `disabled`

### `dm_dropdown/1` — Dropdown

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "bottom" | left, right, top, bottom |
| `color` | string | nil | |
| `dropdown_class` | any | nil | |

Slots: `trigger` (required, attrs: `class`), `content` (required, attrs: `class`)

### `dm_menu/1` — Menu

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `anchor` | string | nil | CSS selector |
| `placement` | string | "bottom-start" | top, bottom, left, right, top-start, top-end, bottom-start, bottom-end |
| `label` | string | nil | aria-label |

Slots: `inner_block` (required)

### `dm_menu_item/1`

| Attr | Type | Default |
|------|------|---------|
| `value` | string | nil |
| `disabled` | boolean | false |
| `icon` | string | nil |

Slots: `inner_block` (required)

### `dm_toggle_group/1` — Toggle Group

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | nil, segmented, outlined, filled, chip |
| `color` | string | nil | nil, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `vertical` | boolean | false | |
| `exclusive` | boolean | false | Radio-like single selection |
| `full` | boolean | false | Full width |
| `label` | string | nil | aria-label |

Slots: `item` (required, attrs: `active`, `disabled`, `value`, `icon`, `icon_only`, `class`, `label`)

---

## Data Display

### `dm_accordion/1`

| Attr | Type | Default |
|------|------|---------|
| `multiple` | boolean | false |
| `value` | string | nil |

Slots: `item` (required, attrs: `value` required, `header` required, `disabled`)

### `dm_avatar/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `src` | string | nil | Image URL |
| `alt` | string | nil | |
| `name` | string | nil | Generates initials |
| `placeholder_img` | any | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `shape` | string | "circle" | circle, square, rounded |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `ring` | boolean | false | |
| `ring_color` | string | nil | nil, primary, secondary, tertiary |
| `online` | boolean | false | |
| `offline` | boolean | false | |
| `img_class` | any | nil | |
| `placeholder_class` | any | nil | |

Accessibility attrs: `online_label`, `offline_label`, `default_icon_label`, `placeholder_alt`

Slots: `placeholder`

### `dm_badge/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error, ghost, neutral |
| `size` | string | "md" | xs, sm, md, lg |
| `outline` | boolean | false | |
| `soft` | boolean | false | |
| `pill` | boolean | false | |
| `dot` | boolean | false | |

Slots: `inner_block` (required)

### `dm_card/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `body_class` | any | nil | |
| `variant` | string | nil | nil, compact, side, bordered, glass |
| `shadow` | string | nil | nil, none, sm, md, lg, xl, 2xl |
| `interactive` | boolean | false | |
| `padding` | string | nil | nil, none, sm, md, lg |
| `image` | string | nil | Image URL |
| `image_alt` | string | "" | |

Slots: `title` (attrs: `id`, `class`), `action` (attrs: `id`, `class`), `inner_block`

### `dm_async_card/1`

Extends `dm_card` with: `assign` (any — AsyncResult struct), `skeleton_class`.

Slots: `inner_block` (required), `title` (attrs: `id`, `class`), `action` (attrs: `id`, `class`)

### `dm_chip/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | "filled" | filled, outlined, soft |
| `color` | string | nil | nil, primary, secondary, tertiary, success, warning, error, info |
| `size` | string | "md" | sm, md, lg |
| `deletable` | boolean | false | |
| `selected` | boolean | false | |
| `disabled` | boolean | false | |

Slots: `inner_block` (required), `icon`

### `dm_collapse/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `disabled` | boolean | false | |
| `variant` | string | nil | nil, card, bordered, ghost, divider |
| `color` | string | nil | nil, primary, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `animation` | string | nil | nil, fade, slide |
| `speed` | string | nil | nil, fast, slow |
| `nested` | boolean | false | Nested with indent and left border |

Slots: `trigger` (required), `content` (required)

### `dm_collapse_group/1`

Slots: `inner_block` (required)

### `dm_flash/1`

| Attr | Type | Default |
|------|------|---------|
| `id` | string | "flash" |
| `flash` | map | %{} |
| `title` | string | nil |
| `kind` | atom | — | Values: :info, :error |
| `autoshow` | boolean | true |
| `close` | boolean | true |
| `close_label` | string | "Close" |

Slots: `inner_block`

### `dm_flash_group/1`

| Attr | Type | Default |
|------|------|---------|
| `flash` | map | required |
| `info_title` | string | "Success!" |
| `error_title` | string | "Error!" |
| `disconnected_title` | string | "We can't find the internet" |
| `reconnecting_text` | string | "Attempting to reconnect" |

### `dm_list/1`

| Attr | Type | Default |
|------|------|---------|
| `bordered` | boolean | false |
| `compact` | boolean | false |
| `dense` | boolean | false |
| `hoverable` | boolean | false |
| `two_line` | boolean | false |
| `three_line` | boolean | false |

Slots: `item` (required, attrs: `title`, `subtitle`, `icon`, `active`, `disabled`, `interactive`, `class`), `subheader`

### `dm_markdown/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `debug` | boolean | false | |
| `content` | string | "" | Markdown content (inline) |
| `src` | string | nil | URL to fetch markdown |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | Disable mermaid diagrams |

### `dm_pagination/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `page_size` | integer | 10 | |
| `page_num` | integer | 1 | |
| `total` | integer | 0 | |
| `show_total` | boolean | false | |
| `update_event` | string | "update_current_page" | LiveView event name |
| `page_url` | any | nil | URL pattern for page links |
| `page_url_marker` | string | "{page}" | Marker to replace with page number |
| `page_link_type` | string | "patch" | patch, navigate, href |
| `el_size` | string | nil | nil, xs, sm, md, lg |
| `el_color` | string | nil | nil, primary, secondary, neutral |

Accessibility attrs: `prev_label`, `next_label`, `pagination_label`, `prev_page_label`, `next_page_label`, `ellipsis_label`, `page_button_label`

Slots: `inner_block`

### `dm_pagination_thin/1`

| Attr | Type | Default |
|------|------|---------|
| `loading` | boolean | false |
| `show_page_jumper` | boolean | false |
| `page_size` | integer | 10 |
| `page_num` | integer | 1 |
| `total` | integer | 0 |
| `show_total` | boolean | false |
| `update_event` | string | "update_current_page" |

Accessibility attrs: `prev_label`, `next_label`, `pagination_label`, `prev_page_label`, `next_page_label`, `jump_to_page_label`, `page_button_label`

### `dm_popover/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `trigger_mode` | string | "click" | click, hover, focus |
| `placement` | string | "bottom" | top, bottom, left, right, top-start, top-end, bottom-start, bottom-end, left-start, left-end, right-start, right-end |
| `offset` | integer | 8 | |
| `arrow` | boolean | true | |

Slots: `trigger` (required), `inner_block`

### `dm_progress/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "linear" | linear, circular |
| `value` | integer | 0 | |
| `max` | integer | 100 | |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `show_label` | boolean | false | |
| `inline_label` | boolean | false | Linear only |
| `striped` | boolean | false | Linear only |
| `animated` | boolean | false | Implies striped, linear only |
| `indeterminate` | boolean | false | |
| `label_class` | any | nil | |
| `progress_class` | any | nil | |
| `label_text` | string | "Progress" | |
| `complete_text` | string | "Complete" | |

### `dm_skeleton/1` — Base Skeleton

| Attr | Type | Default |
|------|------|---------|
| `variant` | string | nil | circle, square, text, avatar |
| `size` | string | nil | xs, sm, md, lg, xl |
| `animation` | string | nil | wave, bounce |
| `width` | string | nil | e.g., "w-32", "w-full" |
| `height` | string | nil | e.g., "h-4", "h-8" |
| `loading_label` | string | "Loading" | |

### `dm_skeleton_text/1`

| Attr | Type | Default |
|------|------|---------|
| `lines` | integer | 3 |
| `line_height` | string | "h-4" |
| `last_line_width` | string | "w-full" |
| `animation` | string | nil |
| `loading_label` | string | "Loading content" |

### `dm_skeleton_avatar/1`

| Attr | Type | Default |
|------|------|---------|
| `size` | string | "md" |
| `animation` | string | nil |
| `loading_label` | string | "Loading avatar" |

### `dm_skeleton_card/1`

| Attr | Type | Default |
|------|------|---------|
| `show_avatar` | boolean | false |
| `avatar_size` | string | "md" |
| `lines` | integer | 3 |
| `show_action` | boolean | false |
| `animation` | string | nil |
| `loading_label` | string | "Loading card" |

### `dm_skeleton_table/1`

| Attr | Type | Default |
|------|------|---------|
| `rows` | integer | 5 |
| `columns` | integer | 4 |
| `show_header` | boolean | true |
| `animation` | string | nil |
| `loading_label` | string | "Loading table" |

### `dm_skeleton_list/1`

| Attr | Type | Default |
|------|------|---------|
| `items` | integer | 5 |
| `show_avatar` | boolean | false |
| `avatar_size` | string | "sm" |
| `lines_per_item` | integer | 1 |
| `animation` | string | nil |
| `loading_label` | string | "Loading list" |

### `dm_skeleton_form/1`

| Attr | Type | Default |
|------|------|---------|
| `fields` | integer | 4 |
| `field_types` | list | nil | List of: text, select, textarea, checkbox |
| `show_submit` | boolean | true |
| `animation` | string | nil |
| `loading_label` | string | "Loading form" |

### `dm_skeleton_comment/1`

| Attr | Type | Default |
|------|------|---------|
| `show_replies` | integer | 0 |
| `animation` | string | nil |
| `loading_label` | string | "Loading comments" |

### `dm_stat/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `title` | string | required | |
| `value` | string | required | |
| `description` | string | nil | |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | "md" | sm, md, lg |

Slots: `icon`

### `dm_table/1`

| Attr | Type | Default |
|------|------|---------|
| `border` | boolean | false |
| `zebra` | boolean | false |
| `hover` | boolean | false |
| `compact` | boolean | false |
| `data` | list | [] |
| `stream` | boolean | false |

Slots: `caption` (attrs: `id`, `class`), `col` (attrs: `label`, `label_class`, `class`), `expand` (attrs: `id`, `class`)

### `dm_timeline/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `layout` | string | nil | nil, alternate, right, horizontal |

Slots: `item` (required, attrs: `title`, `time`, `icon`, `color`, `completed`, `active`, `loading`, `class`)

### `dm_tooltip/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `content` | string | required | |
| `position` | string | "top" | top, bottom, left, right |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `open` | boolean | false | |

Slots: `inner_block` (required)

---

## Data Entry

### `dm_form/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `for` | any | nil | Phoenix.HTML.Form struct |
| `as` | any | nil | |
| `actions_align` | string | nil | nil, between, right, center |

Slots: `inner_block` (required), `actions`

Global attrs: passed through to `<form>`.

### `dm_label/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `for` | string | nil | |
| `required` | boolean | false | |
| `optional` | boolean | false | |
| `size` | string | nil | nil, sm, lg |

Slots: `inner_block` (required)

### `dm_error/1`

Slots: `inner_block` (required)

### `dm_alert/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | nil, info, success, warning, error |
| `icon` | string | nil | |
| `title` | string | nil | |
| `dismissible` | boolean | false | |
| `compact` | boolean | false | |
| `filled` | boolean | false | |
| `outlined` | boolean | false | |

Slots: `inner_block` (required)

### `dm_fieldset/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `legend` | string | nil | |
| `variant` | string | nil | nil, filled, borderless, card |

Slots: `inner_block` (required)

### `dm_form_grid/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `cols` | integer | 2 | 2, 3, 4 |

Slots: `inner_block` (required)

### `dm_form_section/1`

| Attr | Type | Default |
|------|------|---------|
| `title` | string | nil |
| `description` | string | nil |

Slots: `inner_block` (required)

### `dm_form_divider/1`

| Attr | Type | Default |
|------|------|---------|
| `text` | string | nil |

### `dm_form_counter/1`

| Attr | Type | Default |
|------|------|---------|
| `current` | integer | required |
| `max` | integer | required |
| `error` | boolean | false |

### `dm_form_row/1`, `dm_form_inline/1`, `dm_form_hint/1`

Layout wrappers. Slots: `inner_block` (required).

### `dm_input/1`

Universal input with 30+ types. Key attributes:

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "text" | checkbox, color, date, datetime-local, email, file, hidden, month, number, password, range, rating, rich-text, search, select, slider, switch, tel, text, textarea, time, url, week, ... |
| `field` | Phoenix.HTML.FormField | nil | |
| `label` | string | nil | |
| `value` | any | nil | |
| `name` | string | nil | |
| `color` | string | nil | |
| `size` | string | nil | |
| `variant` | string | nil | ghost, filled, bordered |
| `classic` | boolean | false | Use classic HTML inputs |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `state` | string | nil | nil, success, warning |
| `options` | list | [] | For select type |
| `prompt` | string | nil | For select type |
| `multiple` | boolean | false | For select type |
| `horizontal` | boolean | false | |
| `checked` | boolean | false | For checkbox type |
| `suggestions` | list | nil | Datalist suggestions |
| `swatches` | list | nil | Color swatches |

Accessibility attrs: `drop_text`, `choose_files_text`, `add_tag_placeholder`, `password_hint_weak`, `password_hint_medium`, `password_hint_strong`, `password_strength_label`, `strength_label_weak`, `strength_label_medium`, `strength_label_strong`, `remove_file_label`, `toolbar_label`, `bold_label`, `italic_label`, `underline_label`, `bulleted_list_label`, `numbered_list_label`, `insert_link_label`, `toggle_password_label`, `rating_group_label`, `rating_item_label`, `remove_tag_label`, `select_color_label`, `tags_group_label`

### `dm_compact_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "text" | color, date, datetime-local, email, file, month, number, password, search, select, tel, text, time, url, week |
| `field` | FormField | nil | |
| `label` | string | nil | |
| `size` | string | nil | xs, sm, md, lg |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `variant` | string | nil | ghost, filled, bordered |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `state` | string | nil | nil, success, warning |
| `disabled` | boolean | false | |
| `options` | list | [] | |
| `prompt` | string | nil | |
| `multiple` | boolean | false | |
| `horizontal` | boolean | false | |

Slots: `inner_block` (optional)

### `dm_checkbox/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `checked` | boolean | false | |
| `size` | string | nil | xs, sm, md, lg, xl |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `indeterminate` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `multiple` | boolean | false | |
| `label_class` | any | nil | |
| `checkbox_class` | any | nil | |

### `dm_radio/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `checked` | boolean | false | |
| `size` | string | nil | xs, sm, md, lg, xl |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `label_class` | any | nil | |
| `radio_class` | any | nil | |

### `dm_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `options` | list | nil | |
| `prompt` | string | nil | |
| `value` | any | nil | |
| `size` | string | nil | xs, sm, md, lg |
| `variant` | string | nil | ghost, filled, bordered |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `multiple` | boolean | false | |
| `label_class` | any | nil | |
| `select_class` | any | nil | |

Slots: `inner_block` (optional)

### `dm_switch/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `checked` | boolean | false | |
| `size` | string | nil | xs, sm, md, lg, xl |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `multiple` | boolean | false | |
| `label_class` | any | nil | |
| `switch_class` | any | nil | |

### `dm_slider/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `min` | integer | 0 | |
| `max` | integer | 100 | |
| `step` | integer | 1 | |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | nil | xs, sm, md, lg |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `vertical` | boolean | false | |
| `show_value` | boolean | true | |
| `label_class` | any | nil | |
| `slider_class` | any | nil | |

### `dm_textarea/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `placeholder` | string | nil | |
| `value` | any | nil | |
| `rows` | integer | 3 | |
| `cols` | integer | nil | |
| `size` | string | nil | xs, sm, md, lg |
| `variant` | string | nil | ghost, filled, bordered |
| `color` | string | nil | primary, secondary, tertiary, accent, info, success, warning, error |
| `resize` | string | nil | none, vertical, horizontal, both |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |
| `readonly` | boolean | false | |
| `required` | boolean | false | |
| `maxlength` | integer | nil | |
| `label_class` | any | nil | |
| `textarea_class` | any | nil | |

### `dm_rating/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `value` | integer | 0 | |
| `max` | integer | 5 | |
| `size` | string | nil | nil, xs, sm, lg, xl |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `readonly` | boolean | false | |
| `disabled` | boolean | false | |
| `animated` | boolean | false | |
| `compact` | boolean | false | |
| `icon` | string | "star" | |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `helper` | string | nil | |
| `group_label` | string | nil | |
| `item_label` | string | nil | |

### `dm_segment_control/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `variant` | string | nil | nil, outlined, ghost |
| `full` | boolean | false | |
| `icon_only` | boolean | false | |
| `multi` | boolean | false | |
| `label` | string | nil | aria-label |

Slots: `item` (required, attrs: `active`, `disabled`, `icon`, `value`, `class`, `label`)

### `dm_multi_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `options` | list | [] | |
| `selected` | list | [] | |
| `placeholder` | string | nil | |
| `open` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `loading` | boolean | false | |
| `searchable` | boolean | false | |
| `show_actions` | boolean | false | |
| `show_counter` | boolean | false | |
| `clearable` | boolean | false | |
| `tag_variant` | string | nil | nil, primary, outlined |
| `max_tags` | integer | nil | |
| `helper` | string | nil | |

Accessibility attrs: `empty_text`, `search_placeholder`, `search_label`, `clear_label`, `select_all_text`, `deselect_all_text`, `overflow_text`, `remove_tag_label`

### `dm_autocomplete/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `options` | list | [] | |
| `value` | any | nil | |
| `multiple` | boolean | false | |
| `disabled` | boolean | false | |
| `clearable` | boolean | false | |
| `placeholder` | string | nil | |
| `loading` | boolean | false | |
| `no_results_text` | string | nil | |
| `size` | string | nil | sm, md, lg |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `helper` | string | nil | |

### `dm_otp_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `length` | integer | 6 | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `variant` | string | nil | nil, filled, underline |
| `gap` | string | nil | nil, compact, wide |
| `masked` | boolean | false | |
| `disabled` | boolean | false | |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `success` | boolean | false | |
| `label` | string | nil | |
| `label_class` | any | nil | |
| `helper` | string | nil | |
| `error_message` | string | nil | |
| `group_label` | string | nil | |
| `digit_label` | string | nil | |

### `dm_pin_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `length` | integer | 4 | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `variant` | string | nil | nil, filled |
| `shape` | string | nil | nil, circle |
| `compact` | boolean | false | |
| `dots` | boolean | false | |
| `visible` | boolean | true | |
| `disabled` | boolean | false | |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `success` | boolean | false | |
| `label` | string | nil | |
| `label_class` | any | nil | |
| `helper` | string | nil | |
| `error_message` | string | nil | |
| `group_label` | string | nil | |
| `digit_label` | string | nil | |

### `dm_file_upload/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `accept` | string | nil | |
| `multiple` | boolean | false | |
| `disabled` | boolean | false | |
| `max_size` | integer | nil | |
| `max_files` | integer | nil | |
| `show_preview` | boolean | false | |
| `compact` | boolean | false | |
| `size` | string | nil | sm, md, lg |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `helper` | string | nil | |

Slots: `inner_block` (custom dropzone content)

### `dm_time_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `value` | any | nil | |
| `disabled` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `variant` | string | nil | nil, filled |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `helper` | string | nil | |
| `show_seconds` | boolean | false | |
| `show_period` | boolean | false | |
| `label` | string | nil | |

Accessibility attrs: `am_label`, `pm_label`, `hours_label`, `minutes_label`, `seconds_label`

### `dm_cascader/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `options` | list | [] | |
| `selected_path` | list | [] | |
| `placeholder` | string | nil | |
| `size` | string | nil | sm, md, lg |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `loading` | boolean | false | |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `separator` | string | nil | |
| `multiple` | boolean | false | |
| `change_on_select` | boolean | false | |
| `expand_trigger` | string | "click" | click, hover |
| `helper` | string | nil | |

### `dm_tree_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `options` | list | [] | |
| `selected` | list | [] | |
| `expanded` | list | [] | |
| `placeholder` | string | nil | |
| `open` | boolean | false | |
| `multiple` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `error` | boolean | false | |
| `errors` | list | [] | |
| `disabled` | boolean | false | |
| `loading` | boolean | false | |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `show_path` | boolean | false | |
| `helper` | string | nil | |

Accessibility attrs: `empty_text`, `search_placeholder`, `search_label`, `clear_label`, `toggle_node_label`, `remove_tag_label`

### `dm_markdown_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `field` | FormField | nil | |
| `label` | string | nil | |
| `value` | any | nil | |
| `placeholder` | string | nil | |
| `disabled` | boolean | false | |
| `readonly` | boolean | false | |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |

---

## Feedback

### `dm_modal/1` — Dialog

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `hide_close` | boolean | false | |
| `position` | string | nil | nil, top, middle, bottom |
| `backdrop` | boolean | false | |
| `size` | string | nil | nil, xs, sm, md, lg, xl |
| `responsive` | boolean | false | |
| `no_backdrop` | boolean | false | |
| `close_label` | string | "Close" | |
| `dialog_label` | string | "Dialog" | |

Slots: `trigger` (attrs: `class`), `title` (attrs: `class`), `body` (required, attrs: `class`), `footer` (attrs: `class`)

### `dm_loading_spinner/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `variant` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `text` | string | nil | |
| `loading_label` | string | "Loading" | |

### `dm_loading_ex/1`

| Attr | Type | Default |
|------|------|---------|
| `item_count` | integer | 88 |
| `speed` | string | "4s" |
| `size` | integer | 21 |
| `loading_label` | string | "Loading" |

### `dm_toast_container/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "top-right" | top-right, top-left, top-center, bottom-right, bottom-left, bottom-center |

Slots: `inner_block` (required)

### `dm_toast/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error |
| `title` | string | nil | |
| `icon` | string | nil | |
| `filled` | boolean | false | |
| `open` | boolean | false | |
| `show_close` | boolean | false | |
| `close_label` | string | "Close" | |

Slots: `inner_block`

### `dm_snackbar/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error, primary, secondary, tertiary, dark |
| `open` | boolean | false | |
| `multiline` | boolean | false | |
| `position` | string | nil | nil, bottom, bottom-left, bottom-right, top, top-left, top-right |
| `close_label` | string | "Close" | |

Slots: `message` (required), `action`, `close`

### `dm_snackbar_container/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "bottom" | bottom, bottom-left, bottom-right, top, top-left, top-right |

Slots: `inner_block` (required)

---

## Navigation

### `dm_actionbar/1`

| Attr | Type | Default |
|------|------|---------|
| `left_class` | any | nil |
| `right_class` | any | nil |
| `toolbar_label` | string | "Actions" |

Slots: `left` (attrs: `id`, `class`), `right` (attrs: `id`, `class`)

### `dm_appbar/1`

| Attr | Type | Default |
|------|------|---------|
| `title` | string | "" |
| `title_to` | string | nil |
| `sticky` | boolean | true |
| `nav_label` | string | "Main navigation" |

Slots: `menu` (attrs: `class`, `to`, `active`), `logo`, `user_profile`

### `dm_simple_appbar/1`

| Attr | Type | Default |
|------|------|---------|
| `title` | string | "" |
| `toggle_menu_label` | string | "Toggle mobile menu" |
| `nav_label` | string | "Main navigation" |

Slots: `menu` (attrs: `class`, `to`, `active`), `logo`, `user_profile`

### `dm_bottom_nav/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `value` | string | nil | |
| `color` | string | "primary" | primary, secondary, success, warning, error |
| `position` | string | "fixed" | fixed, static, sticky |
| `items` | list | required | Each: `:value`, `:label`, `:icon`, `:disabled`, `:href` |

### `dm_breadcrumb/1`

| Attr | Type | Default |
|------|------|---------|
| `separator` | string | nil |
| `nav_label` | string | "Breadcrumb" |

Slots: `crumb` (required, attrs: `id`, `class`, `to`)

### `dm_left_menu/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `active` | string | "" | |
| `nav_label` | string | "Navigation menu" | |

Slots: `title` (attrs: `class`), `menu`

### `dm_left_menu_group/1`

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | true |
| `active` | string | "" |

Slots: `title` (required, attrs: `class`), `menu` (attrs: `id`, `class`, `to`, `disabled`)

### `dm_navbar/1`

| Attr | Type | Default |
|------|------|---------|
| `start_class` | any | nil |
| `center_class` | any | nil |
| `end_class` | any | nil |
| `nav_label` | string | "Main navigation" |

Slots: `start_part`, `center_part`, `end_part`

### `dm_nested_menu/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, xs, sm, lg |
| `bordered` | boolean | false | |
| `compact` | boolean | false | |
| `nav_label` | string | "Navigation menu" | |

Slots: `title`, `item` (attrs: `to`, `active`, `disabled`), `group` (attrs: `title` required, `open`)

### `dm_nested_menu_item/1`

| Attr | Type | Default |
|------|------|---------|
| `to` | string | nil |
| `active` | boolean | false |
| `disabled` | boolean | false |

Slots: `inner_block` (required)

### `dm_page_footer/1`

| Attr | Type | Default |
|------|------|---------|
| `label` | string | nil |

Slots: `section` (attrs: `class`, `title`, `title_class`, `body_class`), `copyright` (attrs: `class`, `title`, `title_class`, `body_class`), `inner_block`

### `dm_page_header/1`

Requires `PageHeader` hook.

| Attr | Type | Default |
|------|------|---------|
| `id` | string | "wc-page-header-header" |
| `nav_id` | string | "wc-page-header-nav" |
| `nav_class` | any | nil |
| `nav_label` | string | "Site navigation" |
| `toggle_menu_label` | string | "Toggle mobile menu" |

Slots: `menu` (attrs: `class`, `to`, `active`), `user_profile` (attrs: `class`), `inner_block`

### `dm_stepper/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `vertical` | boolean | false | |
| `variant` | string | nil | nil, dots, alt-labels, icons |
| `color` | string | nil | nil, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `clickable` | boolean | false | |

Slots: `step` (required, attrs: `label` required, `description`, `active`, `completed`, `error`, `disabled`, `optional`)

### `dm_steps/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `current` | integer | 0 | |
| `orientation` | string | "horizontal" | horizontal, vertical |
| `color` | string | "primary" | primary, secondary, tertiary, accent, success, warning, error, info |
| `clickable` | boolean | false | |
| `steps` | list | required | Each: `:label`, `:description`, `:icon` |

### `dm_tab/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `header_class` | any | nil | |
| `orientation` | string | "horizontal" | horizontal, vertical |
| `active_tab_index` | integer | 0 | |
| `active_tab_name` | string | "" | |
| `variant` | string | nil | nil, lifted, bordered, boxed |
| `size` | string | nil | nil, xs, sm, md, lg |
| `content_class` | any | nil | |

Slots: `tab` (attrs: `id`, `class`, `name`, `phx_click`), `tab_content` (attrs: `id`, `class`, `name`)

---

## Layout

### `dm_bottom_sheet/1`

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | false |
| `modal` | boolean | false |
| `persistent` | boolean | false |
| `snap_points` | string | nil |
| `label` | string | nil |

Slots: `header`, `inner_block`

### `dm_divider/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `orientation` | string | "horizontal" | horizontal, vertical |
| `variant` | string | "base" | base, primary, secondary, light, dark |
| `style` | string | "solid" | solid, dashed, dotted |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `gradient` | boolean | false | |
| `inset` | string | nil | nil, left, right, both |
| `text_position` | string | nil | nil, left, right |

Slots: `inner_block`

### `dm_drawer/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `position` | string | "left" | left, right |
| `modal` | boolean | false | |
| `width` | string | nil | |
| `label` | string | nil | |

Slots: `header`, `inner_block` (required), `footer`

### `dm_theme_switcher/1`

Requires `ThemeSwitcher` hook.

| Attr | Type | Default |
|------|------|---------|
| `theme` | string | "" |
| `select_theme_label` | string | "Select theme" |
| `button_text` | string | "Theme" |
| `auto_label` | string | "Auto" |
| `light_label` | string | "Sunshine" |
| `dark_label` | string | "Moonlight" |

---

## Icon

### `dm_mdi/1` — Material Design Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required |
| `color` | string | "currentcolor" |

### `dm_bsi/1` — Bootstrap Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required |
| `color` | string | "currentcolor" |

---

## CSS Art

All art components require `id` (required string) and accept `class` + `rest` global attrs.
Import via `use PhoenixDuskmoon.ArtComponent`.

### `dm_art_atom/1`
Animated atom. Attrs: `id` (required), `class`, `rest`.

### `dm_art_cat_stargazer/1`
Cat stargazer scene. Attrs: `id` (required), `class`, `rest`.

### `dm_art_circular_gallery/1`
Circular gallery. Attrs: `id` (required), `class`, `rest`.

### `dm_art_color_spin/1`
Color spin effect. Attrs: `id` (required), `class`, `rest`.

### `dm_art_eclipse/1`
Animated eclipse. Attrs: `id` (required), `class`, `rest`.

### `dm_art_flower_animation/1`
Flower animation. Attrs: `id` (required), `class`, `rest`.

### `dm_art_gemini_input/1`
Gemini-style input. Attrs: `id` (required), `class`, `size` (nil, sm, md, lg), `placeholder`, `rest`.

### `dm_art_moon/1`
Moon scene. Attrs: `id` (required), `class`, `rest`.

### `dm_art_mountain/1`
Mountain landscape. Attrs: `id` (required), `class`, `rest`.

### `dm_art_plasma_ball/1`
Interactive plasma ball. Attrs: `id` (required), `class`, `rest` (includes `no-base`).

### `dm_art_snow/1`
Falling snowflakes. Attrs: `id` (required), `class`, `rest` (includes `unicode`, `fall`).

### `dm_art_sun/1`
Sun scene. Attrs: `id` (required), `class`, `rest`.

### `dm_art_synthwave_starfield/1`
Synthwave starfield. Attrs: `id` (required), `class`, `rest`.
