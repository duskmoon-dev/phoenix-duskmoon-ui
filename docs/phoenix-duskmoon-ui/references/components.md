# Component Reference

Full attribute and slot reference for all phoenix_duskmoon components.
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
| `content` | string | nil | Button text for noise variant |
| `confirm` | string | nil | Confirmation message (activates dialog variant) |
| `confirm_title` | string | nil | Dialog title |
| `confirm_text` | string | "Yes" | Confirm button text |
| `cancel_text` | string | "Cancel" | Cancel button text |

Slots: `inner_block` (required), `prefix`, `suffix`, `confirm_action`

Global attrs: includes `phx-click`, `phx-target`, `phx-value-id`, `phx-disable-with`, `name`, `value`, `type`, `form`

### `dm_link/1` — Link

| Attr | Type | Default | Notes |
|------|------|---------|-------|
| `navigate` | string | nil | LiveView navigate |
| `patch` | string | nil | LiveView patch |
| `href` | string | nil | Standard href |
| `replace` | boolean | false | |
| `method` | string | "get" | |

Slots: `inner_block` (required)

### `dm_dropdown/1` — Dropdown

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "bottom" | left, right, top, bottom |
| `color` | string | nil | |

Slots: `trigger` (required, attrs: `class`), `content` (required, attrs: `class`)

### `dm_menu/1` — Menu

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `open` | boolean | false | |
| `anchor` | string | nil | CSS selector |
| `placement` | string | "bottom-start" | top, bottom, left, right + -start/-end |
| `label` | string | nil | aria-label |

Slots: `inner_block` (required)

### `dm_menu_item/1`

| Attr | Type | Default |
|------|------|---------|
| `value` | any | nil |
| `disabled` | boolean | false |
| `icon` | string | nil | MDI icon name |

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
| `multiple` | boolean | false | Allow multiple panels open |
| `value` | string | nil | Comma-separated IDs of open items |

Slots: `item` (required, attrs: `value` required, `header` required, `disabled`)

### `dm_avatar/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `src` | string | nil | Image URL |
| `alt` | string | nil | |
| `name` | string | nil | Generates initials |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `shape` | string | "circle" | circle, square, rounded |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `ring` | boolean | false | |
| `online` | boolean | false | |
| `offline` | boolean | false | |

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
| `variant` | string | nil | nil, compact, side, bordered, glass |
| `shadow` | string | nil | nil, none, sm, md, lg, xl, 2xl |
| `interactive` | boolean | false | |
| `padding` | string | nil | nil, none, sm, md, lg |
| `image` | string | nil | Image URL |

Slots: `title` (attrs: `id`, `class`), `action` (attrs: `id`, `class`), `inner_block`

### `dm_async_card/1`

Extends `dm_card` with: `assign` (AsyncResult struct), `skeleton_class`.

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

### `dm_flash/1`

| Attr | Type | Default |
|------|------|---------|
| `flash` | map | nil | Flash map |
| `kind` | atom | nil | :info, :error |
| `title` | string | nil | |
| `close` | boolean | true | |

Slots: `inner_block`

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
| `content` | string | nil | Markdown text |
| `src` | string | nil | URL to fetch |
| `theme` | string | nil | nil, github, atom-one-dark, atom-one-light, auto |
| `no_mermaid` | boolean | false | |

### `dm_pagination/1`

| Attr | Type | Default |
|------|------|---------|
| `page_size` | integer | 10 |
| `page_num` | integer | 1 |
| `total` | integer | 0 |
| `show_total` | boolean | false |
| `update_event` | string | nil | Phoenix event name |
| `page_url` | string | nil | URL template |
| `page_link_type` | string | nil | patch, navigate, href |
| `el_size` | string | nil | xs, sm, md, lg |
| `el_color` | string | nil | primary, secondary, neutral |

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
| `value` | integer | nil | |
| `max` | integer | 100 | |
| `color` | string | "primary" | primary, secondary, tertiary, accent, info, success, warning, error |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `striped` | boolean | false | |
| `animated` | boolean | false | |
| `indeterminate` | boolean | false | |

### `dm_skeleton_*`

8 skeleton variants: `dm_skeleton`, `dm_skeleton_text`, `dm_skeleton_avatar`,
`dm_skeleton_card`, `dm_skeleton_table`, `dm_skeleton_list`, `dm_skeleton_form`,
`dm_skeleton_comment`. All share `animation` and `loading_label` attrs. Each has
type-specific attrs (e.g., `lines` for text, `rows`/`columns` for table).

### `dm_stat/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `title` | string | required | |
| `value` | string | required | |
| `description` | string | nil | |
| `color` | string | nil | primary through error |
| `size` | string | "md" | sm, md, lg |

Slots: `icon`

### `dm_table/1`

| Attr | Type | Default |
|------|------|---------|
| `data` | list | nil | Data rows |
| `stream` | boolean | false | |
| `border` | boolean | false | |
| `zebra` | boolean | false | |
| `hover` | boolean | false | |
| `compact` | boolean | false | |

Slots: `caption`, `col` (attrs: `label`, `label_class`, `class`), `expand`

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
| `color` | string | "primary" | primary through error |
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

### `dm_input/1` — Universal Input

Dispatches based on `type` attr (default "text"). Supports 30+ types including:
text, checkbox, color, date, datetime-local, email, file, hidden, month,
number, password, range, radio, search, select, tel, textarea, time, url, week,
checkbox_group, radio_group, toggle, range_slider, rating, datepicker,
timepicker, color_picker, switch, search_with_suggestions, file_upload,
rich_text, tags, slider_range, password_strength.

Additional attrs: `variant` (ghost/filled/bordered), `color`, `size`, `label`.

### `dm_select/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `options` | list | [] | List of `{value, label}` tuples |
| `prompt` | string | nil | Placeholder option |
| `variant` | string | nil | ghost, filled, bordered |
| `color` | string | "primary" | |
| `size` | string | "md" | xs, sm, md, lg |
| `multiple` | boolean | false | |

### `dm_checkbox/1`, `dm_radio/1`, `dm_switch/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `checked` | any | nil | |
| `label` | string | nil | |
| `size` | string | "md" | xs, sm, md, lg, xl |
| `color` | string | "primary" | primary through error |

### `dm_slider/1`

| Attr | Type | Default |
|------|------|---------|
| `min` | integer | 0 |
| `max` | integer | 100 |
| `step` | integer | 1 |
| `show_value` | boolean | true |
| `vertical` | boolean | false |

### `dm_textarea/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `rows` | integer | 3 | |
| `resize` | string | "vertical" | none, vertical, horizontal, both |
| `variant` | string | nil | ghost, filled, bordered |

### `dm_rating/1`

| Attr | Type | Default |
|------|------|---------|
| `max` | integer | 5 |
| `icon` | string | "star" |
| `readonly` | boolean | false |
| `animated` | boolean | false |
| `compact` | boolean | false |

### `dm_segment_control/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `variant` | string | nil | nil, outlined, ghost |
| `full` | boolean | false | |
| `multi` | boolean | false | |

Slots: `item` (required, attrs: `active`, `disabled`, `icon`, `value`, `class`, `label`)

### `dm_multi_select/1`

| Attr | Type | Default |
|------|------|---------|
| `options` | list | [] | Maps with :value, :label, opt :description/:disabled/:group |
| `selected` | list | [] | |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `max_tags` | integer | nil | |

### `dm_autocomplete/1`

| Attr | Type | Default |
|------|------|---------|
| `options` | list | [] | Maps |
| `multiple` | boolean | false | |
| `clearable` | boolean | false | |

### `dm_otp_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 6 | |
| `variant` | string | nil | nil, filled, underline |
| `gap` | string | nil | nil, compact, wide |
| `masked` | boolean | false | |

### `dm_pin_input/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `length` | integer | 4 | |
| `shape` | string | nil | nil, circle |
| `dots` | boolean | false | |
| `visible` | boolean | true | |

### `dm_file_upload/1`

| Attr | Type | Default |
|------|------|---------|
| `accept` | string | nil | |
| `multiple` | boolean | false | |
| `max_size` | any | nil | |
| `max_files` | any | nil | |
| `show_preview` | boolean | false | |
| `compact` | boolean | false | |

### `dm_time_input/1`

| Attr | Type | Default |
|------|------|---------|
| `show_seconds` | boolean | false | |
| `show_period` | boolean | false | |

### `dm_cascader/1`

| Attr | Type | Default |
|------|------|---------|
| `options` | list | [] | Tree of maps with :value, :label, opt :children, :disabled |
| `selected_path` | list | [] | |
| `searchable` | boolean | false | |
| `clearable` | boolean | false | |
| `separator` | string | " / " | |

### `dm_tree_select/1`

| Attr | Type | Default |
|------|------|---------|
| `options` | list | [] | Tree of maps |
| `selected` | list | [] | |
| `expanded` | list | [] | |
| `multiple` | boolean | false | |
| `show_path` | boolean | false | |

---

## Feedback

### `dm_modal/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `hide_close` | boolean | false | |
| `position` | string | nil | nil, top, middle, bottom |
| `backdrop` | boolean | false | |
| `size` | string | nil | nil, xs, sm, md, lg, xl |
| `responsive` | boolean | false | |

Slots: `trigger` (attrs: `class`), `title` (attrs: `class`), `body` (required, attrs: `class`), `footer` (attrs: `class`)

### `dm_loading_spinner/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `variant` | string | "primary" | primary through error |
| `text` | string | nil | |

### `dm_toast/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error |
| `title` | string | nil | |
| `icon` | string | nil | |
| `filled` | boolean | false | |
| `open` | boolean | false | |
| `show_close` | boolean | false | |

Slots: `inner_block`

### `dm_toast_container/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `position` | string | "top-right" | top-right, top-left, top-center, bottom-right, bottom-left, bottom-center |

### `dm_snackbar/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `type` | string | nil | nil, info, success, warning, error, primary, secondary, tertiary, dark |
| `open` | boolean | false | |
| `multiline` | boolean | false | |
| `position` | string | nil | nil, bottom, bottom-left, bottom-right, top, top-left, top-right |

Slots: `message` (required), `action`, `close`

---

## Navigation

### `dm_appbar/1`

| Attr | Type | Default |
|------|------|---------|
| `title` | string | nil |
| `title_to` | string | nil | Navigate path |
| `sticky` | boolean | true | |

Slots: `menu` (attrs: `class`, `to`, `active`), `logo`, `user_profile`

### `dm_breadcrumb/1`

| Attr | Type | Default |
|------|------|---------|
| `separator` | string | nil | Custom separator char |

Slots: `crumb` (required, attrs: `id`, `class`, `to`)

### `dm_left_menu/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "md" | xs, sm, md, lg |
| `active` | string | nil | Active item ID |

Slots: `title` (attrs: `class`), `menu` (content)

### `dm_left_menu_group/1`

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | true |
| `active` | string | nil |

Slots: `title` (required, attrs: `class`), `menu` (attrs: `id`, `class`, `to`, `disabled`)

### `dm_tab/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `orientation` | string | "horizontal" | horizontal, vertical |
| `active_tab_index` | integer | 0 | |
| `active_tab_name` | string | nil | |
| `variant` | string | nil | nil, lifted, bordered, boxed |
| `size` | string | nil | nil, xs, sm, md, lg |

Slots: `tab` (attrs: `id`, `class`, `name`, `phx_click`), `tab_content` (attrs: `id`, `class`, `name`)

### `dm_page_header/1`

Requires `PageHeader` hook. Uses `phx-hook="PageHeader"`.

Slots: `menu` (attrs: `class`, `to`, `active`), `user_profile` (attrs: `class`), `inner_block`

### `dm_stepper/1` (CSS-only)

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `vertical` | boolean | false | |
| `variant` | string | nil | nil, dots, alt-labels, icons |
| `color` | string | nil | nil, secondary, tertiary, accent |
| `size` | string | nil | nil, sm, lg |
| `clickable` | boolean | false | |

Slots: `step` (required, attrs: `label` required, `description`, `active`, `completed`, `error`, `disabled`, `optional`)

### `dm_steps/1` (Custom Element)

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `current` | integer | 0 | 0-based index |
| `orientation` | string | "horizontal" | horizontal, vertical |
| `color` | string | "primary" | primary through info |
| `clickable` | boolean | false | |
| `steps` | list | required | Maps with :label, opt :description, :icon |

### `dm_bottom_nav/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `value` | string | nil | Selected item value |
| `color` | string | "primary" | primary, secondary, success, warning, error |
| `position` | string | "fixed" | fixed, static, sticky |
| `items` | list | required | Maps with :value, :label, opt :icon, :disabled, :href |

### `dm_page_footer/1`

Slots: `section` (attrs: `class`, `title`, `title_class`, `body_class`), `copyright` (same attrs), `inner_block`

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

Slots: `header`, `inner_block` (required), `footer`

### `dm_theme_switcher/1`

Requires `ThemeSwitcher` hook.

| Attr | Type | Default |
|------|------|---------|
| `theme` | string | nil | Current theme value |
| `button_text` | string | "Theme" | |

### `dm_bottom_sheet/1`

| Attr | Type | Default |
|------|------|---------|
| `open` | boolean | false | |
| `modal` | boolean | false | |
| `persistent` | boolean | false | |
| `snap_points` | string | nil | e.g., "25,50,75,100" |

Slots: `header`, `inner_block`

---

## Icon

### `dm_mdi/1` — Material Design Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required | MDI icon name |
| `color` | string | "currentcolor" | |

Helper: `PhoenixDuskmoon.Component.Icon.Icons.mdi_icons/0` — returns all available names.

### `dm_bsi/1` — Bootstrap Icons

| Attr | Type | Default |
|------|------|---------|
| `name` | string | required | BSI icon name |
| `color` | string | "currentcolor" | |

Helper: `PhoenixDuskmoon.Component.Icon.Icons.bsi_icons/0` — returns all available names.

---

## CSS Art

All CSS art components require an `id` attr and use `aria-hidden="true"`.
Import via `use PhoenixDuskmoon.CssArt`.

### `dm_art_button_noise/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `content` | string | required | Button text |
| `font_size` | string | "24px" | |
| `color_scheme` | string | "default" | default, electric, neon |

### `dm_art_eclipse/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "medium" | small (400px), medium (600px), large (800px) |
| `animation_speed` | float | 1.0 | |

### `dm_art_plasma_ball/1`

| Attr | Type | Default | Values |
|------|------|---------|--------|
| `size` | string | "medium" | small (250px), medium (350px), large (450px) |
| `show_electrode` | boolean | true | |

### `dm_art_signature/1`

| Attr | Type | Default |
|------|------|---------|
| `content` | string | "A" |
| `size` | string | "medium" | small (48px), medium (80px), large (128px) |
| `color` | string | "#ff0000aa" |
| `rotation` | integer | -30 | Degrees |
| `opacity` | float | 0.618 | |

### `dm_art_snow/1`

| Attr | Type | Default |
|------|------|---------|
| `count` | integer | 30 | |
| `size_range` | tuple | {5, 20} | {min_px, max_px} |
| `color` | string | "#FFFFFF" | |
| `use_unicode` | boolean | false | |

### `dm_art_spotlight_search/1`

Requires `Spotlight` hook.

| Attr | Type | Default |
|------|------|---------|
| `placeholder` | string | "Search..." | |
| `shortcut` | string | "cmd+k" | |
| `open` | boolean | false | |
| `loading` | boolean | false | |

Slots: `suggestion` (attrs: `icon`, `label` required, `action`, `description`)
