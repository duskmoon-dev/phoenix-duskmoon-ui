defmodule NPM.Package.JSON do
  @moduledoc """
  Read and write `package.json` files.
  """

  @default_path "package.json"

  @doc "Read dependencies from `package.json`."
  @spec read(String.t()) :: {:ok, %{String.t() => String.t()}} | {:error, term()}
  def read(path \\ @default_path) do
    read_field(path, "dependencies")
  end

  @doc "Read all dependency groups from `package.json`."
  @spec read_all(String.t()) ::
          {:ok, %{dependencies: map(), dev_dependencies: map(), optional_dependencies: map()}}
          | {:error, term()}
  def read_all(path \\ @default_path) do
    case read_raw(path) do
      {:ok, data} ->
        {:ok,
         %{
           dependencies: Map.get(data, "dependencies", %{}),
           dev_dependencies: Map.get(data, "devDependencies", %{}),
           optional_dependencies: Map.get(data, "optionalDependencies", %{})
         }}

      {:error, :enoent} ->
        {:ok, %{dependencies: %{}, dev_dependencies: %{}, optional_dependencies: %{}}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Read scripts from `package.json`."
  @spec read_scripts(String.t()) :: {:ok, %{String.t() => String.t()}} | {:error, term()}
  def read_scripts(path \\ @default_path) do
    read_field(path, "scripts")
  end

  @doc "Read workspace patterns from `package.json`."
  @spec read_workspaces(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def read_workspaces(path \\ @default_path) do
    case read_raw(path) do
      {:ok, data} ->
        case Map.get(data, "workspaces") do
          nil -> {:ok, []}
          patterns when is_list(patterns) -> {:ok, patterns}
          %{"packages" => patterns} when is_list(patterns) -> {:ok, patterns}
          _ -> {:ok, []}
        end

      {:error, :enoent} ->
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Expand workspace patterns to actual directories with package.json files.

  Supports glob patterns like `packages/*` and `apps/**`.
  """
  @spec expand_workspaces([String.t()], String.t()) :: [String.t()]
  def expand_workspaces(patterns, base_dir \\ ".") do
    Enum.flat_map(patterns, fn pattern ->
      Path.join(base_dir, pattern)
      |> Path.wildcard()
      |> Enum.filter(&File.exists?(Path.join(&1, "package.json")))
    end)
  end

  @doc """
  Check if a dependency range refers to a local file path.

  Supports `file:../path` and `file:./path` references.
  """
  @spec file_dep?(String.t()) :: boolean()
  def file_dep?("file:" <> _), do: true
  def file_dep?(_), do: false

  @doc """
  Resolve a file dependency path.

  Returns the absolute path for a `file:` reference.
  """
  @spec resolve_file_dep(String.t(), String.t()) :: String.t()
  def resolve_file_dep("file:" <> path, base_dir) do
    Path.expand(path, base_dir)
  end

  @doc """
  Check if a dependency range refers to a git repository.

  Supports `git+https://`, `git+ssh://`, `github:user/repo`, and `git://` URLs.
  """
  @spec git_dep?(String.t()) :: boolean()
  def git_dep?("git+" <> _), do: true
  def git_dep?("git://" <> _), do: true
  def git_dep?("github:" <> _), do: true
  def git_dep?(range), do: String.contains?(range, ".git")

  @doc """
  Check if a dependency range refers to a URL tarball.

  Supports `http://` and `https://` URLs ending in `.tgz` or `.tar.gz`.
  """
  @spec url_dep?(String.t()) :: boolean()
  def url_dep?("http://" <> _ = url), do: tarball_url?(url)
  def url_dep?("https://" <> _ = url), do: tarball_url?(url)
  def url_dep?(_), do: false

  defp tarball_url?(url) do
    String.ends_with?(url, ".tgz") or String.ends_with?(url, ".tar.gz")
  end

  @doc "Read overrides from `package.json`."
  @spec read_overrides(String.t()) :: {:ok, %{String.t() => String.t()}} | {:error, term()}
  def read_overrides(path \\ @default_path) do
    read_field(path, "overrides")
  end

  @doc "Read resolutions (Yarn-style) from `package.json`."
  @spec read_resolutions(String.t()) :: {:ok, %{String.t() => String.t()}} | {:error, term()}
  def read_resolutions(path \\ @default_path) do
    read_field(path, "resolutions")
  end

  @doc """
  Read bundleDependencies (or bundledDependencies) from `package.json`.

  Returns a list of package names that should be bundled in the tarball.
  """
  @spec read_bundle_deps(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def read_bundle_deps(path \\ @default_path) do
    case read_raw(path) do
      {:ok, data} ->
        bundle =
          Map.get(data, "bundleDependencies") ||
            Map.get(data, "bundledDependencies", [])

        case bundle do
          true -> {:ok, Map.keys(Map.get(data, "dependencies", %{}))}
          deps when is_list(deps) -> {:ok, deps}
          _ -> {:ok, []}
        end

      {:error, :enoent} ->
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp read_field(path, field) do
    case read_raw(path) do
      {:ok, data} -> {:ok, Map.get(data, field, %{})}
      {:error, :enoent} -> {:ok, %{}}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Add a dependency to `package.json`, creating the file if needed.

  ## Options

    * `:dev` - when `true`, adds to `devDependencies` instead of `dependencies`
  """
  @spec add_dep(String.t(), String.t(), String.t(), keyword()) :: :ok | {:error, term()}
  def add_dep(name, range, path \\ @default_path, opts \\ []) do
    data = read_raw!(path)

    field =
      cond do
        opts[:dev] -> "devDependencies"
        opts[:optional] -> "optionalDependencies"
        true -> "dependencies"
      end

    deps = Map.get(data, field, %{})
    updated = Map.put(data, field, Map.put(deps, name, range))

    File.write(path, NPM.JSON.encode_pretty(updated))
  end

  @doc "Remove a dependency from `package.json`."
  @spec remove_dep(String.t(), String.t()) :: :ok | {:error, term()}
  def remove_dep(name, path \\ @default_path) do
    data = read_raw!(path)

    field =
      ["dependencies", "devDependencies", "optionalDependencies"]
      |> Enum.find(fn field ->
        data |> Map.get(field, %{}) |> Map.has_key?(name)
      end)

    if field do
      deps = Map.get(data, field, %{})
      updated = Map.put(data, field, Map.delete(deps, name))
      File.write(path, NPM.JSON.encode_pretty(updated))
    else
      {:error, {:not_found, name}}
    end
  end

  defp read_raw(path), do: NPM.JSON.read_file(path)

  defp read_raw!(path) do
    case read_raw(path) do
      {:ok, data} -> data
      {:error, :enoent} -> %{}
      {:error, reason} -> raise reason
    end
  end
end
