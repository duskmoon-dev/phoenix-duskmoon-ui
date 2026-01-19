# Phoenix Duskmoon UI - Integration Guide

This guide provides comprehensive instructions for integrating Phoenix Duskmoon UI into your Phoenix projects.

## Prerequisites

- **Elixir**: ~> 1.12
- **Phoenix**: ~> 1.8.1
- **Phoenix LiveView**: ~> 1.1.0
- **TailwindCSS**: >= 4.0
- **Node.js**: For frontend asset management

## Installation

### 1. Add Dependencies

Add to your `mix.exs` dependencies:

```elixir
def deps do
  [
    # ... other deps
    {:phoenix_duskmoon, "~> 9.0"}
  ]
end
```

Install the dependency:

```bash
mix deps.get
```

### 2. Configure View Helpers

In your `lib/your_app_web.ex` file, add the components to your `html_helpers` function:

```elixir
defp html_helpers do
  quote do
    # ... existing imports

    # Import all Duskmoon UI components
    use PhoenixDuskmoon.Component
    # Import all Duskmoon UI fun components
    use PhoenixDuskmoon.Fun
  end
end
```

### 3. Configure CSS/Assets

#### Using npm/yarn (Recommended)

Install the required npm packages:

```bash
npm install tailwindcss @duskmoon-dev/core duskmoon-elements
# or
yarn add tailwindcss @duskmoon-dev/core duskmoon-elements
# or
bun add tailwindcss @duskmoon-dev/core duskmoon-elements
```

> **Note (v9)**: Phoenix Duskmoon UI v9 uses `@duskmoon-dev/core` instead of `duskmoonui` (daisyui).

#### Configure TailwindCSS

In your `assets/css/app.css`:

```css
@source "../js/**/*.js";
@source '../../lib/**/*.exs';
@source '../../lib/**/*.ex';

@import "tailwindcss";
@import "@duskmoon-dev/core";
@import "phoenix_duskmoon/components";
```

#### Using esbuild/tailwind config

Update your `config/config.exs` to include the asset configuration:

```elixir
config :tailwind, :default,
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
  cd: Path.expand("../assets", __DIR__)
```

### 4. Theme Configuration (Optional)

For advanced theming, you can import additional CSS modules:

```css
/* Neumorphic theme for special effects */
@import "phoenix_duskmoon/neumorphic";
```

## Available Components

### Basic Components

- **Buttons**: `<.dm_btn>` - Variants: primary, secondary, accent, info, success, warning, error, ghost, link, outline
- **Cards**: `<.dm_card>` - Content containers with styling
- **Icons**: `<.dm_mdi>`, `<.dm_bsi>` - Material Design Icons and Bootstrap Icons
- **Links**: `<.dm_link>` - Styled links with variants

### Layout Components

- **App Bar**: `<.dm_appbar>` - Top navigation bar
- **Page Header**: `<.dm_page_header>` - Page title section
- **Page Footer**: `<.dm_page_footer>` - Page footer section
- **Breadcrumb**: `<.dm_breadcrumb>` - Navigation breadcrumbs
- **Tabs**: `<.dm_tab>` - Tabbed content areas

### Form Components

- **Form**: `<.dm_form>` - Styled form containers
- **Loading**: `<.dm_loading>` - Loading indicators
- **Modal**: `<.dm_modal>` - Dialog modals
- **Theme Switcher**: `<.dm_theme_switcher>` - Dark/light mode toggle

### Data Display

- **Table**: `<.dm_table>` - Styled data tables
- **Pagination**: `<.dm_pagination>` - Page navigation
- **Flash**: `<.dm_flash>` - Flash message notifications
- **Markdown**: `<.dm_markdown>` - Markdown content renderer

### Navigation

- **Navbar**: `<.dm_navbar>` - Navigation menu
- **Left Menu**: `<.dm_left_menu>` - Sidebar navigation
- **Action Bar**: `<.dm_actionbar>` - Action button groups

## Usage Examples

### Basic Button

```heex
<.dm_btn variant="primary" size="md">Click me</.dm_btn>
<.dm_btn variant="secondary" size="lg" loading>Loading</.dm_btn>
<.dm_btn variant="error" size="sm" shape="circle">×</.dm_btn>
```

### Form with Validation

```heex
<.dm_form for={@form} phx-submit="save">
  <.input field={@form[:email]} label="Email" type="email" />
  <.input field={@form[:password]} label="Password" type="password" />

  <.dm_btn variant="primary" type="submit">Save</.dm_btn>
</.dm_form>
```

### Card with Actions

```heex
<.dm_card class="p-6">
  <:title>
    <h3 class="text-lg font-semibold">User Profile</h3>
  </:title>

  <p class="text-gray-600">User information and settings</p>

  <:footer>
    <.dm_btn variant="primary" phx-click="edit">Edit</.dm_btn>
    <.dm_btn variant="ghost" phx-click="delete">Delete</.dm_btn>
  </:footer>
</.dm_card>
```

> **Note (v9)**: Components render as HTML Custom Elements (e.g., `<el-dm-card>`, `<el-dm-button>`) for improved encapsulation.

### Modal Dialog

```heex
<.dm_modal id="confirm-dialog" show={@show_modal}>
  <:header>Confirm Action</:header>

  <p>Are you sure you want to proceed?</p>

  <:footer>
    <.dm_btn phx-click="cancel">Cancel</.dm_btn>
    <.dm_btn variant="primary" phx-click="confirm">Confirm</.dm_btn>
  </:footer>
</.dm_modal>
```

### Navigation Bar

```heex
<.dm_appbar>
  <:brand>
    <h1 class="text-xl font-bold">MyApp</h1>
  </:brand>

  <:nav>
    <.dm_link href="/dashboard">Dashboard</.dm_link>
    <.dm_link href="/users">Users</.dm_link>
    <.dm_link href="/settings">Settings</.dm_link>
  </:nav>

  <:actions>
    <.dm_theme_switcher />
    <.dm_btn variant="ghost" shape="circle">
      <.dm_mdi name="account_circle" />
    </.dm_btn>
  </:actions>
</.dm_appbar>
```

## Live Storybook

For exploring all available components and their variations, visit the [Live Storybook](https://duskmoon-storybook.gsmlg.dev) or run it locally:

```bash
cd /path/to/phoenix-duskmoon-ui
mix phx.server
```

Then navigate to `http://localhost:4000/storybook`.

## Configuration Options

### Custom Icons

The library includes Material Design Icons and Bootstrap Icons:

```elixir
# Material Design Icons
<.dm_mdi name="home" />

# Bootstrap Icons
<.dm_bsi name="house" />
```

### Custom Themes

You can extend the theme with CSS custom properties (v9 uses OKLCH colors):

```css
:root {
  /* Customize theme colors using CSS custom properties */
  --dm-color-primary: oklch(0.65 0.19 250);
  --dm-color-secondary: oklch(0.75 0.15 200);
  --dm-color-accent: oklch(0.7 0.2 150);

  /* Semantic colors */
  --dm-color-success: oklch(0.7 0.2 145);
  --dm-color-warning: oklch(0.8 0.15 85);
  --dm-color-error: oklch(0.6 0.2 25);
  --dm-color-info: oklch(0.7 0.15 250);
}
```

### Component Variants

Most components support the `variant` attribute for different styles:

- `primary`, `secondary`, `accent` - Main color variants
- `info`, `success`, `warning`, `error` - Semantic variants
- `ghost`, `link`, `outline` - Minimal variants

## Troubleshooting

### Common Issues

1. **Components not found**: Ensure you've added `use PhoenixDuskmoon.Component` to your view helpers
2. **Styles not applied**: Check that TailwindCSS is properly configured and CSS imports are correct
3. **Icons not showing**: Verify that the icon fonts are loaded and the icon name is correct

### CSS Issues

If styles aren't applying:

1. Check your TailwindCSS configuration includes the right sources
2. Ensure `@duskmoon-dev/core` is imported
3. Verify CSS imports are in the correct order
4. Run `mix tailwind default` to rebuild CSS

### JavaScript Issues

If interactive components aren't working:

1. Ensure Phoenix LiveView is properly set up
2. Check that JavaScript hooks are loaded
3. Verify CSRF tokens are configured properly

## Support

- **Documentation**: [HexDocs](https://hexdocs.pm/phoenix_duskmoon/)
- **Issues**: [GitHub Issues](https://github.com/duskmoon-dev/phoenix-duskmoon-ui/issues)
- **Live Examples**: [Storybook](https://duskmoon-storybook.gsmlg.dev)

## Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.