# Getting Started

This guide walks through adding Phoenix Duskmoon UI to a Phoenix LiveView project.

## Prerequisites

- Elixir ~> 1.15
- Phoenix ~> 1.8.1
- Phoenix LiveView ~> 1.1.0
- TailwindCSS >= 4.0
- [Bun](https://bun.sh) (for frontend package management)

## Installation

### 1. Add the Hex dependency

```elixir
# mix.exs
defp deps do
  [
    {:phoenix_duskmoon, "~> 9.0"}
  ]
end
```

```bash
mix deps.get
```

### 2. Install frontend packages

```bash
bun add @duskmoon-dev/core @duskmoon-dev/elements
```

`@duskmoon-dev/core` provides the CSS design system (theme variables, component
classes, design tokens). `@duskmoon-dev/elements` is a meta-package that installs
all `el-dm-*` custom element packages.

### 3. Import components in your view helpers

In your `lib/my_app_web.ex`, add the component imports to `html_helpers/0`:

```elixir
defp html_helpers do
  quote do
    # Import all Duskmoon UI components (dm_btn, dm_card, dm_input, etc.)
    use PhoenixDuskmoon.Component

    # Import CSS art components (dm_art_snow, dm_art_plasma_ball, etc.)
    use PhoenixDuskmoon.CssArt

    # ... your other imports
  end
end
```

### 4. Configure CSS

In your `assets/css/app.css`:

```css
@source "../js/**/*.js";
@source "../../lib/**/*.exs";
@source "../../lib/**/*.ex";

@import "tailwindcss";
@plugin "@duskmoon-dev/core/plugin";
```

The `@plugin` directive registers the Duskmoon design system with Tailwind v4,
providing all theme variables, component classes, and design tokens.

### 5. Register custom elements

In your `assets/js/app.js`, import the element packages you use:

```javascript
// Register individual elements
import "@duskmoon-dev/el-button/register";
import "@duskmoon-dev/el-card/register";
import "@duskmoon-dev/el-input/register";
// ... add more as needed

// Or register all elements at once
import "@duskmoon-dev/elements/register";
```

Each custom element must be explicitly registered for its tag to be defined in
the browser. Without registration, content inside the element's `<template>` is
inert and invisible.

### 6. Set up LiveView hooks

Some components require JavaScript hooks for client-side interactions. Import and
register them with your LiveSocket:

```javascript
import { LiveSocket } from "phoenix_live_view";
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: DuskmoonHooks,
});
```

To merge with your own hooks:

```javascript
import * as DuskmoonHooks from "phoenix_duskmoon/hooks";
import MyHooks from "./my_hooks";

let hooks = { ...DuskmoonHooks, ...MyHooks };

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});
```

See the [Hooks](hooks.md) guide for details on each hook.

## Usage

All components use the `dm_` prefix:

```heex
<%!-- Buttons --%>
<.dm_btn variant="primary">Save</.dm_btn>
<.dm_btn variant="error" shape="circle">×</.dm_btn>

<%!-- Cards with slots --%>
<.dm_card>
  <:title>Card Title</:title>
  Content goes here
  <:footer><.dm_btn variant="primary">Action</.dm_btn></:footer>
</.dm_card>

<%!-- Icons --%>
<.dm_mdi name="home" />
<.dm_bsi name="house" />

<%!-- Forms with field binding --%>
<.dm_form for={@form} phx-submit="save">
  <.dm_input field={@form[:name]} label="Name" />
  <.dm_select field={@form[:role]} label="Role" options={[{"admin", "Admin"}, {"user", "User"}]} />
  <.dm_btn variant="primary" type="submit">Save</.dm_btn>
</.dm_form>
```

### Common attributes

| Attribute | Values | Description |
|-----------|--------|-------------|
| `variant` | `primary`, `secondary`, `accent`, `info`, `success`, `warning`, `error`, `ghost`, `link`, `outline` | Color variant |
| `size` | `xs`, `sm`, `md`, `lg` | Size variant |
| `shape` | `square`, `circle` | Shape variant |
| `loading` | boolean | Shows loading spinner |
| `disabled` | boolean | Disables interaction |
| `class` | string or list | Additional CSS classes |

### Form field binding

Data entry components support direct `Phoenix.HTML.FormField` binding via the
`field` attribute, which automatically sets `name`, `id`, `value`, and error state:

```heex
<.dm_input field={@form[:email]} label="Email" type="email" />
<.dm_checkbox field={@form[:terms]} label="I agree to the terms" />
<.dm_switch field={@form[:notifications]} label="Enable notifications" />
```
