defmodule NPM.Lockfile do
  @moduledoc """
  Read and write npm `package-lock.json` lockfiles.

  The lockfile records resolved versions, integrity hashes, and dependency
  relationships to ensure reproducible installs.
  """

  alias NPM.Config
  alias NPM.Security.RegistryPolicy

  @default_path "package-lock.json"
  @legacy_path "npm.lock"
  @npm_ex_metadata "x-npm-ex"
  @package_lock_version 3

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

  @doc "Return the legacy npm_ex lockfile path."
  @spec legacy_path :: String.t()
  def legacy_path, do: @legacy_path

  @doc "Read the lockfile. Returns empty map if it doesn't exist."
  @spec read(String.t()) :: {:ok, t()} | {:error, term()}
  def read(path \\ @default_path)

  def read(@default_path) do
    cond do
      File.exists?(@default_path) -> read_file(@default_path)
      File.exists?(@legacy_path) -> migrate_legacy()
      true -> {:ok, %{}}
    end
  end

  def read(path) do
    read_file(path)
  end

  @doc """
  Migrates the legacy `npm.lock` schema to `package-lock.json` v3.

  The legacy file is left in place so callers can decide when to remove it.
  """
  @spec migrate_legacy(String.t(), String.t()) :: {:ok, t()} | {:error, term()}
  def migrate_legacy(legacy_path \\ @legacy_path, target_path \\ @default_path) do
    with {:ok, data} <- read_json(legacy_path),
         lockfile <- parse_legacy_packages(Map.get(data, "packages", %{})),
         policy <- lockfile_policy(data),
         :ok <- write_package_lock(lockfile, target_path, policy) do
      {:ok, lockfile}
    end
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        lockfile = parse_data(data)
        {:ok, lockfile}

      {:error, :enoent} ->
        {:ok, %{}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Write the lockfile."
  @spec write(t(), String.t() | keyword(), keyword()) :: :ok | {:error, term()}
  def write(lockfile, path \\ @default_path, opts \\ [])

  def write(lockfile, opts, []) when is_list(opts) do
    write(lockfile, @default_path, opts)
  end

  def write(lockfile, path, opts) do
    if legacy_path?(path) do
      write_legacy(lockfile, path, current_policy())
    else
      write_package_lock(lockfile, path, current_policy(), opts)
    end
  end

  defp write_package_lock(lockfile, path, policy, opts \\ []) do
    root_data = read_root_package()
    packages = package_lock_packages(lockfile, root_data, opts)

    data =
      %{
        "lockfileVersion" => @package_lock_version,
        "requires" => true,
        "packages" => packages,
        @npm_ex_metadata => %{"policy" => policy}
      }
      |> maybe_put("name", root_data["name"])
      |> maybe_put("version", root_data["version"])

    File.write(path, NPM.JSON.encode_pretty(data))
  end

  defp write_legacy(lockfile, path, policy) do
    data = %{
      "lockfileVersion" => 1,
      "policy" => policy,
      "packages" => serialize_legacy(lockfile)
    }

    File.write(path, NPM.JSON.encode_pretty(data))
  end

  @doc "Read the security policy recorded in the lockfile."
  @spec read_policy(String.t()) :: {:ok, map() | nil} | {:error, term()}
  def read_policy(path \\ @default_path)

  def read_policy(@default_path) do
    cond do
      File.exists?(@default_path) -> read_policy_file(@default_path)
      File.exists?(@legacy_path) -> read_policy_file(@legacy_path)
      true -> {:ok, nil}
    end
  end

  def read_policy(path), do: read_policy_file(path)

  defp read_policy_file(path) do
    case read_json(path) do
      {:ok, data} -> {:ok, lockfile_policy(data)}
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
  def parse_packages(packages) do
    if package_lock_packages?(packages) do
      parse_package_lock_packages(packages)
    else
      parse_legacy_packages(packages)
    end
  end

  @doc "Parse a raw package-lock map into lockfile entries."
  @spec parse(map()) :: t()
  def parse(data) when is_map(data), do: parse_data(data)

  defp parse_data(%{"packages" => packages} = data) when is_map(packages) do
    cond do
      package_lock?(data, packages) -> parse_package_lock_packages(packages)
      true -> parse_legacy_packages(packages)
    end
  end

  defp parse_data(%{"dependencies" => deps}) when is_map(deps),
    do: parse_legacy_dependencies(deps)

  defp parse_data(_), do: %{}

  defp parse_legacy_packages(packages) do
    for {name, info} <- packages, into: %{} do
      {name,
       %{
         version: Map.get(info, "version", ""),
         integrity: Map.get(info, "integrity", ""),
         tarball: Map.get(info, "tarball", ""),
         dependencies: Map.get(info, "dependencies", %{}),
         optional_dependencies: optional_dependencies(info),
         has_install_script: has_install_script?(info)
       }}
    end
  end

  defp parse_package_lock_packages(packages) do
    packages
    |> Enum.flat_map(fn {location, info} ->
      with false <- Map.get(info, "link") == true,
           {:ok, name} <- package_name_from_location(location) do
        [
          {name,
           %{
             version: Map.get(info, "version", ""),
             integrity: Map.get(info, "integrity", ""),
             tarball: Map.get(info, "resolved", ""),
             dependencies: Map.get(info, "dependencies", %{}),
             optional_dependencies: optional_dependencies(info),
             has_install_script: has_install_script?(info)
           }}
        ]
      else
        _ -> []
      end
    end)
    |> Map.new()
  end

  defp parse_legacy_dependencies(deps) do
    Map.new(deps, fn {name, info} ->
      {name,
       %{
         version: Map.get(info, "version", ""),
         integrity: Map.get(info, "integrity", ""),
         tarball: Map.get(info, "resolved", ""),
         dependencies: Map.get(info, "requires", %{}),
         optional_dependencies: optional_dependencies(info),
         has_install_script: has_install_script?(info)
       }}
    end)
  end

  @doc "Get the lockfile version from a file."
  @spec version(String.t()) :: integer() | nil
  def version(path \\ @default_path)

  def version(@default_path) do
    cond do
      File.exists?(@default_path) -> version_file(@default_path)
      File.exists?(@legacy_path) -> version_file(@legacy_path)
      true -> nil
    end
  end

  def version(path), do: version_file(path)

  defp version_file(path) do
    case read_json(path) do
      {:ok, data} -> Map.get(data, "lockfileVersion")
      {:error, _} -> nil
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

  @doc false
  @spec all_package_names(String.t()) :: {:ok, [String.t()]} | {:error, term()}
  def all_package_names(path \\ @default_path) do
    case read_json(path) do
      {:ok, %{"packages" => packages} = data} when is_map(packages) ->
        names =
          if package_lock?(data, packages) do
            package_lock_all_package_names(packages)
          else
            Map.keys(parse_legacy_packages(packages))
          end

        {:ok, Enum.sort(names)}

      {:ok, data} ->
        {:ok, data |> parse_data() |> Map.keys() |> Enum.sort()}

      {:error, :enoent} ->
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp serialize_legacy(lockfile) do
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

  defp package_lock_packages(lockfile, root_data, opts) do
    manifests = package_manifests()

    %{}
    |> Map.put("", root_package_descriptor(root_data))
    |> put_workspace_package_descriptors(manifests)
    |> put_registry_package_descriptors(lockfile)
    |> put_nested_package_descriptors(Keyword.get(opts, :nested, %{}))
    |> put_workspace_links(manifests)
  end

  defp root_package_descriptor(root_data) do
    %{}
    |> maybe_put("name", root_data["name"])
    |> maybe_put("version", root_data["version"])
    |> maybe_put("workspaces", root_data["workspaces"])
    |> maybe_put("dependencies", empty_to_nil(root_data["dependencies"]))
    |> maybe_put("devDependencies", empty_to_nil(root_data["devDependencies"]))
    |> maybe_put("optionalDependencies", empty_to_nil(root_data["optionalDependencies"]))
    |> maybe_put("peerDependencies", empty_to_nil(root_data["peerDependencies"]))
  end

  defp put_workspace_package_descriptors(packages, manifests) do
    manifests
    |> Enum.reject(& &1.root?)
    |> Enum.reduce(packages, fn manifest, acc ->
      Map.put(acc, relative_path(manifest.dir), package_descriptor(manifest.data))
    end)
  end

  defp package_descriptor(data) do
    %{}
    |> maybe_put("name", data["name"])
    |> maybe_put("version", data["version"])
    |> maybe_put("dependencies", empty_to_nil(data["dependencies"]))
    |> maybe_put("devDependencies", empty_to_nil(data["devDependencies"]))
    |> maybe_put("optionalDependencies", empty_to_nil(data["optionalDependencies"]))
    |> maybe_put("peerDependencies", empty_to_nil(data["peerDependencies"]))
  end

  defp put_registry_package_descriptors(packages, lockfile) do
    Enum.reduce(lockfile, packages, fn {name, entry}, acc ->
      Map.put(acc, "node_modules/#{name}", package_lock_entry(entry))
    end)
  end

  defp put_nested_package_descriptors(packages, nested) do
    Enum.reduce(nested, packages, fn {location, entry}, acc ->
      Map.put(acc, location, package_lock_entry(entry))
    end)
  end

  defp package_lock_entry(entry) do
    %{
      "version" => entry.version,
      "resolved" => entry.tarball,
      "integrity" => entry.integrity
    }
    |> maybe_put("dependencies", empty_to_nil(entry.dependencies))
    |> maybe_put(
      "optionalDependencies",
      empty_to_nil(Map.get(entry, :optional_dependencies, %{}))
    )
    |> maybe_put("hasInstallScript", if(Map.get(entry, :has_install_script, false), do: true))
  end

  defp put_workspace_links(packages, manifests) do
    manifests
    |> Enum.reject(& &1.root?)
    |> Enum.reduce(packages, fn manifest, acc ->
      with name when is_binary(name) and name != "" <- manifest.data["name"] do
        Map.put(acc, "node_modules/#{name}", %{
          "resolved" => relative_path(manifest.dir),
          "link" => true
        })
      else
        _ -> acc
      end
    end)
  end

  defp package_manifests do
    case NPM.Workspace.manifests(".") do
      {:ok, manifests} -> manifests
      _ -> []
    end
  end

  defp read_root_package do
    case NPM.JSON.read_file("package.json") do
      {:ok, data} when is_map(data) -> data
      _ -> %{}
    end
  end

  defp read_json(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, NPM.JSON.decode!(content)}
      error -> error
    end
  end

  defp lockfile_policy(data) do
    get_in(data, [@npm_ex_metadata, "policy"]) || Map.get(data, "policy")
  end

  defp package_lock?(data, packages) do
    Map.get(data, "lockfileVersion") in [2, 3] and package_lock_packages?(packages)
  end

  defp package_lock_packages?(packages) do
    Map.has_key?(packages, "") or Enum.any?(packages, fn {path, _} -> package_location?(path) end)
  end

  defp package_location?("node_modules/" <> _), do: true
  defp package_location?(_), do: false

  defp package_name_from_location("node_modules/" <> rest) do
    case String.split(rest, "/") do
      ["@" <> _ = scope, package] -> {:ok, "#{scope}/#{package}"}
      [package] when package != "" -> {:ok, package}
      _ -> :error
    end
  end

  defp package_name_from_location(_), do: :error

  defp package_lock_all_package_names(packages) do
    packages
    |> Enum.flat_map(fn {location, info} ->
      with false <- Map.get(info, "link") == true,
           {:ok, name} <- package_name_from_any_location(location) do
        [name]
      else
        _ -> []
      end
    end)
    |> Enum.uniq()
  end

  defp package_name_from_any_location(location) do
    segments = String.split(location, "/")

    segments
    |> Enum.with_index()
    |> Enum.filter(fn {segment, _index} -> segment == "node_modules" end)
    |> List.last()
    |> case do
      {"node_modules", index} -> package_name_from_segments(Enum.drop(segments, index + 1))
      nil -> :error
    end
  end

  defp package_name_from_segments(["@" <> _ = scope, package | _]),
    do: {:ok, "#{scope}/#{package}"}

  defp package_name_from_segments([package | _]) when package != "", do: {:ok, package}
  defp package_name_from_segments(_), do: :error

  defp optional_dependencies(info) do
    Map.get(info, "optionalDependencies") || Map.get(info, "optional_dependencies", %{})
  end

  defp has_install_script?(info) do
    Map.get(info, "hasInstallScript") || Map.get(info, "has_install_script", false)
  end

  defp legacy_path?(path), do: Path.basename(path) == @legacy_path

  defp relative_path(path) do
    path
    |> Path.relative_to(File.cwd!())
    |> Path.split()
    |> Enum.join("/")
  end

  defp empty_to_nil(map) when map == %{}, do: nil
  defp empty_to_nil(value), do: value

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, ""), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
