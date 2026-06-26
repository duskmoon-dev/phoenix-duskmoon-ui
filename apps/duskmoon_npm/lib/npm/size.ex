defmodule NPM.Size do
  @moduledoc """
  Estimates install size and disk usage per package.

  Analyzes node_modules to report per-package and total sizes,
  helping identify heavy dependencies.
  """

  @type size_entry :: %{
          name: String.t(),
          version: String.t() | nil,
          size: non_neg_integer(),
          file_count: non_neg_integer()
        }

  @doc """
  Analyzes a node_modules directory and returns size info per package.
  """
  @spec analyze(String.t()) :: [size_entry()]
  def analyze(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&analyze_entry(node_modules_dir, &1))
        |> Enum.sort_by(& &1.size, :desc)

      _ ->
        []
    end
  end

  @doc """
  Returns the top N largest packages.
  """
  @spec top(String.t(), non_neg_integer()) :: [size_entry()]
  def top(node_modules_dir, n \\ 10) do
    node_modules_dir |> analyze() |> Enum.take(n)
  end

  @doc """
  Calculates total install size across all packages.
  """
  @spec total_size([size_entry()]) :: non_neg_integer()
  def total_size(entries), do: Enum.reduce(entries, 0, &(&1.size + &2))

  @doc """
  Calculates total file count.
  """
  @spec total_files([size_entry()]) :: non_neg_integer()
  def total_files(entries), do: Enum.reduce(entries, 0, &(&1.file_count + &2))

  @doc """
  Formats a size in bytes as a human-readable string.
  """
  @spec format_size(non_neg_integer()) :: String.t()
  defdelegate format_size(bytes), to: NPM.FormatUtil

  @doc """
  Returns a summary of the node_modules analysis.
  """
  @spec summary([size_entry()]) :: %{
          package_count: non_neg_integer(),
          total_size: non_neg_integer(),
          total_files: non_neg_integer(),
          formatted_size: String.t()
        }
  def summary(entries) do
    ts = total_size(entries)

    %{
      package_count: length(entries),
      total_size: ts,
      total_files: total_files(entries),
      formatted_size: format_size(ts)
    }
  end

  defp analyze_entry(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      analyze_scope(nm_dir, entry)
    else
      analyze_package(nm_dir, entry)
    end
  end

  defp analyze_scope(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &analyze_package(scope_dir, &1, scope))
      _ -> []
    end
  end

  defp analyze_package(parent, name, scope \\ nil) do
    dir = Path.join(parent, name)
    pkg_name = if scope, do: "#{scope}/#{name}", else: name

    if File.dir?(dir) do
      {size, count} = walk_dir(dir)
      version = read_version(dir)
      [%{name: pkg_name, version: version, size: size, file_count: count}]
    else
      []
    end
  end

  defp walk_dir(dir) do
    case File.ls(dir) do
      {:ok, entries} -> Enum.reduce(entries, {0, 0}, &acc_entry(dir, &1, &2))
      _ -> {0, 0}
    end
  end

  defp acc_entry(dir, entry, {size_acc, count_acc}) do
    path = Path.join(dir, entry)

    if File.dir?(path) do
      {s, c} = walk_dir(path)
      {size_acc + s, count_acc + c}
    else
      {size_acc + file_size(path), count_acc + 1}
    end
  end

  defp file_size(path) do
    case File.stat(path) do
      {:ok, %{size: s}} -> s
      _ -> 0
    end
  end

  defp read_version(dir) do
    case File.read(Path.join(dir, "package.json")) do
      {:ok, content} -> NPM.JSON.decode!(content)["version"]
      _ -> nil
    end
  rescue
    _ -> nil
  end
end
