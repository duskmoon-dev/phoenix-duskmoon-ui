defmodule OXC.MixProject do
  use Mix.Project

  @version "9.6.4"
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"
  @upstream_url "https://github.com/elixir-volt/oxc_ex"

  def project do
    [
      app: :duskmoon_oxc,
      version: @version,
      elixir: "~> 1.18",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix]],
      name: "DuskmoonOXC",
      description:
        "Duskmoon fork of OXC Elixir bindings — parse, transform, minify, and bundle JS/TS via Rust NIFs.",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Upstream" => @upstream_url,
        "OXC" => "https://oxc.rs"
      },
      files:
        ~w(lib native/oxc_ex_nif/src native/oxc_ex_nif/Cargo.toml native/oxc_lint_nif/src native/oxc_lint_nif/Cargo.toml native/oxc_lint_nif/Cargo.lock native/oxc_fmt_nif/src native/oxc_fmt_nif/Cargo.toml native/oxc_fmt_nif/Cargo.lock Cargo.toml Cargo.lock .formatter.exs mix.exs README.md LICENSE checksum-*.exs)
    ]
  end

  defp docs do
    [
      main: "OXC",
      extras: ["README.md", "LICENSE"],
      source_ref: "v#{@version}"
    ]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "credo --strict",
        "ex_dna",
        "dialyzer",
        "cmd cargo fmt --manifest-path native/oxc_ex_nif/Cargo.toml -- --check",
        "cmd cargo fmt --manifest-path native/oxc_fmt_nif/Cargo.toml -- --check",
        "cmd cargo fmt --manifest-path native/oxc_lint_nif/Cargo.toml -- --check",
        "cmd cargo clippy --manifest-path native/oxc_ex_nif/Cargo.toml -- -D warnings",
        "cmd cargo clippy --manifest-path native/oxc_fmt_nif/Cargo.toml -- -D warnings",
        "cmd cargo clippy --manifest-path native/oxc_lint_nif/Cargo.toml -- -D warnings"
      ],
      ci: [
        "lint",
        "reach.check --smells --strict --baseline .reach-baseline.json",
        "cmd --shell OXC_EX_BUILD=1 MIX_ENV=test mix test"
      ]
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.38", runtime: false},
      {:rustler_precompiled, "~> 0.8", runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.2", only: [:dev, :test], runtime: false},
      {:reach, "~> 2.5", only: :dev, runtime: false},
      {:jason, "~> 1.4"}
    ]
  end
end
