# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Phoenix Duskmoon UI is an umbrella project providing Duskmoon UI components for Phoenix applications. It consists of three main applications:

1. **phoenix_duskmoon** - Core UI component library (Hex package)
2. **duskmoon_storybook** - Storybook backend/context
3. **duskmoon_storybook_web** - Live Storybook web application for component showcase

## Architecture

This is an Elixir umbrella project with Phoenix LiveView components and a Node.js workspace:

- **Umbrella Structure**: Run commands from root directory - they cascade to `apps/*` subdirectories
- **Component Library**: Phoenix LiveView HEEX components with `@doc type: :component`
- **Frontend Dependencies**: Uses `duskmoonui` npm package (extends `daisyui` with tertiary colors)
- **Storybook**: Live component showcase for development and documentation

### Component Organization

Components are organized into three main categories:

1. **Standard Components** (`PhoenixDuskmoon.Component.*`): UI components like buttons, cards, forms, navigation
   - Imported via `use PhoenixDuskmoon.Component` in view helpers
   - All use `dm_` prefix (e.g., `dm_btn`, `dm_card`, `dm_form`)

2. **Form Components** (`PhoenixDuskmoon.Component.Form.*`): Specialized form inputs
   - Separated into individual modules: Input, CompactInput, Checkbox, Radio, Select, Slider, Switch, Textarea
   - The main Form module provides form container, labels, and error handling
   - **Important**: Never use `<.variation />` in storybook templates - it's undefined. Use actual component calls like `<.dm_fun_snow id="..." />`

3. **Fun Components** (`PhoenixDuskmoon.Component.Fun.*`): Interactive/animated components
   - ButtonNoise, Eclipse, PlasmaBall, Signature, Snow, SpotlightSearch
   - Imported via `use PhoenixDuskmoon.Fun` in view helpers
   - Use `dm_fun_` prefix (e.g., `dm_fun_snow`, `dm_fun_plasma_ball`)

### Storybook Architecture

Storybook stories are defined in `.story.exs` files under `apps/duskmoon_storybook_web/storybook/components/`:
- Each story uses `PhoenixStorybook.Story` with `%Variation{}` structs
- Variations can have `attributes` or custom `template` blocks
- When using templates, **always use explicit component calls** - the `.variation` helper is not available in template contexts

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
- `mix phx.server` - Start storybook web server (run from root)
- `mix tailwind storybook` - Build Storybook CSS
- `mix bun storybook` - Build Storybook JS
- `mix tailwind duskmoon` - Build main package CSS
- `mix bun duskmoon` - Build main package JS

### Package Management
- `mix deps.get` - Install Elixir dependencies
- `bun install` - Install Node.js dependencies (in workspaces)
- `mix cmd mix deps.get` - Run command in all umbrella apps

### Publishing
- `mix prepublish` - Prepare package for publishing (copies README, builds CSS/JS)
- Version is managed in `apps/phoenix_duskmoon/mix.exs` (@version)
- Also update `package.json` version to match

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
- CSS built with TailwindCSS v4+ using `duskmoonui` theme
- The `duskmoonui` npm package extends `daisyui` with tertiary color support
- Import structure:
  ```css
  @import "tailwindcss";
  @plugin "@tailwindcss/typography";
  @plugin "duskmoonui";
  @import "phoenix_duskmoon/theme";
  @import "phoenix_duskmoon/components";
  ```

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
  - `storybook/components/` - Story definitions (.story.exs files)
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
- Components require `use PhoenixDuskmoon.Component` and `use PhoenixDuskmoon.Fun` in view helpers
- Common component patterns:
  ```elixir
  # Buttons with variants
  <.dm_btn variant="primary" size="md">Click me</.dm_btn>
  <.dm_btn variant="secondary" loading={@loading}>Loading</.dm_btn>
  <.dm_btn variant="error" shape="circle">×</.dm_btn>

  # Cards with slots
  <.dm_card class="p-6">
    <:header><h3>Title</h3></:header>
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
@plugin "@tailwindcss/typography";
@plugin "duskmoonui";
@import "phoenix_duskmoon/theme";
@import "phoenix_duskmoon/components";
```

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
