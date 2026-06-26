defmodule NPM.FileSize do
  @moduledoc """
  Analyzes file sizes within installed packages.

  Identifies large files, breaks down by extension, and helps
  optimize node_modules size.
  """

  @doc """
  Analyzes files in a package directory.
  """
  @spec analyze(String.t()) :: [%{path: String.t(), size: non_neg_integer()}]
  def analyze(package_dir) do
    case list_files(package_dir) do
      {:ok, files} ->
        Enum.map(files, fn file ->
          %{path: file, size: file_size(Path.join(package_dir, file))}
        end)
        |> Enum.sort_by(& &1.size, :desc)

      _ ->
        []
    end
  end

  @doc """
  Returns the N largest files in a package.
  """
  @spec largest(String.t(), non_neg_integer()) :: [%{path: String.t(), size: non_neg_integer()}]
  def largest(package_dir, n \\ 10) do
    analyze(package_dir) |> Enum.take(n)
  end

  @doc """
  Groups file sizes by extension.
  """
  @spec by_extension(String.t()) :: %{String.t() => non_neg_integer()}
  def by_extension(package_dir) do
    analyze(package_dir)
    |> Enum.group_by(fn %{path: path} ->
      case Path.extname(path) do
        "" -> "(none)"
        ext -> ext
      end
    end)
    |> Map.new(fn {ext, files} ->
      {ext, files |> Enum.map(& &1.size) |> Enum.sum()}
    end)
  end

  @doc """
  Returns total size of all files in a package.
  """
  @spec total(String.t()) :: non_neg_integer()
  def total(package_dir) do
    analyze(package_dir) |> Enum.map(& &1.size) |> Enum.sum()
  end

  @doc """
  Formats a byte size to human-readable string.
  """
  @spec format_size(non_neg_integer()) :: String.t()
  defdelegate format_size(bytes), to: NPM.FormatUtil

  defp list_files(dir) do
    if File.dir?(dir) do
      files =
        dir
        |> Path.join("**/*")
        |> Path.wildcard()
        |> Enum.filter(&File.regular?/1)
        |> Enum.map(&Path.relative_to(&1, dir))

      {:ok, files}
    else
      {:error, :not_dir}
    end
  end

  defp file_size(path) do
    case File.stat(path) do
      {:ok, %{size: size}} -> size
      _ -> 0
    end
  end
end
