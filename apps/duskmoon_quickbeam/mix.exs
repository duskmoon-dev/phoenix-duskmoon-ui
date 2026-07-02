defmodule QuickBEAM.MixProject do
  use Mix.Project

  @version "9.6.3"

  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"
  @upstream_url "https://github.com/elixir-volt/quickbeam"

  def project do
    [
      app: :duskmoon_quickbeam,
      version: @version,
      elixir: "~> 1.18",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:crypto, :inets, :ssl, :public_key]],
      name: "DuskmoonQuickBEAM",
      description:
        "Duskmoon fork of QuickBEAM — JavaScript runtime for the BEAM with Web APIs backed by OTP.",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs(),
      test_coverage: [tool: QuickBEAM.Cover, ignore_modules: [QuickBEAM.Native.Manifest]]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :public_key, :xmerl],
      mod: {QuickBEAM.Application, []}
    ]
  end

  def cli do
    [preferred_envs: [ci: :test]]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "credo --strict",
        "ex_dna",
        "cmd zlint lib/quickbeam/*.zig lib/quickbeam/napi/*.zig",
        "cmd npx oxlint -c oxlint.json --type-aware --type-check priv/ts/",
        "cmd sh -c \"npx jscpd priv/ts/*.ts --min-tokens 50 --threshold 0\""
      ],
      ci: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "dialyzer",
        "ex_dna",
        "cmd zlint lib/quickbeam/*.zig lib/quickbeam/napi/*.zig",
        "cmd npx oxlint -c oxlint.json --type-aware --type-check priv/ts/",
        "cmd sh -c \"npx jscpd priv/ts/*.ts --min-tokens 50 --threshold 0\"",
        "test --no-start --exclude napi_addon --exclude napi_sqlite"
      ],
      "fuzz.sanity": "cmd --cd fuzz zig build test"
    ]
  end

  defp deps do
    [
      {:zigler_precompiled, "~> 0.1.4", runtime: false},
      {:zigler, "~> 0.13.0 or ~> 0.14.0 or ~> 0.15.0 or ~> 0.16.0", runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.2", only: [:dev, :test], runtime: false},
      {:jason, "~> 1.4"},
      {:duskmoon_oxc, in_umbrella: true},
      {:rustler, "~> 0.38", optional: true, runtime: false},
      {:duskmoon_npm, in_umbrella: true},
      {:mint_web_socket, "~> 1.0"},
      {:nimble_pool, "~> 1.1"},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Upstream" => @upstream_url
      },
      files: ~w[
        lib priv/c_src priv/ts
        mix.exs README.md LICENSE CHANGELOG.md
        checksum-QuickBEAM.Native.exs
        .formatter.exs
      ]
    ]
  end

  defp docs do
    [
      main: "QuickBEAM",
      extras: [
        "README.md",
        "docs/javascript-api.md",
        "docs/architecture.md",
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        Guides: ["docs/javascript-api.md", "docs/architecture.md"]
      ],
      source_ref: "v#{@version}"
    ]
  end
end
