defmodule PhoenixDuskmoon.Mixfile do
  use Mix.Project

  # Version is automatically updated by semantic-release in CI
  # Do not manually edit - use mix version.sync to sync from published version
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui.git"
  @version "7.2.1"

  def project do
    [
      app: :phoenix_duskmoon,
      version: @version,
      elixir: "~> 1.15",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      deps: deps(),
      name: "PhoenixDuskmoon",
      description: "Duskmoon UI component library for Phoenix LiveView",
      package: package(),
      aliases: aliases(),
      docs: [
        extras: ["CHANGELOG.md"],
        source_url: @source_url,
        source_ref: "v#{@version}",
        main: "PhoenixDuskmoon",
        skip_undefined_reference_warnings_on: ["CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:eex, :logger],
      env: [csrf_token_reader: {Plug.CSRFProtection, :get_csrf_token_for, []}]
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.8.1"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:plug, "~> 1.5", optional: true},
      {:bun, "~> 1.4", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:jason, "~> 1.2", only: :test},
      {:ex_doc, ">= 0.0.0", only: :prod, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Jonathan Gao"],
      licenses: ["MIT"],
      files: ~w(lib priv CHANGELOG.md LICENSE mix.exs package.json assets README.md),
      links: %{
        Changelog: "https://hexdocs.pm/phoenix_duskmoon/changelog.html",
        GitHub: @source_url
      }
    ]
  end

  defp aliases do
    [
      prepublish: [
        "cmd cp #{Path.expand("../../README.md", __DIR__)} #{Path.expand("README.md", __DIR__)}",
        "tailwind duskmoon",
        "bun duskmoon"
      ]
    ]
  end
end
