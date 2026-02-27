# Phoenix Duskmoon UI

Duskmoon UI component library for Phoenix LiveView applications.

Phoenix Duskmoon UI provides 60+ ready-to-use LiveView components that render as
HTML Custom Elements, powered by the `@duskmoon-dev/core` design system and
`@duskmoon-dev/elements` web component packages.

## Architecture

```
Phoenix LiveView
       │
       ▼
┌──────────────────┐
│  HEEX Components │  ← dm_btn, dm_card, dm_input (API layer)
│  (dm_* prefix)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Custom Elements │  ← <el-dm-button>, <el-dm-card> (rendering layer)
│  (el-dm-* tags)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ @duskmoon-dev/   │  ← CSS custom properties, design tokens
│     core         │
└──────────────────┘
```

HEEX components provide a familiar Phoenix API (`attr/3`, `slot/2`, form field
binding) while the rendering is handled by custom elements with shadow DOM
encapsulation. The `@duskmoon-dev/core` design system provides all colors, typography,
spacing, and elevation tokens through CSS custom properties.

## Quick Install

```elixir
# mix.exs
{:phoenix_duskmoon, "~> 9.0"}
```

```bash
bun add @duskmoon-dev/core @duskmoon-dev/elements
```

See the [Getting Started](getting-started.md) guide for full setup instructions.

## Component Categories

| Category | Examples | Count |
|----------|----------|-------|
| [Action](`PhoenixDuskmoon.Component.Action.Button`) | Button, Dropdown, Link, Menu, Toggle | 5 |
| [Data Display](`PhoenixDuskmoon.Component.DataDisplay.Card`) | Card, Table, Badge, Avatar, Pagination, Timeline | 17 |
| [Data Entry](`PhoenixDuskmoon.Component.DataEntry.Input`) | Input, Select, Checkbox, Switch, Autocomplete, TreeSelect | 19 |
| [Feedback](`PhoenixDuskmoon.Component.Feedback.Dialog`) | Dialog, Loading, Snackbar, Toast | 4 |
| [Navigation](`PhoenixDuskmoon.Component.Navigation.Appbar`) | Appbar, Breadcrumb, Tab, Stepper, PageHeader | 12 |
| [Layout](`PhoenixDuskmoon.Component.Layout.Divider`) | Divider, Drawer, BottomSheet, ThemeSwitcher | 4 |
| [Icon](`PhoenixDuskmoon.Component.Icon.Icons`) | Material Design Icons, Bootstrap Icons | 1 |
| [CSS Art](`PhoenixDuskmoon.CssArt.Snow`) | Snow, Eclipse, PlasmaBall, Signature, SpotlightSearch | 6 |

## Guides

- [Getting Started](getting-started.md) — Installation, view helpers, CSS and JS setup
- [Theming](theming.md) — Sunshine/moonlight themes, CSS custom properties, custom colors
- [Hooks](hooks.md) — JavaScript hooks reference for LiveView integration

## Links

- [Hex Package](https://hex.pm/packages/phoenix_duskmoon)
- [npm Package](https://www.npmjs.com/package/phoenix_duskmoon)
- [GitHub](https://github.com/duskmoon-dev/phoenix-duskmoon-ui)
- [Live Storybook](https://duskmoon-storybook.fly.dev)
