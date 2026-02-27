# Migrating to v9

This guide covers upgrading from Phoenix Duskmoon UI v6/v7/v8 to v9. The v9
release is a major rewrite — components now render as HTML Custom Elements and
the CSS system has been replaced entirely.

## Overview of Breaking Changes

| Area | v6/v7/v8 | v9 |
|------|----------|-----|
| CSS framework | DaisyUI | `@duskmoon-dev/core` |
| Tailwind version | v3 | v4+ |
| CSS plugin directive | `@plugin "daisyui"` | `@plugin "@duskmoon-dev/core/plugin"` |
| Rendering | Plain HTML | HTML Custom Elements (`<el-dm-*>`) |
| Module paths | `PhoenixDuskmoon.Component.Button` | `PhoenixDuskmoon.Component.Action.Button` |
| Package manager | npm | Bun |
| Elixir version | `~> 1.12` | `~> 1.15` |

## Step-by-Step Migration

### 1. Update Elixir dependency

```elixir
# mix.exs — before
{:phoenix_duskmoon, "~> 7.0"}

# mix.exs — after
{:phoenix_duskmoon, "~> 9.0"}
```

```bash
mix deps.get
```

### 2. Replace npm packages with bun

Remove old npm dependencies and install the new ones:

```bash
# Remove old packages
bun remove daisyui

# Install new packages
bun add @duskmoon-dev/core @duskmoon-dev/elements
```

`@duskmoon-dev/core` replaces both DaisyUI and the old `phoenix_duskmoon/theme`
+ `phoenix_duskmoon/components` CSS exports. `@duskmoon-dev/elements` provides
the custom element packages that components render as.

### 3. Update CSS imports

This is the most significant change. The old CSS import pattern using DaisyUI
and phoenix_duskmoon exports is replaced entirely.

```css
/* ❌ v6/v7/v8 — REMOVE these */
@plugin "daisyui";
@import "phoenix_duskmoon/theme";
@import "phoenix_duskmoon/components";
```

```css
/* ✅ v9 — ADD these instead */
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
```

The `@duskmoon-dev/core/plugin` directive registers the full design system with
Tailwind v4: theme variables, component classes, and design tokens. The old
`phoenix_duskmoon/theme` and `phoenix_duskmoon/components` CSS export paths no
longer exist.

**Optional**: Import built-in themes for light/dark mode support:

```css
@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
@import "@duskmoon-dev/core/themes/sunshine";
@import "@duskmoon-dev/core/themes/moonlight";
```

### 4. Register custom elements in JavaScript

v9 components render as `<el-dm-*>` custom elements. These must be registered
in your `app.js`:

```javascript
// Register all elements at once
import "@duskmoon-dev/elements/register";

// Or register individually (smaller bundle)
import "@duskmoon-dev/el-button/register";
import "@duskmoon-dev/el-card/register";
import "@duskmoon-dev/el-input/register";
// ... add the elements you use
```

Without registration, components will render empty — the custom element's
`<template>` content is inert until the element is defined.

### 5. Set up LiveView hooks

v9 introduces JavaScript hooks for client-side interactions. Add them to your
LiveSocket:

```javascript
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: DuskmoonHooks,
});
```

If you have existing hooks, merge them:

```javascript
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";
import MyHooks from "./my_hooks";

let hooks = { ...DuskmoonHooks, ...MyHooks };
```

See the [Hooks](hooks.md) guide for details on each hook.

### 6. Update module imports (if importing individual modules)

Component modules have been reorganized into 8 categories. If you import
individual modules directly, update the paths:

```elixir
# ❌ v6/v7/v8 paths (no longer exist)
alias PhoenixDuskmoon.Component.Button
alias PhoenixDuskmoon.Component.Form.Input

# ✅ v9 paths
alias PhoenixDuskmoon.Component.Action.Button
alias PhoenixDuskmoon.Component.DataEntry.Input
```

If you use `use PhoenixDuskmoon.Component` in your view helpers (recommended),
no changes are needed — all components are still imported with the same `dm_`
prefixed function names.

### 7. Update CSS class overrides

If you target DaisyUI class names in custom CSS, update them to the BEM naming
convention:

```css
/* ❌ v6/v7/v8 DaisyUI classes */
.btn-primary { ... }
.card-body { ... }
.form-control { ... }

/* ✅ v9 BEM classes */
.dm-btn--primary { ... }
.dm-card__body { ... }
.dm-input { ... }
```

The naming convention is:
- Block: `dm-component` (e.g., `dm-btn`, `dm-card`)
- Modifier: `dm-component--variant` (e.g., `dm-btn--primary`)
- Element: `dm-component__element` (e.g., `dm-card__header`)

## Verifying the Migration

After completing all steps:

1. Run `mix compile --warnings-as-errors` to catch any removed module references
2. Start the dev server with `mix phx.server` and check browser console for:
   - Missing custom element warnings (add missing `import ... /register` lines)
   - CSS errors (verify `@plugin` directive is correct)
3. Verify theme switching works if you use `<.dm_theme_switcher />`

## Common Issues

### Components render empty / invisible

Custom elements are not registered. Add the appropriate `import "@duskmoon-dev/el-*/register"` line to your `app.js`.

### Styles look wrong or missing

CSS imports still reference DaisyUI or old phoenix_duskmoon exports. Replace with `@plugin "@duskmoon-dev/core/plugin"`.

### "module not found" compilation errors

Module paths changed. Use `use PhoenixDuskmoon.Component` (auto-imports everything) or update individual aliases to the new category-based paths.
