defmodule NPM.Gitignore do
  @moduledoc """
  Manages .gitignore entries for npm projects.
  """

  @essential_patterns ["node_modules/", ".npm/"]
  @recommended_patterns ["node_modules/", ".npm/", "*.tgz", ".env", ".env.local"]

  @doc """
  Returns essential gitignore patterns for npm projects.
  """
  @spec essential :: [String.t()]
  def essential, do: @essential_patterns

  @doc """
  Returns recommended gitignore patterns.
  """
  @spec recommended :: [String.t()]
  def recommended, do: @recommended_patterns

  @doc """
  Checks if a .gitignore file covers node_modules.
  """
  @spec covers_node_modules?(String.t()) :: boolean()
  def covers_node_modules?(content) do
    content
    |> String.split("\n")
    |> Enum.any?(fn line ->
      trimmed = String.trim(line)
      trimmed == "node_modules" or trimmed == "node_modules/"
    end)
  end

  @doc """
  Returns missing essential patterns from a .gitignore file.
  """
  @spec missing(String.t()) :: [String.t()]
  def missing(content) do
    lines = content |> String.split("\n") |> Enum.map(&String.trim/1) |> MapSet.new()

    Enum.reject(@essential_patterns, fn pattern ->
      bare = String.trim_trailing(pattern, "/")
      MapSet.member?(lines, pattern) or MapSet.member?(lines, bare)
    end)
  end

  @doc """
  Generates a .gitignore content for an npm project.
  """
  @spec generate(keyword()) :: String.t()
  def generate(opts \\ []) do
    patterns =
      if Keyword.get(opts, :recommended, true),
        do: @recommended_patterns,
        else: @essential_patterns

    extra = Keyword.get(opts, :extra, [])
    (patterns ++ extra) |> Enum.join("\n")
  end

  @doc """
  Checks a .gitignore file on disk.
  """
  @spec check(String.t()) :: {:ok, [String.t()]} | {:error, :not_found}
  def check(project_dir) do
    path = Path.join(project_dir, ".gitignore")

    case File.read(path) do
      {:ok, content} -> {:ok, missing(content)}
      _ -> {:error, :not_found}
    end
  end
end
