defmodule NPM.Packager do
  @moduledoc """
  Create tarballs for npm publishing.

  Reads `package.json` to determine which files to include,
  respecting the `files` field and `.npmignore`.
  """

  @always_include ["package.json", "README.md", "README", "LICENSE", "LICENCE", "CHANGELOG.md"]
  @always_exclude [".git", "node_modules", ".npmrc", "npm.lock"]

  @doc """
  List files that would be included in a publish tarball.
  """
  @spec files_to_pack(String.t()) :: [String.t()]
  def files_to_pack(dir \\ ".") do
    case read_files_field(dir) do
      nil -> all_files(dir)
      patterns -> expand_patterns(dir, patterns)
    end
    |> Enum.concat(always_included(dir))
    |> Enum.reject(&excluded?/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Calculate the total size of files to pack in bytes.
  """
  @spec pack_size(String.t()) :: non_neg_integer()
  def pack_size(dir \\ ".") do
    files_to_pack(dir)
    |> Enum.reduce(0, fn file, acc ->
      path = Path.join(dir, file)

      case File.stat(path) do
        {:ok, %{size: size}} -> acc + size
        _ -> acc
      end
    end)
  end

  @doc """
  Count of files to pack.
  """
  @spec pack_file_count(String.t()) :: non_neg_integer()
  def pack_file_count(dir \\ "."), do: length(files_to_pack(dir))

  defp read_files_field(dir) do
    path = Path.join(dir, "package.json")

    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        Map.get(data, "files")

      {:error, _} ->
        nil
    end
  end

  defp expand_patterns(dir, patterns) do
    Enum.flat_map(patterns, fn pattern ->
      dir
      |> Path.join(pattern)
      |> Path.wildcard()
      |> Enum.map(&Path.relative_to(&1, dir))
      |> Enum.filter(&File.regular?(Path.join(dir, &1)))
    end)
  end

  defp all_files(dir) do
    dir
    |> Path.join("**/*")
    |> Path.wildcard()
    |> Enum.map(&Path.relative_to(&1, dir))
    |> Enum.filter(&File.regular?(Path.join(dir, &1)))
  end

  defp always_included(dir) do
    @always_include
    |> Enum.filter(&File.exists?(Path.join(dir, &1)))
  end

  defp excluded?(path) do
    Enum.any?(@always_exclude, fn excl ->
      String.starts_with?(path, excl)
    end)
  end
end
