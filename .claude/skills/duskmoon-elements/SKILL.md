# Claude Code Skills Reference

This document describes the Claude Code skills and commands available in the DuskMoon Elements repository. These extend Claude Code with project-specific capabilities when working in this monorepo.

## Overview

Skills and commands are defined in `.claude/skills/` and `.claude/commands/` respectively. They give Claude Code specialized knowledge about this project's patterns, conventions, and workflows.

## Project-Specific Skills

### `/create_element` — Element Package Management

Creates, modifies, or removes element packages in `elements/`. This is the primary skill for adding new components to the library.

**When to use:** Any time you need to add a new `<el-dm-*>` component.

**What it does:**
1. Scaffolds the full package structure (`package.json`, `tsconfig.json`, source files)
2. Creates the component class extending `BaseElement`
3. Updates the bundle package (`packages/elements/`) with imports, exports, and references
4. Updates root `package.json` build/release scripts
5. Creates a playground test page
6. Creates documentation in `packages/docs/`

**Example:**
```
/create_element tooltip
```

**Key conventions enforced:**
- Package: `@duskmoon-dev/el-{name}`
- Tag: `<el-dm-{name}>`
- Class: `ElDm{Name}`
- Strips `@layer` wrappers from `@duskmoon-dev/core` styles for Shadow DOM
- Includes verification checklist (build, typecheck, lint, format)

### `/duskmoon-dev-core` — CSS Library Reference

Reference for the `@duskmoon-dev/core` CSS component library that provides base styles used by element packages.

**When to use:** When writing component styles, checking available CSS classes, or understanding how core CSS integrates with Shadow DOM.

**What it provides:**
- Installation and setup instructions
- Full list of available CSS components and their class names
- Color system and theme variables
- Usage examples for buttons, cards, forms, alerts, navigation, etc.
- Guide for importing component CSS into custom elements (including `@layer` stripping)

**Example:**
```
/duskmoon-dev-core
```

## Project Commands

### `/sync-core` — Core Package Sync Analysis

Compares local `@duskmoon-dev/el-core` with the published npm version and generates an update plan for element packages.

**When to use:** After making changes to the core package, to understand the impact on all 30 element packages.

**What it does:**
1. Compares local vs published API surface (exports, method signatures, types)
2. Scans element packages for core API usage
3. Categorizes changes as breaking, deprecation, or new feature
4. Generates per-element impact assessment with priority levels
5. Produces actionable update plan with file locations and before/after code
6. Optionally applies updates with user approval

**Example:**
```
/sync-core                  # Analyze all elements
/sync-core button switch    # Analyze specific elements only
```

**Priority levels:**
- CRITICAL — Uses removed/renamed API (won't compile)
- HIGH — Uses deprecated API (works but should update)
- MEDIUM — Could benefit from new features
- LOW — No changes needed

### `/speckit.*` — Feature Specification Toolkit

A suite of commands for structured feature development:

| Command | Description |
|---------|-------------|
| `/speckit.specify` | Create or update a feature specification from a description |
| `/speckit.clarify` | Identify underspecified areas and ask up to 5 clarification questions |
| `/speckit.plan` | Generate implementation plan with design artifacts |
| `/speckit.tasks` | Generate dependency-ordered `tasks.md` from design artifacts |
| `/speckit.taskstoissues` | Convert tasks into GitHub issues |
| `/speckit.implement` | Execute the implementation plan from `tasks.md` |
| `/speckit.checklist` | Generate a custom checklist for the feature |
| `/speckit.analyze` | Cross-artifact consistency check across spec, plan, and tasks |
| `/speckit.constitution` | Create or update project principles |

**Typical workflow:**
```
/speckit.specify "Add a color picker element"
/speckit.clarify
/speckit.plan
/speckit.tasks
/speckit.implement
```

## Configuration Files

### `.claude/CLAUDE.md` (CLAUDE.md)

Project-level instructions loaded into every Claude Code session. Contains:
- Build and development commands
- Architecture overview (monorepo structure, core package, element pattern)
- TypeScript project references explanation
- Workspace dependency notes

### `AGENTS.md`

Machine-readable conventions for agentic coding tools:
- Repository layout
- Build, lint, test commands
- Code style guidelines (TypeScript, formatting, naming)
- Custom element patterns
- Testing guidelines

## Working with This Repository in Claude Code

### Common Workflows

**Add a new element:**
```
/create_element {name}
```

**After modifying core, check element impact:**
```
/sync-core
```

**Plan a new feature end-to-end:**
```
/speckit.specify "description"
/speckit.plan
/speckit.tasks
/speckit.implement
```

**Check what CSS classes are available:**
```
/duskmoon-dev-core
```

### Quick Reference: Key Paths

| What | Path |
|------|------|
| Core package source | `packages/core/src/` |
| Core public API | `packages/core/src/index.ts` |
| Element packages | `elements/{name}/src/` |
| Bundle package | `packages/elements/src/` |
| Test setup (happy-dom) | `test-setup.ts` |
| Bun config | `bunfig.toml` |
| Playground | `playground/` |
| Documentation site | `packages/docs/` |
| CI workflows | `.github/workflows/` |

### Quick Reference: Key Commands

```bash
bun install              # Install dependencies
bun run build:all        # Build everything (core first)
bun run test             # Run all 416 tests
bun run typecheck        # Type check all packages
bun run lint:check       # ESLint (zero warnings policy)
bun run format:check     # Prettier check
bun run playground       # Start playground at :4220
bun run docs:dev         # Start docs site at :4331
```

### Core API Exports

The `@duskmoon-dev/el-core` package exports:

| Category | Exports |
|----------|---------|
| **Base class** | `BaseElement`, `PropertyDefinition`, `PropertyDefinitions` |
| **Styles** | `css`, `combineStyles`, `cssVars`, `defaultTheme`, `resetStyles`, `lightThemeColors` |
| **Animations** | `animationStyles`, `animation`, `transition`, `durations`, `easings` |
| **Themes** | `sunshineTheme`, `moonlightTheme`, `oceanTheme`, `forestTheme`, `roseTheme`, `themes`, `applyTheme` |
| **Mixins** | `FocusableMixin`, `FormMixin`, `EventListenerMixin`, `SlotObserverMixin` |
| **Validation** | `validate`, `validateAsync`, `validators` |
| **Performance** | `debounce`, `throttle`, `scheduleIdle` |
| **Types** | `Size`, `Variant`, `ValidationState`, `FormElementProps`, `ValidatableProps`, etc. |
