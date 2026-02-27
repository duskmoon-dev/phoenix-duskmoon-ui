# Theming

Phoenix Duskmoon UI uses CSS custom properties from `@duskmoon-dev/core` for all
colors, typography, spacing, and elevation. Two built-in themes are provided:
**sunshine** (light) and **moonlight** (dark).

## Built-in Themes

Import the themes in your CSS:

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
```

The `sunshine` theme activates with `[data-theme="sunshine"]` on the `<html>` element,
and `moonlight` with `[data-theme="moonlight"]`. Use the `<.dm_theme_switcher />`
component to let users toggle between them (requires the `ThemeSwitcher` hook — see
the [Hooks](hooks.md) guide).

## CSS Custom Properties

All component styles reference CSS custom properties. The full set includes:

### Brand colors

| Property | Description |
|----------|-------------|
| `--color-primary` | Primary brand color |
| `--color-primary-content` | Text on primary |
| `--color-secondary` | Secondary brand color |
| `--color-secondary-content` | Text on secondary |
| `--color-tertiary` | Tertiary brand color |
| `--color-accent` | Accent color (maps to tertiary) |
| `--color-accent-content` | Text on accent |

### Surface colors

| Property | Description |
|----------|-------------|
| `--color-surface` | Default surface background |
| `--color-surface-dim` | Dimmed surface |
| `--color-surface-bright` | Brightened surface |
| `--color-surface-variant` | Alternative surface |
| `--color-on-surface` | Text on surface |
| `--color-on-surface-variant` | Secondary text on surface |

### Semantic colors

| Property | Description |
|----------|-------------|
| `--color-info` | Informational |
| `--color-success` | Success state |
| `--color-warning` | Warning state |
| `--color-error` | Error state |

Each semantic color also has `-content`, `-container`, and `-on-container` variants.

### Design tokens

| Category | Properties |
|----------|-----------|
| Typography | `--font-family`, `--font-size-{xs,sm,md,lg,xl}`, `--font-weight-{normal,medium,semibold,bold}` |
| Shape | `--radius-{sm,md,lg,xl,full}` |
| Elevation | `--shadow-{sm,md,lg}` |
| Spacing | `--spacing-{xs,sm,md,lg,xl}` |
| Motion | `--transition-{fast,normal,slow}` |
| Focus | `--focus-ring`, `--focus-ring-offset` |

## Custom Colors

To customize the theme, override CSS custom properties in your stylesheet:

```css
:root {
  --color-primary: oklch(0.65 0.19 250);
  --color-secondary: oklch(0.75 0.15 200);
  --color-accent: oklch(0.7 0.2 150);
  --color-success: oklch(0.7 0.2 145);
  --color-warning: oklch(0.8 0.15 85);
  --color-error: oklch(0.6 0.2 25);
  --color-info: oklch(0.7 0.15 250);
}
```

Use `oklch()` color values for perceptually uniform color manipulation. The
`@duskmoon-dev/core` design system uses oklch throughout.

## Element Theme Bridge

Custom elements render inside shadow DOM, which isolates them from the document's
CSS custom properties by default. Phoenix Duskmoon UI includes an **element theme
bridge** (`element-theme-bridge.css`) that forces all `el-dm-*` elements to
`inherit` the document's theme tokens.

This bridge is included automatically when you use `@plugin "@duskmoon-dev/core/plugin"`
in your CSS. It ensures that:

- All `el-dm-*` custom elements respect the document theme
- Theme switching (sunshine/moonlight) propagates into shadow DOM
- Custom property overrides in your stylesheets affect custom elements

### Per-element overrides

Some custom elements use non-standard property names internally. The bridge
maps these to the standard theme tokens:

- `el-dm-table` — bridges `--dm-color-*` namespace to `--color-*`
- `el-dm-pagination` — bridges `--color-border`, `--color-text` to theme tokens
- `el-dm-bottom-navigation` — bridges `--color-border`, `--color-text-secondary`
- `el-dm-popover` — fixes upstream shadow DOM arrow positioning via `::part(arrow)`

## CSS Class Naming (BEM)

Components follow BEM naming convention for CSS classes:

| Pattern | Example | Description |
|---------|---------|-------------|
| `dm-component` | `dm-btn`, `dm-card` | Block (component root) |
| `dm-component--variant` | `dm-btn--primary`, `dm-input--lg` | Modifier (variant/size) |
| `dm-component__element` | `dm-card__header`, `dm-switch__track` | Element (child part) |
