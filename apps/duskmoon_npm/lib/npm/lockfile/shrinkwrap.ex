defmodule NPM.Lockfile.Shrinkwrap do
  @moduledoc """
  Implements npm shrinkwrap lockfile freezing.

  Creates a `npm-shrinkwrap.json` that locks the entire dependency tree,
  including transitive dependencies. Unlike `package-lock.json`, shrinkwrap
  files are published with the package.
  """

  @shrinkwrap_file "npm-shrinkwrap.json"
  @lockfile "package-lock.json"

  @doc """
  Creates a shrinkwrap file from the current lockfile.
  """
  @spec create(String.t()) :: :ok | {:error, term()}
  def create(project_dir \\ ".") do
    lock_path = Path.join(project_dir, @lockfile)
    shrink_path = Path.join(project_dir, @shrinkwrap_file)

    case File.read(lock_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        shrinkwrap = Map.put(data, "lockfileVersion", Map.get(data, "lockfileVersion", 3))
        File.write(shrink_path, :json.encode(shrinkwrap))

      {:error, reason} ->
        {:error, {:no_lockfile, reason}}
    end
  end

  @doc """
  Checks if a shrinkwrap file exists.
  """
  @spec exists?(String.t()) :: boolean()
  def exists?(project_dir \\ ".") do
    project_dir |> Path.join(@shrinkwrap_file) |> File.exists?()
  end

  @doc """
  Reads and parses the shrinkwrap file.
  """
  @spec read(String.t()) :: {:ok, map()} | {:error, term()}
  def read(project_dir \\ ".") do
    path = Path.join(project_dir, @shrinkwrap_file)

    case File.read(path) do
      {:ok, content} -> {:ok, NPM.JSON.decode!(content)}
      error -> error
    end
  end

  @doc """
  Verifies that installed packages match the shrinkwrap exactly.
  Returns a list of mismatches.
  """
  @spec verify(map(), map()) :: [mismatch()]
  def verify(shrinkwrap_deps, installed) do
    Enum.flat_map(shrinkwrap_deps, fn {name, expected_version} ->
      case Map.get(installed, name) do
        nil ->
          [%{name: name, expected: expected_version, actual: nil, type: :missing}]

        %{version: actual} when actual != expected_version ->
          [%{name: name, expected: expected_version, actual: actual, type: :version_mismatch}]

        _ ->
          []
      end
    end)
    |> Enum.sort_by(& &1.name)
  end

  @typep mismatch :: %{
           name: String.t(),
           expected: String.t(),
           actual: String.t() | nil,
           type: :missing | :version_mismatch
         }

  @doc """
  Checks if the shrinkwrap is outdated compared to the lockfile.
  """
  @spec outdated?(String.t()) :: boolean()
  def outdated?(project_dir \\ ".") do
    lock_path = Path.join(project_dir, @lockfile)
    shrink_path = Path.join(project_dir, @shrinkwrap_file)

    with {:ok, lock_content} <- File.read(lock_path),
         {:ok, shrink_content} <- File.read(shrink_path) do
      lock_data = NPM.JSON.decode!(lock_content)
      shrink_data = NPM.JSON.decode!(shrink_content)

      lock_packages = lock_data["packages"] || lock_data["dependencies"] || %{}
      shrink_packages = shrink_data["packages"] || shrink_data["dependencies"] || %{}

      lock_packages != shrink_packages
    else
      _ -> true
    end
  end

  @doc """
  Removes the shrinkwrap file.
  """
  @spec remove(String.t()) :: :ok | {:error, term()}
  def remove(project_dir \\ ".") do
    path = Path.join(project_dir, @shrinkwrap_file)

    case File.rm(path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      error -> error
    end
  end
end
