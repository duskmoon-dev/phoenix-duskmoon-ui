defmodule NPM.Diff do
  @moduledoc """
  Compares two versions of a package to show what changed.

  Provides file-level diffs between package versions, useful for
  reviewing what changed before updating.
  """

  @type file_change :: %{
          path: String.t(),
          type: :added | :removed | :modified
        }

  @type version_diff :: %{
          name: String.t(),
          from: String.t(),
          to: String.t(),
          files: [file_change()]
        }

  @doc """
  Compares file lists between two extracted package directories.

  Takes two maps of `%{path => content_hash}` and returns the changes.
  """
  @spec compare_files(map(), map()) :: [file_change()]
  def compare_files(old_files, new_files) do
    old_keys = MapSet.new(Map.keys(old_files))
    new_keys = MapSet.new(Map.keys(new_files))

    added =
      MapSet.difference(new_keys, old_keys)
      |> Enum.map(&%{path: &1, type: :added})

    removed =
      MapSet.difference(old_keys, new_keys)
      |> Enum.map(&%{path: &1, type: :removed})

    modified =
      MapSet.intersection(old_keys, new_keys)
      |> Enum.filter(fn path -> old_files[path] != new_files[path] end)
      |> Enum.map(&%{path: &1, type: :modified})

    (added ++ removed ++ modified)
    |> Enum.sort_by(& &1.path)
  end

  @doc """
  Creates a file hash map from a directory.

  Walks the directory and creates a map of relative paths to content hashes.
  """
  @spec file_hashes(String.t()) :: map()
  def file_hashes(dir) do
    dir
    |> list_files_recursive()
    |> Map.new(fn path ->
      rel = Path.relative_to(path, dir)
      hash = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
      {rel, hash}
    end)
  end

  @doc """
  Summarizes changes between two versions.
  """
  @spec summary([file_change()]) :: %{
          added: non_neg_integer(),
          removed: non_neg_integer(),
          modified: non_neg_integer(),
          total: non_neg_integer()
        }
  def summary(changes) do
    %{
      added: Enum.count(changes, &(&1.type == :added)),
      removed: Enum.count(changes, &(&1.type == :removed)),
      modified: Enum.count(changes, &(&1.type == :modified)),
      total: length(changes)
    }
  end

  @doc """
  Formats a change list as a human-readable string.
  """
  @spec format_changes([file_change()]) :: String.t()
  def format_changes([]), do: "No changes."

  def format_changes(changes) do
    Enum.map_join(changes, "\n", fn change ->
      prefix =
        case change.type do
          :added -> "+"
          :removed -> "-"
          :modified -> "~"
        end

      "#{prefix} #{change.path}"
    end)
  end

  defp list_files_recursive(dir) do
    case File.ls(dir) do
      {:ok, entries} -> Enum.flat_map(entries, &expand_entry(dir, &1))
      _ -> []
    end
  end

  defp expand_entry(dir, entry) do
    path = Path.join(dir, entry)
    if File.dir?(path), do: list_files_recursive(path), else: [path]
  end
end
