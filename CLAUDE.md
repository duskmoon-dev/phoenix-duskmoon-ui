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

## Development Commands

### Essential Commands
- `mix setup` - Setup all applications in the umbrella
- `mix test` - Run all tests across all apps
- `mix test path/to/file_test.exs` - Run specific test file
- `mix test path/to/file_test.exs:line_number` - Run specific test
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

### Testing and Quality
- Tests run on Elixir 1.18 with OTP 27/28 in CI
- `mix format --check-formatted` is enforced in PRs
- Compilation with warnings as errors (with some known exceptions)

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

## File Structure

- `apps/phoenix_duskmoon/` - Main component library (published to Hex)
- `apps/duskmoon_storybook/` - Storybook backend application
- `apps/duskmoon_storybook_web/` - Storybook Phoenix web application
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
  <.dm_mdi>home</.dm_mdi>
  <.dm_bsi>house</.dm_bsi>

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

### Available Components
- **Basic**: buttons, cards, links, icons
- **Navigation**: appbar, navbar, breadcrumb, tabs
- **Data Display**: tables, pagination, flash, markdown
- **Forms**: form containers, loading, modal
- **Layout**: page headers, footers, theme switcher

When adding new UI components, follow the established pattern and use the appropriate Duskmoon UI components rather than custom HTML/CSS.