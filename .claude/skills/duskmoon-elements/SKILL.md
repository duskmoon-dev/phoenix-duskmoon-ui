---
name: duskmoon-elements
description: Use the DuskMoon Elements custom element library (`<el-dm-*>` web components). Use when building web pages or apps with DuskMoon elements, registering elements, setting properties/attributes, listening to events, using slots, applying themes, or styling with CSS custom properties. Covers all 31 element packages including button, card, input, dialog, table, tabs, pro-data-grid, and more.
---

# DuskMoon Elements

31 custom element packages built on `@duskmoon-dev/el-core`. Each element is a standard Web Component with Shadow DOM.

## Installation

```bash
# Individual element
bun add @duskmoon-dev/el-button

# All elements at once
bun add @duskmoon-dev/elements
```

## Registration

```typescript
// Option 1: Explicit (tree-shakable)
import { register } from '@duskmoon-dev/el-button';
register();

// Option 2: Side-effect auto-register
import '@duskmoon-dev/el-button/register';

// Option 3: Register all elements
import { registerAll } from '@duskmoon-dev/elements';
registerAll();
```

## Usage in HTML

```html
<el-dm-button variant="filled" color="primary" size="md">
  Click me
</el-dm-button>

<el-dm-dialog id="my-dialog">
  <span slot="header">Title</span>
  Dialog content here.
  <div slot="footer">
    <el-dm-button onclick="this.closest('el-dm-dialog').hide()">Close</el-dm-button>
  </div>
</el-dm-dialog>
```

## Properties & Attributes

Set via HTML attributes (kebab-case) or JS properties (camelCase). Properties with `reflect: true` sync both directions.

```html
<!-- HTML attributes -->
<el-dm-button variant="outlined" disabled>Save</el-dm-button>

<!-- JS properties -->
<script>
  const btn = document.querySelector('el-dm-button');
  btn.variant = 'outlined';
  btn.disabled = true;
</script>
```

Common properties across elements:

| Property | Type | Description |
|----------|------|-------------|
| `variant` | String | Visual variant (`filled`, `outlined`, `soft`, `text`, `ghost`) |
| `color` | String | Color theme (`primary`, `secondary`, `success`, `warning`, `error`, `info`) |
| `size` | String | Size (`sm`, `md`, `lg`) |
| `disabled` | Boolean | Disable interaction |

Complex data (arrays, objects) must be set via JS — use `attribute: false`:

```javascript
const table = document.querySelector('el-dm-table');
table.columns = [{ field: 'name', header: 'Name' }];
table.data = [{ name: 'Alice' }, { name: 'Bob' }];
```

## Events

Listen with `addEventListener`. Events bubble and are composed (cross shadow DOM).

```javascript
const table = document.querySelector('el-dm-table');
table.addEventListener('sort', (e) => {
  console.log(e.detail); // { column: 'name', direction: 'asc' }
});
table.addEventListener('row-click', (e) => {
  console.log(e.detail); // { row: {...}, rowIndex: 0 }
});
```

Common events:

| Element | Event | Detail |
|---------|-------|--------|
| dialog | `open`, `close` | — |
| table | `sort` | `{ column, direction }` |
| table | `select` | `{ selectedIds, selectedRows }` |
| table | `page-change` | `{ page, pageSize }` |
| pagination | `page-change` | `{ page }` |
| tabs | `tab-change` | `{ index, tab }` |
| input | `dm-input`, `dm-change` | `{ value }` |

## Slots

Named slots project light DOM content into the element's shadow DOM.

```html
<el-dm-button>
  <span slot="prefix">🔍</span>
  Search
  <span slot="suffix">→</span>
</el-dm-button>

<el-dm-card>
  <span slot="header">Card Title</span>
  Card body content
  <div slot="footer">Footer</div>
</el-dm-card>
```

Common slots: (default), `header`, `footer`, `prefix`, `suffix`, `empty`, `actions`.

## CSS Parts

Style shadow DOM internals from outside using `::part()`:

```css
el-dm-button::part(button) {
  border-radius: 0;
}
el-dm-dialog::part(backdrop) {
  backdrop-filter: blur(4px);
}
el-dm-table::part(thead) {
  background: var(--color-surface-container-high);
}
```

## Theming

Elements use CSS custom properties from `@duskmoon-dev/el-core`. Apply a preset theme:

```typescript
import { applyTheme } from '@duskmoon-dev/el-core';

applyTheme(document.documentElement, 'moonlight'); // dark
applyTheme(document.documentElement, 'sunshine');   // light
// Also: 'ocean', 'forest', 'rose'
```

Override individual variables:

```css
:root {
  --color-primary: oklch(60% 0.15 250);
  --color-surface: #ffffff;
}
```

Key variables: `--color-primary`, `--color-surface`, `--color-on-surface`, `--color-outline`, `--color-surface-container`.

See [references/core-api.md](references/core-api.md) for full CSS variable list.

## Batched Rendering

Property changes are batched via `queueMicrotask`. Multiple changes in the same tick produce a single re-render:

```javascript
const el = document.querySelector('el-dm-button');
el.variant = 'outlined';
el.color = 'error';
el.size = 'lg';
// → single re-render
```

## References

- [Element catalog](references/element-catalog.md) — all 31 packages by category with class names
- [Core API](references/core-api.md) — BaseElement API, mixins, style utilities, CSS variables, themes, validation
