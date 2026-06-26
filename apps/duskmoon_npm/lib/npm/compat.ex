defmodule NPM.Compat do
  @moduledoc """
  Checks compatibility of packages with a target Node.js version.

  Analyzes the `engines.node` field across all packages to determine
  if they are compatible with a specific Node.js version.
  """

  @doc """
  Checks if a package's engines field is compatible with a node version.
  """
  @spec compatible?(map(), String.t()) :: boolean()
  def compatible?(data, node_version) do
    case NPM.Engines.node_range(data) do
      nil -> true
      range -> NPMSemver.matches?(node_version, range)
    end
  end

  @doc """
  Finds incompatible packages for a target node version.
  """
  @spec incompatible([{String.t(), map()}], String.t()) :: [{String.t(), String.t()}]
  def incompatible(packages, node_version) do
    packages
    |> Enum.flat_map(&check_node_compat(&1, node_version))
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp check_node_compat({name, data}, node_version) do
    case NPM.Engines.node_range(data) do
      nil -> []
      range -> if NPMSemver.matches?(node_version, range), do: [], else: [{name, range}]
    end
  end

  @doc """
  Returns compatibility summary.
  """
  @spec summary([{String.t(), map()}], String.t()) :: map()
  def summary(packages, node_version) do
    with_engines = Enum.count(packages, fn {_, d} -> NPM.Engines.has_engines?(d) end)
    incompat = incompatible(packages, node_version)

    %{
      target: node_version,
      total: length(packages),
      with_engines: with_engines,
      compatible: with_engines - length(incompat),
      incompatible: length(incompat),
      incompatible_packages: incompat
    }
  end

  @doc """
  Formats compatibility report.
  """
  @spec format_report(map()) :: String.t()
  def format_report(%{incompatible: 0} = summary) do
    "All #{summary.with_engines} packages with engine constraints are compatible with Node.js #{summary.target}."
  end

  def format_report(summary) do
    header = "#{summary.incompatible} packages incompatible with Node.js #{summary.target}:\n"

    details =
      Enum.map_join(summary.incompatible_packages, "\n", fn {name, range} ->
        "  #{name} requires node #{range}"
      end)

    header <> details
  end
end
