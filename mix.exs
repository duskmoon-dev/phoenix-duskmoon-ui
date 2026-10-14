Code.require_file("scripts/native-policy.exs", __DIR__)
DuskmoonUI.NativePolicy.validate!()

defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "10.0.0"
  @bundler_version File.read!(Path.join(__DIR__, "BUNDLER_VERSION")) |> String.trim()

  def project do
    [
      apps_path: "apps",
      apps: [:phoenix_duskmoon, :duskmoon_storybook],
      version: @version,
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

  defp deps do
    # Pin the entire build-tool cohort without adding it to the public component package.
    [
      {:ex_doc, "~> 0.40", runtime: false, override: true},
      # Keep Plug available to both test servers and runtime umbrella applications.
      {:plug, "~> 1.19"},
      {:duskmoon_oxc, "== #{@bundler_version}", runtime: false},
      {:duskmoon_oxide, "== #{@bundler_version}", runtime: false},
      {:duskmoon_vize, "== #{@bundler_version}", runtime: false},
      {:duskmoon_quickbeam, "== #{@bundler_version}", runtime: false},
      {:duskmoon_npm, "== #{@bundler_version}", runtime: false},
      {:duskmoon_hex_solver, "== #{@bundler_version}", runtime: false}
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
