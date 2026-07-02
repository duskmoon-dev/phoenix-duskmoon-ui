defmodule DuskmoonNpm.MixProject do
  use Mix.Project

  @version "9.6.4"
  @source_url "https://github.com/duskmoon-dev/phoenix-duskmoon-ui"

  def project do
    [
      app: :duskmoon_npm,
      version: @version,
      elixir: "~> 1.15",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [plt_add_apps: [:mix]],
      name: "DuskmoonNPM",
      description:
        "Duskmoon fork of npm_ex — resolve, fetch, and manage npm dependencies with Mix tasks.",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [extra_applications: [:crypto]]
  end

  defp aliases do
    [
      lint: [
        "format --check-formatted",
        "credo --strict",
        "ex_dna",
        "dialyzer"
      ],
      ci: ["lint", "cmd MIX_ENV=test mix test"]
    ]
  end

  defp deps do
    [
      {:duskmoon_hex_solver, in_umbrella: true},
      {:nimble_parsec, "~> 1.0", runtime: false},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_slop, "~> 0.4", only: [:dev, :test], runtime: false},
      {:ex_dna, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w[lib priv guides mix.exs README.md LICENSE CHANGELOG.md]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "guides/introduction/getting-started.md",
        "guides/introduction/why-npm-ex.md",
        "guides/workflows/dependencies.md",
        "guides/workflows/ci.md",
        "guides/workflows/runtime-install.md",
        "guides/security/supply-chain-safety.md",
        "guides/security/malicious-package-audits.md",
        "guides/reference/configuration.md",
        "guides/reference/mix-tasks.md",
        "guides/cheatsheets/cli.cheatmd",
        "guides/cheatsheets/configuration.cheatmd"
      ],
      groups_for_extras: [
        Introduction: ~r/guides\/introduction\//,
        Workflows: ~r/guides\/workflows\//,
        Security: ~r/guides\/security\//,
        Reference: ~r/guides\/reference\//,
        Cheatsheets: ~r/guides\/cheatsheets\//
      ],
      groups_for_modules: [
        Core: [NPM, NPM.Config, NPM.Cache, NPM.Lockfile],
        "Package Metadata": [NPM.Package.JSON, NPM.Package.Manifest, NPM.Package.Spec],
        Dependencies: [
          NPM.Dependency.Graph,
          NPM.Dependency.Dedupe,
          NPM.Dependency.Outdated,
          NPM.Dependency.Peer
        ],
        Install: [NPM.Install.Linker, NPM.Install.Lifecycle, NPM.Install.ScriptInstall],
        Security: [
          NPM.Security.Audit,
          NPM.Security.Compromised,
          NPM.Security.ExoticDeps,
          NPM.Security.RegistryPolicy
        ],
        Registry: [
          NPM.Registry,
          NPM.Registry.URL,
          NPM.Registry.Mirror,
          NPM.Registry.Scope,
          NPM.Registry.Token
        ],
        Node: [NPM.Node.Exec, NPM.Node.Runner, NPM.Node.Bin, NPM.Node.BinResolver],
        Diagnostics: [NPM.Diagnostics, NPM.Diagnostics.Doctor, NPM.Diagnostics.Health],
        "Mix Tasks": [
          Mix.Tasks.Npm.Install,
          Mix.Tasks.Npm.Ci,
          Mix.Tasks.Npm.Audit,
          Mix.Tasks.Npm.Verify,
          Mix.Tasks.Npm.Exec
        ]
      ],
      source_ref: "v#{@version}"
    ]
  end
end
