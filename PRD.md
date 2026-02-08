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

## 10. Success Criteria

- [ ] All components organized into 8 categories
- [ ] All available custom elements have Phoenix wrapper components
- [ ] Every component has a storybook page with demos and docs
- [ ] Every component has at least one test
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix test` passes (all existing + new tests)
- [ ] `mix format --check-formatted` passes
- [ ] Storybook renders all component pages correctly
- [ ] No references to neumorphic CSS remain
- [ ] `@duskmoon-dev/core` is the sole design system dependency
- [ ] CSS bundle size is smaller than before refactor
- [ ] All hooks documented and exported correctly

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
