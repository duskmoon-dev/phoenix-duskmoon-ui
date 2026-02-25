---
name: phoenix-duskmoon-ui
description: >
  Phoenix Duskmoon UI component library for Elixir/Phoenix LiveView applications.
  Use when building UIs with `phoenix_duskmoon` — covers installation, CSS/JS setup,
  component usage patterns (dm_* prefix), slots, form inputs, icons, CSS art,
  and the v9 custom elements architecture. Trigger on: adding phoenix_duskmoon to a
  Phoenix project, using dm_* components, configuring themes, setting up hooks,
  or integrating @duskmoon-dev/core CSS design system.
---

# Phoenix Duskmoon UI

Elixir component library providing 80+ LiveView HEEX components that render as
HTML Custom Elements (`<el-dm-*>`) styled by `@duskmoon-dev/core`.

## Installation

```elixir
# mix.exs
{:phoenix_duskmoon, "~> 9.0"}
```

```bash
# Install frontend dependencies
npm install @duskmoon-dev/core @duskmoon-dev/elements
# or: bun add @duskmoon-dev/core @duskmoon-dev/elements
```

## Setup

### 1. Import components in `app_web.ex`

```elixir
defp html_helpers do
  quote do
    use PhoenixDuskmoon.Component   # all dm_* UI components
    use PhoenixDuskmoon.CssArt      # all dm_art_* decorative components
  end
end
```

### 2. CSS (`assets/css/app.css`)

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
@import "@duskmoon-dev/core/components";
```

For custom elements to inherit theme colors, include the element-theme-bridge
(ships with the package or copy from the repo's `assets/css/element-theme-bridge.css`).

### 3. JavaScript hooks (`assets/js/app.js`)

```javascript
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: DuskmoonHooks
});
```

Merge with your own hooks: `hooks: { ...DuskmoonHooks, ...MyHooks }`.

### 4. Register custom elements

```javascript
import "@duskmoon-dev/el-button/register";
import "@duskmoon-dev/el-card/register";
// ... register each el-* package you use
```

Without registration, `<el-dm-*>` content is invisible.

## Architecture (v9)

```
HEEX Components (dm_btn, dm_card)
       ↓
Custom Elements (<el-dm-button>, <el-dm-card>)
       ↓
@duskmoon-dev/core (CSS variables, design tokens)
```

**CSS class naming (BEM):** `dm-component`, `dm-component--variant`, `dm-component__element`

**Color mapping:** `"accent"` in component APIs maps to `"tertiary"` in CSS tokens.

## Hooks Reference

| Hook | Used by | Purpose |
|------|---------|---------|
| `WebComponentHook` | Any `el-dm-*` with `phx-*` events | Bridges custom element events to LiveView |
| `FormElementHook` | Form `el-dm-*` inputs | Adds `phx-feedback-for` support |
| `ThemeSwitcher` | `dm_theme_switcher` | Theme toggle + localStorage persistence |
| `Spotlight` | `dm_art_spotlight_search` | Cmd/Ctrl+K keyboard shortcut |
| `PageHeader` | `dm_page_header` | IntersectionObserver for scroll-based nav |

## Component Quick Reference

All components use `dm_` prefix. Common attributes across most components:

- `id`, `class` — standard HTML
- `variant` — visual style (values vary per component)
- `color` — primary | secondary | tertiary | accent | info | success | warning | error
- `size` — xs | sm | md | lg (varies per component)
- `disabled` — boolean
- `rest` — passes through global HTML attributes

For full component catalog with all attributes and slots, see
[references/components.md](references/components.md).

### Action

| Function | Module | Description |
|----------|--------|-------------|
| `dm_btn` | Action.Button | Button with variants, confirm dialog, noise effect |
| `dm_link` | Action.Link | LiveView-aware link (navigate/patch/href) |
| `dm_dropdown` | Action.Dropdown | Popover-based dropdown with trigger + content slots |
| `dm_menu` / `dm_menu_item` | Action.Menu | Anchored menu with placement control |
| `dm_toggle_group` | Action.Toggle | Toggle button group (segmented, chip, etc.) |

### Data Display

| Function | Module | Description |
|----------|--------|-------------|
| `dm_accordion` | DataDisplay.Accordion | Multi-panel expand/collapse |
| `dm_avatar` | DataDisplay.Avatar | User avatar with status indicators |
| `dm_badge` | DataDisplay.Badge | Label badge with color variants |
| `dm_card` / `dm_async_card` | DataDisplay.Card | Content card with title/action slots |
| `dm_chip` | DataDisplay.Chip | Deletable chip/tag |
| `dm_collapse` / `dm_collapse_group` | DataDisplay.Collapse | Single collapsible panel |
| `dm_flash` / `dm_flash_group` | DataDisplay.Flash | Flash messages |
| `dm_list` | DataDisplay.List | Structured list with icons and subtitles |
| `dm_markdown` | DataDisplay.Markdown | Markdown renderer with syntax highlighting |
| `dm_pagination` / `dm_pagination_thin` | DataDisplay.Pagination | Page navigation |
| `dm_popover` | DataDisplay.Popover | Contextual overlay with trigger |
| `dm_progress` | DataDisplay.Progress | Linear/circular progress |
| `dm_skeleton_*` | DataDisplay.Skeleton | 8 skeleton variants (text, avatar, card, table, list, form, comment, base) |
| `dm_stat` | DataDisplay.Stat | Stat display with icon slot |
| `dm_table` | DataDisplay.Table | Data table with streaming support |
| `dm_timeline` | DataDisplay.Timeline | Vertical/horizontal timeline |
| `dm_tooltip` | DataDisplay.Tooltip | Tooltip wrapper |

### Data Entry

| Function | Module | Description |
|----------|--------|-------------|
| `dm_form` | DataEntry.Form | Form container + layout helpers (`dm_label`, `dm_error`, `dm_alert`, `dm_fieldset`, `dm_form_row`, `dm_form_grid`, `dm_form_section`, `dm_form_divider`, `dm_form_inline`, `dm_form_hint`, `dm_form_counter`) |
| `dm_input` | DataEntry.Input | Universal input (30+ types via `type` attr) |
| `dm_compact_input` | DataEntry.CompactInput | Compact variant of input |
| `dm_checkbox` | DataEntry.Checkbox | Checkbox with label |
| `dm_radio` | DataEntry.Radio | Radio button with label |
| `dm_select` | DataEntry.Select | Select dropdown |
| `dm_switch` | DataEntry.Switch | Toggle switch |
| `dm_slider` | DataEntry.Slider | Range slider |
| `dm_textarea` | DataEntry.Textarea | Multi-line text input |
| `dm_rating` | DataEntry.Rating | Star rating |
| `dm_segment_control` | DataEntry.SegmentControl | Segmented control |
| `dm_multi_select` | DataEntry.MultiSelect | Multi-select with tags |
| `dm_autocomplete` | DataEntry.Autocomplete | Autocomplete input |
| `dm_otp_input` | DataEntry.OtpInput | OTP code input |
| `dm_pin_input` | DataEntry.PinInput | PIN input |
| `dm_file_upload` | DataEntry.FileUpload | File upload area |
| `dm_time_input` | DataEntry.TimeInput | Time picker |
| `dm_cascader` | DataEntry.Cascader | Cascading select |
| `dm_tree_select` | DataEntry.TreeSelect | Tree-structured select |

### Feedback

| Function | Module | Description |
|----------|--------|-------------|
| `dm_modal` | Feedback.Dialog | Modal dialog with trigger/title/body/footer slots |
| `dm_loading_spinner` / `dm_loading_ex` | Feedback.Loading | Loading indicators |
| `dm_toast` / `dm_toast_container` | Feedback.Toast | Toast notifications |
| `dm_snackbar` / `dm_snackbar_container` | Feedback.Snackbar | Snackbar messages |

### Navigation

| Function | Module | Description |
|----------|--------|-------------|
| `dm_actionbar` | Navigation.Actionbar | Action toolbar with left/right slots |
| `dm_appbar` / `dm_simple_appbar` | Navigation.Appbar | Top navigation bar |
| `dm_bottom_nav` | Navigation.BottomNav | Mobile bottom navigation |
| `dm_breadcrumb` | Navigation.Breadcrumb | Breadcrumb trail |
| `dm_left_menu` / `dm_left_menu_group` | Navigation.LeftMenu | Sidebar menu |
| `dm_navbar` | Navigation.Navbar | Horizontal navbar (start/center/end) |
| `dm_nested_menu` / `dm_nested_menu_item` | Navigation.NestedMenu | Nested collapsible menu |
| `dm_page_footer` | Navigation.PageFooter | Page footer with sections |
| `dm_page_header` | Navigation.PageHeader | Page header with scroll-aware nav (needs hook) |
| `dm_stepper` | Navigation.Stepper | CSS-only stepper |
| `dm_steps` | Navigation.Steps | Stepper via custom element |
| `dm_tab` | Navigation.Tab | Tabbed content |

### Layout

| Function | Module | Description |
|----------|--------|-------------|
| `dm_divider` | Layout.Divider | Horizontal/vertical divider |
| `dm_drawer` | Layout.Drawer | Slide-out drawer panel |
| `dm_theme_switcher` | Layout.ThemeSwitcher | Theme toggle (needs hook) |
| `dm_bottom_sheet` | Layout.BottomSheet | Bottom sheet overlay |

### Icon

| Function | Module | Description |
|----------|--------|-------------|
| `dm_mdi` | Icon.Icons | Material Design Icons (7000+ icons) |
| `dm_bsi` | Icon.Icons | Bootstrap Icons (2000+ icons) |

### CSS Art (decorative)

| Function | Module | Description |
|----------|--------|-------------|
| `dm_art_button_noise` | CssArt.ButtonNoise | Animated noise button |
| `dm_art_eclipse` | CssArt.Eclipse | Animated eclipse |
| `dm_art_plasma_ball` | CssArt.PlasmaBall | Interactive plasma ball |
| `dm_art_signature` | CssArt.Signature | Decorative seal stamp |
| `dm_art_snow` | CssArt.Snow | Falling snowflakes |
| `dm_art_spotlight_search` | CssArt.SpotlightSearch | Spotlight search (needs hook) |

## Usage Examples

```heex
<%!-- Button with variant --%>
<.dm_btn variant="primary" size="md">Save</.dm_btn>
<.dm_btn variant="error" shape="circle" loading={@saving}>X</.dm_btn>

<%!-- Button with confirmation dialog --%>
<.dm_btn confirm="Delete this item?" phx-click="delete" phx-value-id={@item.id}>
  Delete
</.dm_btn>

<%!-- Card with slots --%>
<.dm_card variant="bordered">
  <:title>Dashboard</:title>
  Content here
  <:action><.dm_btn variant="primary">View</.dm_btn></:action>
</.dm_card>

<%!-- Icons --%>
<.dm_mdi name="home" class="w-6 h-6" />
<.dm_bsi name="house" class="w-5 h-5" />

<%!-- Form with inputs --%>
<.dm_form for={@form} phx-submit="save">
  <.dm_input field={@form[:name]} label="Name" />
  <.dm_select field={@form[:role]} label="Role" options={[{"admin", "Admin"}, {"user", "User"}]} />
  <.dm_switch field={@form[:active]} label="Active" />
  <:actions>
    <.dm_btn variant="primary" type="submit">Save</.dm_btn>
  </:actions>
</.dm_form>

<%!-- Navigation --%>
<.dm_appbar title="My App" title_to={~p"/"}>
  <:menu to={~p"/dashboard"} active={@active == :dashboard}>Dashboard</:menu>
  <:menu to={~p"/settings"}>Settings</:menu>
  <:user_profile>
    <.dm_avatar name={@current_user.name} size="sm" />
  </:user_profile>
</.dm_appbar>

<%!-- Theme switcher (requires ThemeSwitcher hook) --%>
<.dm_theme_switcher id="theme-toggle" theme={@theme} />

<%!-- Tabs --%>
<.dm_tab id="my-tabs" active_tab_index={0}>
  <:tab name="overview">Overview</:tab>
  <:tab name="details">Details</:tab>
  <:tab_content name="overview">Overview content</:tab_content>
  <:tab_content name="details">Details content</:tab_content>
</.dm_tab>

<%!-- Modal --%>
<.dm_modal id="confirm-modal">
  <:trigger><.dm_btn>Open</.dm_btn></:trigger>
  <:title>Confirm</:title>
  <:body>Are you sure?</:body>
  <:footer><.dm_btn variant="primary" phx-click="confirm">Yes</.dm_btn></:footer>
</.dm_modal>
```

## npm Package Exports

| Import path | File |
|---|---|
| `phoenix_duskmoon` | `priv/static/phoenix_duskmoon.js` |
| `phoenix_duskmoon/hooks` | `assets/js/hooks/index.js` |
| `phoenix_duskmoon/css` | `priv/static/phoenix_duskmoon.css` |
| `phoenix_duskmoon/svg/mdi/*.svg` | `priv/mdi/svg/*.svg` |
| `phoenix_duskmoon/svg/bsi/*.svg` | `priv/bsi/svg/*.svg` |
