defmodule DuskmoonHexSolver.MixProject do
  use Mix.Project

  @version "9.5.3"
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"

  def project do
    [
      app: :duskmoon_hex_solver,
      version: @version,
      elixir: "~> 1.15",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "DuskmoonHexSolver",
      description: "Duskmoon fork of hex_solver - PubGrub based dependency version solver.",
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

  defp deps do
    [
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url},
      files: ~w[lib mix.exs README.md CHANGELOG.md]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
    ]
  end
end
