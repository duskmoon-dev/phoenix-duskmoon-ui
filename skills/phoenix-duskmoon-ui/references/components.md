# Component Reference

Full attribute and slot reference for all phoenix_duskmoon components (v9.4.0).
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
| `confirm_dialog_label` | string | "Confirmation" | Accessible fallback label |

Slots: `inner_block` (required), `prefix`, `suffix`, `confirm_action`

Global attrs: includes `phx-click`, `phx-target`, `phx-value-id`, `phx-disable-with`, `name`, `value`, `type`, `form`

Hook: Uses `WebComponentHook` when `phx-click` is present.

### `dm_link/1` — Link

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `navigate` | string | | LiveView page navigation |
| `patch` | string | | LiveView patch navigation |
| `href` | any | | Traditional browser navigation |
| `replace` | boolean | false | Replace browser history |
| `method` | string | "get" | HTTP method |
| `csrf_token` | any | true | CSRF token for non-get |

Slots: `inner_block` (required)

Global attrs: includes `download`, `hreflang`, `referrerpolicy`, `rel`, `target`, `type`, `disabled`

### `dm_dropdown/1` — Dropdown

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "bottom" | left, right, top, bottom |
| `color` | string | nil | primary, secondary, tertiary |
| `dropdown_class` | any | nil | CSS classes on the popover panel |

Slots: `trigger` (required, attrs: `class`), `content` (required, attrs: `class`)

### `dm_menu/1` + `dm_menu_item/1` — Menu

**dm_menu:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `anchor` | string | nil | CSS selector of trigger |
| `placement` | string | "bottom-start" | top, bottom, left, right, top-start, top-end, bottom-start, bottom-end |
| `label` | string | nil | aria-label |

Slots: `inner_block` (required)

**dm_menu_item:**

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
| `exclusive` | boolean | false | Radio-like single select |
| `full` | boolean | false | Full width |
| `label` | string | nil | aria-label |

Slots: `item` (required) — attrs: `active`, `disabled`, `value`, `icon`, `icon_only`, `class`, `label`

---

## Data Display

### `dm_accordion/1` — Accordion

| Attr | Type | Default |
|------|------|---------|
| `multiple` | boolean | false |
| `value` | string | nil |

Slots: `item` (required) — attrs: `value` (required), `header` (required), `disabled`

### `dm_avatar/1` — Avatar

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `src` | string | nil | Image URL |
| `alt` | string | nil | |
| `name` | string | nil | For initials |
| `placeholder_img` | any | nil | placeholder image URL or `true` for initials |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `shape` | string | "circle" | circle, square, rounded |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `ring` | boolean | false | |
| `ring_color` | string | nil | nil, primary, secondary, tertiary |
| `online` | boolean | false | |
| `offline` | boolean | false | |
| `img_class` | any | nil | additional CSS for the image |
| `placeholder_class` | any | nil | additional CSS for the placeholder |
| `online_label` | string | "Online" | accessible label |
| `offline_label` | string | "Offline" | accessible label |
| `default_icon_label` | string | "User" | accessible label for default icon |
| `placeholder_alt` | string | "Placeholder" | alt text for placeholder image |

Slots: `placeholder`

### `dm_badge/1` — Badge

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error, ghost, neutral |
| `size` | string | "md" | xs, sm, md, lg |
| `outline` | boolean | false | |
| `soft` | boolean | false | |
| `pill` | boolean | false | |
| `dot` | boolean | false | |

Slots: `inner_block` (required)

### `dm_card/1` — Card

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | nil, compact, side, bordered, glass |
| `shadow` | string | nil | nil, none, sm, md, lg, xl, 2xl |
| `interactive` | boolean | false | |
| `padding` | string | nil | nil, none, sm, md, lg |
| `image` | string | nil | |
| `image_alt` | string | "" | |
| `body_class` | any | nil | |

Slots: `title` (attrs: `id`, `class`), `action` (attrs: `id`, `class`), `inner_block`

### `dm_async_card/1` — Async Card

Same as `dm_card` plus:

| Attr | Type | Default |
|------|------|---------|
| `assign` | any | nil | Phoenix.LiveView.AsyncResult |
| `skeleton_class` | any | nil | |

### `dm_chat/1` — Chat Message

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | any | nil | |
| `align` | string | "start" | start, end |
| `color` | string | nil | nil, primary, secondary, tertiary, info, success, warning, error |
| `size` | string | nil | nil, xs, sm, md, lg |
| `variant` | string | nil | nil, tonal, filled |
| `streaming` | boolean | false | |
| `avatar` | string | nil | avatar text |
| `author` | string | nil | message author |
| `time` | string | nil | timestamp |
| `status` | string | nil | delivery status |
| `actions` | string | nil | comma-separated quick action labels |
| `content` | string | nil | markdown message content |

Global attrs: includes `duskmoon-send-quick-action`, `duskmoon-receive`

Slots: `inner_block`, `avatar_slot`, `header`, `footer`, `actions_slot`

Hook: Uses `WebComponentHook` when chat event attrs are present.

### `dm_chat_bubble/1` — Chat Bubble

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | any | nil | |
| `align` | string | "start" | start, end |
| `color` | string | nil | nil, primary, secondary, tertiary, info, success, warning, error |
| `size` | string | nil | nil, xs, sm, md, lg |
| `variant` | string | nil | nil, tonal, filled |
| `streaming` | boolean | false | |
| `content` | string | nil | markdown bubble content |

Slots: `inner_block`

### `dm_chat_input/1` — Chat Input

| Attr | Type | Default |
|------|------|---------|
| `id` | any | nil |
| `name` | any | nil |
| `value` | any | nil |
| `field` | Phoenix.HTML.FormField | nil |
| `placeholder` | string | nil |
| `disabled` | boolean | false |
| `readonly` | boolean | false |
| `send_label` | string | "Send" |
| `clear_on_send` | boolean | false |

Global attrs: includes `duskmoon-send-send`, `duskmoon-receive`, `duskmoon-receive-reset`

Hook: Uses `WebComponentHook` when chat event attrs are present.

### `dm_chat_reasoning/1` — Chat Reasoning

| Attr | Type | Default |
|------|------|---------|
| `id` | any | nil |
| `summary` | string | "Reasoning" |
| `open` | boolean | false |

Slots: `inner_block`, `summary_slot`, `tool`, `tools`

### `dm_chat_tool/1` — Chat Tool

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | any | nil | |
| `name` | string | nil | |
| `status` | string | "pending" | pending, running, success, error |
| `open` | boolean | false | |

Slots: `inner_block`, `name_slot`, `call`, `result`

### `dm_chat_typing/1` — Chat Typing

| Attr | Type | Default |
|------|------|---------|
| `id` | any | nil |

### `dm_chip/1` — Chip

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | "filled" | filled, outlined, soft |
| `color` | string | nil | nil, primary, secondary, tertiary, success, warning, error, info |
| `size` | string | "md" | sm, md, lg |
| `deletable` | boolean | false | |
| `selected` | boolean | false | |
| `disabled` | boolean | false | |

Slots: `inner_block` (required), `icon`

### `dm_collapse/1` + `dm_collapse_group/1` — Collapse

**dm_collapse:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `disabled` | boolean | false | |
| `variant` | string | nil | nil, card, bordered, ghost, divider |
| `color` | string | nil | nil, primary, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `animation` | string | nil | nil, fade, slide |
| `speed` | string | nil | nil, fast, slow |
| `nested` | boolean | false | |

Slots: `trigger` (required), `content` (required)

### `dm_flash/1` + `dm_flash_group/1` — Flash

**dm_flash:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | string | "flash" | |
| `flash` | map | %{} | |
| `title` | string | nil | |
| `kind` | atom | | :info, :error |
| `autoshow` | boolean | true | |
| `close` | boolean | true | |

Slots: `inner_block`

**dm_flash_group:** `flash` (map, required), `info_title`, `error_title`, `disconnected_title`, `reconnecting_text`

### `dm_list/1` — List

| Attr | Type | Default |
|------|------|---------|
| `bordered` | boolean | false |
| `compact` | boolean | false |
| `dense` | boolean | false |
| `hoverable` | boolean | false |
| `two_line` | boolean | false |
| `three_line` | boolean | false |

Slots: `item` (required) — attrs: `title`, `subtitle`, `icon`, `active`, `disabled`, `interactive`, `class`; `subheader`

### `dm_markdown/1` — Markdown

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `content` | string | "" | Inline markdown |
| `src` | string | nil | URL to fetch |
| `debug` | boolean | false | |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |

### `dm_pagination/1` — Pagination

| Attr | Type | Default |
|------|------|---------|
| `page_size` | integer | 10 |
| `page_num` | integer | 1 |
| `total` | integer | 0 |
| `show_total` | boolean | false |
| `update_event` | string | "update_current_page" |
| `page_url` | any | nil |
| `page_link_type` | string | "patch" |
| `el_size` | string | nil |
| `el_color` | string | nil |

### `dm_pagination_thin/1` — Thin Pagination

Same core attrs as `dm_pagination` plus `loading`, `show_page_jumper`.

### `dm_popover/1` — Popover

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `trigger_mode` | string | "click" | click, hover, focus |
| `placement` | string | "bottom" | top, bottom, left, right, *-start, *-end |
| `offset` | integer | 8 | |
| `arrow` | boolean | true | |

Slots: `trigger` (required), `inner_block`

### `dm_progress/1` — Progress

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "linear" | linear, circular |
| `value` | integer | 0 | |
| `max` | integer | 100 | |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `show_label` | boolean | false | |
| `inline_label` | boolean | false | |
| `striped` | boolean | false | |
| `animated` | boolean | false | |
| `indeterminate` | boolean | false | |

### `dm_skeleton_*` — Skeleton

8 variants: `dm_skeleton`, `dm_skeleton_text`, `dm_skeleton_avatar`, `dm_skeleton_card`, `dm_skeleton_table`, `dm_skeleton_list`, `dm_skeleton_form`, `dm_skeleton_comment`. All share `animation` (nil, "wave", "bounce"). See source for variant-specific attrs.

### `dm_stat/1` — Stat

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `title` | string | required | |
| `value` | string | required | |
| `description` | string | nil | |
| `color` | string | nil | nil, primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | "md" | sm, md, lg |

Slots: `icon`

### `dm_table/1` — Table

| Attr | Type | Default |
|------|------|---------|
| `border` | boolean | false |
| `zebra` | boolean | false |
| `hover` | boolean | false |
| `compact` | boolean | false |
| `data` | list | [] |
| `stream` | boolean | false |

Slots: `caption` (attrs: `id`, `class`), `col` (attrs: `label`, `label_class`, `class`), `expand` (attrs: `id`, `class`)

### `dm_timeline/1` — Timeline

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `layout` | string | nil | nil, alternate, right, horizontal |

Slots: `item` (required) — attrs: `title`, `time`, `icon`, `color`, `completed`, `active`, `loading`, `class`

### `dm_tooltip/1` — Tooltip

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `content` | string | required | |
| `position` | string | "top" | top, bottom, left, right |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `open` | boolean | false | |

Slots: `inner_block` (required)

---

## Data Entry

All data entry components with a `field` attr accept `Phoenix.HTML.FormField` for automatic `id`/`name`/`value` extraction.

### `dm_form/1` — Form

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `for` | any | | Phoenix form struct |
| `as` | any | | Form name prefix |
| `actions_align` | string | "between" | between, right, center |

Slots: `inner_block`, `actions`

Helper functions: `dm_label/1`, `dm_error/1`, `dm_alert/1`, `dm_fieldset/1`, `dm_form_row/1`, `dm_form_grid/1`, `dm_form_section/1`, `dm_form_divider/1`, `dm_form_inline/1`, `dm_form_hint/1`, `dm_form_counter/1`

### `dm_input/1` — Universal Input

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "text" | checkbox, color, date, datetime-local, email, file, month, number, password, search, select, tel, text, time, url, week, toggle, checkbox_group, radio_group, textarea, range_slider, color_picker, tag_input, datepicker, rating |
| `label` | string | nil | |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | | primary, secondary, etc. |
| `size` | string | | xs, sm, md, lg |
| `helper` | string | nil | |
| `errors` | list | [] | |
| `horizontal` | boolean | false | |
| `state` | string | nil | nil, success, warning |

Plus type-specific attrs (`options`, `prompt`, `multiple`, `checked`, `suggestions`, `swatches`, etc.)

### `dm_compact_input/1` — Compact Input

Same as `dm_input` but with compact layout.

### `dm_checkbox/1` — Checkbox

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `indeterminate` | boolean | false | |
| `horizontal` | boolean | false | |
| `multiple` | boolean | false | |

### `dm_radio/1` — Radio

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `horizontal` | boolean | false | |

### `dm_select/1` — Select

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | nil | |
| `prompt` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | "primary" | primary, secondary, etc. |
| `multiple` | boolean | false | |
| `horizontal` | boolean | false | |

Slots: `inner_block`

### `dm_switch/1` — Switch

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `horizontal` | boolean | false | |
| `multiple` | boolean | false | |

### `dm_slider/1` — Slider

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `label` | string | nil | |
| `min` | integer | 0 | |
| `max` | integer | 100 | |
| `step` | integer | 1 | |
| `color` | string | "primary" | primary, secondary, etc. |
| `size` | string | "md" | xs, sm, md, lg |
| `show_value` | boolean | true | |
| `vertical` | boolean | false | |

### `dm_textarea/1` — Textarea

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `rows` | integer | 3 | |
| `cols` | integer | nil | |
| `size` | string | "md" | xs, sm, md, lg |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | "primary" | primary, secondary, etc. |
| `resize` | string | "vertical" | none, vertical, horizontal, both |
| `readonly` | boolean | false | |
| `required` | boolean | false | |
| `maxlength` | integer | nil | |

### `dm_rating/1` — Rating

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `max` | integer | 5 | |
| `size` | string | nil | nil, xs, sm, lg, xl |
| `color` | string | nil | nil, primary, secondary, etc. |
| `readonly` | boolean | false | |
| `animated` | boolean | false | |
| `compact` | boolean | false | |
| `icon` | string | "star" | |

### `dm_segment_control/1` — Segment Control

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, etc. |
| `variant` | string | nil | nil, outlined, ghost |
| `full` | boolean | false | |
| `icon_only` | boolean | false | |
| `multi` | boolean | false | |

Slots: `item` (required) — attrs: `active`, `disabled`, `icon`, `value`, `class`, `label`

### `dm_multi_select/1` — Multi Select

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `selected` | list | [] | |
| `placeholder` | string | nil | |
| `open` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `searchable` | boolean | false | |
| `show_actions` | boolean | false | |
| `show_counter` | boolean | false | |
| `clearable` | boolean | false | |
| `max_tags` | integer | nil | |

### `dm_autocomplete/1` — Autocomplete

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `multiple` | boolean | false | |
| `clearable` | boolean | false | |
| `placeholder` | string | nil | |
| `loading` | boolean | false | |
| `size` | string | "md" | sm, md, lg |

### `dm_otp_input/1` — OTP Input

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 6 | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, etc. |
| `variant` | string | nil | nil, filled, underline |
| `gap` | string | nil | nil, compact, wide |
| `masked` | boolean | false | |

### `dm_pin_input/1` — PIN Input

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 4 | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, etc. |
| `variant` | string | nil | nil, filled |
| `shape` | string | nil | nil, circle |
| `compact` | boolean | false | |
| `dots` | boolean | false | |
| `visible` | boolean | true | |

### `dm_file_upload/1` — File Upload

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `accept` | string | nil | |
| `multiple` | boolean | false | |
| `max_size` | integer | nil | |
| `max_files` | integer | nil | |
| `show_preview` | boolean | false | |
| `compact` | boolean | false | |
| `size` | string | "md" | sm, md, lg |

Slots: `inner_block`

### `dm_time_input/1` — Time Input

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | nil, primary, secondary, etc. |
| `variant` | string | nil | nil, filled |
| `show_seconds` | boolean | false | |
| `show_period` | boolean | false | |

### `dm_cascader/1` — Cascader

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `selected_path` | list | [] | |
| `size` | string | "md" | sm, md, lg |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `separator` | string | " / " | |
| `multiple` | boolean | false | |
| `change_on_select` | boolean | false | |
| `expand_trigger` | string | "click" | click, hover |

### `dm_tree_select/1` — Tree Select

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `selected` | list | [] | |
| `expanded` | list | [] | |
| `multiple` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `show_path` | boolean | false | |

### `dm_markdown_input/1` — Markdown Input

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `label` | string | nil | |
| `placeholder` | string | nil | |
| `disabled` | boolean | false | |
| `readonly` | boolean | false | |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |
| `no_preview` | boolean | false | |
| `upload_url` | string | nil | |
| `max_words` | integer | nil | |
| `resize` | string | nil | nil, none, vertical, horizontal, both |
| `live_preview` | boolean | false | |
| `debounce` | integer | nil | |

Slots: `bottom` (attrs: `class`), `bottom_start` (attrs: `class`), `bottom_end` (attrs: `class`)

### `dm_code_engine/1` — Code Engine

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `language` | string | nil | elixir, python, rust, go, sql, yaml, markdown, xml, html, javascript, typescript, css, json, and more |
| `readonly` | boolean | false | |
| `theme` | string | nil | nil, duskmoon, sunshine, moonlight, one-dark |
| `wrap` | boolean | false | |
| `show_topbar` | boolean | false | |
| `show_bottombar` | boolean | false | |
| `title` | string | nil | |

Slots: `topbar` (attrs: `class`), `bottombar` (attrs: `class`)

---

## Feedback

### `dm_modal/1` — Dialog

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | any | | Required |
| `hide_close` | boolean | false | |
| `position` | string | nil | nil, top, middle, bottom |
| `backdrop` | boolean | false | |
| `size` | string | nil | nil, xs, sm, md, lg, xl |
| `responsive` | boolean | false | |
| `no_backdrop` | boolean | false | |

Slots: `trigger`, `title` (attrs: `class`), `body` (required, attrs: `class`), `footer` (attrs: `class`)

### `dm_loading_spinner/1` — Loading Spinner

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `variant` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `text` | string | nil | |

### `dm_loading_ex/1` — Elixir Loading

| Attr | Type | Default |
|------|------|---------|
| `item_count` | integer | 88 |
| `speed` | string | "4s" |
| `size` | integer | 21 |

### `dm_toast/1` + `dm_toast_container/1` — Toast

**dm_toast:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error |
| `title` | string | nil | |
| `icon` | string | nil | |
| `filled` | boolean | false | |
| `open` | boolean | false | |
| `show_close` | boolean | false | |

Slots: `inner_block`

**dm_toast_container:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "top-right" | top-right, top-left, top-center, bottom-right, bottom-left, bottom-center |

### `dm_snackbar/1` + `dm_snackbar_container/1` — Snackbar

**dm_snackbar:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error, primary, secondary, tertiary, dark |
| `open` | boolean | false | |
| `multiline` | boolean | false | |
| `position` | string | nil | nil, bottom, bottom-left, bottom-right, top, top-left, top-right |

Slots: `message` (required), `action`, `close`

---

## Navigation

### `dm_appbar/1` — Appbar

| Attr | Type | Default |
|------|------|---------|
| `title` | string | "" |
| `title_to` | string | nil |
| `sticky` | boolean | true |

Slots: `menu` (attrs: `class`, `to`, `active`), `logo`, `after_title`, `user_profile`

### `dm_simple_appbar/1` — Simple Appbar

| Attr | Type | Default |
|------|------|---------|
| `title` | string | "" |

Slots: `menu` (attrs: `class`, `to`, `active`), `logo`, `user_profile`

### `dm_actionbar/1` — Actionbar

Slots: `left` (attrs: `id`, `class`), `right` (attrs: `id`, `class`)

### `dm_bottom_nav/1` — Bottom Nav

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `value` | string | nil | |
| `color` | string | "primary" | primary, secondary, success, warning, error |
| `position` | string | "fixed" | fixed, static, sticky |
| `items` | list | required | Maps with :value, :label, :icon, :disabled, :href |

### `dm_breadcrumb/1` — Breadcrumb

| Attr | Type | Default |
|------|------|---------|
| `separator` | string | nil |

Slots: `crumb` (required) — attrs: `id`, `class`, `to`

### `dm_left_menu/1` + `dm_left_menu_group/1` — Left Menu

**dm_left_menu:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `active` | string | "" | |

Slots: `title` (attrs: `class`), `menu`

**dm_left_menu_group:**

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | true |
| `active` | string | "" |

Slots: `title` (required, attrs: `class`), `menu` (attrs: `id`, `class`, `to`, `disabled`)

### `dm_navbar/1` — Navbar

Slots: `start_part`, `center_part`, `end_part`. Attrs: `start_class`, `center_class`, `end_class`.

### `dm_nested_menu/1` + `dm_nested_menu_item/1` — Nested Menu

**dm_nested_menu:**

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, xs, sm, lg |
| `bordered` | boolean | false | |
| `compact` | boolean | false | |

Slots: `title`, `item` (attrs: `to`, `active`, `disabled`), `group` (attrs: `title` required, `open`)

### `dm_page_footer/1` — Page Footer

Slots: `section` (attrs: `class`, `title`, `title_class`, `body_class`), `copyright` (attrs: `class`, `title`, `title_class`, `body_class`), `inner_block`

### `dm_page_header/1` — Page Header

| Attr | Type | Default |
|------|------|---------|
| `id` | string | "wc-page-header-header" |
| `nav_id` | string | "wc-page-header-nav" |

Slots: `menu` (attrs: `class`, `to`, `active`), `user_profile` (attrs: `class`), `inner_block`

Hook: **PageHeader** — IntersectionObserver for scroll-based nav opacity.

### `dm_stepper/1` — Stepper

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `vertical` | boolean | false | |
| `variant` | string | nil | nil, dots, alt-labels, icons |
| `color` | string | nil | nil, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `clickable` | boolean | false | |

Slots: `step` (required) — attrs: `label` (required), `description`, `active`, `completed`, `error`, `disabled`, `optional`

### `dm_steps/1` — Steps

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `current` | integer | 0 | |
| `orientation` | string | "horizontal" | horizontal, vertical |
| `color` | string | "primary" | primary, secondary, etc. |
| `clickable` | boolean | false | |
| `steps` | list | required | Maps with :label, :description, :icon |

### `dm_tab/1` — Tab

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `active_tab_index` | integer | 0 | |
| `active_tab_name` | string | "" | |
| `variant` | string | nil | nil, lifted, bordered, boxed |
| `size` | string | nil | nil, xs, sm, md, lg |
| `orientation` | string | "horizontal" | horizontal, vertical |

Slots: `tab` (attrs: `id`, `class`, `name`, `phx_click`), `tab_content` (attrs: `id`, `class`, `name`)

---

## Layout

### `dm_bottom_sheet/1` — Bottom Sheet

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | false |
| `modal` | boolean | false |
| `persistent` | boolean | false |
| `snap_points` | string | nil |
| `label` | string | nil |

Slots: `header`, `inner_block`

### `dm_divider/1` — Divider

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

### `dm_drawer/1` — Drawer

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `position` | string | "left" | left, right |
| `modal` | boolean | false | |
| `width` | string | nil | |
| `label` | string | nil | |

Slots: `header`, `inner_block` (required), `footer`

### `dm_theme_switcher/1` — Theme Switcher

| Attr | Type | Default |
|------|------|---------|
| `theme` | string | "" |
| `button_text` | string | "Theme" |
| `auto_label` | string | "Auto" |
| `light_label` | string | "Sunshine" |
| `dark_label` | string | "Moonlight" |

Hook: **ThemeSwitcher** — localStorage persistence.

---

## Icon

### `dm_mdi/1` — Material Design Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required |
| `color` | string | "currentcolor" |

7000+ icons available via `mdi_icons/0`.

### `dm_bsi/1` — Bootstrap Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required |
| `color` | string | "currentcolor" |

2000+ icons available via `bsi_icons/0`.

---

## CSS Art

All art components: `id` (string, required), `class` (any), `rest` (global).
Import via `use PhoenixDuskmoon.ArtComponent`.

| Function | Custom Element | Extra Attrs |
|----------|---------------|-------------|
| `dm_art_atom` | el-dm-art-atom | — |
| `dm_art_cat_stargazer` | el-dm-art-cat-stargazer | — |
| `dm_art_circular_gallery` | el-dm-art-circular-gallery | — |
| `dm_art_color_spin` | el-dm-art-color-spin | — |
| `dm_art_eclipse` | el-dm-art-eclipse | — |
| `dm_art_flower_animation` | el-dm-art-flower-animation | — |
| `dm_art_gemini_input` | el-dm-art-gemini-input | `size` (nil, sm, md, lg), `placeholder` |
| `dm_art_moon` | el-dm-art-moon | — |
| `dm_art_mountain` | el-dm-art-mountain | — |
| `dm_art_plasma_ball` | el-dm-art-plasma-ball | global includes `no-base` |
| `dm_art_snow` | el-dm-art-snow | global includes `unicode`, `fall` |
| `dm_art_sun` | el-dm-art-sun | — |
| `dm_art_synthwave_starfield` | el-dm-art-synthwave-starfield | — |
