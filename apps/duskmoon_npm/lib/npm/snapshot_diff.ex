defmodule NPM.SnapshotDiff do
  @moduledoc """
  Compares two lockfile snapshots to determine what changed.
  """

  @doc """
  Computes the diff between two lockfiles.
  """
  @spec diff(map(), map()) :: map()
  def diff(old, new) do
    old_keys = Map.keys(old) |> MapSet.new()
    new_keys = Map.keys(new) |> MapSet.new()

    added = MapSet.difference(new_keys, old_keys) |> MapSet.to_list() |> Enum.sort()
    removed = MapSet.difference(old_keys, new_keys) |> MapSet.to_list() |> Enum.sort()

    updated =
      MapSet.intersection(old_keys, new_keys)
      |> Enum.filter(fn name ->
        version(old[name]) != version(new[name])
      end)
      |> Enum.map(fn name ->
        %{name: name, from: version(old[name]), to: version(new[name])}
      end)
      |> Enum.sort_by(& &1.name)

    %{added: added, removed: removed, updated: updated, unchanged: unchanged_count(old, new)}
  end

  @doc """
  Checks if two lockfiles are identical.
  """
  @spec identical?(map(), map()) :: boolean()
  def identical?(old, new) do
    d = diff(old, new)
    d.added == [] and d.removed == [] and d.updated == []
  end

  @doc """
  Returns a summary of changes.
  """
  @spec summary(map()) :: String.t()
  def summary(diff_result) do
    parts = []

    parts =
      if diff_result.added != [], do: ["#{length(diff_result.added)} added" | parts], else: parts

    parts =
      if diff_result.removed != [],
        do: ["#{length(diff_result.removed)} removed" | parts],
        else: parts

    parts =
      if diff_result.updated != [],
        do: ["#{length(diff_result.updated)} updated" | parts],
        else: parts

    case Enum.reverse(parts) do
      [] -> "No changes."
      list -> Enum.join(list, ", ")
    end
  end

  @doc """
  Formats a detailed diff for display.
  """
  @spec format(map()) :: String.t()
  def format(diff_result) do
    lines = []

    lines =
      diff_result.added
      |> Enum.reduce(lines, fn name, acc -> ["+ #{name}" | acc] end)

    lines =
      diff_result.removed
      |> Enum.reduce(lines, fn name, acc -> ["- #{name}" | acc] end)

    lines =
      diff_result.updated
      |> Enum.reduce(lines, fn %{name: n, from: f, to: t}, acc ->
        ["~ #{n}: #{f} → #{t}" | acc]
      end)

    case Enum.reverse(lines) do
      [] -> "No changes."
      list -> Enum.join(list, "\n")
    end
  end

  defp version(%{version: v}), do: v
  defp version(%{"version" => v}), do: v
  defp version(_), do: nil

  defp unchanged_count(old, new) do
    old_keys = Map.keys(old) |> MapSet.new()
    new_keys = Map.keys(new) |> MapSet.new()

    MapSet.intersection(old_keys, new_keys)
    |> Enum.count(fn name -> version(old[name]) == version(new[name]) end)
  end
end
