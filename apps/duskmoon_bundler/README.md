# Duskmoon Bundler

[![Hex.pm](https://img.shields.io/hexpm/v/duskmoon_bundler.svg)](https://hex.pm/packages/duskmoon_bundler) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/duskmoon_bundler)

Duskmoon-maintained frontend tooling for Phoenix that runs inside the BEAM. This app is based on [Volt](https://github.com/elixir-volt/volt) and keeps the same Vite-level workflow under the `:duskmoon_bundler` OTP app and `DuskmoonBundler` module namespace.

One dep replaces esbuild, the Tailwind CLI, and Node.js with Rust NIFs powered by [OXC](https://oxc.rs), [LightningCSS](https://lightningcss.dev), and [QuickBEAM](https://hex.pm/packages/duskmoon_quickbeam) for embedded JavaScript runtimes.

```bash
mix igniter.install duskmoon_bundler
mix phx.server
```

The installer configures everything. No binaries to download, no extra processes to manage.

## Why Duskmoon Bundler

Phoenix ships with esbuild and a Tailwind CLI as separate binaries downloaded at compile time. They can't coordinate HMR or share work, and anything beyond vanilla JS requires Node.js.

DuskmoonBundler replaces both with a single Elixir dep. `mix phx.server` starts the frontend toolchain automatically, rebuilding Tailwind in ~40ms on template changes and hot-swapping JS modules via HMR. Compilation errors show as a browser overlay. Production builds finish in under 100ms.

You also get features you'd expect from Vite: code splitting, CSS Modules, JSON imports, asset query modes, web workers, HTML entry points, `import.meta.glob()`, dynamic import variables, `.env` variables, static asset imports, import aliases, and `import.meta.hot` with state preservation.

The pieces integrate because they run in one toolchain: template edits can trigger incremental Tailwind rebuilds, browser console output can flow back to your Elixir terminal, and project-specific JS/TS lint rules can be written as Elixir modules. See the [Features guide](https://hexdocs.pm/duskmoon_bundler/features.html) for the full list.

## Installation

```bash
mix igniter.install duskmoon_bundler
```

Or add the dep manually:

```elixir
def deps do
  [{:duskmoon_bundler, "~> 0.14"}]
end
```

See the [Getting Started guide](https://hexdocs.pm/duskmoon_bundler/getting-started.html) for manual configuration.

## Configuration

Standard `config/*.exs`. No `vite.config.js`, no `tailwind.config.js`:

```elixir
config :duskmoon_bundler,
  entry: ["assets/js/app.ts", "assets/js/admin.ts"],
  target: :es2020,
  import_source: "react",
  aliases: %{
    "@" => "assets/src",
    "@components" => "assets/src/components"
  },
  external: ~w(phoenix phoenix_html phoenix_live_view),
  chunks: %{
    "vendor" => ["react", "react-dom"],
    "ui" => ["assets/src/components"]
  },
  env_prefix: ["DUSKMOON_BUNDLER_", "PUBLIC_"],
  asset_url_prefix: "/assets",
  public_dir: "public",
  sourcemap: :hidden,
  tailwind: [
    css: "assets/css/app.css",
    sources: [
      %{base: "lib/", pattern: "**/*.{ex,heex}"},
      %{base: "assets/", pattern: "**/*.{js,ts,jsx,tsx,vue,svelte}"}
    ]
  ],
  plugins: [MyApp.MarkdownPlugin]

config :duskmoon_bundler, :server,
  prefix: "/assets",
  watch_dirs: ["lib/"]
```

`DuskmoonBundler.static_path/2` resolves DuskmoonBundler-managed assets to source files in dev and content-hashed paths in production:

```heex
<link phx-track-static rel="stylesheet" href={DuskmoonBundler.static_path(@endpoint, "/assets/css/app.css")} />
<script defer phx-track-static type="module" src={DuskmoonBundler.static_path(@endpoint, "/assets/js/app.js")}></script>
<img src={DuskmoonBundler.static_path(@endpoint, "/assets/images/logo.svg")} />
```

## Production builds

```
$ mix duskmoon_bundler.build

Building Tailwind CSS...
  app-1a2b3c4d.css  23.9 KB
Built Tailwind in 43ms
Building "assets/js/app.ts"...
  app-5e6f7a8b.js  128.4 KB  (gzip: 38.2 KB)
  manifest.json  2 entries
Built in 15ms
```

Tree-shaking, minification, code splitting, configurable env prefixes and asset URL prefixes, source maps, content-hashed JavaScript/CSS/assets, and manifest output. `DuskmoonBundler.Preload.tags/2` can generate modulepreload tags from the manifest, and the build is ready for `mix phx.digest`.

## Framework support

Vue SFCs with scoped CSS, React JSX with the automatic runtime, Svelte 5 with runes, and Solid JSX all compile without Node.js installed. Plain TypeScript with LiveView hooks works too.

Framework support follows the upstream Volt examples and is exposed through the `DuskmoonBundler.Plugin.*` modules.

## Developer tools

JS/TS formatting and linting run as Rust NIFs. `mix format` handles Elixir and JavaScript together:

```elixir
# .formatter.exs
[plugins: [DuskmoonBundler.Formatter], inputs: ["assets/**/*.{js,ts,jsx,tsx}"]]
```

```bash
mix format           # Elixir + JS/TS
mix duskmoon_bundler.lint        # 650+ oxlint rules
mix duskmoon_bundler.js.check    # format + lint for CI
mix duskmoon_bundler.js.check --type-aware --type-check
```

Project-specific lint rules can be written in Elixir with `OXC.Lint.Rule`. Type-aware TypeScript rules can run through `tsgolint` with `--type-aware`.

## Plugins

Extend the build pipeline with the `DuskmoonBundler.Plugin` behaviour. Plugins can turn custom file types into JavaScript and CSS, resolve virtual modules, transform parsed JavaScript and CSS ASTs, customize vendor prebundling, render final chunks, or call JS tooling through a QuickBEAM-powered embedded runtime:

```elixir
defmodule MyApp.MarkdownPlugin do
  @behaviour DuskmoonBundler.Plugin

  def name, do: "markdown"

  def compile(path, source, _opts) do
    if String.ends_with?(path, ".card.md") do
      html = Earmark.as_html!(source)

      {:ok,
       %DuskmoonBundler.Pipeline.Result{
         code: "export default #{Jason.encode!(html)};\n",
         css: ".markdown-card { padding: 1rem; border-radius: .75rem; }"
       }}
    end
  end
end
```

```elixir
config :duskmoon_bundler, plugins: [MyApp.MarkdownPlugin]
```

See the [Plugins guide](https://hexdocs.pm/duskmoon_bundler/plugins.html) for the full hook API.

## Documentation

Full documentation, guides, and cheatsheets on [HexDocs](https://hexdocs.pm/duskmoon_bundler).

## License

MIT. Based on Volt, copyright 2026 Danila Poyarkov. Duskmoon Bundler modifications copyright 2026 Jonathan Gao.
