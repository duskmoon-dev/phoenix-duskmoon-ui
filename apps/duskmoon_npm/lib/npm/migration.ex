defmodule NPM.Migration do
  @moduledoc """
  Provides migration guidance between npm and lockfile versions.
  """

  @doc """
  Determines required lockfile version for an npm version.
  """
  @spec lockfile_version(String.t()) :: non_neg_integer()
  def lockfile_version(npm_version) do
    case major_version(npm_version) do
      n when n >= 9 -> 3
      n when n >= 7 -> 2
      _ -> 1
    end
  end

  @doc """
  Checks if a lockfile migration is needed.
  """
  @spec needs_migration?(non_neg_integer(), String.t()) :: boolean()
  def needs_migration?(current_lockfile_version, target_npm_version) do
    lockfile_version(target_npm_version) != current_lockfile_version
  end

  @doc """
  Returns breaking changes between npm major versions.
  """
  @spec breaking_changes(non_neg_integer(), non_neg_integer()) :: [String.t()]
  def breaking_changes(from, to) when from < to do
    from..to
    |> Enum.flat_map(&changes_for_version/1)
  end

  def breaking_changes(_, _), do: []

  @doc """
  Returns migration steps.
  """
  @spec steps(non_neg_integer(), non_neg_integer()) :: [String.t()]
  def steps(from_lockfile, to_lockfile) when from_lockfile < to_lockfile do
    base = ["Delete node_modules/", "Delete package-lock.json", "Run npm install"]

    if to_lockfile >= 3 do
      base ++ ["Verify package-lock.json uses lockfileVersion #{to_lockfile}"]
    else
      base
    end
  end

  def steps(from, to) when from == to, do: ["No migration needed."]
  def steps(_, _), do: ["Downgrade not recommended."]

  @doc """
  Formats migration guide.
  """
  @spec format_guide(non_neg_integer(), non_neg_integer()) :: String.t()
  def format_guide(from, to) do
    step_list =
      steps(from, to) |> Enum.with_index(1) |> Enum.map_join("\n", fn {s, i} -> "#{i}. #{s}" end)

    "Migration from lockfileVersion #{from} to #{to}:\n#{step_list}"
  end

  defp major_version(version) do
    case String.split(version, ".", parts: 2) do
      [major | _] -> String.to_integer(major)
      _ -> 0
    end
  end

  defp changes_for_version(7) do
    ["package-lock.json v2 format", "Automatic peer dependency installation"]
  end

  defp changes_for_version(9) do
    ["package-lock.json v3 format", "Dropped support for Node.js 14"]
  end

  defp changes_for_version(10) do
    ["package-lock.json v3 format", "Dropped support for Node.js 16"]
  end

  defp changes_for_version(_), do: []
end
