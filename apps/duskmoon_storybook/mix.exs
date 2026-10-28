defmodule DuskmoonStorybook.MixProject do
  use Mix.Project

  @version "0.0.0"

  def project do
    [
      app: :duskmoon_storybook,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: lockfile(),
      elixir: if(hologram?(), do: ">= 1.19.0", else: ">= 1.18.0"),
      compilers: Mix.compilers() ++ hologram_compilers(),
      test_paths: ["test"] ++ hologram_test_paths(),
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
      mod: {DuskmoonStorybook.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "storybook"] ++ hologram_paths()
  defp elixirc_paths(_), do: ["lib", "storybook"] ++ hologram_paths()

  defp hologram?, do: System.get_env("DUSKMOON_HOLOGRAM") == "1"
  defp hologram_paths, do: if(hologram?(), do: ["hologram"], else: [])
  defp hologram_test_paths, do: if(hologram?(), do: ["hologram_test"], else: [])
  defp hologram_compilers, do: if(hologram?(), do: [:hologram], else: [])
  defp hologram_deps, do: if(hologram?(), do: [{:hologram, "== 0.12.2"}], else: [])

  defp lockfile do
    if hologram?(), do: "../../_build/hologram-example.mix.lock", else: "../../mix.lock"
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.6", only: :dev},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_storybook, "~> 1.1"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_pubsub, "~> 2.2"},
      {:lazy_html, "~> 0.1.0"},
      {:duskmoon_bundler_runtime, "~> 10.0"},
      {:duskmoon_bundler, "~> 10.0", runtime: Mix.env() in [:dev, :test]},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.3"},
      {:gettext, "~> 1.0"},
      {:phoenix_duskmoon, in_umbrella: true},
      {:jason, "~> 1.4"},
      {:gaoxy_http, "~> 0.13.0"}
    ] ++ hologram_deps()
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": ["duskmoon_bundler.build duskmoon_storybook", "phx.digest"]
    ]
  end
end
