<!--
Sync Impact Report
==================
Version change: 1.0.0 → 1.1.0 (MINOR - new principle + naming expansion + stack correction)
Modified principles:
  - I. Component-First Design: added CSS Art (dm_art_) prefix rule
  - VI. Simplicity: unchanged
Added sections:
  - Principle VII. Color Policy (new)
  - Development Standards: Technology Stack corrected (removed daisyui, added @duskmoon-dev/elements)
  - Development Standards: Component Naming table now includes CSS Art row
  - Development Standards: v9 Architecture sub-section added
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md: ✅ compatible (Constitution Check section exists; no principle references broken)
  - .specify/templates/spec-template.md: ✅ compatible (no principle-specific references)
  - .specify/templates/tasks-template.md: ✅ compatible (task categories unaffected)
  - .specify/templates/commands/: ✅ N/A (no command files exist)
Follow-up TODOs: None
-->

# Phoenix Duskmoon UI Constitution

## Core Principles

### I. Component-First Design

Every UI element MUST be implemented as a reusable Phoenix LiveView component with clear boundaries.

- Components MUST be self-contained and independently usable
- Components MUST use `attr/3` and `slot/2` for LiveView HEEX definitions
- Components MUST have `@doc type: :component` annotation
- Standard components MUST follow the `dm_` prefix convention (e.g., `dm_btn`, `dm_card`)
- CSS Art / decorative components MUST follow the `dm_art_` prefix convention (e.g., `dm_art_snow`, `dm_art_plasma_ball`)
- Fun/interactive components MUST follow the `dm_fun_` prefix convention
- CSS Art components MUST reside in the `PhoenixDuskmoon.CssArt.*` namespace
- Form components MUST reside in `PhoenixDuskmoon.Component.Form.*` namespace

**Rationale**: Self-contained components with clear naming conventions enable independent testing, clear
documentation, and predictable behavior for library consumers.

### II. API Stability

Public APIs MUST remain stable across minor versions; breaking changes require major version bumps.

- Semantic versioning (MAJOR.MINOR.PATCH) MUST be strictly followed
- Deprecated attributes/slots MUST remain functional for at least one major version
- Deprecation warnings MUST be emitted at compile-time when deprecated APIs are used
- Breaking changes MUST be documented in CHANGELOG.md with migration guidance
- Component attribute defaults MUST NOT change in minor/patch releases

**Rationale**: Library consumers depend on stable APIs; unexpected changes cause upgrade friction and erode trust.

### III. Accessibility (a11y)

All interactive components MUST support accessible usage patterns.

- Interactive components MUST be keyboard navigable
- Form inputs MUST associate labels correctly using standard HTML semantics
- Focus states MUST be visually distinguishable
- Components MUST NOT rely solely on color to convey information
- ARIA attributes SHOULD be used where native HTML semantics are insufficient
- Screen reader compatibility SHOULD be verified for complex components

**Rationale**: Accessible components expand the user base and ensure compliance with legal requirements
in many jurisdictions.

### IV. Documentation Standards

Every public component MUST be documented with usage examples and a Storybook story.

- Public functions/components MUST have `@moduledoc` and `@doc` annotations
- All component attributes MUST be documented with types and descriptions via `attr/3`
- Storybook stories (`.story.exs` files) MUST exist for each public component
- Stories MUST include at least one variation demonstrating typical usage
- README and HexDocs MUST stay synchronized with implementation
- JavaScript hooks MUST document setup requirements when used

**Rationale**: Clear documentation reduces support burden and accelerates adoption.

### V. Testing Discipline

Tests are encouraged for all components; critical paths and complex logic MUST be tested.

- New components SHOULD have corresponding test files in `test/phoenix_duskmoon/component/`
- Bug fixes SHOULD include a regression test when feasible
- Component tests MUST use `Phoenix.LiveViewTest.render_component/2`
- Integration tests SHOULD verify hook interactions when JavaScript is involved
- Tests MUST NOT depend on exact HTML output; use partial matching (`=~`) for assertions
- CI MUST pass before merging: `mix format --check-formatted`, `mix compile --warnings-as-errors`, `mix test`

**Rationale**: Tests provide confidence during refactoring and catch regressions early, while avoiding TDD
overhead allows faster iteration for exploratory UI work.

### VI. Simplicity

Prefer minimal, focused implementations over feature-rich complexity.

- Components MUST solve one problem well; avoid Swiss-army-knife designs
- Avoid premature abstractions; duplication is acceptable until patterns emerge
- Configuration options MUST be justified by demonstrated user need
- Internal helper modules MUST NOT be exposed in the public API
- Refactoring toward simplicity is always permitted when it improves clarity

**Rationale**: Simple components are easier to understand, maintain, test, and extend.

### VII. Color Policy

All colors MUST originate from theme CSS custom properties; hardcoded color values are forbidden.

- Hardcoded hex, rgb, hsl, or named color values MUST NOT appear in component markup or stylesheets
- Components MUST reference existing `@duskmoon-dev/core` theme variables
  (e.g., `var(--color-primary)`, `var(--color-surface)`, `var(--color-on-surface)`)
- If a required color has no existing theme variable, a new CSS custom property MUST be defined in
  the theme variable system and referenced via `var(--color-your-name)`
- This rule ensures components adapt correctly across all themes (sunshine/moonlight/auto/custom)

**Rationale**: Hardcoded colors break theme switching and violate the design-token contract; consistency
in theming is a first-class requirement for a design-system library.

## Development Standards

### Technology Stack

- **Language**: Elixir 1.12+ with Phoenix 1.8+, Phoenix LiveView 1.1+
- **CSS / Theming**: `@duskmoon-dev/core` — design tokens, CSS utility classes, TailwindCSS v4 plugin
- **Custom Elements**: `@duskmoon-dev/elements` (`@duskmoon-dev/el-*` packages) — HTML Custom Elements
- **Package Manager**: Mix for Elixir; Bun for Node.js workspace
- **Documentation**: HexDocs, PhoenixStorybook for live component showcase

### v9 Architecture

Components render through a two-layer stack:

```
Phoenix LiveView (HEEX)  →  HTML Custom Elements  →  @duskmoon-dev/core CSS tokens
dm_btn / dm_card / ...      <el-dm-button>             var(--color-primary) etc.
```

- Custom elements (`el-dm-*`) MUST be explicitly registered via their
  `@duskmoon-dev/el-*/register` import in `assets/js/app.js`
- CSS/layout-only patterns (e.g., appbar) MAY use `@duskmoon-dev/core` utility classes
  directly without a custom element when appropriate

### Code Style

- Run `mix format` before every commit
- Use snake_case for variables/functions, CamelCase for modules
- Import modules at top of file; avoid aliasing unless necessary
- Error handling: prefer `with` statements for multiple operations

### Component Naming

| Category      | Prefix      | Namespace                              |
|---------------|-------------|----------------------------------------|
| Standard UI   | `dm_`       | `PhoenixDuskmoon.Component.*`          |
| Form inputs   | `dm_`       | `PhoenixDuskmoon.Component.Form.*`     |
| Fun/animated  | `dm_fun_`   | `PhoenixDuskmoon.Component.Fun.*`      |
| CSS Art       | `dm_art_`   | `PhoenixDuskmoon.CssArt.*`             |

## Quality Gates

### Pre-Commit Checklist

- [ ] `mix format` passes
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix test` passes (if tests exist for modified components)
- [ ] Storybook story exists for new public components
- [ ] `@doc` and `@moduledoc` present for public modules
- [ ] No hardcoded color values introduced (Principle VII)

### Pre-Release Checklist

- [ ] All CI checks pass (format, compile, test)
- [ ] CHANGELOG.md updated with user-facing changes
- [ ] Version managed by semantic-release (do not manually edit)
- [ ] Breaking changes documented with migration notes
- [ ] HexDocs generated without warnings

## Governance

This constitution defines the non-negotiable standards for Phoenix Duskmoon UI development.

### Amendment Process

1. Propose amendment via GitHub issue with rationale
2. Discussion period of at least 7 days for major changes
3. Amendment requires maintainer approval
4. Update constitution version following semantic versioning:
   - MAJOR: Principle removal or incompatible redefinition
   - MINOR: New principle or significant guidance expansion
   - PATCH: Clarifications, wording fixes, non-semantic changes
5. Document amendment in Sync Impact Report (HTML comment at top of file)

### Compliance

- All pull requests SHOULD demonstrate awareness of relevant principles
- Code reviews MAY cite constitution principles when requesting changes
- Complexity additions MUST be justified against Principle VI (Simplicity)
- Color usage MUST be validated against Principle VII (Color Policy)
- Runtime development guidance is maintained in `CLAUDE.md`

**Version**: 1.1.0 | **Ratified**: 2025-12-16 | **Last Amended**: 2026-03-09
