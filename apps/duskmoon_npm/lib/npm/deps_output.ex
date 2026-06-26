defmodule NPM.DepsOutput do
  @moduledoc """
  Formats installed npm packages for display, similar to `mix deps`.
  """

  @doc """
  Formats a lockfile as a `mix deps`-style listing.

  Each entry shows: `* name version (npm registry)`
  with locked version and status on the next line.
  """
  @spec format_lockfile(map()) :: String.t()
  def format_lockfile(lockfile) when map_size(lockfile) == 0, do: "No npm dependencies installed."

  def format_lockfile(lockfile) do
    lockfile
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", &format_entry/1)
  end

  @doc """
  Formats a lockfile diff (added, removed, updated packages).
  """
  @spec format_diff(map(), map()) :: String.t()
  def format_diff(old, new) do
    old_keys = Map.keys(old) |> MapSet.new()
    new_keys = Map.keys(new) |> MapSet.new()

    added = MapSet.difference(new_keys, old_keys) |> MapSet.to_list() |> Enum.sort()
    removed = MapSet.difference(old_keys, new_keys) |> MapSet.to_list() |> Enum.sort()

    updated =
      MapSet.intersection(old_keys, new_keys)
      |> Enum.filter(fn k -> old[k].version != new[k].version end)
      |> Enum.sort()

    lines =
      Enum.map(added, fn n -> "  + #{n} #{new[n].version}" end) ++
        Enum.map(updated, fn n -> "  ↑ #{n} #{old[n].version} → #{new[n].version}" end) ++
        Enum.map(removed, fn n -> "  - #{n} #{old[n].version}" end)

    case lines do
      [] -> ""
      _ -> Enum.join(lines, "\n")
    end
  end

  @doc """
  Formats install summary with timing.
  """
  @spec format_summary(non_neg_integer(), non_neg_integer()) :: String.t()
  def format_summary(count, ms) do
    pkg = if count == 1, do: "package", else: "packages"
    "Installed #{count} #{pkg} in #{ms}ms"
  end

  @doc """
  Prints the lockfile listing to the Mix shell.
  """
  @spec print(map()) :: :ok
  def print(lockfile) do
    Mix.shell().info(format_lockfile(lockfile))
  end

  defp format_entry({name, entry}) do
    integrity = format_integrity(Map.get(entry, :integrity, ""))
    "* #{name} #{entry.version} (npm registry)\n  locked at #{entry.version} #{integrity}\n  ok"
  end

  defp format_integrity(""), do: ""
  defp format_integrity(hash) when byte_size(hash) > 16, do: String.slice(hash, 0, 8)
  defp format_integrity(hash), do: hash
end
