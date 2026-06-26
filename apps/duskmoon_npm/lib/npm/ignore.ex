defmodule NPM.Ignore do
  @moduledoc """
  Parses .npmignore and .gitignore files for package publishing.

  Determines which files to include/exclude when packing or publishing
  a package, following npm's ignore rules.
  """

  @always_ignored ~w(.git .svn CVS .hg .DS_Store node_modules .npmrc)
  @never_ignored ~w(package.json README.md LICENSE LICENCE CHANGELOG.md)

  @doc """
  Reads and parses an ignore file.
  """
  @spec read(String.t()) :: [String.t()]
  def read(path) do
    case File.read(path) do
      {:ok, content} -> parse(content)
      _ -> []
    end
  end

  @doc """
  Parses ignore file content into a list of patterns.
  """
  @spec parse(String.t()) :: [String.t()]
  def parse(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&comment_or_blank?(&1))
    |> Enum.uniq()
  end

  @doc """
  Checks if a file path is ignored by the given patterns.
  """
  @spec ignored?(String.t(), [String.t()]) :: boolean()
  def ignored?(path, patterns) do
    basename = Path.basename(path)

    cond do
      always_ignored?(basename) -> true
      never_ignored?(basename) -> false
      true -> Enum.any?(patterns, &pattern_matches?(path, &1))
    end
  end

  @doc """
  Returns the list of always-ignored paths.
  """
  @spec always_ignored :: [String.t()]
  def always_ignored, do: @always_ignored

  @doc """
  Returns the list of never-ignored paths.
  """
  @spec never_ignored :: [String.t()]
  def never_ignored, do: @never_ignored

  @doc """
  Gets the effective ignore patterns for a package directory.

  Checks .npmignore first, falls back to .gitignore.
  """
  @spec effective_patterns(String.t()) :: [String.t()]
  def effective_patterns(package_dir) do
    npmignore = Path.join(package_dir, ".npmignore")
    gitignore = Path.join(package_dir, ".gitignore")

    case read(npmignore) do
      [] -> read(gitignore)
      patterns -> patterns
    end
  end

  defp always_ignored?(name), do: name in @always_ignored

  defp never_ignored?(name) do
    downcased = String.downcase(name)
    Enum.any?(@never_ignored, &(String.downcase(&1) == downcased))
  end

  defp comment_or_blank?(line) do
    line == "" or String.starts_with?(line, "#")
  end

  defp pattern_matches?(path, pattern) do
    cond do
      String.ends_with?(pattern, "/") ->
        dir_pattern = String.trim_trailing(pattern, "/")
        String.starts_with?(path, dir_pattern <> "/") or path == dir_pattern

      String.contains?(pattern, "/") ->
        path == pattern or String.starts_with?(path, pattern <> "/")

      true ->
        Path.basename(path) == pattern or
          path == pattern or
          String.ends_with?(path, "/" <> pattern)
    end
  end
end
