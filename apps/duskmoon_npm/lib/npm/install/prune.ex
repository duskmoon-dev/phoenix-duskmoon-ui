defmodule NPM.Install.Prune do
  @moduledoc """
  Identifies and removes extraneous packages from node_modules.

  Compares the installed packages against the lockfile to find
  packages that are no longer needed.
  """

  @type prune_entry :: %{
          name: String.t(),
          version: String.t() | nil,
          path: String.t(),
          reason: :not_in_lockfile | :orphaned_scope
        }

  @doc """
  Finds extraneous packages in node_modules that aren't in the lockfile.
  """
  @spec find_extraneous(String.t(), map()) :: [prune_entry()]
  def find_extraneous(node_modules_dir, lockfile) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        locked_names = MapSet.new(Map.keys(lockfile))

        entries
        |> Enum.flat_map(&check_entry(node_modules_dir, &1, locked_names))
        |> Enum.sort_by(& &1.name)

      _ ->
        []
    end
  end

  @doc """
  Calculates the total disk size of extraneous packages.
  """
  @spec extraneous_size([prune_entry()]) :: non_neg_integer()
  def extraneous_size(entries) do
    Enum.reduce(entries, 0, fn entry, acc ->
      acc + dir_size(entry.path)
    end)
  end

  @doc """
  Performs a dry run, returning what would be removed.
  """
  @spec dry_run(String.t(), map()) :: %{
          to_remove: [prune_entry()],
          count: non_neg_integer()
        }
  def dry_run(node_modules_dir, lockfile) do
    entries = find_extraneous(node_modules_dir, lockfile)
    %{to_remove: entries, count: length(entries)}
  end

  @doc """
  Removes extraneous packages from node_modules.
  Returns the list of removed entries.
  """
  @spec prune!(String.t(), map()) :: [prune_entry()]
  def prune!(node_modules_dir, lockfile) do
    entries = find_extraneous(node_modules_dir, lockfile)

    Enum.each(entries, fn entry ->
      File.rm_rf!(entry.path)
    end)

    entries
  end

  defp check_entry(nm_dir, entry, locked_names) do
    if String.starts_with?(entry, "@") do
      check_scoped(nm_dir, entry, locked_names)
    else
      check_regular(nm_dir, entry, locked_names)
    end
  end

  defp check_regular(nm_dir, name, locked_names) do
    if MapSet.member?(locked_names, name) do
      []
    else
      path = Path.join(nm_dir, name)
      version = read_version(path)
      [%{name: name, version: version, path: path, reason: :not_in_lockfile}]
    end
  end

  defp check_scoped(nm_dir, scope, locked_names) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, sub_entries} ->
        Enum.flat_map(sub_entries, &check_scoped_sub(scope_dir, scope, &1, locked_names))

      _ ->
        []
    end
  end

  defp check_scoped_sub(scope_dir, scope, sub, locked_names) do
    name = "#{scope}/#{sub}"

    if MapSet.member?(locked_names, name) do
      []
    else
      path = Path.join(scope_dir, sub)
      version = read_version(path)
      [%{name: name, version: version, path: path, reason: :not_in_lockfile}]
    end
  end

  defp read_version(pkg_dir) do
    pkg_json = Path.join(pkg_dir, "package.json")

    case File.read(pkg_json) do
      {:ok, content} -> NPM.JSON.decode!(content)["version"]
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp dir_size(path) do
    if File.dir?(path) do
      path |> File.ls!() |> Enum.reduce(0, &(entry_size(path, &1) + &2))
    else
      file_size(path)
    end
  rescue
    _ -> 0
  end

  defp entry_size(parent, name) do
    full = Path.join(parent, name)
    if File.dir?(full), do: dir_size(full), else: file_size(full)
  end

  defp file_size(path) do
    case File.stat(path) do
      {:ok, %{size: size}} -> size
      _ -> 0
    end
  end
end
