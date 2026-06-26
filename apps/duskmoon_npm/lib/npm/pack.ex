defmodule NPM.Pack do
  @moduledoc """
  Creates npm-compatible tarballs from local projects.

  Implements the `npm pack` functionality — reads `files` from package.json,
  applies default exclusions, and generates a publishable tarball.
  """

  @always_include ~w(package.json README.md README LICENSE LICENCE CHANGELOG)
  @always_exclude ~w(.git .svn .hg node_modules .npm .DS_Store)

  @doc """
  Lists files that would be included in the tarball.
  """
  @spec list_files(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def list_files(project_dir) do
    pkg_path = Path.join(project_dir, "package.json")

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        files = resolve_files(data, project_dir)
        {:ok, Enum.sort(files)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Generates the tarball filename from package.json data.
  """
  @spec tarball_name(map()) :: String.t()
  def tarball_name(%{"name" => name, "version" => version}) do
    safe_name = String.replace(name, "/", "-") |> String.trim_leading("@")
    "#{safe_name}-#{version}.tgz"
  end

  def tarball_name(%{"name" => name}), do: String.replace(name, "/", "-") <> "-0.0.0.tgz"

  @doc """
  Checks if a file should be excluded from the tarball.
  """
  @spec excluded?(String.t()) :: boolean()
  def excluded?(path) do
    basename = Path.basename(path)
    dirname = path |> Path.split() |> hd()

    basename in @always_exclude or dirname in @always_exclude or
      String.starts_with?(basename, ".")
  end

  @doc """
  Checks if a file should always be included regardless of `files` field.
  """
  @spec always_included?(String.t()) :: boolean()
  def always_included?(path) do
    basename = Path.basename(path)
    name_no_ext = Path.rootname(basename)
    name_upper = String.upcase(name_no_ext)

    Enum.any?(@always_include, fn pattern ->
      String.upcase(pattern) == name_upper or String.upcase(basename) == String.upcase(pattern)
    end)
  end

  @doc """
  Returns the default files list when no `files` field is specified.
  """
  @spec default_files(String.t()) :: [String.t()]
  def default_files(project_dir) do
    case File.ls(project_dir) do
      {:ok, entries} ->
        entries
        |> Enum.reject(&excluded?/1)
        |> Enum.flat_map(&expand_if_dir(project_dir, &1))
        |> Enum.sort()

      _ ->
        []
    end
  end

  defp resolve_files(%{"files" => patterns} = data, project_dir) when is_list(patterns) do
    explicit =
      patterns
      |> Enum.flat_map(&match_pattern(project_dir, &1))
      |> Enum.reject(&excluded?/1)

    always =
      case File.ls(project_dir) do
        {:ok, entries} -> Enum.filter(entries, &always_included?/1)
        _ -> []
      end

    main_file = main_entry(data)
    main_files = if main_file, do: [main_file], else: []

    (always ++ main_files ++ explicit)
    |> Enum.uniq()
    |> Enum.filter(&File.exists?(Path.join(project_dir, &1)))
  end

  defp resolve_files(_data, project_dir), do: default_files(project_dir)

  defp main_entry(%{"main" => main}) when is_binary(main), do: main
  defp main_entry(_), do: nil

  defp match_pattern(base, pattern) do
    full = Path.join(base, pattern)

    if File.dir?(full) do
      expand_if_dir(base, pattern)
    else
      case Path.wildcard(full) do
        [] -> []
        matches -> Enum.map(matches, &Path.relative_to(&1, base))
      end
    end
  end

  defp expand_if_dir(base, entry) do
    full = Path.join(base, entry)

    if File.dir?(full) do
      walk_files(full)
      |> Enum.map(&Path.relative_to(&1, base))
    else
      [entry]
    end
  end

  defp walk_files(dir) do
    case File.ls(dir) do
      {:ok, entries} -> Enum.flat_map(entries, &expand_path(dir, &1))
      _ -> []
    end
  end

  defp expand_path(dir, entry) do
    path = Path.join(dir, entry)
    if File.dir?(path), do: walk_files(path), else: [path]
  end
end
