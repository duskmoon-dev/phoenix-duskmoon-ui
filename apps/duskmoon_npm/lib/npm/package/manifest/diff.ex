defmodule NPM.Package.Manifest.Diff do
  @moduledoc """
  Diffs two package.json manifests to determine what changed.
  """

  @dep_fields ~w(dependencies devDependencies peerDependencies optionalDependencies)

  @doc """
  Computes a diff between two package.json maps.
  """
  @spec diff(map(), map()) :: map()
  def diff(old, new) do
    %{
      name_changed: old["name"] != new["name"],
      version_changed: version_change(old["version"], new["version"]),
      deps: diff_all_deps(old, new),
      scripts: diff_map(old["scripts"] || %{}, new["scripts"] || %{}),
      fields: diff_top_level(old, new)
    }
  end

  @doc """
  Diffs a specific dependency group.
  """
  @spec diff_deps(map(), map()) :: map()
  def diff_deps(old_deps, new_deps) when is_map(old_deps) and is_map(new_deps) do
    diff_map(old_deps, new_deps)
  end

  @doc """
  Checks if two manifests are equivalent.
  """
  @spec equivalent?(map(), map()) :: boolean()
  def equivalent?(old, new) do
    d = diff(old, new)

    not d.name_changed and d.version_changed == nil and
      empty_diff?(d.deps) and empty_diff?(d.scripts)
  end

  @doc """
  Formats diff for display.
  """
  @spec format(map()) :: String.t()
  def format(diff_result) do
    parts = []
    parts = if diff_result.name_changed, do: ["Name changed" | parts], else: parts

    parts =
      if diff_result.version_changed,
        do: ["Version: #{format_change(diff_result.version_changed)}" | parts],
        else: parts

    parts = format_section(parts, "Dependencies", diff_result.deps)
    parts = format_section(parts, "Scripts", diff_result.scripts)

    case Enum.reverse(parts) do
      [] -> "No changes."
      list -> Enum.join(list, "\n")
    end
  end

  defp diff_all_deps(old, new) do
    @dep_fields
    |> Enum.map(fn field -> {field, diff_map(old[field] || %{}, new[field] || %{})} end)
    |> Enum.reject(fn {_, d} -> empty_diff?(d) end)
    |> Map.new()
  end

  defp diff_map(old, new) do
    old_keys = Map.keys(old) |> MapSet.new()
    new_keys = Map.keys(new) |> MapSet.new()

    %{
      added: MapSet.difference(new_keys, old_keys) |> MapSet.to_list() |> Enum.sort(),
      removed: MapSet.difference(old_keys, new_keys) |> MapSet.to_list() |> Enum.sort(),
      changed:
        MapSet.intersection(old_keys, new_keys)
        |> Enum.filter(fn k -> old[k] != new[k] end)
        |> Enum.map(fn k -> {k, old[k], new[k]} end)
        |> Enum.sort_by(&elem(&1, 0))
    }
  end

  defp empty_diff?(%{added: [], removed: [], changed: []}), do: true
  defp empty_diff?(map) when is_map(map), do: map_size(map) == 0
  defp empty_diff?(_), do: true

  defp version_change(same, same), do: nil
  defp version_change(old, new), do: {old, new}

  defp format_change({old, new}), do: "#{old} → #{new}"

  defp format_section(parts, label, diff) do
    if empty_diff?(diff), do: parts, else: ["#{label} changed" | parts]
  end

  defp diff_top_level(old, new) do
    skip = MapSet.new(@dep_fields ++ ~w(name version scripts))
    old_keys = old |> Map.keys() |> Enum.reject(&MapSet.member?(skip, &1)) |> MapSet.new()
    new_keys = new |> Map.keys() |> Enum.reject(&MapSet.member?(skip, &1)) |> MapSet.new()

    %{
      added: MapSet.difference(new_keys, old_keys) |> MapSet.to_list() |> Enum.sort(),
      removed: MapSet.difference(old_keys, new_keys) |> MapSet.to_list() |> Enum.sort()
    }
  end
end
