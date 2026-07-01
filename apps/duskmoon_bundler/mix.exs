defmodule DuskmoonBundler.MixProject do
  use Mix.Project

  @version "9.6.1"
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"

  def project do
    [
      app: :duskmoon_bundler,
      version: @version,
      elixir: "~> 1.18",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix], flags: [:no_opaque]],
      name: "DuskmoonBundler",
      description:
        "Elixir-native frontend build tool — dev server, HMR, and production builds powered by OXC and Vize.",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DuskmoonBundler.Application, []}
    ]
  end

  defp deps do
    [
      {:reach, "~> 2.6.1", only: :dev, runtime: false},
      {:glob_ex, "~> 0.1"},
      {:duskmoon_oxc, in_umbrella: true},
      {:duskmoon_vize, in_umbrella: true},
      {:duskmoon_oxide, in_umbrella: true},
      {:duskmoon_quickbeam, in_umbrella: true},
      {:dotenvy, "~> 1.1"},
      {:floki, "~> 0.38"},
      {:plug, "~> 1.16"},
      {:websock_adapter, "~> 0.5"},
      {:file_system, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:json_codec, "~> 0.1.5"},
      {:igniter, "~> 0.5", optional: true},
      {:duskmoon_npm, in_umbrella: true},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:makeup_js, "~> 0.1", only: :dev, runtime: false},
      {:bandit, "~> 1.0", only: :test},
      {:playwright_ex, "~> 0.5", only: :test}
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "duskmoon_bundler.js.check --type-aware --type-check",
        "credo --strict",
        "ex_dna --min-mass 20",
        "reach.check --arch --dead-code --smells --strict",
        "dialyzer"
      ],
      setup: ["deps.get"],
      ci: ["lint", "cmd env MIX_ENV=test mix test"]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w[lib priv guides mix.exs README.md CHANGELOG.md LICENSE]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "guides/introduction/getting-started.md",
        "guides/introduction/why-duskmoon-bundler.md",
        "guides/features/features.md",
        "guides/features/frameworks.md",
        "guides/features/tailwind.md",
        "guides/features/hmr.md",
        "guides/features/code-splitting.md",
        "guides/features/css-modules.md",
        "guides/features/static-assets.md",
        "guides/features/environment-variables.md",
        "guides/features/glob-imports.md",
        "guides/features/plugins.md",
        "guides/features/formatting-and-linting.md",
        "guides/deployment/production-builds.md",
        "guides/migration/from-esbuild.md",
        "guides/cheatsheets/configuration.cheatmd",
        "guides/cheatsheets/cli.cheatmd"
      ],
      groups_for_extras: [
        Introduction: ~r/guides\/introduction\//,
        Features: ~r/guides\/features\//,
        Deployment: ~r/guides\/deployment\//,
        Migration: ~r/guides\/migration\//,
        Cheatsheets: ~r/guides\/cheatsheets\//
      ],
      groups_for_modules: [
        Core: [
          DuskmoonBundler,
          DuskmoonBundler.Preload,
          DuskmoonBundler.Config,
          DuskmoonBundler.Plugin
        ],
        "Dev Server": [
          DuskmoonBundler.DevServer,
          DuskmoonBundler.Watcher,
          DuskmoonBundler.Dev.ConsoleForwarder
        ],
        "Production Build": [
          DuskmoonBundler.Builder,
          DuskmoonBundler.ChunkGraph,
          DuskmoonBundler.PublicDir
        ],
        "Tailwind CSS": [DuskmoonBundler.Tailwind],
        CSS: [DuskmoonBundler.CSS.Modules],
        Plugins: [
          DuskmoonBundler.Plugin.Vue,
          DuskmoonBundler.Plugin.Svelte,
          DuskmoonBundler.Plugin.React,
          DuskmoonBundler.Plugin.Solid,
          DuskmoonBundler.Plugin.Helpers,
          DuskmoonBundler.PluginRunner
        ],
        JavaScript: [
          DuskmoonBundler.Assets,
          DuskmoonBundler.Env,
          DuskmoonBundler.JS.Runtime,
          DuskmoonBundler.JS.Format
        ],
        Formatting: [DuskmoonBundler.Formatter, DuskmoonBundler.Format],
        "Mix Tasks": [
          Mix.Tasks.DuskmoonBundler.Build,
          Mix.Tasks.DuskmoonBundler.Dev,
          Mix.Tasks.DuskmoonBundler.Lint,
          Mix.Tasks.DuskmoonBundler.Js.Format,
          Mix.Tasks.DuskmoonBundler.Js.Check,
          Mix.Tasks.DuskmoonBundler.Install
        ],
        "Internals: Builder": [
          DuskmoonBundler.Builder.Collector,
          DuskmoonBundler.Builder.Collector.State,
          DuskmoonBundler.Builder.Context,
          DuskmoonBundler.Builder.BuildContext,
          DuskmoonBundler.Builder.Dependencies,
          DuskmoonBundler.Builder.Externals,
          DuskmoonBundler.Builder.Output,
          DuskmoonBundler.Builder.OutputContext,
          DuskmoonBundler.Builder.OutputFile,
          DuskmoonBundler.Builder.Resolver,
          DuskmoonBundler.Builder.Result,
          DuskmoonBundler.Builder.Rewriter,
          DuskmoonBundler.Builder.Writer,
          DuskmoonBundler.HTMLEntry,
          DuskmoonBundler.Pipeline,
          DuskmoonBundler.Pipeline.Result
        ],
        "Internals: Config": [
          DuskmoonBundler.Config.Build,
          DuskmoonBundler.Config.Profile,
          DuskmoonBundler.Config.Server
        ],
        "Internals: CSS": [
          DuskmoonBundler.CSS.AST,
          DuskmoonBundler.CSS.AssetURLRewriter
        ],
        "Internals: Dev Server": [
          DuskmoonBundler.Cache,
          DuskmoonBundler.DevServer.CacheEntry,
          DuskmoonBundler.DevServer.Config
        ],
        "Internals: HMR": [
          DuskmoonBundler.HMR.Boundary,
          DuskmoonBundler.HMR.GlobGraph,
          DuskmoonBundler.HMR.ImportGraph,
          DuskmoonBundler.HMR.Message,
          DuskmoonBundler.HMR.ModuleGraph,
          DuskmoonBundler.HMR.ModuleGraph.Node,
          DuskmoonBundler.HMR.Socket
        ],
        "Internals: JavaScript": [
          DuskmoonBundler.Assets.Query,
          DuskmoonBundler.JS.Asset,
          DuskmoonBundler.JS.AST,
          DuskmoonBundler.JS.Extensions,
          DuskmoonBundler.JS.Helpers,
          DuskmoonBundler.JS.ImportExtractor,
          DuskmoonBundler.JS.ImportExtractor.Result,
          DuskmoonBundler.JS.Patch,
          DuskmoonBundler.JS.PrebundleEntry,
          DuskmoonBundler.JS.PrebundleEntry.Export,
          DuskmoonBundler.JS.PrebundleEntry.Import,
          DuskmoonBundler.JS.Resolution,
          DuskmoonBundler.JS.Resolver,
          DuskmoonBundler.JS.Runtime.Bundler,
          DuskmoonBundler.JS.Runtime.Entry,
          DuskmoonBundler.JS.Runtime.Error,
          DuskmoonBundler.JS.Runtime.Installer,
          DuskmoonBundler.JS.Transforms.AssetURLs,
          DuskmoonBundler.JS.Transforms.DynamicImports,
          DuskmoonBundler.JS.Transforms.DynamicImports.Replacement,
          DuskmoonBundler.JS.Transforms.GlobImports,
          DuskmoonBundler.JS.Transforms.GlobImports.Call,
          DuskmoonBundler.JS.Transforms.GlobImports.File,
          DuskmoonBundler.JS.Transforms.ImportMetaEnv,
          DuskmoonBundler.JS.Transforms.Imports,
          DuskmoonBundler.JS.Transforms.Specifiers,
          DuskmoonBundler.JS.Transforms.Workers,
          DuskmoonBundler.JS.TSConfig,
          DuskmoonBundler.JS.Vendor
        ],
        "Internals: Support": [
          DuskmoonBundler.Application,
          DuskmoonBundler.ETS,
          DuskmoonBundler.Path,
          DuskmoonBundler.Tailwind.Loader,
          DuskmoonBundler.Tailwind.Resolver,
          DuskmoonBundler.URL
        ],
        "Internals: Plugin Options": [
          DuskmoonBundler.Plugin.Solid.CompilerOptions,
          DuskmoonBundler.Plugin.Solid.CompilerOptions.SolidOptions,
          DuskmoonBundler.Plugin.Svelte.CompilerOptions
        ]
      ],
      skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
    ]
  end
end
