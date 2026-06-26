defmodule NPM.Security.ExoticDeps do
  @moduledoc """
  Detects and blocks exotic dependency specs in published package metadata.

  Registry packages can declare dependencies that resolve from outside the
  configured registry, such as Git repositories, direct tarball URLs, local
  files, or GitHub shorthand specs. Those sources bypass the normal registry
  integrity and metadata flow and have been used by supply-chain malware to
  trigger hidden build steps through transitive `optionalDependencies`.

  `npm_ex` blocks these transitive specs by default. Direct project dependencies
  are still controlled by the root manifest; this module protects against a
  package from the registry unexpectedly introducing an external source deeper
  in the dependency graph.
  """

  defmodule Error do
    @moduledoc """
    Raised when a dependency points at an exotic source blocked by policy.
    """

    defexception [:package, :version, :field, :dependency, :spec, :direct?]

    @impl true
    def message(%__MODULE__{direct?: true} = error) do
      "#{error.dependency}: #{error.spec} is an exotic direct dependency. " <>
        "Add the exact spec to config :duskmoon_npm, exotic_deps: [...] or NPM_EX_EXOTIC_DEPS to allow it."
    end

    def message(%__MODULE__{} = error) do
      "#{error.package}@#{error.version} declares exotic #{error.field} entry " <>
        "#{error.dependency}: #{error.spec}. Transitive git, file, and URL dependencies are blocked by default."
    end
  end

  @fields [
    {:dependencies, "dependencies"},
    {:optional_dependencies, "optionalDependencies"}
  ]

  @doc "Validate a direct project dependency against the exotic dependency allowlist."
  @spec validate_direct!(String.t(), term()) :: :ok
  def validate_direct!(dependency, spec) do
    if exotic?(spec) and spec not in NPM.Config.exotic_deps() do
      raise Error, dependency: dependency, spec: spec, direct?: true
    end

    :ok
  end

  @spec validate!(String.t(), String.t(), map()) :: :ok
  def validate!(package, version, info) do
    if NPM.Config.block_exotic_subdeps?() do
      Enum.each(@fields, &validate_field!(&1, package, version, info))
    end

    :ok
  end

  defp validate_field!({key, field}, package, version, info) do
    info
    |> Map.get(key, %{})
    |> Enum.each(fn {dependency, spec} ->
      if exotic?(spec) do
        raise Error,
          package: package,
          version: version,
          field: field,
          dependency: dependency,
          spec: spec
      end
    end)
  end

  @spec exotic?(term()) :: boolean()
  def exotic?(spec) when is_binary(spec) do
    spec = String.trim(spec)

    has_exotic_prefix?(spec) or github_shorthand?(spec)
  end

  def exotic?(_), do: false

  defp has_exotic_prefix?(spec) do
    prefixes = ~w(file: git+ git:// github: ssh:// http:// https://)
    Enum.any?(prefixes, &String.starts_with?(spec, &1))
  end

  defp github_shorthand?(spec) do
    Regex.match?(~r/^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+(?:#.+)?$/, spec)
  end
end
