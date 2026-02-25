# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Phoenix Duskmoon UI is an umbrella project providing Duskmoon UI components for Phoenix applications. It consists of three main applications:

1. **phoenix_duskmoon** - Core UI component library (Hex package)
2. **duskmoon_storybook** - Storybook backend/context
3. **duskmoon_storybook_web** - Live Storybook web application for component showcase

## Color Policy

**All colors MUST come from theme CSS variables.** Never use hardcoded color values (hex, rgb, hsl, named colors) in components or styles. Instead:

- Use existing `@duskmoon-dev/core` theme variables: `var(--color-primary)`, `var(--color-surface)`, `var(--color-on-surface)`, etc.
- If a needed color doesn't exist in the theme, **define a new CSS custom property** in the theme's variable system and reference it via `var(--color-your-name)`.
- This ensures all components adapt correctly when themes change (e.g., sunshine/moonlight/auto).

## Upstream Dependencies Policy

**This project ONLY uses `@duskmoon-dev/core` and `@duskmoon-dev/elements` for styling and custom elements.** Do NOT use `@gsmlg/lit` or other UI libraries.

- **CSS/Theming**: Use `@duskmoon-dev/core` CSS classes. Read `.claude/skills/duskmoon-dev-core/SKILL.md` for the full API.
- **Custom Elements**: Use `@duskmoon-dev/el-*` packages. Read `.claude/skills/duskmoon-elements/SKILL.md` and its `references/` for the full API.
- **Missing features**: If `@duskmoon-dev/core` or `@duskmoon-dev/elements` is missing a needed CSS class, component, or feature, file a GitHub issue as a feature request to the upstream repo instead of working around it with other libraries.

### Upstream GitHub Repos for Issues

- **CSS/Theme issues**: https://github.com/duskmoon-dev/duskmoonui
- **Custom Element issues**: https://github.com/duskmoon-dev/duskmoon-elements

## @duskmoon-dev/core (upstream dependency)

`@duskmoon-dev/core` lives in `duskmoon-dev/duskmoonui` — it is our own package. If core has bugs or missing features, file a GitHub issue on `duskmoon-dev/duskmoonui` with the label `internal request`. Never use `bun patch` or other local workarounds.

## Architecture

This is an Elixir umbrella project with Phoenix LiveView components and a Node.js workspace:

- **Umbrella Structure**: Run commands from root directory - they cascade to `apps/*` subdirectories
- **Component Library**: Phoenix LiveView HEEX components wrapping HTML Custom Elements with `@doc type: :component`
- **Frontend Dependencies**: Uses `@duskmoon-dev/core` (CSS design system) and `@duskmoon-dev/elements` (custom elements)
- **Storybook**: Live component showcase for development and documentation

### v9 Architecture (Custom Elements)

Phoenix Duskmoon UI v9 uses HTML Custom Elements for rendering:

```
Phoenix LiveView
       │
       ▼
┌──────────────────┐
│  HEEX Components │  ← dm_btn, dm_card, dm_input (API layer)
│  (dm_* prefix)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Custom Elements │  ← <el-dm-button>, <el-dm-card> (rendering layer)
│  (el-dm-* tags)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ @duskmoon-dev/   │  ← CSS custom properties, design tokens
│     core         │
└──────────────────┘
```

**CSS Class Naming (BEM Convention)**:
- Component: `dm-component` (e.g., `dm-btn`, `dm-card`, `dm-input`)
- Variant/Modifier: `dm-component--variant` (e.g., `dm-btn--primary`, `dm-input--lg`)
- Element: `dm-component__element` (e.g., `dm-card__header`, `dm-switch__track`)

### Component Organization

Components are organized into three main categories:

1. **Standard Components** (`PhoenixDuskmoon.Component.*`): UI components like buttons, cards, forms, navigation
   - Imported via `use PhoenixDuskmoon.Component` in view helpers
   - All use `dm_` prefix (e.g., `dm_btn`, `dm_card`, `dm_form`)

2. **Form Components** (`PhoenixDuskmoon.Component.Form.*`): Specialized form inputs
   - Separated into individual modules: Input, CompactInput, Checkbox, Radio, Select, Slider, Switch, Textarea
   - The main Form module provides form container, labels, and error handling
   - **Important**: Never use `<.variation />` in storybook templates - it's undefined. Use actual component calls like `<.dm_art_snow id="..." />`

3. **CSS Art Components** (`PhoenixDuskmoon.CssArt.*`): Decorative/animated visual effects
   - ButtonNoise, Eclipse, PlasmaBall, Signature, Snow, SpotlightSearch
   - Imported via `use PhoenixDuskmoon.CssArt` in view helpers
   - Use `dm_art_` prefix (e.g., `dm_art_snow`, `dm_art_plasma_ball`)

### Storybook Architecture

**PhoenixStorybook stories** are in `.story.exs` files under `apps/duskmoon_storybook_web/storybook/{category}/`:
- Each story uses `PhoenixStorybook.Story` with `%Variation{}` structs
- When using templates, **always use explicit component calls** - the `.variation` helper is not available in template contexts

**Demo pages** (standalone controller-based pages) live under `apps/duskmoon_storybook_web/lib/duskmoon_storybook_web/controllers/components/`:
- 8 controllers (one per category): ActionController, DataDisplayController, DataEntryController, FeedbackController, NavigationController, LayoutController, IconController, FunComponentController
- Each controller has a matching HTML module and HEEX templates directory
- Routes are scoped under `/components/{category}/{component}` in `router.ex`
- The sidebar in `app.html.heex` links to all demo pages
- The appbar uses plain HTML with `@duskmoon-dev/core` CSS classes (`.appbar`, `.appbar-sticky`, `.appbar-primary`, etc.) — not a custom element

### Custom Elements Registration

The storybook registers individual `@duskmoon-dev/el-*` packages in `apps/duskmoon_storybook_web/assets/js/app.js`:
```javascript
import "@duskmoon-dev/el-button/register";
import "@duskmoon-dev/el-card/register";
// ... etc
```

Each `el-*` element must be explicitly imported for its custom element tag to be defined. Without registration, content inside the custom element's `<template>` is inert/invisible.

## Development Commands

### Essential Commands
- `mix setup` - Setup all applications in the umbrella
- `mix test` - Run all tests across all apps
- `mix test path/to/file_test.exs` - Run specific test file
- `mix test path/to/file_test.exs:line_number` - Run specific test at line
- `mix format` - Format all code (required before commits)
- `mix format --check-formatted` - Check formatting without changes
- `mix compile --warnings-as-errors` - Compile with warnings as errors

### Application-Specific Commands
- `mix phx.server` - Start storybook web server (run from root, listens on port 4600)
- `mix tailwind storybook` - Build Storybook CSS
- `mix bun storybook` - Build Storybook JS
- `mix tailwind duskmoon` - Build main package CSS
- `mix bun duskmoon` - Build main package JS

### Package Management
- `mix deps.get` - Install Elixir dependencies
- `bun install` - Install Node.js dependencies (in workspaces)
- `mix cmd mix deps.get` - Run command in all umbrella apps

### Version Management

**Version Files** (all three must stay in sync):
- `apps/phoenix_duskmoon/mix.exs` - Source of truth (@version)
- `apps/phoenix_duskmoon/package.json` - npm package version
- `mix.exs` (umbrella root) - Tracks phoenix_duskmoon version

**Commands**:
- `mix version.sync` - Sync all version files (run after pulling main branch)

### Publishing

Releases are triggered manually via GitHub Actions `workflow_dispatch` or by pushing a version tag (`v*.*.*`).

**How it works**:
1. Run the Release workflow from GitHub Actions (or push a `v*.*.*` tag)
2. CI sets the version in all three version files
3. Runs `mix prepublish` to build CSS/JS assets
4. Publishes to Hex.pm and npm
5. Builds and pushes Docker demo image
6. Creates GitHub Release with links to published packages
- `mix prepublish` - Prepare package manually (copies README, builds CSS/JS)
- Only needed for local testing or manual publishing

### Testing and Quality
- Tests run on Elixir 1.18 with OTP 27/28 in CI
- `mix format --check-formatted` is enforced in CI
- Compilation with warnings as errors
- Use `render_component/2` from Phoenix.LiveViewTest for component testing

## Code Style Guidelines

### Elixir Conventions
- Snake_case for variables/functions, CamelCase for modules
- Use `@moduledoc` and `@doc` for all public modules/functions
- Import modules at top of file, avoid aliasing unless necessary
- Error handling: use `with` statements for multiple operations, `try/rescue` for exceptions

### Component Development
- Components use `attr/3` and `slot/2` for LiveView HEEX components
- All components must have `@doc type: :component`
- Component naming: prefix with `dm_` (e.g., `dm_btn`, `dm_mdi`)
- Form components go in `PhoenixDuskmoon.Component.Form.*` namespace
- Fun/interactive components go in `PhoenixDuskmoon.Component.Fun.*` namespace
- Use `render_component/2` for component tests

### Frontend/Styling
- CSS built with TailwindCSS v4+ using `@duskmoon-dev/core` design system
- Components render as HTML Custom Elements (`<el-dm-button>`, `<el-dm-card>`, etc.)
- CSS uses BEM naming: `dm-component`, `dm-component--variant`, `dm-component__element`
- Import structure:
  ```css
  @import "tailwindcss";
  @plugin "@duskmoon-dev/core/plugin";
  ```
- For CSS-only layouts (e.g., appbar, footer), prefer `@duskmoon-dev/core` CSS classes over custom elements when appropriate

### Test Writing
- Test files mirror source structure: `apps/phoenix_duskmoon/test/phoenix_duskmoon/component/`
- Use `async: true` for parallel test execution when possible
- Import `Phoenix.LiveViewTest` and use `render_component/2`
- Use partial string matching with `=~` for HTML assertions (avoid exact matches that break with formatting)

## File Structure

- `apps/phoenix_duskmoon/` - Main component library (published to Hex)
  - `lib/phoenix_duskmoon/component/` - Standard UI components
  - `lib/phoenix_duskmoon/component/form/` - Form input components
  - `lib/phoenix_duskmoon/component/fun/` - Interactive/animated components
  - `test/` - Test files mirroring lib structure
  - `assets/css/` - CSS source files
- `apps/duskmoon_storybook/` - Storybook backend application
- `apps/duskmoon_storybook_web/` - Storybook Phoenix web application
  - `storybook/` - PhoenixStorybook story definitions (.story.exs) organized by category
  - `lib/.../controllers/components/` - Demo page controllers, HTML modules, and HEEX templates
  - `assets/js/app.js` - Custom element registration
- `package.json` - Root workspace configuration
- Each app has its own `mix.exs` with shared dependencies

## Development Workflow

1. Run `mix setup` after cloning to initialize all apps
2. Use `mix phx.server` from root to start storybook for component development
3. Format code with `mix format` before committing
4. Run tests with `mix test` - CI enforces formatting and compilation standards
5. Use `mix tailwind` and `mix bun` commands for CSS/JS builds during development

## Using Phoenix Duskmoon UI in Other Projects

When working on Phoenix projects that use the Phoenix Duskmoon UI library:

### Component Usage Pattern
- All components are prefixed with `dm_` (e.g., `<.dm_btn>`, `<.dm_card>`, `<.dm_mdi>`)
- Components require `use PhoenixDuskmoon.Component` and `use PhoenixDuskmoon.CssArt` in view helpers
- **v9 Note**: Components render as HTML Custom Elements (e.g., `<el-dm-button>`, `<el-dm-card>`)
- Common component patterns:
  ```elixir
  # Buttons with variants (renders as <el-dm-button>)
  <.dm_btn variant="primary" size="md">Click me</.dm_btn>
  <.dm_btn variant="secondary" loading={@loading}>Loading</.dm_btn>
  <.dm_btn variant="error" shape="circle">×</.dm_btn>

  # Cards with slots (renders as <el-dm-card>)
  <.dm_card class="p-6">
    <:title><h3>Title</h3></:title>
    <p>Content here</p>
    <:footer><.dm_btn>Action</.dm_btn></:footer>
  </.dm_card>

  # Icons (Material Design or Bootstrap)
  <.dm_mdi name="home" />
  <.dm_bsi name="house" />

  # Forms with styling
  <.dm_form for={@form} phx-submit="save">
    <!-- form fields -->
    <.dm_btn variant="primary" type="submit">Save</.dm_btn>
  </.dm_form>
  ```

### Common Attributes
- `variant`: primary, secondary, accent, info, success, warning, error, ghost, link, outline
- `size`: xs, sm, md, lg
- `shape`: square, circle
- `loading`: boolean for loading state
- `disabled`: boolean for disabled state
- `class`: additional CSS classes

### Layout Components
- `<.dm_appbar>` - Top navigation bar with `:brand`, `:nav`, `:actions` slots
- `<.dm_page_header>` - Page title section
- `<.dm_breadcrumb>` - Navigation breadcrumbs
- `<.dm_tab>` - Tabbed content areas
- `<.dm_modal>` - Dialog modals with `:header`, `:footer` slots

### CSS Integration
Projects need these CSS imports:
```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
```

**Note**: v9 uses `@plugin` (Tailwind v4 plugin directive) for `@duskmoon-dev/core` which includes all theme variables, design tokens, and component styles.

### JavaScript Hooks Setup (Required)

**IMPORTANT**: Some components require LiveView hooks to function properly. You must register these hooks in your application.

Components that require hooks:
- `<.dm_theme_switcher>` - Theme switching with localStorage
- `<.dmf_spotlight>` - Keyboard shortcut handling (Cmd/Ctrl+K)
- `<.dm_page_header>` - Intersection observer for scroll effects

#### Setup Instructions

1. In your `assets/js/app.js` or equivalent:

```javascript
import {LiveSocket} from "phoenix_live_view"
import * as DuskmoonHooks from "phoenix_duskmoon/hooks"

// When creating your LiveSocket:
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: DuskmoonHooks  // Add this line
})
```

2. If you need to merge with existing hooks:

```javascript
import * as DuskmoonHooks from "phoenix_duskmoon/hooks"
import MyCustomHooks from "./my_hooks"

let hooks = {...DuskmoonHooks, ...MyCustomHooks}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: hooks
})
```

3. Individual hook imports (if needed):

```javascript
import {ThemeSwitcher, Spotlight, PageHeader} from "phoenix_duskmoon/hooks"

let hooks = {
  ThemeSwitcher,
  Spotlight,
  PageHeader,
  // ... your other hooks
}
```

**Note**: Components using hooks will not function correctly without this setup. The hooks handle client-side interactions like keyboard shortcuts, localStorage persistence, and scroll-based effects that cannot be handled server-side.

### Available Components
- **Basic**: buttons, cards, links, icons, avatar, badge, divider, dropdown, progress, tooltip
- **Navigation**: appbar, navbar, breadcrumb, tabs
- **Data Display**: tables, pagination, flash, markdown
- **Forms**: form containers, inputs, checkbox, radio, select, slider, switch, textarea
- **Layout**: page headers, footers, theme switcher, loading, modal
- **Fun**: button noise, eclipse, plasma ball, signature, snow effects, spotlight search

When adding new UI components, follow the established pattern and use the appropriate Duskmoon UI components rather than custom HTML/CSS.
