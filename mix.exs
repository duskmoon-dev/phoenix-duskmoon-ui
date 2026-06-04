defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "9.4.2"

  def project do
    [
      apps_path: "apps",
      version: @version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      listeners: [Phoenix.CodeReloader],
      releases: [
        storybook: [
          applications: [duskmoon_storybook_web: :permanent]
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
      setup: ["cmd mix setup"]
    ]
  end
end
