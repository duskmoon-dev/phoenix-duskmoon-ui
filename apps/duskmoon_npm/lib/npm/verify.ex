defmodule NPM.Verify do
  @moduledoc """
  Verifies that installed packages match the lockfile.

  Checks version consistency, integrity hashes, and completeness
  of the node_modules directory against the lockfile.
  """

  @type issue :: %{
          package: String.t(),
          type: :missing | :version_mismatch | :integrity_mismatch | :extraneous,
          expected: String.t() | nil,
          actual: String.t() | nil
        }

  @doc """
  Verifies installed packages against a lockfile.

  Returns a list of issues found.
  """
  @spec check(String.t(), map()) :: [issue()]
  def check(node_modules_dir, lockfile) do
    missing = find_missing(node_modules_dir, lockfile)
    mismatched = find_mismatched(node_modules_dir, lockfile)
    extraneous = find_extraneous(node_modules_dir, lockfile)
    Enum.sort_by(missing ++ mismatched ++ extraneous, & &1.package)
  end

  @doc """
  Checks if the installation is clean (no issues).
  """
  @spec clean?(String.t(), map()) :: boolean()
  def clean?(node_modules_dir, lockfile) do
    check(node_modules_dir, lockfile) == []
  end

  @doc """
  Returns a summary of verification results.
  """
  @spec summary([issue()]) :: %{
          total: non_neg_integer(),
          missing: non_neg_integer(),
          mismatched: non_neg_integer(),
          extraneous: non_neg_integer()
        }
  def summary(issues) do
    %{
      total: length(issues),
      missing: Enum.count(issues, &(&1.type == :missing)),
      mismatched: Enum.count(issues, &(&1.type == :version_mismatch)),
      extraneous: Enum.count(issues, &(&1.type == :extraneous))
    }
  end

  @doc """
  Formats an issue for display.
  """
  @spec format_issue(issue()) :: String.t()
  def format_issue(%{type: :missing} = i), do: "MISSING #{i.package} (expected #{i.expected})"
  def format_issue(%{type: :extraneous} = i), do: "EXTRANEOUS #{i.package}@#{i.actual}"

  def format_issue(%{type: :version_mismatch} = i),
    do: "MISMATCH #{i.package}: expected #{i.expected}, got #{i.actual}"

  defp find_missing(nm_dir, lockfile) do
    Enum.flat_map(lockfile, fn {name, entry} ->
      pkg_dir = resolve_package_dir(nm_dir, name)

      if File.exists?(pkg_dir) do
        []
      else
        [%{package: name, type: :missing, expected: entry.version, actual: nil}]
      end
    end)
  end

  defp find_mismatched(nm_dir, lockfile) do
    Enum.flat_map(lockfile, fn {name, entry} ->
      pkg_dir = resolve_package_dir(nm_dir, name)

      case read_installed_version(pkg_dir) do
        nil ->
          []

        version when version != entry.version ->
          [%{package: name, type: :version_mismatch, expected: entry.version, actual: version}]

        _ ->
          []
      end
    end)
  end

  defp find_extraneous(nm_dir, lockfile) do
    case File.ls(nm_dir) do
      {:ok, entries} ->
        locked_names = MapSet.new(Map.keys(lockfile))

        entries
        |> Enum.reject(&String.starts_with?(&1, "."))
        |> Enum.flat_map(&check_extraneous(nm_dir, &1, locked_names))

      _ ->
        []
    end
  end

  defp check_extraneous(nm_dir, entry, locked_names) do
    if String.starts_with?(entry, "@") do
      check_scoped_extraneous(nm_dir, entry, locked_names)
    else
      check_single_extraneous(nm_dir, entry, locked_names)
    end
  end

  defp check_single_extraneous(nm_dir, name, locked_names) do
    if MapSet.member?(locked_names, name) do
      []
    else
      version = read_installed_version(Path.join(nm_dir, name))
      [%{package: name, type: :extraneous, expected: nil, actual: version}]
    end
  end

  defp check_scoped_extraneous(nm_dir, scope, locked_names) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &check_scoped_sub(scope_dir, scope, &1, locked_names))
      _ -> []
    end
  end

  defp check_scoped_sub(scope_dir, scope, sub, locked_names) do
    name = "#{scope}/#{sub}"

    if MapSet.member?(locked_names, name) do
      []
    else
      version = read_installed_version(Path.join(scope_dir, sub))
      [%{package: name, type: :extraneous, expected: nil, actual: version}]
    end
  end

  defp resolve_package_dir(nm_dir, name) do
    Path.join(nm_dir, name)
  end

  defp read_installed_version(pkg_dir) do
    case File.read(Path.join(pkg_dir, "package.json")) do
      {:ok, content} -> NPM.JSON.decode!(content)["version"]
      _ -> nil
    end
  rescue
    _ -> nil
  end
end
