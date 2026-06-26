defmodule NPM.Dependency.Peer do
  @moduledoc """
  Analyzes and validates peer dependency declarations.

  Peer dependencies declare that a package expects the consumer to provide a
  compatible version of another package. This module extracts peer dependency
  metadata from package manifests, distinguishes required and optional peers,
  checks lockfiles for satisfaction, and formats peer warnings for reports.
  """

  @type warning :: %{
          package: String.t(),
          peer: String.t(),
          required: String.t(),
          found: String.t() | nil,
          satisfied: boolean()
        }

  @doc "Extract peer dependencies from package manifest data."
  @spec extract(map()) :: map()
  def extract(%{"peerDependencies" => peers}) when is_map(peers), do: peers
  def extract(_), do: %{}

  @doc "Extract raw `peerDependenciesMeta` data from package manifest data."
  @spec meta(map()) :: map()
  def meta(%{"peerDependenciesMeta" => meta}) when is_map(meta), do: meta
  def meta(_), do: %{}

  @doc "Return the peer dependency names marked as optional."
  @spec optional_peers(map()) :: MapSet.t()
  def optional_peers(data) do
    data
    |> meta()
    |> Enum.filter(fn {_name, opts} -> is_map(opts) and opts["optional"] == true end)
    |> Enum.map(&elem(&1, 0))
    |> MapSet.new()
  end

  @doc "Check if a peer dependency is marked as optional."
  @spec optional?(String.t(), map()) :: boolean()
  def optional?(name, data), do: MapSet.member?(optional_peers(data), name)

  @doc "Return required, non-optional peer dependencies."
  @spec required(map()) :: map()
  def required(data) do
    optional = optional_peers(data)

    data
    |> extract()
    |> Map.reject(fn {name, _range} -> MapSet.member?(optional, name) end)
  end

  @doc "Check if all required peers are satisfied by a lockfile."
  @spec satisfied?(map(), map()) :: boolean()
  def satisfied?(data, lockfile) do
    data
    |> required()
    |> Enum.all?(fn {name, range} -> peer_satisfied?(lockfile, name, range) end)
  end

  @doc "List required peer dependencies not satisfied by a lockfile."
  @spec unsatisfied(map(), map()) :: [{String.t(), String.t(), String.t() | nil}]
  def unsatisfied(data, lockfile) do
    data
    |> required()
    |> Enum.flat_map(&check_peer(&1, lockfile))
    |> Enum.sort_by(&elem(&1, 0))
  end

  @doc "Count total peer dependency declarations across packages."
  @spec count_across([map()]) :: non_neg_integer()
  def count_across(packages) do
    packages |> Enum.map(&(extract(&1) |> map_size())) |> Enum.sum()
  end

  @doc "Check peer dependency satisfaction for a list of package manifests."
  @spec check(map(), [map()]) :: [warning()]
  def check(lockfile, manifests) when is_map(lockfile) and is_list(manifests) do
    Enum.flat_map(manifests, &check_manifest(lockfile, &1))
  end

  def check(_, _), do: []

  @doc "Summarize peer dependency warnings for display."
  @spec summary([warning()]) :: %{
          satisfied: non_neg_integer(),
          missing: non_neg_integer(),
          incompatible: non_neg_integer()
        }
  def summary(warnings) do
    {missing, incompatible} =
      Enum.reduce(warnings, {0, 0}, fn warning, {missing, incompatible} ->
        if warning.found == nil,
          do: {missing + 1, incompatible},
          else: {missing, incompatible + 1}
      end)

    %{satisfied: 0, missing: missing, incompatible: incompatible}
  end

  @doc "Format peer dependency warnings as human-readable strings."
  @spec format_warnings([warning()]) :: [String.t()]
  def format_warnings(warnings) do
    Enum.map(warnings, fn warning ->
      case warning.found do
        nil ->
          "#{warning.package} requires #{warning.peer}@#{warning.required} but it is not installed"

        version ->
          "#{warning.package} requires #{warning.peer}@#{warning.required} but found #{version}"
      end
    end)
  end

  defp check_manifest(lockfile, manifest) do
    package_name = manifest["name"] || "unknown"
    optional = optional_peers(manifest)

    manifest
    |> extract()
    |> Enum.reject(fn {name, range} -> peer_ok?(lockfile, name, range, optional) end)
    |> Enum.map(fn {peer_name, required_range} ->
      %{
        package: package_name,
        peer: peer_name,
        required: required_range,
        found: installed_version(lockfile, peer_name),
        satisfied: false
      }
    end)
  end

  defp peer_ok?(lockfile, name, range, optional) do
    MapSet.member?(optional, name) or peer_satisfied?(lockfile, name, range)
  end

  defp check_peer({name, range}, lockfile) do
    case installed_version(lockfile, name) do
      nil -> [{name, range, nil}]
      version -> if version_satisfies?(version, range), do: [], else: [{name, range, version}]
    end
  end

  defp peer_satisfied?(lockfile, name, range) do
    case installed_version(lockfile, name) do
      nil -> false
      version -> version_satisfies?(version, range)
    end
  end

  defp installed_version(lockfile, name) do
    case Map.get(lockfile, name) do
      %{version: version} -> version
      _ -> nil
    end
  end

  defp version_satisfies?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    ArgumentError -> false
  end
end
