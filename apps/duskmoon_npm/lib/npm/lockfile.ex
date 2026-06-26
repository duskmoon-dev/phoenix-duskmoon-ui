defmodule NPM.Lockfile do
  @moduledoc """
  Read and write `npm.lock` lockfile.

  The lockfile records resolved versions, integrity hashes, and dependency
  relationships to ensure reproducible installs.
  """

  alias NPM.Config
  alias NPM.Security.RegistryPolicy

  @default_path "npm.lock"

  @type entry :: %{
          version: String.t(),
          integrity: String.t(),
          tarball: String.t(),
          dependencies: %{String.t() => String.t()},
          optional_dependencies: %{String.t() => String.t()},
          has_install_script: boolean()
        }

  @type t :: %{String.t() => entry()}

  @doc "Return the default npm_ex lockfile path."
  @spec default_path :: String.t()
  def default_path, do: @default_path

  @doc "Read the lockfile. Returns empty map if it doesn't exist."
  @spec read(String.t()) :: {:ok, t()} | {:error, term()}
  def read(path \\ @default_path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        lockfile = parse(Map.get(data, "packages", %{}))
        {:ok, lockfile}

      {:error, :enoent} ->
        {:ok, %{}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Write the lockfile."
  @spec write(t(), String.t()) :: :ok | {:error, term()}
  def write(lockfile, path \\ @default_path) do
    data = %{
      "lockfileVersion" => 1,
      "policy" => current_policy(),
      "packages" => serialize(lockfile)
    }

    File.write(path, NPM.JSON.encode_pretty(data))
  end

  @doc "Read the security policy recorded in the lockfile."
  @spec read_policy(String.t()) :: {:ok, map() | nil} | {:error, term()}
  def read_policy(path \\ @default_path) do
    case File.read(path) do
      {:ok, content} -> {:ok, content |> NPM.JSON.decode!() |> Map.get("policy")}
      {:error, :enoent} -> {:ok, nil}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Return the effective lockfile security policy for new locks."
  @spec current_policy :: map()
  def current_policy do
    %{
      "block_exotic_subdeps" => Config.block_exotic_subdeps?(),
      "exotic_deps" => Config.exotic_deps(),
      "allowed_registries" => RegistryPolicy.allowed_origins(),
      "allow_registry_redirects" => Config.allow_registry_redirects?()
    }
  end

  @doc "Whether a recorded lockfile policy is compatible with current settings."
  @spec policy_matches?(map() | nil) :: boolean()
  def policy_matches?(nil), do: false

  def policy_matches?(policy) when is_map(policy) do
    policy["block_exotic_subdeps"] == Config.block_exotic_subdeps?() and
      MapSet.subset?(
        MapSet.new(policy["exotic_deps"] || []),
        MapSet.new(Config.exotic_deps())
      ) and
      MapSet.subset?(
        MapSet.new(policy["allowed_registries"] || []),
        MapSet.new(RegistryPolicy.allowed_origins())
      ) and
      policy["allow_registry_redirects"] == Config.allow_registry_redirects?()
  end

  @doc "Parse a raw packages map into lockfile entries."
  @spec parse_packages(map()) :: t()
  def parse_packages(packages), do: parse(packages)

  defp parse(packages) do
    for {name, info} <- packages, into: %{} do
      {name,
       %{
         version: Map.get(info, "version", ""),
         integrity: Map.get(info, "integrity", ""),
         tarball: Map.get(info, "tarball", ""),
         dependencies: Map.get(info, "dependencies", %{}),
         optional_dependencies: Map.get(info, "optional_dependencies", %{}),
         has_install_script: Map.get(info, "has_install_script", false)
       }}
    end
  end

  @doc "Get the lockfile version from a file."
  @spec version(String.t()) :: integer() | nil
  def version(path \\ @default_path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        Map.get(data, "lockfileVersion")

      {:error, _} ->
        nil
    end
  end

  @doc "List all package names in the lockfile."
  @spec package_names(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def package_names(path \\ @default_path) do
    case read(path) do
      {:ok, lockfile} -> {:ok, Map.keys(lockfile) |> Enum.sort()}
      error -> error
    end
  end

  @doc """
  Check if a specific package is in the lockfile.
  """
  @spec has_package?(String.t(), String.t()) :: boolean()
  def has_package?(name, path \\ @default_path) do
    case read(path) do
      {:ok, lockfile} -> Map.has_key?(lockfile, name)
      _ -> false
    end
  end

  @doc "Get a single package entry from the lockfile."
  @spec get_package(String.t(), String.t()) :: {:ok, entry()} | :error
  def get_package(name, path \\ @default_path) do
    case read(path) do
      {:ok, lockfile} -> Map.fetch(lockfile, name)
      _ -> :error
    end
  end

  defp serialize(lockfile) do
    for {name, entry} <- Enum.sort_by(lockfile, &elem(&1, 0)), into: %{} do
      {name,
       %{
         "version" => entry.version,
         "integrity" => entry.integrity,
         "tarball" => entry.tarball,
         "dependencies" => entry.dependencies,
         "optional_dependencies" => Map.get(entry, :optional_dependencies, %{}),
         "has_install_script" => Map.get(entry, :has_install_script, false)
       }}
    end
  end
end
