---
name: cmd-update-project-skill
description: Regenerate the Phoenix Duskmoon UI project skill from current source and documentation.
disable-model-invocation: true
---

# Update Project Skill

Re-analyze project source and regenerate one or more files under `skills/`.

## User Input

Use the invoking user request as input.

## Repository ownership

This repository owns `skills/phoenix-duskmoon-ui/`. The bundler skill and toolchain
source are maintained in [duskmoon-bundler](https://github.com/duskmoon-dev/duskmoon-bundler).
For an `all` request, update only the UI skill here and report that the bundler skill
is maintained in that repository.

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
