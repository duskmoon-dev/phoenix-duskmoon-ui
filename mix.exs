defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "9.9.9"

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
    []
  end

  defp aliases do
    [
      setup: ["cmd mix setup"],
      "duskmoon_storybook.run": "phx.server",
      prepublish: [
        "do --app phoenix_duskmoon cmd cp #{Path.expand("README.md", __DIR__)} README.md",
        "duskmoon_bundler.build phoenix_duskmoon",
        "do --app phoenix_duskmoon icons.bundle"
      ]
    ]
  end
end
