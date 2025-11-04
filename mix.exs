defmodule PhoenixDuskmoon.Umbrella.MixProject do
  use Mix.Project

  # Umbrella version tracks phoenix_duskmoon package version
  @version "7.2.1"

  def project do
    [
      apps_path: "apps",
      version: @version,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
