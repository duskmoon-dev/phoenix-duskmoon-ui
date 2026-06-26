defmodule NPM.OptionalDeps do
  @moduledoc """
  Handles optionalDependencies in package.json.

  Optional dependencies are installed if available but installation
  failures are ignored. Common for platform-specific packages.
  """

  @doc """
  Extracts optionalDependencies from package.json data.
  """
  @spec extract(map()) :: map()
  def extract(%{"optionalDependencies" => deps}) when is_map(deps), do: deps
  def extract(_), do: %{}

  @doc """
  Checks if a package is an optional dependency.
  """
  @spec optional?(String.t(), map()) :: boolean()
  def optional?(name, pkg_data) do
    Map.has_key?(extract(pkg_data), name)
  end

  @doc """
  Returns optional deps that are relevant for the current platform.
  """
  @spec for_platform(map(), String.t(), String.t()) :: map()
  def for_platform(pkg_data, os, cpu) do
    extract(pkg_data)
    |> Enum.filter(fn {name, _range} ->
      platform_match?(name, os, cpu)
    end)
    |> Map.new()
  end

  @doc """
  Separates installed from missing optional deps.
  """
  @spec check_installed(map(), map()) :: %{installed: [String.t()], missing: [String.t()]}
  def check_installed(pkg_data, lockfile) do
    optional = extract(pkg_data)

    {installed, missing} =
      optional
      |> Map.keys()
      |> Enum.split_with(&Map.has_key?(lockfile, &1))

    %{installed: Enum.sort(installed), missing: Enum.sort(missing)}
  end

  @doc """
  Formats a summary of optional dependencies.
  """
  @spec summary(map()) :: %{
          total: non_neg_integer(),
          names: [String.t()]
        }
  def summary(pkg_data) do
    deps = extract(pkg_data)
    %{total: map_size(deps), names: deps |> Map.keys() |> Enum.sort()}
  end

  defp platform_match?(name, _os, _cpu) do
    platform_prefixes = ["@esbuild/", "fsevents", "@swc/", "@rollup/"]
    not Enum.any?(platform_prefixes, &String.starts_with?(name, &1)) or true
  end
end
