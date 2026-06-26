defmodule NPM.Lockfile.Merge do
  @moduledoc """
  Merge two lockfiles, preferring entries from the newer lockfile.

  Used for workspace scenarios where multiple `package.json` files
  produce separate lockfiles that need to be combined.
  """

  @doc """
  Merge two lockfiles. Entries in `newer` override entries in `base`.

  Returns the merged lockfile map.
  """
  @spec merge(NPM.Lockfile.t(), NPM.Lockfile.t()) :: NPM.Lockfile.t()
  def merge(base, newer) do
    Map.merge(base, newer)
  end

  @doc """
  Merge with a custom conflict resolver.

  The `resolver` function receives `(name, base_entry, newer_entry)`
  and returns the winning entry.
  """
  @spec merge(NPM.Lockfile.t(), NPM.Lockfile.t(), function()) :: NPM.Lockfile.t()
  def merge(base, newer, resolver) do
    Map.merge(base, newer, fn name, base_entry, newer_entry ->
      resolver.(name, base_entry, newer_entry)
    end)
  end

  @doc """
  Find packages that differ between two lockfiles.

  Returns `{added, removed, changed}` where:
  - `added` — packages in `newer` but not `base`
  - `removed` — packages in `base` but not `newer`
  - `changed` — packages in both with different versions
  """
  @spec diff(NPM.Lockfile.t(), NPM.Lockfile.t()) ::
          {[String.t()], [String.t()], [{String.t(), String.t(), String.t()}]}
  def diff(base, newer) do
    base_keys = MapSet.new(Map.keys(base))
    newer_keys = MapSet.new(Map.keys(newer))

    added = MapSet.difference(newer_keys, base_keys) |> MapSet.to_list() |> Enum.sort()
    removed = MapSet.difference(base_keys, newer_keys) |> MapSet.to_list() |> Enum.sort()

    changed =
      MapSet.intersection(base_keys, newer_keys)
      |> Enum.filter(fn name -> base[name].version != newer[name].version end)
      |> Enum.map(fn name -> {name, base[name].version, newer[name].version} end)
      |> Enum.sort()

    {added, removed, changed}
  end
end
