defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "9.16.6"

  def project do
    [
      apps_path: "apps",
      version: @version,
      elixir: "~> 1.18",
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
    # zig_doc 0.7.0 pins ex_doc 0.39.1; keep the umbrella on current ExDoc.
    [{:ex_doc, "~> 0.40", runtime: false, override: true}]
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
