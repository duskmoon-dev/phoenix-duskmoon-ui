# PRD: Phoenix Duskmoon UI v9 Refactor

## 1. Overview

Phoenix Duskmoon UI v9 is a major refactor that fully embraces **HTML Custom Elements** as the rendering layer. Every Phoenix HEEX component becomes a thin wrapper around `@duskmoon-dev/elements` custom elements, styled by `@duskmoon-dev/core`.

### Goals

1. **Reorganize components by category** (actions, data display, data entry, feedback, navigation, layout, icons, fun)
2. **Migrate all components to custom elements** — close the gap between 7 currently using `<el-dm-*>` and the 28 available element packages
3. **Refactor the storybook** — each component gets a dedicated page with live demos, attribute playground, and documentation
4. **Simplify CSS/JS** — remove legacy styling (neumorphic), rely entirely on `@duskmoon-dev/core` design tokens
5. **Improve developer experience** — consistent API, clear module paths, comprehensive tests

### Non-Goals

- Breaking the umbrella project structure (keep 3 apps)
- Changing the build toolchain (keep bun + tailwind + mix)
- Rewriting `@duskmoon-dev/core` or `@duskmoon-dev/elements` (those are upstream)
- Publishing to Hex during the refactor (release after stabilization)

---

## 2. Current State

### Architecture

```
Phoenix LiveView HEEX → Custom Elements (partial) → @duskmoon-dev/core CSS
```

### Problems

| Problem | Impact |
|---------|--------|
| **Flat component structure** — 27 standard components in one directory | Hard to find related components, unclear categorization |
| **Inconsistent rendering** — only 7/41 components use custom elements | Mixed rendering strategies, unpredictable behavior |
| **28 element packages available, 7 used** | Missing features, duplicated CSS-only implementations |
| **Legacy CSS** — neumorphic theme, manual BEM classes | Conflicts with `@duskmoon-dev/core` design system |
| **Storybook is a flat list** — no per-component docs | Poor discoverability, no API reference |
| **Single import modules** — `use PhoenixDuskmoon.Component` imports everything | Compilation coupling, unclear dependencies |
| **Sparse test coverage** — 13 test files for 41 components | Regression risk during refactor |

### Current Component Count

| Category | Components | Using Custom Elements |
|----------|-----------|----------------------|
| Standard | 27 | 7 (button, card, badge, breadcrumb, modal, tab, pagination) |
| Form | 8 | 0 |
| Fun | 6 | 0 |
| **Total** | **41** | **7** |

---

## 3. Target Architecture

### 3.1 Component Organization

Reorganize `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/` into category folders:

```
lib/phoenix_duskmoon/component/
├── action/                    # User-triggered actions
│   ├── button.ex             → <el-dm-button>
│   ├── link.ex               → <a> (no custom element needed)
│   └── dropdown.ex           → <el-dm-menu>
│
├── data_display/              # Read-only data presentation
│   ├── avatar.ex             → <el-dm-avatar> (new element or CSS-only)
│   ├── badge.ex              → <el-dm-badge>
│   ├── card.ex               → <el-dm-card>
│   ├── chip.ex               → <el-dm-chip> (new component)
│   ├── flash.ex              → <el-dm-alert>
│   ├── markdown.ex           → <el-dm-markdown>
│   ├── pagination.ex         → <el-dm-pagination>
│   ├── progress.ex           → <el-dm-progress>
│   ├── skeleton.ex           → CSS-only (dm-skeleton)
│   ├── table.ex              → <el-dm-table>
│   ├── timeline.ex           → CSS-only (new component)
│   └── tooltip.ex            → <el-dm-tooltip>
│
├── data_entry/                # Form inputs and controls
│   ├── autocomplete.ex       → <el-dm-autocomplete> (new component)
│   ├── checkbox.ex           → CSS-only (dm-checkbox)
│   ├── compact_input.ex      → <el-dm-input> variant
│   ├── datepicker.ex         → <el-dm-datepicker> (new component)
│   ├── file_upload.ex        → <el-dm-file-upload> (new component)
│   ├── form.ex               → <el-dm-form>
│   ├── input.ex              → <el-dm-input>
│   ├── radio.ex              → CSS-only (dm-radio)
│   ├── select.ex             → CSS-only (dm-select)
│   ├── slider.ex             → <el-dm-slider>
│   ├── switch.ex             → <el-dm-switch>
│   └── textarea.ex           → CSS-only (dm-textarea)
│
├── feedback/                  # System feedback and status
│   ├── alert.ex              → <el-dm-alert> (new component)
│   ├── dialog.ex             → <el-dm-dialog>
│   ├── loading.ex            → CSS-only (dm-progress indeterminate)
│   ├── modal.ex              → <el-dm-dialog> (alias/variant)
│   └── popover.ex            → <el-dm-popover> (new component)
│
├── navigation/                # Wayfinding and page structure
│   ├── actionbar.ex          → CSS-only (dm-appbar)
│   ├── appbar.ex             → CSS-only (dm-appbar)
│   ├── bottom_nav.ex         → <el-dm-bottom-navigation> (new component)
│   ├── breadcrumb.ex         → <el-dm-breadcrumbs>
│   ├── drawer.ex             → <el-dm-drawer> (new component)
│   ├── left_menu.ex          → <el-dm-menu> / <el-dm-drawer>
│   ├── navbar.ex             → <el-dm-navbar>
│   ├── page_footer.ex        → CSS-only
│   ├── page_header.ex        → CSS-only
│   ├── stepper.ex            → <el-dm-stepper> (new component)
│   └── tab.ex                → <el-dm-tabs>
│
├── layout/                    # Structural and utility
│   ├── accordion.ex          → <el-dm-accordion> (new component)
│   ├── divider.ex            → CSS-only (dm-divider)
│   └── theme_switcher.ex     → LiveView hook (no element)
│
├── icon/                      # Icon systems
│   └── icons.ex              → dm_mdi, dm_bsi (inline SVG)
│
└── fun/                       # Interactive/animated effects
    ├── button_noise.ex       → CSS/JS animation
    ├── eclipse.ex            → CSS animation
    ├── plasma_ball.ex        → CSS animation
    ├── signature.ex          → Canvas-based
    ├── snow.ex               → CSS animation
    └── spotlight_search.ex   → LiveView hook
```

### 3.2 Module Naming Convention

```elixir
# Category-based module paths
PhoenixDuskmoon.Component.Action.Button        # dm_btn
PhoenixDuskmoon.Component.DataDisplay.Card      # dm_card
PhoenixDuskmoon.Component.DataEntry.Input       # dm_input
PhoenixDuskmoon.Component.Feedback.Dialog       # dm_dialog
PhoenixDuskmoon.Component.Navigation.Navbar     # dm_navbar
PhoenixDuskmoon.Component.Layout.Divider        # dm_divider
PhoenixDuskmoon.Component.Icon.Icons            # dm_mdi, dm_bsi
PhoenixDuskmoon.Component.Fun.Snow              # dm_fun_snow
```

### 3.3 Import Modules

Replace the single monolithic import with category-based imports:

```elixir
# NEW: Category-based imports
use PhoenixDuskmoon.Component          # All standard components (backwards compatible)
use PhoenixDuskmoon.Component.Action   # Only action components
use PhoenixDuskmoon.Component.Form     # Only form/data entry components
use PhoenixDuskmoon.Fun                # Fun components (unchanged)

# Individual imports still work
import PhoenixDuskmoon.Component.Action.Button
```

### 3.4 Custom Element Migration

**Phase 1 — Already done (7 components):**
- button, card, badge, breadcrumb, modal/dialog, tab, pagination

**Phase 2 — Direct mapping to existing elements (13 components):**
- alert, autocomplete, datepicker, drawer, file_upload, form, input, markdown, menu/dropdown, navbar, progress, slider, switch, stepper, table, tooltip

**Phase 3 — New components wrapping available elements (8 components):**
- accordion, bottom_nav, bottom_sheet, chip, popover

**Phase 4 — CSS-only components (no custom element needed):**
- avatar, checkbox, compact_input, divider, flash, left_menu, loading, page_footer, page_header, radio, select, skeleton, textarea, timeline, actionbar, appbar

### 3.5 Component API Standards

Every component MUST follow this pattern:

```elixir
defmodule PhoenixDuskmoon.Component.Action.Button do
  @moduledoc """
  Button component for triggering actions.

  ## Examples

      <.dm_btn variant="primary">Click me</.dm_btn>
      <.dm_btn variant="secondary" size="sm" loading>Processing</.dm_btn>

  ## Attributes

  See `dm_btn/1` for full attribute documentation.
  """
  use Phoenix.Component

  @doc """
  Renders a button.

  Wraps the `<el-dm-button>` custom element from `@duskmoon-dev/elements`.

  ## Examples

      <.dm_btn variant="primary">Click me</.dm_btn>
  """
  @doc type: :component
  attr :id, :any, default: nil
  attr :class, :any, default: nil
  attr :variant, :string,
    values: ~w(primary secondary tertiary outline ghost text),
    default: nil,
    doc: "Visual style variant"
  attr :size, :string,
    values: ~w(xs sm md lg),
    default: nil,
    doc: "Button size"
  attr :loading, :boolean, default: false, doc: "Show loading spinner"
  attr :disabled, :boolean, default: false, doc: "Disable interaction"
  attr :rest, :global, include: ~w(phx-click phx-target type form name value)
  slot :inner_block, required: true

  def dm_btn(assigns) do
    ~H"""
    <el-dm-button
      id={@id}
      variant={@variant}
      size={@size}
      loading={@loading}
      disabled={@disabled}
      class={@class}
      {@rest}
    >
      {render_slot(@inner_block)}
    </el-dm-button>
    """
  end
end
```

**Standards enforced:**
- `@moduledoc` with description, examples, and attribute reference
- `@doc` with rendering details and examples
- `@doc type: :component`
- All attributes documented with `:doc` option
- `variant` values aligned with `@duskmoon-dev/core` (primary, secondary, tertiary, outline, ghost, text)
- Custom elements get `phx-hook` only when needed for event bridging
- `@rest` with explicit `:include` list

---

## 4. Storybook Refactor

### 4.1 Structure

Reorganize storybook to mirror the component categories:

```
apps/duskmoon_storybook_web/storybook/
├── index.exs                          # Root index with categories
├── action/                            # Action components
│   ├── index.exs
│   ├── button.story.exs
│   ├── link.story.exs
│   └── dropdown.story.exs
├── data_display/                      # Data display components
│   ├── index.exs
│   ├── card.story.exs
│   ├── table.story.exs
│   ├── badge.story.exs
│   ├── avatar.story.exs
│   ├── chip.story.exs
│   ├── pagination.story.exs
│   ├── progress.story.exs
│   ├── skeleton.story.exs
│   ├── tooltip.story.exs
│   ├── markdown.story.exs
│   └── flash.story.exs
├── data_entry/                        # Form/input components
│   ├── index.exs
│   ├── input.story.exs
│   ├── textarea.story.exs
│   ├── select.story.exs
│   ├── checkbox.story.exs
│   ├── radio.story.exs
│   ├── switch.story.exs
│   ├── slider.story.exs
│   ├── datepicker.story.exs
│   ├── file_upload.story.exs
│   ├── autocomplete.story.exs
│   └── form.story.exs
├── feedback/                          # Feedback components
│   ├── index.exs
│   ├── alert.story.exs
│   ├── dialog.story.exs
│   ├── modal.story.exs
│   ├── loading.story.exs
│   └── popover.story.exs
├── navigation/                        # Navigation components
│   ├── index.exs
│   ├── navbar.story.exs
│   ├── appbar.story.exs
│   ├── breadcrumb.story.exs
│   ├── tab.story.exs
│   ├── drawer.story.exs
│   ├── stepper.story.exs
│   ├── left_menu.story.exs
│   └── bottom_nav.story.exs
├── layout/                            # Layout components
│   ├── index.exs
│   ├── divider.story.exs
│   ├── accordion.story.exs
│   └── theme_switcher.story.exs
├── icon/                              # Icon systems
│   ├── index.exs
│   └── icons.story.exs
└── fun/                               # Fun/animated components
    ├── index.exs
    ├── snow.story.exs
    ├── eclipse.story.exs
    ├── plasma_ball.story.exs
    ├── button_noise.story.exs
    ├── signature.story.exs
    └── spotlight_search.story.exs
```

### 4.2 Story Page Standard

Each story file MUST include:

```elixir
defmodule Storybook.Action.Button do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Button.dm_btn/1

  def description do
    """
    Button component for triggering actions.
    Wraps `<el-dm-button>` from @duskmoon-dev/elements.
    """
  end

  def variations do
    [
      # 1. Default / basic usage
      %Variation{
        id: :default,
        attributes: %{variant: "primary"},
        slots: ["Primary Button"]
      },

      # 2. All variants showcase
      %VariationGroup{
        id: :variants,
        description: "Available visual variants",
        variations: [
          %Variation{id: :primary, attributes: %{variant: "primary"}, slots: ["Primary"]},
          %Variation{id: :secondary, attributes: %{variant: "secondary"}, slots: ["Secondary"]},
          %Variation{id: :tertiary, attributes: %{variant: "tertiary"}, slots: ["Tertiary"]},
          %Variation{id: :outline, attributes: %{variant: "outline"}, slots: ["Outline"]},
          %Variation{id: :ghost, attributes: %{variant: "ghost"}, slots: ["Ghost"]},
          %Variation{id: :text, attributes: %{variant: "text"}, slots: ["Text"]},
        ]
      },

      # 3. Sizes
      %VariationGroup{
        id: :sizes,
        description: "Button sizes",
        variations: [
          %Variation{id: :xs, attributes: %{variant: "primary", size: "xs"}, slots: ["Extra Small"]},
          %Variation{id: :sm, attributes: %{variant: "primary", size: "sm"}, slots: ["Small"]},
          %Variation{id: :md, attributes: %{variant: "primary", size: "md"}, slots: ["Medium"]},
          %Variation{id: :lg, attributes: %{variant: "primary", size: "lg"}, slots: ["Large"]},
        ]
      },

      # 4. States
      %VariationGroup{
        id: :states,
        description: "Interactive states",
        variations: [
          %Variation{id: :loading, attributes: %{variant: "primary", loading: true}, slots: ["Loading"]},
          %Variation{id: :disabled, attributes: %{variant: "primary", disabled: true}, slots: ["Disabled"]},
        ]
      },

      # 5. Template for complex compositions
      %Variation{
        id: :with_icon,
        description: "Button with icon",
        template: """
        <.dm_btn variant="primary">
          <.dm_mdi name="check" class="mr-2" /> Confirm
        </.dm_btn>
        """
      }
    ]
  end
end
```

**Story requirements:**
1. Default variation showing basic usage
2. VariationGroup for all variants
3. VariationGroup for all sizes
4. VariationGroup for interactive states (loading, disabled, error)
5. Template variations for complex compositions
6. Description mentioning the underlying custom element

---

## 5. CSS/JS Refactor

### 5.1 CSS

**Remove:**
- `neumorphic.css` and `neumorphic/` directory
- All manual BEM class definitions that duplicate `@duskmoon-dev/core`

**Keep:**
- Component-specific overrides and Phoenix-specific styles
- Layout utilities not covered by the design system

**Target `phoenix_duskmoon.css`:**
```css
@source "../js/**/*.js";
@source "../../lib/**/*.{ex,exs}";

@import "tailwindcss";
@import "@duskmoon-dev/core";

/* Phoenix-specific component styles only */
@import "./components.css";
```

### 5.2 JavaScript

**Simplify `phoenix_duskmoon.js`:**
```javascript
// Import all custom elements
import "@duskmoon-dev/elements";

// Export LiveView hooks
export { WebComponentHook, FormElementHook } from "./hooks/web_component.js";
export { ThemeSwitcher } from "./hooks/theme_switcher.js";
export { Spotlight } from "./hooks/spotlight.js";
export { PageHeader } from "./hooks/page_header.js";
```

**Hook refactor:**
- Keep `WebComponentHook` and `FormElementHook` — they bridge LiveView ↔ custom elements
- Keep `ThemeSwitcher`, `Spotlight`, `PageHeader` — LiveView-specific behaviors
- Remove any hook code that duplicates custom element functionality

---

## 6. Testing Strategy

### 6.1 Test Organization

Mirror the component categories:

```
test/phoenix_duskmoon/component/
├── action/
│   ├── button_test.exs
│   ├── link_test.exs
│   └── dropdown_test.exs
├── data_display/
│   ├── card_test.exs
│   ├── table_test.exs
│   ├── badge_test.exs
│   └── ...
├── data_entry/
│   ├── input_test.exs
│   ├── switch_test.exs
│   └── ...
├── feedback/
│   ├── dialog_test.exs
│   └── ...
├── navigation/
│   ├── navbar_test.exs
│   └── ...
├── layout/
│   └── ...
├── icon/
│   └── icons_test.exs
└── fun/
    └── ...
```

### 6.2 Test Coverage Target

- Every component MUST have at least one test file
- Tests verify: default rendering, all variants, slot rendering, attribute passthrough
- Use `render_component/2` with partial string matching (`=~`)

### 6.3 Test Pattern

```elixir
defmodule PhoenixDuskmoon.Component.Action.ButtonTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias PhoenixDuskmoon.Component.Action.Button

  describe "dm_btn/1" do
    test "renders default button" do
      html = render_component(&Button.dm_btn/1, %{
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Click" end}]
      })
      assert html =~ "<el-dm-button"
      assert html =~ "Click"
    end

    test "renders with variant" do
      html = render_component(&Button.dm_btn/1, %{
        variant: "primary",
        inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Click" end}]
      })
      assert html =~ ~s(variant="primary")
    end
  end
end
```

---

## 7. Migration Plan

### Phase 1: Scaffold & Reorganize (no behavior changes)

1. Create new category directories under `component/`
2. Move existing component files into category folders
3. Update module names (add category namespace)
4. Create backwards-compatible re-exports in old locations
5. Update `PhoenixDuskmoon.Component` import module
6. Move test files to match new structure
7. Verify: `mix compile --warnings-as-errors && mix test`

### Phase 2: Migrate Components to Custom Elements

1. Start with components that have direct element mappings (Phase 2 list from 3.4)
2. For each component:
   - Update HEEX template to render `<el-dm-*>` tag
   - Map attributes to element properties
   - Add `phx-hook="WebComponentHook"` where event bridging needed
   - Update/add tests
3. Verify storybook renders correctly after each migration

### Phase 3: New Components

1. Add wrapper components for available elements not yet wrapped:
   - accordion, alert, autocomplete, bottom_nav, chip, datepicker, drawer, file_upload, popover, stepper
2. Follow the component API standard from section 3.5
3. Add storybook stories for each new component

### Phase 4: Storybook Refactor

1. Create category directories in storybook
2. Create `index.exs` for each category
3. Rewrite each story file to the new standard (section 4.2)
4. Remove legacy showcase stories (ui_showcase, forms_showcase, fun_showcase)
5. Verify all stories render and interactive controls work

### Phase 5: CSS/JS Cleanup

1. Remove `neumorphic.css` and `neumorphic/` directory
2. Audit remaining CSS — remove anything duplicated by `@duskmoon-dev/core`
3. Simplify JS entry point
4. Update `package.json` exports

### Phase 6: Backwards Compatibility Removal

1. Remove re-export shims from Phase 1
2. Update all imports to use new paths
3. Update `CLAUDE.md`, `AGENTS.md`, skill files
4. Final `mix compile --warnings-as-errors && mix test && mix format --check-formatted`

---

## 8. New Components Inventory

Components to ADD that wrap available `@duskmoon-dev/elements`:

| Component | Element Package | Category | Priority |
|-----------|----------------|----------|----------|
| `dm_accordion` | `@duskmoon-dev/el-accordion` | Layout | Medium |
| `dm_alert` | `@duskmoon-dev/el-alert` | Feedback | High |
| `dm_autocomplete` | `@duskmoon-dev/el-autocomplete` | Data Entry | Medium |
| `dm_bottom_nav` | `@duskmoon-dev/el-bottom-navigation` | Navigation | Low |
| `dm_bottom_sheet` | `@duskmoon-dev/el-bottom-sheet` | Feedback | Low |
| `dm_chip` | `@duskmoon-dev/el-chip` | Data Display | Medium |
| `dm_datepicker` | `@duskmoon-dev/el-datepicker` | Data Entry | High |
| `dm_drawer` | `@duskmoon-dev/el-drawer` | Navigation | Medium |
| `dm_file_upload` | `@duskmoon-dev/el-file-upload` | Data Entry | Medium |
| `dm_popover` | `@duskmoon-dev/el-popover` | Feedback | Medium |
| `dm_stepper` | `@duskmoon-dev/el-stepper` | Navigation | Low |

---

## 9. Components to Deprecate/Remove

| Component | Reason | Replacement |
|-----------|--------|-------------|
| `dm_modal` | Duplicate of dialog | `dm_dialog` with modal variant |
| `dm_actionbar` | Unclear distinction from appbar | Merge into `dm_appbar` |
| `dm_loading` | Covered by progress indeterminate | `dm_progress` with indeterminate attr |
| Neumorphic theme | Legacy design, conflicts with MD3 | Remove entirely |

---

## 10. TODO Checklist

### Phase 1: Scaffold & Reorganize

#### 1.1 Create category directories
- [ ] Create `lib/phoenix_duskmoon/component/action/`
- [ ] Create `lib/phoenix_duskmoon/component/data_display/`
- [ ] Create `lib/phoenix_duskmoon/component/data_entry/`
- [ ] Create `lib/phoenix_duskmoon/component/feedback/`
- [ ] Create `lib/phoenix_duskmoon/component/navigation/`
- [ ] Create `lib/phoenix_duskmoon/component/layout/`
- [ ] Create `lib/phoenix_duskmoon/component/icon/`
- [ ] Create `lib/phoenix_duskmoon/component/fun/` (already exists — verify)

#### 1.2 Move & rename component modules — Action
- [ ] Move `button.ex` → `action/button.ex`, rename module to `Action.Button`
- [ ] Move `link.ex` → `action/link.ex`, rename module to `Action.Link`
- [ ] Move `dropdown.ex` → `action/dropdown.ex`, rename module to `Action.Dropdown`

#### 1.3 Move & rename component modules — Data Display
- [ ] Move `avatar.ex` → `data_display/avatar.ex`, rename module to `DataDisplay.Avatar`
- [ ] Move `badge.ex` → `data_display/badge.ex`, rename module to `DataDisplay.Badge`
- [ ] Move `card.ex` → `data_display/card.ex`, rename module to `DataDisplay.Card`
- [ ] Move `flash.ex` → `data_display/flash.ex`, rename module to `DataDisplay.Flash`
- [ ] Move `markdown.ex` → `data_display/markdown.ex`, rename module to `DataDisplay.Markdown`
- [ ] Move `pagination.ex` → `data_display/pagination.ex`, rename module to `DataDisplay.Pagination`
- [ ] Move `progress.ex` → `data_display/progress.ex`, rename module to `DataDisplay.Progress`
- [ ] Move `skeleton.ex` → `data_display/skeleton.ex`, rename module to `DataDisplay.Skeleton`
- [ ] Move `table.ex` → `data_display/table.ex`, rename module to `DataDisplay.Table`
- [ ] Move `tooltip.ex` → `data_display/tooltip.ex`, rename module to `DataDisplay.Tooltip`

#### 1.4 Move & rename component modules — Data Entry
- [ ] Move `form/checkbox.ex` → `data_entry/checkbox.ex`, rename to `DataEntry.Checkbox`
- [ ] Move `form/compact_input.ex` → `data_entry/compact_input.ex`, rename to `DataEntry.CompactInput`
- [ ] Move `form.ex` → `data_entry/form.ex`, rename to `DataEntry.Form`
- [ ] Move `form/input.ex` → `data_entry/input.ex`, rename to `DataEntry.Input`
- [ ] Move `form/radio.ex` → `data_entry/radio.ex`, rename to `DataEntry.Radio`
- [ ] Move `form/select.ex` → `data_entry/select.ex`, rename to `DataEntry.Select`
- [ ] Move `form/slider.ex` → `data_entry/slider.ex`, rename to `DataEntry.Slider`
- [ ] Move `form/switch.ex` → `data_entry/switch.ex`, rename to `DataEntry.Switch`
- [ ] Move `form/textarea.ex` → `data_entry/textarea.ex`, rename to `DataEntry.Textarea`

#### 1.5 Move & rename component modules — Feedback
- [ ] Move `loading.ex` → `feedback/loading.ex`, rename to `Feedback.Loading`
- [ ] Move `modal.ex` → `feedback/dialog.ex`, rename to `Feedback.Dialog`

#### 1.6 Move & rename component modules — Navigation
- [ ] Move `actionbar.ex` → `navigation/actionbar.ex`, rename to `Navigation.Actionbar`
- [ ] Move `appbar.ex` → `navigation/appbar.ex`, rename to `Navigation.Appbar`
- [ ] Move `breadcrumb.ex` → `navigation/breadcrumb.ex`, rename to `Navigation.Breadcrumb`
- [ ] Move `left_menu.ex` → `navigation/left_menu.ex`, rename to `Navigation.LeftMenu`
- [ ] Move `navbar.ex` → `navigation/navbar.ex`, rename to `Navigation.Navbar`
- [ ] Move `page_footer.ex` → `navigation/page_footer.ex`, rename to `Navigation.PageFooter`
- [ ] Move `page_header.ex` → `navigation/page_header.ex`, rename to `Navigation.PageHeader`
- [ ] Move `tab.ex` → `navigation/tab.ex`, rename to `Navigation.Tab`

#### 1.7 Move & rename component modules — Layout
- [ ] Move `divider.ex` → `layout/divider.ex`, rename to `Layout.Divider`
- [ ] Move `theme_switcher.ex` → `layout/theme_switcher.ex`, rename to `Layout.ThemeSwitcher`

#### 1.8 Move & rename component modules — Icon
- [ ] Move `icons.ex` → `icon/icons.ex`, rename to `Icon.Icons`

#### 1.9 Move & rename component modules — Fun
- [ ] Verify `fun/button_noise.ex` → `Fun.ButtonNoise` (already in fun/)
- [ ] Verify `fun/eclipse.ex` → `Fun.Eclipse`
- [ ] Verify `fun/plasma_ball.ex` → `Fun.PlasmaBall`
- [ ] Verify `fun/signature.ex` → `Fun.Signature`
- [ ] Verify `fun/snow.ex` → `Fun.Snow`
- [ ] Verify `fun/spotlight_search.ex` → `Fun.SpotlightSearch`

#### 1.10 Update import/helper modules
- [ ] Update `lib/phoenix_duskmoon/component.ex` — import from new paths
- [ ] Create category import modules (`Action`, `DataDisplay`, `DataEntry`, etc.)
- [ ] Update `lib/phoenix_duskmoon/fun.ex` — verify fun imports still work
- [ ] Create backwards-compatible re-exports at old module paths (defdelegate)
- [ ] Update any cross-component references (Flash→Icons, Card→Form, Appbar→Link, etc.)

#### 1.11 Move test files to match new structure
- [ ] Create `test/phoenix_duskmoon/component/action/`
- [ ] Create `test/phoenix_duskmoon/component/data_display/`
- [ ] Create `test/phoenix_duskmoon/component/data_entry/`
- [ ] Create `test/phoenix_duskmoon/component/feedback/`
- [ ] Create `test/phoenix_duskmoon/component/navigation/`
- [ ] Create `test/phoenix_duskmoon/component/layout/`
- [ ] Create `test/phoenix_duskmoon/component/icon/`
- [ ] Move `button_test.exs` → `action/button_test.exs`
- [ ] Move `card_test.exs` → `data_display/card_test.exs`
- [ ] Move `avatar_test.exs` → `data_display/avatar_test.exs`
- [ ] Move `badge_test.exs` → `data_display/badge_test.exs` (if exists)
- [ ] Move `icons_test.exs` → `icon/icons_test.exs`
- [ ] Move `link_test.exs` → `action/link_test.exs`
- [ ] Move `markdown_test.exs` → `data_display/markdown_test.exs`
- [ ] Move `pagination_test.exs` → `data_display/pagination_test.exs`
- [ ] Move `skeleton_test.exs` → `data_display/skeleton_test.exs`
- [ ] Move `table_test.exs` → `data_display/table_test.exs`
- [ ] Move `left_menu_test.exs` → `navigation/left_menu_test.exs`
- [ ] Move `form/input_types_test.exs` → `data_entry/input_types_test.exs`
- [ ] Move `form/switch_test.exs` → `data_entry/switch_test.exs`
- [ ] Move `fun/spotlight_search_test.exs` → `fun/spotlight_search_test.exs`
- [ ] Update test module names to match new component modules

#### 1.12 Verify Phase 1
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix test` passes (all existing tests)
- [ ] `mix format --check-formatted` passes

---

### Phase 2: Migrate Existing Components to Custom Elements

#### 2.1 Components with direct element mapping (currently NOT using custom elements)
- [ ] `Navbar` → render as `<el-dm-navbar>`
- [ ] `Progress` → render as `<el-dm-progress>`
- [ ] `Tooltip` → render as `<el-dm-tooltip>`
- [ ] `Table` → render as `<el-dm-table>`
- [ ] `Markdown` → render as `<el-dm-markdown>`
- [ ] `Dropdown` → render as `<el-dm-menu>`
- [ ] `LeftMenu` → render as `<el-dm-menu>` / `<el-dm-drawer>`
- [ ] `Form` → render as `<el-dm-form>`
- [ ] `Input` → render as `<el-dm-input>`
- [ ] `CompactInput` → render as `<el-dm-input>` (compact variant)
- [ ] `Slider` → render as `<el-dm-slider>`
- [ ] `Switch` → render as `<el-dm-switch>`
- [ ] `Flash` → render as `<el-dm-alert>`

#### 2.2 Components already using custom elements (verify/update)
- [ ] `Button` — verify `<el-dm-button>` mapping is complete
- [ ] `Card` — verify `<el-dm-card>` mapping is complete
- [ ] `Badge` — verify `<el-dm-badge>` mapping is complete
- [ ] `Breadcrumb` — verify `<el-dm-breadcrumbs>` mapping is complete
- [ ] `Modal/Dialog` — verify `<el-dm-dialog>` mapping is complete
- [ ] `Tab` — verify `<el-dm-tabs>` mapping is complete
- [ ] `Pagination` — verify `<el-dm-pagination>` mapping is complete

#### 2.3 Update/add tests for migrated components
- [ ] Add/update test for `Navbar`
- [ ] Add/update test for `Progress`
- [ ] Add/update test for `Tooltip`
- [ ] Add/update test for `Table`
- [ ] Add/update test for `Markdown`
- [ ] Add/update test for `Dropdown`
- [ ] Add/update test for `LeftMenu`
- [ ] Add/update test for `Form`
- [ ] Add/update test for `Input`
- [ ] Add/update test for `CompactInput`
- [ ] Add/update test for `Slider`
- [ ] Add/update test for `Switch`
- [ ] Add/update test for `Flash`

#### 2.4 Verify Phase 2
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix test` passes
- [ ] Storybook renders migrated components correctly

---

### Phase 3: New Components

#### 3.1 High Priority — create component + test + story
- [ ] `Feedback.Alert` — wraps `<el-dm-alert>` (component, test, story)
- [ ] `DataEntry.Datepicker` — wraps `<el-dm-datepicker>` (component, test, story)

#### 3.2 Medium Priority — create component + test + story
- [ ] `Layout.Accordion` — wraps `<el-dm-accordion>` (component, test, story)
- [ ] `DataEntry.Autocomplete` — wraps `<el-dm-autocomplete>` (component, test, story)
- [ ] `DataDisplay.Chip` — wraps `<el-dm-chip>` (component, test, story)
- [ ] `Navigation.Drawer` — wraps `<el-dm-drawer>` (component, test, story)
- [ ] `DataEntry.FileUpload` — wraps `<el-dm-file-upload>` (component, test, story)
- [ ] `Feedback.Popover` — wraps `<el-dm-popover>` (component, test, story)

#### 3.3 Low Priority — create component + test + story
- [ ] `Navigation.BottomNav` — wraps `<el-dm-bottom-navigation>` (component, test, story)
- [ ] `Navigation.Stepper` — wraps `<el-dm-stepper>` (component, test, story)
- [ ] `DataDisplay.Timeline` — CSS-only (component, test, story)

#### 3.4 Verify Phase 3
- [ ] All new components compile
- [ ] All new tests pass
- [ ] All new storybook stories render

---

### Phase 4: Storybook Refactor

#### 4.1 Create storybook category structure
- [ ] Create `storybook/action/` directory + `index.exs`
- [ ] Create `storybook/data_display/` directory + `index.exs`
- [ ] Create `storybook/data_entry/` directory + `index.exs`
- [ ] Create `storybook/feedback/` directory + `index.exs`
- [ ] Create `storybook/navigation/` directory + `index.exs`
- [ ] Create `storybook/layout/` directory + `index.exs`
- [ ] Create `storybook/icon/` directory + `index.exs`
- [ ] Create `storybook/fun/` directory + `index.exs`
- [ ] Update root `storybook/index.exs` to reference category folders

#### 4.2 Rewrite stories — Action (3 stories)
- [ ] `action/button.story.exs` — variants, sizes, states, compositions
- [ ] `action/link.story.exs` — variants, external links, phx-navigate
- [ ] `action/dropdown.story.exs` — basic, with icons, positions

#### 4.3 Rewrite stories — Data Display (12 stories)
- [ ] `data_display/avatar.story.exs`
- [ ] `data_display/badge.story.exs`
- [ ] `data_display/card.story.exs`
- [ ] `data_display/chip.story.exs` (new)
- [ ] `data_display/flash.story.exs`
- [ ] `data_display/markdown.story.exs`
- [ ] `data_display/pagination.story.exs`
- [ ] `data_display/progress.story.exs`
- [ ] `data_display/skeleton.story.exs`
- [ ] `data_display/table.story.exs`
- [ ] `data_display/timeline.story.exs` (new)
- [ ] `data_display/tooltip.story.exs`

#### 4.4 Rewrite stories — Data Entry (12 stories)
- [ ] `data_entry/autocomplete.story.exs` (new)
- [ ] `data_entry/checkbox.story.exs`
- [ ] `data_entry/compact_input.story.exs`
- [ ] `data_entry/datepicker.story.exs` (new)
- [ ] `data_entry/file_upload.story.exs` (new)
- [ ] `data_entry/form.story.exs`
- [ ] `data_entry/input.story.exs`
- [ ] `data_entry/radio.story.exs`
- [ ] `data_entry/select.story.exs`
- [ ] `data_entry/slider.story.exs`
- [ ] `data_entry/switch.story.exs`
- [ ] `data_entry/textarea.story.exs`

#### 4.5 Rewrite stories — Feedback (5 stories)
- [ ] `feedback/alert.story.exs` (new)
- [ ] `feedback/dialog.story.exs`
- [ ] `feedback/loading.story.exs`
- [ ] `feedback/modal.story.exs`
- [ ] `feedback/popover.story.exs` (new)

#### 4.6 Rewrite stories — Navigation (9 stories)
- [ ] `navigation/appbar.story.exs`
- [ ] `navigation/actionbar.story.exs`
- [ ] `navigation/bottom_nav.story.exs` (new)
- [ ] `navigation/breadcrumb.story.exs`
- [ ] `navigation/drawer.story.exs` (new)
- [ ] `navigation/left_menu.story.exs`
- [ ] `navigation/navbar.story.exs`
- [ ] `navigation/stepper.story.exs` (new)
- [ ] `navigation/tab.story.exs`

#### 4.7 Rewrite stories — Layout (3 stories)
- [ ] `layout/accordion.story.exs` (new)
- [ ] `layout/divider.story.exs`
- [ ] `layout/theme_switcher.story.exs`

#### 4.8 Rewrite stories — Icon (1 story)
- [ ] `icon/icons.story.exs`

#### 4.9 Rewrite stories — Fun (6 stories)
- [ ] `fun/button_noise.story.exs`
- [ ] `fun/eclipse.story.exs`
- [ ] `fun/plasma_ball.story.exs`
- [ ] `fun/signature.story.exs`
- [ ] `fun/snow.story.exs`
- [ ] `fun/spotlight_search.story.exs`

#### 4.10 Clean up legacy storybook files
- [ ] Remove `storybook/components/ui_showcase.story.exs`
- [ ] Remove `storybook/components/forms_showcase.story.exs`
- [ ] Remove `storybook/components/fun_showcase.story.exs`
- [ ] Remove old `storybook/components/` directory (after all stories moved)
- [ ] Remove storybook stories for features not in v9 (color_picker, range_slider, rating, rich_text, search_with_suggestions, tags, password_strength, timepicker, slider_range)

#### 4.11 Verify Phase 4
- [ ] All 51 storybook stories render correctly
- [ ] Category navigation works in storybook sidebar
- [ ] No orphan story files remain in old locations

---

### Phase 5: CSS/JS Cleanup

#### 5.1 CSS cleanup
- [ ] Remove `assets/css/neumorphic.css`
- [ ] Remove `assets/css/neumorphic/` directory (button.css, checkbox.css, radio.css, range.css, table.css)
- [ ] Audit `phoenix_duskmoon.css` — remove any classes duplicated by `@duskmoon-dev/core`
- [ ] Create minimal `assets/css/components.css` for Phoenix-specific overrides only
- [ ] Update `phoenix_duskmoon.css` to new target structure

#### 5.2 JavaScript cleanup
- [ ] Simplify `phoenix_duskmoon.js` — ensure `@duskmoon-dev/elements` import
- [ ] Review `WebComponentHook` — remove any logic now handled by custom elements
- [ ] Review `FormElementHook` — remove duplicated behavior
- [ ] Verify `hooks/index.js` exports all hooks cleanly

#### 5.3 Package exports
- [ ] Update `apps/phoenix_duskmoon/package.json` exports map
- [ ] Verify `priv/static/phoenix_duskmoon.js` builds correctly
- [ ] Verify `priv/static/phoenix_duskmoon.css` builds correctly

#### 5.4 Verify Phase 5
- [ ] `mix tailwind duskmoon` builds without errors
- [ ] `mix bun duskmoon` builds without errors
- [ ] CSS bundle smaller than pre-refactor (compare file sizes)
- [ ] No neumorphic references remain in codebase

---

### Phase 6: Backwards Compatibility Removal & Final Polish

#### 6.1 Remove backwards-compatible shims
- [ ] Remove re-export/defdelegate modules at old paths
- [ ] Update all internal imports to use new category paths
- [ ] Remove old empty `component/form/` directory (if empty)

#### 6.2 Update storybook app references
- [ ] Update `storybook.ex` — story paths point to new category folders
- [ ] Update `router.ex` if storybook routes reference old paths
- [ ] Update storybook CSS/JS if any component references changed

#### 6.3 Fill test coverage gaps
- [ ] Add tests for `Action.Link`
- [ ] Add tests for `Action.Dropdown`
- [ ] Add tests for `DataDisplay.Avatar`
- [ ] Add tests for `DataDisplay.Badge`
- [ ] Add tests for `DataDisplay.Flash`
- [ ] Add tests for `DataDisplay.Progress`
- [ ] Add tests for `DataDisplay.Tooltip`
- [ ] Add tests for `DataEntry.Checkbox`
- [ ] Add tests for `DataEntry.CompactInput`
- [ ] Add tests for `DataEntry.Form`
- [ ] Add tests for `DataEntry.Radio`
- [ ] Add tests for `DataEntry.Select`
- [ ] Add tests for `DataEntry.Slider`
- [ ] Add tests for `DataEntry.Textarea`
- [ ] Add tests for `Feedback.Loading`
- [ ] Add tests for `Feedback.Dialog`
- [ ] Add tests for `Navigation.Actionbar`
- [ ] Add tests for `Navigation.Appbar`
- [ ] Add tests for `Navigation.Breadcrumb`
- [ ] Add tests for `Navigation.Navbar`
- [ ] Add tests for `Navigation.PageFooter`
- [ ] Add tests for `Navigation.PageHeader`
- [ ] Add tests for `Navigation.Tab`
- [ ] Add tests for `Layout.Divider`
- [ ] Add tests for `Layout.ThemeSwitcher`
- [ ] Add tests for `Fun.ButtonNoise`
- [ ] Add tests for `Fun.Eclipse`
- [ ] Add tests for `Fun.PlasmaBall`
- [ ] Add tests for `Fun.Signature`
- [ ] Add tests for `Fun.Snow`

#### 6.4 Update documentation
- [ ] Update `CLAUDE.md` — new component paths, categories, import patterns
- [ ] Update `INTEGRATION_GUIDE.md` — new usage patterns
- [ ] Update `README.md` — v9 architecture overview
- [ ] Update `.claude/skills/` — reflect new structure

#### 6.5 Final verification
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix test` passes — all components tested
- [ ] `mix format --check-formatted` passes
- [ ] Storybook renders all 51 pages correctly
- [ ] No deprecated module references remain
- [ ] No neumorphic CSS references remain
- [ ] `@duskmoon-dev/core` is sole design system dependency
- [ ] All hooks exported and documented

---

### Summary Counts

| Phase | Tasks | Status |
|-------|-------|--------|
| Phase 1: Scaffold & Reorganize | 68 | Not started |
| Phase 2: Migrate to Custom Elements | 37 | Not started |
| Phase 3: New Components | 14 | Not started |
| Phase 4: Storybook Refactor | 62 | Not started |
| Phase 5: CSS/JS Cleanup | 14 | Not started |
| Phase 6: Final Polish | 43 | Not started |
| **Total** | **238** | **Not started** |

---

## 11. Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking existing consumers | Phase 1 creates backwards-compatible re-exports; remove in Phase 6 |
| Custom element behavior differs from current | Test each migration against storybook before merging |
| Storybook framework limitations | phoenix_storybook 0.9 supports VariationGroup; verify category index support |
| Missing custom element for some components | CSS-only components are explicitly allowed (section 3.4 Phase 4) |
| Build system complexity | Each phase must pass CI before next phase starts |

---

## Appendix A: Full Component Mapping

| Current Module | New Module | Custom Element | Category |
|---------------|-----------|----------------|----------|
| `Button` | `Action.Button` | `<el-dm-button>` | Action |
| `Link` | `Action.Link` | `<a>` (native) | Action |
| `Dropdown` | `Action.Dropdown` | `<el-dm-menu>` | Action |
| `Avatar` | `DataDisplay.Avatar` | CSS-only | Data Display |
| `Badge` | `DataDisplay.Badge` | `<el-dm-badge>` | Data Display |
| `Card` | `DataDisplay.Card` | `<el-dm-card>` | Data Display |
| `Flash` | `DataDisplay.Flash` | `<el-dm-alert>` | Data Display |
| `Markdown` | `DataDisplay.Markdown` | `<el-dm-markdown>` | Data Display |
| `Pagination` | `DataDisplay.Pagination` | `<el-dm-pagination>` | Data Display |
| `Progress` | `DataDisplay.Progress` | `<el-dm-progress>` | Data Display |
| `Skeleton` | `DataDisplay.Skeleton` | CSS-only | Data Display |
| `Table` | `DataDisplay.Table` | `<el-dm-table>` | Data Display |
| `Tooltip` | `DataDisplay.Tooltip` | `<el-dm-tooltip>` | Data Display |
| `Form.Checkbox` | `DataEntry.Checkbox` | CSS-only | Data Entry |
| `Form.CompactInput` | `DataEntry.CompactInput` | `<el-dm-input>` | Data Entry |
| `Form` | `DataEntry.Form` | `<el-dm-form>` | Data Entry |
| `Form.Input` | `DataEntry.Input` | `<el-dm-input>` | Data Entry |
| `Form.Radio` | `DataEntry.Radio` | CSS-only | Data Entry |
| `Form.Select` | `DataEntry.Select` | CSS-only | Data Entry |
| `Form.Slider` | `DataEntry.Slider` | `<el-dm-slider>` | Data Entry |
| `Form.Switch` | `DataEntry.Switch` | `<el-dm-switch>` | Data Entry |
| `Form.Textarea` | `DataEntry.Textarea` | CSS-only | Data Entry |
| `Loading` | `Feedback.Loading` | CSS-only | Feedback |
| `Modal` | `Feedback.Dialog` | `<el-dm-dialog>` | Feedback |
| `Actionbar` | `Navigation.Actionbar` | CSS-only | Navigation |
| `Appbar` | `Navigation.Appbar` | CSS-only | Navigation |
| `Breadcrumb` | `Navigation.Breadcrumb` | `<el-dm-breadcrumbs>` | Navigation |
| `LeftMenu` | `Navigation.LeftMenu` | `<el-dm-menu>` | Navigation |
| `Navbar` | `Navigation.Navbar` | `<el-dm-navbar>` | Navigation |
| `PageFooter` | `Navigation.PageFooter` | CSS-only | Navigation |
| `PageHeader` | `Navigation.PageHeader` | CSS-only | Navigation |
| `Tab` | `Navigation.Tab` | `<el-dm-tabs>` | Navigation |
| `Divider` | `Layout.Divider` | CSS-only | Layout |
| `ThemeSwitcher` | `Layout.ThemeSwitcher` | Hook-based | Layout |
| `Icons` | `Icon.Icons` | Inline SVG | Icon |
| `Fun.ButtonNoise` | `Fun.ButtonNoise` | CSS/JS | Fun |
| `Fun.Eclipse` | `Fun.Eclipse` | CSS | Fun |
| `Fun.PlasmaBall` | `Fun.PlasmaBall` | CSS | Fun |
| `Fun.Signature` | `Fun.Signature` | Canvas | Fun |
| `Fun.Snow` | `Fun.Snow` | CSS | Fun |
| `Fun.SpotlightSearch` | `Fun.SpotlightSearch` | Hook | Fun |

## Appendix B: New Components to Create

| New Module | Custom Element | Category |
|-----------|----------------|----------|
| `DataDisplay.Chip` | `<el-dm-chip>` | Data Display |
| `DataDisplay.Timeline` | CSS-only | Data Display |
| `DataEntry.Autocomplete` | `<el-dm-autocomplete>` | Data Entry |
| `DataEntry.Datepicker` | `<el-dm-datepicker>` | Data Entry |
| `DataEntry.FileUpload` | `<el-dm-file-upload>` | Data Entry |
| `Feedback.Alert` | `<el-dm-alert>` | Feedback |
| `Feedback.Popover` | `<el-dm-popover>` | Feedback |
| `Navigation.BottomNav` | `<el-dm-bottom-navigation>` | Navigation |
| `Navigation.Drawer` | `<el-dm-drawer>` | Navigation |
| `Navigation.Stepper` | `<el-dm-stepper>` | Navigation |
| `Layout.Accordion` | `<el-dm-accordion>` | Layout |
