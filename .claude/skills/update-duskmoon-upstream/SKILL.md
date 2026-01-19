# Duskmoon Upstream Style Dependencies

This skill documents the correct approach for handling CSS styles in Phoenix Duskmoon UI - all styles should come from upstream packages, not be maintained locally.

## Architecture Philosophy

```
┌─────────────────────────────────────────────────────────────┐
│                    Upstream Packages (Source of Truth)      │
├─────────────────────────┬───────────────────────────────────┤
│  @duskmoon-dev/core     │  @duskmoon-dev/elements           │
│  (CSS design system)    │  (HTML Custom Elements)           │
│  - Design tokens        │  - el-dm-button                   │
│  - Color palette        │  - el-dm-card                     │
│  - Component styles     │  - el-dm-input                    │
│  - Theme definitions    │  - etc.                           │
└─────────────────────────┴───────────────────────────────────┘
                              │
                              ▼ (consume, don't modify)
┌─────────────────────────────────────────────────────────────┐
│              Phoenix Duskmoon UI (this repo)                │
├─────────────────────────────────────────────────────────────┤
│  - HEEX component wrappers (dm_btn, dm_card, etc.)          │
│  - LiveView integration                                     │
│  - Storybook documentation                                  │
│  - NO custom CSS styles (except temporary compat layer)     │
└─────────────────────────────────────────────────────────────┘
```

**Key Principle**: This repo should NOT maintain CSS styles. All styling comes from upstream packages.

## Correct Approach

### When Styles Work Correctly
Simply import the upstream packages:

```css
/* apps/phoenix_duskmoon/assets/css/phoenix_duskmoon.css */
@import "tailwindcss";
@import "@duskmoon-dev/core";       /* All design tokens and component styles */
@import "@duskmoon-dev/elements";   /* Custom element definitions */
```

### When Styles Are Missing or Broken

**DO NOT** create local CSS files to fix the issue.

**DO** file an issue to the upstream repository:

1. **Identify the issue**
   - Which component is affected?
   - What styles are missing?
   - What is the expected behavior?

2. **File an issue at upstream repo**
   - Repository: `github.com/duskmoon-dev/core` or `github.com/duskmoon-dev/elements`
   - Include: component name, expected vs actual behavior, screenshots

3. **Wait for upstream fix** or submit a PR to the upstream repo

4. **Update package version** once fix is released
   ```bash
   bun update @duskmoon-dev/core @duskmoon-dev/elements
   ```

## Current Temporary State

The `theme-compat.css` file exists as a **temporary compatibility layer** because `@duskmoon-dev/core` is not yet published. This should be removed once the package is available.

**Files to remove when upstream is ready:**
- `apps/phoenix_duskmoon/assets/css/theme-compat.css`
- `apps/phoenix_duskmoon/assets/css/components/*.css` (all component CSS)

**Migration steps:**
1. Install upstream packages: `bun add @duskmoon-dev/core @duskmoon-dev/elements`
2. Update imports in `phoenix_duskmoon.css`
3. Delete local CSS files
4. Verify all components render correctly in Storybook
5. File issues for any missing styles

## What This Repo Should Contain

### YES - Maintain in this repo:
- HEEX component definitions (`lib/phoenix_duskmoon/component/*.ex`)
- Component attributes and slots
- LiveView integration logic
- JavaScript hooks
- Storybook stories
- Tests

### NO - Do not maintain in this repo:
- CSS color definitions
- CSS component styles
- Design tokens
- Theme definitions

## Reporting Upstream Issues

When filing issues for missing styles, include:

```markdown
## Component
[Component name, e.g., dm_switch, dm_card]

## Issue
[Description of what's missing or broken]

## Expected Behavior
[What should happen]

## Actual Behavior
[What currently happens]

## Screenshots
[Include visual comparison if applicable]

## Version
@duskmoon-dev/core: x.x.x
@duskmoon-dev/elements: x.x.x
```

## Related Upstream Repositories

- **@duskmoon-dev/core**: CSS design system, tokens, component styles
- **@duskmoon-dev/elements**: HTML Custom Elements with Shadow DOM
