# Phoenix Duskmoon UI - Agent Guidelines

## Build/Lint/Test Commands
- `mix test` - Run all tests
- `mix test path/to/file_test.exs` - Run single test file
- `mix test path/to/file_test.exs:line_number` - Run specific test
- `mix format` - Format code (required before commits)
- `mix format --check-formatted` - Check formatting without changes
- `mix compile --warnings-as-errors` - Compile with warnings as errors
- `mix deps.get` - Install dependencies
- `mix setup` - Setup project (runs in all apps)

## Code Style Guidelines
- Follow Elixir conventions: snake_case for variables/functions, CamelCase for modules
- Use `@moduledoc` and `@doc` for all public modules/functions
- Components use `attr/3` and `slot/2` for LiveView HEEX components with `@doc type: :component`
- Import modules at top of file, avoid aliasing unless necessary
- Error handling: use `with` statements for multiple operations, `try/rescue` for exceptions
- Tests: use `async: true` when possible, follow ExUnit conventions, use `render_component/2` for component tests
- Format with built-in formatter (.formatter.exs configures inputs and subdirectories)
- Component naming: prefix with `dm_` (e.g., `dm_btn`, `dm_mdi`)
- Umbrella project: run commands from root, they cascade to apps/* subdirectories

## Frontend Dependencies & Styling
- This project uses `@duskmoon-dev/core` as the CSS design system (Tailwind v4 plugin)
- Uses `@duskmoon-dev/elements` for HTML Custom Elements (`<el-dm-*>` tags)
- Use `bun` for all frontend package management (not npm/yarn)
- The theme provides custom component styles and color variants via CSS custom properties