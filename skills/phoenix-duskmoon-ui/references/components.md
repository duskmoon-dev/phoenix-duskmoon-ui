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
| `confirm_dialog_label` | string | "Confirmation" | |

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
| `nested` | boolean | false | |

Slots: `trigger` (required), `content` (required)

### `dm_collapse_group/1`

Slots: `inner_block` (required)

### `dm_flash/1`

| Attr | Type | Default |
|------|------|---------|
| `id` | string | "flash" |
| `flash` | map | %{} |
| `title` | string | nil |
| `kind` | atom | — | values: :info, :error |
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
| `content` | string | "" | Markdown text |
| `src` | string | nil | URL to fetch |
| `debug` | boolean | false | |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |

### `dm_pagination/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `page_size` | integer | 10 | |
| `page_num` | integer | 1 | |
| `total` | integer | 0 | |
| `show_total` | boolean | false | |
| `update_event` | string | "update_current_page" | |
| `page_url` | any | nil | URL template |
| `page_url_marker` | string | "{page}" | |
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
| `placement` | string | "bottom" | top, bottom, left, right + -start/-end |
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
| `inline_label` | boolean | false | |
| `striped` | boolean | false | |
| `animated` | boolean | false | |
| `indeterminate` | boolean | false | |
| `label_class` | any | nil | |
| `progress_class` | any | nil | |

Accessibility attrs: `label_text`, `complete_text`

### `dm_skeleton_*`

8 skeleton variants. All share `id`, `class`, `animation`, `loading_label`, `rest`.

- **`dm_skeleton`**: `variant`, `size`, `width`, `height`
- **`dm_skeleton_text`**: `lines` (3), `line_height` ("h-4"), `last_line_width` ("w-full")
- **`dm_skeleton_avatar`**: `size` ("md")
- **`dm_skeleton_card`**: `show_avatar` (false), `avatar_size` ("md"), `lines` (3), `show_action` (false)
- **`dm_skeleton_table`**: `rows` (5), `columns` (4), `show_header` (true)
- **`dm_skeleton_list`**: `items` (5), `show_avatar` (false), `avatar_size` ("sm"), `lines_per_item` (1)
- **`dm_skeleton_form`**: `fields` (4), `field_types` (nil), `show_submit` (true)
- **`dm_skeleton_comment`**: `show_replies` (0)

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
| `data` | list | [] |
| `stream` | boolean | false |
| `border` | boolean | false |
| `zebra` | boolean | false |
| `hover` | boolean | false |
| `compact` | boolean | false |

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
| `content` | string | required | Tooltip text |
| `position` | string | "top" | top, bottom, left, right |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `open` | boolean | false | |

Slots: `inner_block` (required)

---

## Data Entry

All data entry components share a common pattern:
- `field` (Phoenix.HTML.FormField) — use with `@form[:field_name]`
- `name`, `value`, `id` — manual overrides when not using a form
- `errors` — list of error strings
- `helper` — helper text
- `disabled`, `horizontal`, `state` (nil/success/warning)

### `dm_form/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `for` | any | nil | |
| `as` | any | nil | |
| `actions_align` | string | nil | between, right, center |

Slots: `inner_block` (required), `actions`

### `dm_label/1`

| Attr | Type | Default |
|------|------|---------|
| `for` | string | nil |
| `required` | boolean | false |
| `optional` | boolean | false |
| `size` | string | nil |

Slots: `inner_block` (required)

### `dm_error/1`

Slots: `inner_block` (required)

### `dm_alert/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | |
| `icon` | string | nil | |
| `title` | string | nil | |
| `dismissible` | boolean | false | |
| `compact` | boolean | false | |
| `filled` | boolean | false | |
| `outlined` | boolean | false | |

Slots: `inner_block`

### `dm_fieldset/1`

| Attr | Type | Default |
|------|------|---------|
| `legend` | string | nil |
| `variant` | string | nil |

Slots: `inner_block` (required)

### Form Layout Helpers

- **`dm_form_row`**, **`dm_form_inline`**, **`dm_form_hint`** — `id`, `class`, `rest`; slot: `inner_block`
- **`dm_form_grid`** — `cols` (integer, default: 2, values: 2/3/4); slot: `inner_block`
- **`dm_form_section`** — `title`, `description`; slot: `inner_block`
- **`dm_form_divider`** — `text`; no slots
- **`dm_form_counter`** — `current`, `max`, `error`; no slots

### `dm_input/1` — Universal Input

Dispatches based on `type` attr. Supports 30+ types including:
text, checkbox, color, date, datetime-local, email, file, hidden, month,
number, password, range, radio, search, select, tel, textarea, time, url, week,
checkbox_group, radio_group, toggle, range_slider, rating, datepicker,
timepicker, color_picker, switch, search_with_suggestions, file_upload,
rich_text, tags, slider_range, password_strength.

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "text" | (see above) |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | nil | nil + 8 standard colors |
| `size` | string | nil | |
| `label` | string | nil | |
| `classic` | boolean | — | |
| `swatches` | list | nil | Color picker swatches |
| `suggestions` | list | [] | Search suggestions |

Additional password strength labels and form integration attrs available.

### `dm_compact_input/1`

Compact variant of `dm_input` with similar attrs.

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | "text" | text, email, number, password, tel, url, search, date, time, datetime-local, hidden |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | "primary" | 8 standard colors |
| `size` | string | "md" | xs, sm, md, lg |

Slots: `inner_block`

### `dm_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | nil | List of `{value, label}` tuples |
| `prompt` | string | nil | Placeholder option |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | "primary" | 8 standard colors |
| `size` | string | "md" | xs, sm, md, lg |
| `multiple` | boolean | false | |
| `label` | string | nil | |

Slots: `inner_block` (optional, for custom options)

### `dm_checkbox/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | 8 standard colors |
| `indeterminate` | boolean | false | |
| `multiple` | boolean | false | |

### `dm_radio/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | 8 standard colors |

### `dm_switch/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | boolean | false | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | 8 standard colors |
| `multiple` | boolean | false | |

### `dm_slider/1`

| Attr | Type | Default |
|------|------|---------|
| `min` | any | — |
| `max` | any | — |
| `step` | any | — |
| `size` | string | "md" (xs, sm, md, lg) |
| `color` | string | "primary" |
| `show_value` | boolean | — |
| `vertical` | boolean | — |

### `dm_textarea/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `rows` | any | — | |
| `cols` | any | — | |
| `resize` | string | "vertical" | none, vertical, horizontal, both |
| `variant` | string | "bordered" | ghost, filled, bordered, nil |
| `color` | string | "primary" | 8 standard colors |
| `size` | string | "md" | xs, sm, md, lg |
| `readonly` | boolean | — | |
| `required` | boolean | — | |
| `maxlength` | any | — | |

### `dm_rating/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `max` | integer | 5 | |
| `size` | string | nil | nil, xs, sm, lg, xl |
| `color` | string | nil | 9 standard colors |
| `icon` | string | "star" | |
| `readonly` | boolean | — | |
| `animated` | boolean | — | |
| `compact` | boolean | — | |

### `dm_segment_control/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | 9 standard colors |
| `variant` | string | nil | nil, outlined, ghost |
| `full` | boolean | — | |
| `icon_only` | boolean | — | |
| `multi` | boolean | — | |
| `label` | string | nil | |

Slots: `item` (required, attrs: `active`, `disabled`, `icon`, `value`, `class`, `label`)

### `dm_multi_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `selected` | list | [] | |
| `placeholder` | string | — | |
| `open` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `show_actions` | boolean | — | |
| `show_counter` | boolean | — | |
| `max_tags` | any | — | |
| `tag_variant` | any | — | |

Accessibility attrs: `empty_text`, `search_placeholder`, `search_label`, `clear_label`, `select_all_text`, `deselect_all_text`, `overflow_text`, `remove_tag_label`

### `dm_autocomplete/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | |
| `multiple` | boolean | false | |
| `clearable` | boolean | false | |
| `placeholder` | string | nil | |
| `loading` | boolean | false | |
| `no_results_text` | string | "No results found" | |
| `size` | string | "md" | sm, md, lg |

### `dm_otp_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 6 | |
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | 9 standard colors |
| `variant` | string | nil | nil, filled, underline |
| `gap` | string | nil | nil, compact, wide |
| `masked` | boolean | — | |
| `success` | boolean | — | |

### `dm_pin_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 4 | |
| `size` | string | — | |
| `color` | string | — | |
| `variant` | string | — | |
| `shape` | string | — | |
| `compact` | boolean | — | |
| `dots` | boolean | — | |
| `visible` | boolean | — | |
| `success` | boolean | — | |

### `dm_file_upload/1`

| Attr | Type | Default |
|------|------|---------|
| `accept` | any | — |
| `multiple` | boolean | — |
| `max_size` | any | — |
| `max_files` | any | — |
| `show_preview` | boolean | — |
| `compact` | boolean | — |
| `size` | string | "md" (sm, md, lg) |

Slots: `inner_block` (for custom dropzone content)

### `dm_time_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, lg |
| `color` | string | nil | 9 standard colors |
| `variant` | string | nil | nil, filled |
| `show_seconds` | boolean | — | |
| `show_period` | boolean | — | |

Accessibility attrs: `am_label`, `pm_label`, `hours_label`, `minutes_label`, `seconds_label`

### `dm_cascader/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | Tree of maps with :value, :label, opt :children, :disabled |
| `selected_path` | list | [] | |
| `size` | string | "md" | sm, md, lg |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `separator` | string | " / " | |
| `multiple` | boolean | false | |
| `change_on_select` | boolean | false | |
| `expand_trigger` | string | "click" | click, hover |

### `dm_tree_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | Tree of maps |
| `selected` | list | [] | |
| `expanded` | list | [] | |
| `multiple` | boolean | false | |
| `size` | string | nil | nil, sm, lg |
| `variant` | string | nil | nil, outlined, filled |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `show_path` | boolean | — | |

Accessibility attrs: `empty_text`, `search_placeholder`, `search_label`, `clear_label`, `toggle_node_label`, `remove_tag_label`

### `dm_markdown_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `label` | string | — | |
| `placeholder` | string | — | |
| `disabled` | boolean | — | |
| `readonly` | boolean | — | |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |

---

## Feedback

### `dm_modal/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `id` | any | required | |
| `hide_close` | boolean | false | |
| `position` | string | nil | nil, top, middle, bottom |
| `backdrop` | boolean | false | |
| `size` | string | nil | nil, xs, sm, md, lg, xl |
| `responsive` | boolean | false | |
| `no_backdrop` | boolean | false | |

Accessibility attrs: `close_label`, `dialog_label`

Slots: `trigger` (receives `dialog_id` via `:let`), `title`, `body` (required), `footer`

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

### `dm_toast_container/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "top-right" | top-right, top-left, top-center, bottom-right, bottom-left, bottom-center |

Slots: `inner_block` (required)

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

### `dm_actionbar/1`

| Attr | Type | Default |
|------|------|---------|
| `left_class` | any | nil |
| `right_class` | any | nil |
| `toolbar_label` | string | "Actions" |

Slots: `left` (attrs: `id`, `class`), `right` (attrs: `id`, `class`)

### `dm_navbar/1`

| Attr | Type | Default |
|------|------|---------|
| `start_class` | any | nil |
| `center_class` | any | nil |
| `end_class` | any | nil |
| `nav_label` | string | "Main navigation" |

Slots: `start_part`, `center_part`, `end_part`

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

### `dm_tab/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `orientation` | string | "horizontal" | horizontal, vertical |
| `active_tab_index` | integer | 0 | |
| `active_tab_name` | string | "" | |
| `variant` | string | nil | nil, lifted, bordered, boxed |
| `size` | string | nil | nil, xs, sm, md, lg |
| `header_class` | any | nil | |
| `content_class` | any | nil | |

Slots: `tab` (attrs: `id`, `class`, `name`, `phx_click`), `tab_content` (attrs: `id`, `class`, `name`)

### `dm_page_header/1`

**Requires `PageHeader` hook.** Uses `phx-hook="PageHeader"`.

| Attr | Type | Default |
|------|------|---------|
| `id` | string | "wc-page-header-header" |
| `nav_id` | string | "wc-page-header-nav" |
| `nav_class` | any | nil |
| `nav_label` | string | "Site navigation" |
| `toggle_menu_label` | string | "Toggle mobile menu" |

Slots: `menu` (attrs: `class`, `to`, `active`), `user_profile` (attrs: `class`), `inner_block`

### `dm_page_footer/1`

| Attr | Type | Default |
|------|------|---------|
| `label` | string | nil |

Slots: `section` (attrs: `class`, `title`, `title_class`, `body_class`), `copyright` (same attrs), `inner_block`

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
| `current` | integer | 0 | 0-based index |
| `orientation` | string | "horizontal" | horizontal, vertical |
| `color` | string | "primary" | primary, secondary, tertiary, accent, success, warning, error, info |
| `clickable` | boolean | false | |
| `steps` | list | required | Maps with :label, opt :description, :icon |

### `dm_bottom_nav/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `value` | string | nil | Selected item value |
| `color` | string | "primary" | primary, secondary, success, warning, error |
| `position` | string | "fixed" | fixed, static, sticky |
| `items` | list | required | Maps with :value, :label, opt :icon, :disabled, :href |

---

## Layout

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

Slots: `inner_block` (label text)

### `dm_drawer/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `position` | string | "left" | left, right |
| `modal` | boolean | false | |
| `width` | string | nil | CSS width |
| `label` | string | nil | |

Slots: `header`, `inner_block` (required), `footer`

### `dm_bottom_sheet/1`

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | false |
| `modal` | boolean | false |
| `persistent` | boolean | false |
| `snap_points` | string | nil |
| `label` | string | nil |

Slots: `header`, `inner_block` (required)

### `dm_theme_switcher/1`

**Requires `ThemeSwitcher` hook.** Uses `phx-hook="ThemeSwitcher"`.

| Attr | Type | Default |
|------|------|---------|
| `theme` | string | "" |
| `button_text` | string | "Theme" |
| `select_theme_label` | string | "Select theme" |
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

Helper: `PhoenixDuskmoon.Component.Icon.Icons.mdi_icons/0` — returns all available names.

### `dm_bsi/1` — Bootstrap Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required |
| `color` | string | "currentcolor" |

Helper: `PhoenixDuskmoon.Component.Icon.Icons.bsi_icons/0` — returns all available names.

---

## CSS Art

All CSS art components require `id` (required string) and accept `class` + `rest` global attrs.
Import via `use PhoenixDuskmoon.ArtComponent`.
Module namespace: `PhoenixDuskmoon.ArtComponent.*`

### `dm_art_atom/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_cat_stargazer/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_circular_gallery/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_color_spin/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_eclipse/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_flower_animation/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_gemini_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | nil | nil, sm, md, lg |
| `placeholder` | string | nil | |

### `dm_art_moon/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_mountain/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_plasma_ball/1`

Global attrs include: `no-base`

### `dm_art_snow/1`

Global attrs include: `unicode`, `fall`

### `dm_art_sun/1`

No additional attrs beyond `id`, `class`, `rest`.

### `dm_art_synthwave_starfield/1`

No additional attrs beyond `id`, `class`, `rest`.
