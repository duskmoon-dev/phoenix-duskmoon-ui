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
- Use `bun` for all frontend package management (not npm/yarn)
- The theme provides custom component styles and color variants via CSS custom properties

### Upstream-first component selection

Choose the smallest upstream integration that provides the required behavior:

| Need | Upstream package |
| --- | --- |
| Ordinary UI, styling, layout, and themes | `@duskmoon-dev/core` through its Tailwind v4 plugin and CSS classes |
| Pure CSS art | `@duskmoon-dev/css-art` |
| Complex elements with encapsulated structure or behavior | `@duskmoon-dev/elements` (`<el-dm-*>`) |
| CSS art custom elements | `@duskmoon-dev/art-elements` (`<el-dm-art-*>`) |
| Rich client-side interaction requiring React | `@duskmoon-dev/components` |
| Rich interactive art requiring React | `@duskmoon-dev/art-components` |

- Start with Core/CSS Art and native HEEX. Use Elements for complex custom elements and Components for rich client-side interaction; do not add a client dependency when CSS or existing Phoenix behavior meets the requirement.
- For individual custom elements, prefer the matching published `@duskmoon-dev/el-*` package when the full registry is unnecessary. React components require an explicit JavaScript mount/unmount boundary compatible with LiveView; they are not HEEX components or custom-element tags.
- Reuse upstream styles and behavior. Keep Phoenix wrappers only where they add meaningful Phoenix integration, semantics, slots, or behavior. Simple markup such as `<kbd class="kbd">` needs no wrapper or extra configuration.
- Reuse the canonical component API rather than adding duplicate components for the same responsibility.
- For complex forms, prefer `@duskmoon-dev/components` with React-owned state and JSON values. Use `dm_react_form` and its explicit LiveView event contract; backend handlers validate and persist JSON, while React handles field state and serialization. Keep `dm_form` for existing Phoenix-native forms.
- Simplification must preserve required behavior: for example, interactive Diff needs a working slider, not only styled comparison panels. Verify actual interactions in Storybook, not just rendered markup or successful compilation.

### Upstream synchronization

- Use the single repository skill [cmd-update-upstream-duskmoon](.agents/skills/cmd-update-upstream-duskmoon/SKILL.md) for upstream upgrades and synchronization.
- Review all six packages listed above. Update packages declared or used by the repository; add dependencies only when an actual integration needs them. Packages are independently versioned.
- For each affected component, choose an explicit Add, Update, or Remove path. Keep its Phoenix API, imports, CSS, registrations or client mounts, tests, Storybook examples, and documentation consistent.
- When removing duplicate or obsolete wrappers, migrate consumers to upstream markup or the canonical component, document breaking changes, and remove unused integration code and dependencies. Preserve still-required Phoenix behavior.
- Verify shipped upstream exports and contracts. Do not recreate upstream styles locally to conceal dependency defects; follow the applicable `upstream-github-routing` skill when a dependency is defective.

## Agent note

After we add new feature, change architecture or fix issues we write agent note.
When save note to agent-note, should add labels:
- `project: duskmoon`
- `variant: phoenix`
