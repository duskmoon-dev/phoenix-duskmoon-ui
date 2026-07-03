# Update Project Skill

Re-analyze project source and regenerate one or more files under `skills/`.

## User Input

```text
$ARGUMENTS
```

## Target Selection

- If `$ARGUMENTS` contains `all`, update both project skills.
- Else if `$ARGUMENTS` contains `duskmoon_bundler` or `duskmoon-bundler`, update only
  `skills/duskmoon_bundler/`.
- Else if `$ARGUMENTS` contains `phoenix-duskmoon-ui`, `phoenix_duskmoon`, or
  `phoenix-duskmoon`, update only `skills/phoenix-duskmoon-ui/`.
- Else if `$ARGUMENTS` is empty, update `skills/phoenix-duskmoon-ui/` for backward
  compatibility.

Only touch files for the selected target skill(s).

## Phoenix Duskmoon UI Skill

Regenerate `skills/phoenix-duskmoon-ui/SKILL.md` and
`skills/phoenix-duskmoon-ui/references/components.md`.

### 1. Scan all component modules

Read every `.ex` file under:

- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/`
- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/css_art/`

For each module, extract:

- Module name and category from the path: action, data_display, data_entry,
  feedback, navigation, layout, icon, fun
- All public `def` functions with `@doc type: :component`
- All `attr/3` declarations: name, type, default, values
- All `slot/2` declarations: name, attrs
- Whether the component requires a LiveView hook

### 2. Scan setup files

Read these files for integration details:

- `apps/phoenix_duskmoon/mix.exs` - version, deps
- `apps/phoenix_duskmoon/package.json` - npm exports
- `apps/phoenix_duskmoon/assets/js/hooks/index.js` - exported hooks
- `apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css` - CSS imports
- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component.ex` - main import module
- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/css_art.ex` - CSS art import module

### 3. Regenerate SKILL.md

Update `skills/phoenix-duskmoon-ui/SKILL.md` with:

- Current version number from `mix.exs`
- Installation instructions: Hex and npm
- Setup steps: Elixir imports, CSS, JS hooks, element registration
- Architecture overview: v9 custom elements
- Hooks reference table
- Component quick reference tables organized by category
- Usage examples covering common patterns
- npm package exports table

Keep the YAML frontmatter `name` and `description` fields. Keep `SKILL.md`
under 500 lines and put detailed reference in the components file.

### 4. Regenerate components.md

Update `skills/phoenix-duskmoon-ui/references/components.md` with the full
attribute and slot reference for every component, organized by category.

### 5. Verify accuracy

After regenerating, spot-check 3-5 components by reading their source to confirm
the documented attrs and slots match the actual code. Fix discrepancies.

### 6. Report changes

List what changed:

- New components added
- Components removed
- Attributes changed
- Version updated

## Duskmoon Bundler Skill

Regenerate `skills/duskmoon_bundler/SKILL.md` and keep
`skills/duskmoon_bundler/agents/openai.yaml` aligned if the skill description or
default prompt changes.

### 1. Scan package metadata

Read:

- `apps/duskmoon_bundler/mix.exs` - version, deps, aliases, docs groups
- `apps/duskmoon_bundler_runtime/mix.exs` - runtime version and public modules
- `apps/duskmoon_npm/mix.exs` - npm task package version and public docs groups
- `apps/duskmoon_bundler/package.json` - package name and frontend/runtime deps
- Root `config/config.exs`, `config/dev.exs`, and `config/test.exs` - in-repo
  profile examples and lint config

Keep package versions current. If `duskmoon_bundler`,
`duskmoon_bundler_runtime`, and `duskmoon_npm` versions differ, document each
explicitly.

### 2. Scan user-facing docs

Read the current setup and feature docs before editing the skill:

- `apps/duskmoon_bundler/README.md`
- `apps/duskmoon_bundler/guides/introduction/getting-started.md`
- `apps/duskmoon_bundler/guides/deployment/production-builds.md`
- `apps/duskmoon_bundler/guides/features/features.md`
- `apps/duskmoon_bundler/guides/features/formatting-and-linting.md`
- `apps/duskmoon_bundler/guides/features/tailwind.md`
- `apps/duskmoon_npm/README.md`
- `apps/duskmoon_npm/guides/introduction/getting-started.md`
- `apps/duskmoon_npm/guides/reference/mix-tasks.md`
- `apps/duskmoon_npm/guides/workflows/dependencies.md`
- `apps/duskmoon_npm/guides/workflows/ci.md`

Read feature-specific docs only when the skill needs that topic:

- `apps/duskmoon_bundler/guides/features/frameworks.md`
- `apps/duskmoon_bundler/guides/features/plugins.md`
- `apps/duskmoon_bundler/guides/features/environment-variables.md`
- `apps/duskmoon_bundler/guides/features/static-assets.md`
- `apps/duskmoon_bundler/guides/features/code-splitting.md`
- `apps/duskmoon_bundler/guides/migration/from-esbuild.md`

### 3. Scan implementation docs from source

Read module docs and task docs that define the real API:

- `apps/duskmoon_bundler/lib/duskmoon_bundler/config.ex`
- `apps/duskmoon_bundler/lib/duskmoon_bundler/config/build.ex`
- `apps/duskmoon_bundler/lib/duskmoon_bundler/config/server.ex`
- `apps/duskmoon_bundler/lib/duskmoon_bundler/dev_server.ex`
- `apps/duskmoon_bundler/lib/duskmoon_bundler/formatter.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.install.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.build.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.dev.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.js.format.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.js.check.ex`
- `apps/duskmoon_bundler/lib/mix/tasks/duskmoon_bundler.lint.ex`
- `apps/duskmoon_bundler_runtime/lib/duskmoon_bundler.ex`
- `apps/duskmoon_bundler_runtime/lib/duskmoon_bundler/preload.ex`
- `apps/duskmoon_bundler_runtime/lib/duskmoon_bundler/runtime/config.ex`
- `apps/duskmoon_npm/lib/mix/tasks/npm.install.ex`
- `apps/duskmoon_npm/lib/mix/tasks/npm.ci.ex`
- `apps/duskmoon_npm/lib/mix/tasks/npm.run.ex`
- `apps/duskmoon_npm/lib/mix/tasks/npm.exec.ex`

Use source docs over older guides when they disagree.

### 4. Regenerate SKILL.md

Update `skills/duskmoon_bundler/SKILL.md` with:

- YAML frontmatter with `name: duskmoon-bundler`; keep the directory name
  `duskmoon_bundler`
- A trigger-rich `description` covering install, config, dev server, runtime
  helpers, production builds, Tailwind, formatter, lint, named profiles, and
  migration from esbuild, Tailwind CLI, Bun, npm, and yarn workflows
- Current package version(s)
- Recommended setup path using `mix igniter.install duskmoon_bundler`
- Manual dependency setup with `:duskmoon_bundler_runtime` and
  `:duskmoon_bundler`
- `duskmoon_npm` usage for package management and when to add
  `:duskmoon_npm` explicitly
- Replacement guidance: use DuskmoonBundler for esbuild/Tailwind assets and
  `mix npm.install` instead of `bun add`, `bun install`, `npm install`, or
  `yarn install`
- npm workflow commands: `mix npm.init`, `mix npm.install`,
  `mix npm.install package`, `mix npm.install package --save-dev`,
  `mix npm.ci`, `mix npm.install --frozen`, `mix npm.verify`,
  `mix npm.run script`, and `mix npm.exec binary`
- Umbrella npm workspace guidance: root `package.json`, per-web-app manifests,
  root `npm.lock`, and running `mix npm.install` from the umbrella root
- Warning not to use `only: :dev` for `:duskmoon_bundler`
- Single-app and named-profile config examples
- Dev server plug and watcher examples, including profile usage
- Layout helper examples for `DuskmoonBundler.static_path/2` and
  `DuskmoonBundler.Preload.tags/2`
- Production build commands and alias guidance
- Formatting and linting setup and commands
- Validation commands for normal apps and profile-specific umbrella builds
- Troubleshooting for dev asset 404s, manifest misses, Tailwind source misses,
  and umbrella dependency resolution

Keep `SKILL.md` concise and under 500 lines. Do not create extra README,
quick-reference, changelog, or installation guide files inside the skill.

### 5. Update agents/openai.yaml if needed

If the generated skill changes the user-facing purpose, update
`skills/duskmoon_bundler/agents/openai.yaml` so it still matches:

```yaml
interface:
  display_name: "Duskmoon Bundler"
  short_description: "Setup and use Duskmoon Bundler"
  default_prompt: "Use $duskmoon-bundler to set up Phoenix assets with DuskmoonBundler."
```

Keep strings quoted and keep the default prompt explicitly mentioning
`$duskmoon-bundler`.

### 6. Verify accuracy

Spot-check at least these flows against source or docs:

- Installer edits from `Mix.Tasks.DuskmoonBundler.Install`
- `mix duskmoon_bundler.build` and `mix duskmoon_bundler.dev` options
- Runtime helper ownership in `duskmoon_bundler_runtime`
- Named profile usage in `config/config.exs` and dev watcher config
- `mix npm.install`, `mix npm.ci`, `mix npm.run`, and `mix npm.exec` behavior
- JS/TS format and lint commands

Validate the skill structure:

```bash
uv run --with pyyaml python /home/gao/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/duskmoon_bundler
```

### 7. Report changes

List what changed:

- Version updated
- Setup/config instructions changed
- Commands or options changed
- Runtime helper behavior changed
- Metadata changed
