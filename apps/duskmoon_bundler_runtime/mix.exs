defmodule DuskmoonBundlerRuntime.MixProject do
  use Mix.Project

  @version "9.7.0"
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"

  def project do
    [
      app: :duskmoon_bundler_runtime,
      version: @version,
      elixir: "~> 1.18",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "DuskmoonBundlerRuntime",
      description: "Production runtime asset resolver for DuskmoonBundler manifests.",
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
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w[lib mix.exs README.md CHANGELOG.md LICENSE]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        Core: [
          DuskmoonBundler,
          DuskmoonBundler.Preload,
          DuskmoonBundler.StaticPath
        ],
        Manifest: [
          DuskmoonBundler.Manifest,
          DuskmoonBundler.Manifest.Entry
        ],
        Support: [
          DuskmoonBundler.Paths,
          DuskmoonBundler.Runtime.Config,
          DuskmoonBundler.URL
        ]
      ]
    ]
  end
end
