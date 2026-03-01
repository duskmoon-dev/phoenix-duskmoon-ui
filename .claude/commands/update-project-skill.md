# Update Project Skill

Re-analyze the phoenix_duskmoon project and regenerate `skills/phoenix-duskmoon-ui/SKILL.md` and `skills/phoenix-duskmoon-ui/references/components.md`.

## Steps

### 1. Scan all component modules

Read every `.ex` file under `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component/` and `apps/phoenix_duskmoon/lib/phoenix_duskmoon/css_art/`.

For each module, extract:
- Module name and category (from path: action, data_display, data_entry, feedback, navigation, layout, icon, fun)
- All public `def` functions with `@doc type: :component`
- All `attr/3` declarations (name, type, default, values)
- All `slot/2` declarations (name, attrs)
- Whether the component requires a LiveView hook

### 2. Scan setup files

Read these files for integration details:
- `apps/phoenix_duskmoon/mix.exs` — version, deps
- `apps/phoenix_duskmoon/package.json` — npm exports
- `apps/phoenix_duskmoon/assets/js/hooks/index.js` — exported hooks
- `apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css` — CSS imports
- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/component.ex` — main import module
- `apps/phoenix_duskmoon/lib/phoenix_duskmoon/css_art.ex` — CSS art import module

### 3. Regenerate SKILL.md

Update `skills/phoenix-duskmoon-ui/SKILL.md` with:
- Current version number from mix.exs
- Installation instructions (Hex + npm)
- Setup steps (Elixir imports, CSS, JS hooks, element registration)
- Architecture overview (v9 custom elements)
- Hooks reference table
- Component quick reference tables organized by category
- Usage examples covering common patterns
- npm package exports table

Keep the YAML frontmatter (`name` and `description` fields).
Keep SKILL.md under 500 lines — put detailed reference in the components file.

### 4. Regenerate components.md

Update `skills/phoenix-duskmoon-ui/references/components.md` with the full attribute and slot reference for every component, organized by category.

### 5. Verify accuracy

After regenerating, spot-check 3-5 components by reading their source to confirm the documented attrs/slots match the actual code. Fix any discrepancies.

### 6. Report changes

List what changed:
- New components added
- Components removed
- Attributes changed
- Version updated
