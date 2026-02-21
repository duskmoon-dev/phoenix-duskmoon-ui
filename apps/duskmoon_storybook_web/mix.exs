defmodule DuskmoonStorybookWeb.MixProject do
  use Mix.Project

  @version "0.0.0"

  def project do
    [
      app: :duskmoon_storybook_web,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DuskmoonStorybookWeb.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "storybook"]
  defp elixirc_paths(_), do: ["lib", "storybook"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_storybook, "~> 0.9"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:floki, ">= 0.30.0", only: :test},
      {:bun, "~> 1.4", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:duskmoon_storybook, in_umbrella: true},
      {:phoenix_duskmoon, in_umbrella: true},
      {:jason, "~> 1.2"},
      {:bandit, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["tailwind storybook --minify", "bun storybook --minify", "phx.digest"]
    ]
  end
end
