defmodule NPM.Dependency.Outdated do
  @moduledoc """
  Checks for outdated packages by comparing installed versions
  against the latest available versions on the registry.
  """

  @type outdated_entry :: %{
          name: String.t(),
          current: String.t(),
          wanted: String.t(),
          latest: String.t(),
          type: :major | :minor | :patch | :current
        }

  @doc """
  Checks a lockfile against wanted ranges and latest versions.

  Given a lockfile (installed versions) and deps (wanted ranges from package.json),
  and a map of latest versions from the registry, returns a list of outdated entries.
  """
  @spec check(map(), map(), map()) :: [outdated_entry()]
  def check(lockfile, deps, latest_versions) do
    deps
    |> Enum.flat_map(&check_package(&1, lockfile, latest_versions))
    |> Enum.sort_by(& &1.name)
  end

  defp check_package({name, range}, lockfile, latest_versions) do
    case Map.get(lockfile, name) do
      nil -> []
      entry -> build_entry(name, entry.version, range, latest_versions)
    end
  end

  defp build_entry(name, current, range, latest_versions) do
    latest = Map.get(latest_versions, name, current)

    wanted =
      case NPM.SemverUtil.max_satisfying(available_versions(latest), range) do
        {:ok, v} -> v
        _ -> current
      end

    case NPM.SemverUtil.update_type(current, latest) do
      :none -> []
      type -> [%{name: name, current: current, wanted: wanted, latest: latest, type: type}]
    end
  end

  @doc """
  Classifies an update type.
  """
  @spec update_type(String.t(), String.t()) :: :major | :minor | :patch | :current
  def update_type(current, latest) do
    case NPM.SemverUtil.update_type(current, latest) do
      :none -> :current
      type when type in [:major, :minor, :patch] -> type
    end
  end

  @doc """
  Computes all available updates from `{name, current, latest}` tuples.
  """
  @spec compute([{String.t(), String.t(), String.t()}]) :: [map()]
  def compute(packages) do
    packages
    |> Enum.map(fn {name, current, latest} ->
      %{name: name, current: current, latest: latest, type: update_type(current, latest)}
    end)
    |> Enum.reject(&(&1.type == :current))
    |> Enum.sort_by(fn update -> {type_order(update.type), update.name} end)
  end

  @doc """
  Groups updates by type.
  """
  @spec group_by_type([map()]) :: map()
  def group_by_type(updates) do
    Enum.group_by(updates, & &1.type)
  end

  @doc """
  Filters outdated entries by update type.
  """
  @spec filter_by_type([outdated_entry()], :major | :minor | :patch) :: [outdated_entry()]
  def filter_by_type(entries, type) do
    Enum.filter(entries, &(&1.type == type))
  end

  @doc """
  Formats an outdated entry as a human-readable string.
  """
  @spec format_entry(outdated_entry()) :: String.t()
  def format_entry(entry) do
    "#{entry.name}  #{entry.current} → #{entry.latest} (wanted: #{entry.wanted})"
  end

  @doc """
  Returns a summary of outdated packages.
  """
  @spec summary([outdated_entry()] | [map()]) :: %{
          total: non_neg_integer(),
          major: non_neg_integer(),
          minor: non_neg_integer(),
          patch: non_neg_integer()
        }
  def summary(entries) do
    grouped = group_by_type(entries)

    %{
      total: length(entries),
      major: length(Map.get(grouped, :major, [])),
      minor: length(Map.get(grouped, :minor, [])),
      patch: length(Map.get(grouped, :patch, []))
    }
  end

  @doc """
  Formats updates for display.
  """
  @spec format([map()]) :: String.t()
  def format([]), do: "All packages are up to date."

  def format(updates) do
    Enum.map_join(updates, "\n", fn update ->
      "#{update.name}: #{update.current} → #{update.latest} (#{update.type})"
    end)
  end

  defp available_versions(latest) do
    [latest]
  end

  defp type_order(:major), do: 0
  defp type_order(:minor), do: 1
  defp type_order(:patch), do: 2
  defp type_order(_), do: 3
end
