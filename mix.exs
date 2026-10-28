Code.require_file("scripts/native-policy.exs", __DIR__)
DuskmoonUI.NativePolicy.validate!()

defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "10.0.11"

  def project do
    [
      apps_path: "apps",
      apps: [:phoenix_duskmoon, :duskmoon_storybook],
      version: @version,
      lockfile: lockfile(),
      elixir: ">= 1.18.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      releases: [
        storybook: [
          applications: [duskmoon_storybook: :permanent]
        ]
      ],
      aliases: aliases()
    ]
  end

  defp lockfile do
    if System.get_env("DUSKMOON_HOLOGRAM") == "1" do
      "_build/hologram-example.mix.lock"
    else
      "mix.lock"
    end
  end

  defp deps do
    # Keep the build-tool cohort in the 10.x series without adding it to the public package.
    [
      {:ex_doc, "~> 0.40", runtime: false, override: true},
      # Keep Plug available to both test servers and runtime umbrella applications.
      {:plug, "~> 1.19"},
      {:websock_adapter, "~> 0.13.0", hex: :gaoxy_websock_adapter, override: true},
      {:duskmoon_oxc, "~> 10.0", runtime: false},
      {:duskmoon_oxide, "~> 10.0", runtime: false},
      {:duskmoon_vize, "~> 10.0", runtime: false},
      {:duskmoon_quickbeam, "~> 10.0", runtime: false},
      {:duskmoon_npm, "~> 10.0", runtime: false},
      {:duskmoon_hex_solver, "~> 10.0", runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["cmd mix setup"],
      "duskmoon.dev": "phx.server",
      prepublish: [
        "do --app phoenix_duskmoon cmd cp #{Path.expand("README.md", __DIR__)} README.md",
        "duskmoon_bundler.build phoenix_duskmoon",
        "do --app phoenix_duskmoon icons.bundle"
      ]
    ]
  end
end
