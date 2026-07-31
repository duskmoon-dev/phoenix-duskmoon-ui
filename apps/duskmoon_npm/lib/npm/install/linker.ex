defmodule NPM.Install.Linker do
  @moduledoc """
  Creates `node_modules` from the global cache.

  Supports multiple linking strategies:
  - `:copy` (default) — full file copy
  - `:symlink` — symlinks from `node_modules/pkg` to cache

  Uses a hoisted layout where packages are placed as high in the tree
  as possible, only nesting when version conflicts occur.
  """

  @default_cache_concurrency 16
  @link_concurrency 16

  @type strategy :: :symlink | :copy
  @type resolved :: %{String.t() => NPM.Lockfile.entry()}
  @type nested_info :: %{String.t() => term()}

  @doc """
  Link all resolved packages into `node_modules`.

  First populates the global cache, then creates the `node_modules` tree.
  """
  @spec link(resolved(), String.t(), strategy(), MapSet.t() | nil) :: :ok | {:error, term()}
  def link(
        lockfile,
        node_modules_dir \\ "node_modules",
        strategy \\ default_strategy(),
        skipped \\ nil
      ) do
    with {:ok, skipped} <- populate_cache(lockfile, skipped) do
      create_node_modules(lockfile, node_modules_dir, strategy, skipped)
    end
  end

  @doc """
  Link local workspace and directory `file:` packages into `node_modules`.
  """
  @spec link_local_packages(%{String.t() => String.t()}, String.t()) :: :ok | {:error, term()}
  def link_local_packages(local_links, node_modules_dir \\ "node_modules")

  def link_local_packages(local_links, _node_modules_dir) when map_size(local_links) == 0, do: :ok

  def link_local_packages(local_links, node_modules_dir) do
    File.mkdir_p!(node_modules_dir)

    with :ok <-
           local_links
           |> Enum.sort_by(&elem(&1, 0))
           |> run_concurrently(fn {name, source} ->
             source = Path.expand(source)
             target = Path.join(node_modules_dir, name)
             link_local_package(source, target)
           end) do
      link_bins(node_modules_dir, Enum.map(local_links, fn {name, _path} -> {name, "local"} end))
    end
  end

  @doc """
  Link nested packages into parent package `node_modules/` subdirectories.

  For each nested package, resolves which version each parent needs and
  creates `parent_pkg/node_modules/nested_pkg/` with the correct version.
  """
  @spec link_nested(nested_info(), resolved(), String.t(), strategy()) :: :ok | {:error, term()}
  def link_nested(
        nested_info,
        flat_lockfile,
        nm_dir \\ "node_modules",
        strategy \\ default_strategy()
      ) do
    run_concurrently(nested_info, fn {nested_pkg, _} ->
      original_deps = NPM.Resolver.get_original_deps(nested_pkg)
      install_nested_for_parents(nested_pkg, original_deps, flat_lockfile, nm_dir, strategy)
    end)
  end

  @doc false
  def strategy, do: default_strategy()

  @doc false
  @spec link_nested_lockfile(
          %{String.t() => NPM.Lockfile.entry()},
          String.t(),
          strategy(),
          MapSet.t(String.t())
        ) :: :ok | {:error, term()}
  def link_nested_lockfile(
        nested_lockfile,
        nm_dir \\ "node_modules",
        strategy \\ default_strategy(),
        flat_skipped \\ MapSet.new()
      ) do
    result =
      nested_lockfile
      |> Enum.group_by(fn {location, _entry} -> location_depth(location) end)
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.reduce_while({:ok, MapSet.new()}, fn {_depth, entries},
                                                   {:ok, skipped_locations} ->
        case link_nested_depth(entries, nm_dir, strategy, flat_skipped, skipped_locations) do
          {:ok, new_skipped} -> {:cont, {:ok, new_skipped}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case result do
      {:ok, _skipped_locations} -> :ok
      error -> error
    end
  end

  defp link_nested_depth(entries, nm_dir, strategy, flat_skipped, skipped_locations) do
    entries
    |> Task.async_stream(
      fn {location, entry} ->
        link_nested_entry(location, entry, nm_dir, strategy, flat_skipped, skipped_locations)
      end,
      max_concurrency: @link_concurrency,
      ordered: false,
      timeout: :infinity
    )
    |> Enum.reduce_while({:ok, skipped_locations}, fn
      {:ok, {:ok, :linked}}, {:ok, skipped} ->
        {:cont, {:ok, skipped}}

      {:ok, {:ok, {:skip, location}}}, {:ok, skipped} ->
        {:cont, {:ok, MapSet.put(skipped, location)}}

      {:ok, {:error, reason}}, _ ->
        {:halt, {:error, reason}}

      {:exit, reason}, _ ->
        {:halt, {:error, reason}}
    end)
  end

  defp link_nested_entry(location, entry, nm_dir, strategy, flat_skipped, skipped_locations) do
    with {:ok, name} <- NPM.Lockfile.nested_package_name(location) do
      cond do
        nested_under_skipped?(location, flat_skipped, skipped_locations) ->
          {:ok, {:skip, location}}

        Map.get(entry, :optional, false) and not platform_compatible?(name, entry.version) ->
          {:ok, {:skip, location}}

        true ->
          case NPM.Cache.ensure(name, entry.version, entry.tarball, entry.integrity,
                 optional?: Map.get(entry, :optional, false)
               ) do
            {:ok, :missing_optional} ->
              {:ok, {:skip, location}}

            {:ok, _cache_result} ->
              cache_path = NPM.Cache.package_dir(name, entry.version)
              target = nested_target(nm_dir, location)
              :ok = link_package(cache_path, target, strategy)
              {:ok, :linked}

            {:error, reason} ->
              {:error, reason}
          end
      end
    else
      :error -> {:error, {:invalid_nested_package_location, location}}
    end
  end

  defp populate_cache(lockfile, platform_skipped) do
    platform_skipped = platform_skipped || skipped_packages(lockfile)

    lockfile
    |> Enum.reject(fn {name, _} -> MapSet.member?(platform_skipped, name) end)
    |> Task.async_stream(
      fn {name, entry} ->
        optional? = optional_dependency?(name, lockfile)

        case NPM.Cache.ensure(name, entry.version, entry.tarball, entry.integrity,
               optional?: optional?
             ) do
          {:ok, :missing_optional} -> {:skip, name}
          {:ok, path} -> {:ok, path}
          other -> other
        end
      end,
      max_concurrency: cache_concurrency(),
      ordered: false,
      timeout: :infinity
    )
    |> Enum.reduce_while({:ok, MapSet.union(platform_skipped, MapSet.new())}, fn
      {:ok, {:ok, _}}, {:ok, skipped} ->
        {:cont, {:ok, skipped}}

      {:ok, {:skip, name}}, {:ok, skipped} ->
        {:cont, {:ok, MapSet.put(skipped, name)}}

      {:ok, {:error, reason}}, _ ->
        {:halt, {:error, reason}}

      {:exit, reason}, _ ->
        {:halt, {:error, reason}}
    end)
  end

  defp create_node_modules(lockfile, node_modules_dir, strategy, skipped) do
    File.mkdir_p!(node_modules_dir)

    tree =
      lockfile
      |> hoist()
      |> Enum.reject(fn {name, _version} -> MapSet.member?(skipped, name) end)

    expected_names = MapSet.new(tree, &elem(&1, 0))
    prune(node_modules_dir, expected_names)

    with :ok <-
           run_concurrently(tree, fn {name, version} ->
             cache_path = NPM.Cache.package_dir(name, version)
             target = Path.join(node_modules_dir, name)
             link_package(cache_path, target, strategy)
           end) do
      link_bins(node_modules_dir, tree)
    end
  end

  defp link_package(source, target, :symlink) do
    File.mkdir_p!(Path.dirname(target))
    File.rm_rf!(target)

    case File.ln_s(source, target) do
      :ok -> :ok
      {:error, _reason} -> copy_package(source, target)
    end
  end

  defp link_package(source, target, :copy) do
    copy_package(source, target)
  end

  defp copy_package(source, target) do
    File.mkdir_p!(Path.dirname(target))
    File.rm_rf!(target)
    File.cp_r!(source, target)
    :ok
  end

  defp link_local_package(source, target) do
    if Path.expand(source) != Path.expand(target) do
      File.mkdir_p!(Path.dirname(target))
      File.rm_rf!(target)

      case File.ln_s(source, target) do
        :ok -> :ok
        {:error, _reason} -> copy_package(source, target)
      end
    else
      :ok
    end
  end

  @doc """
  Hoist packages for a flat `node_modules` layout.

  Returns a list of `{name, version}` tuples representing the top-level
  packages. When multiple versions of a package exist, the most commonly
  depended-on version gets hoisted.
  """
  @spec hoist(resolved()) :: [{String.t(), String.t()}]
  def hoist(lockfile) do
    lockfile
    |> collect_all_packages()
    |> pick_hoisted_versions()
  end

  @doc false
  @spec skipped_packages(resolved()) :: MapSet.t(String.t())
  def skipped_packages(lockfile) do
    lockfile
    |> platform_incompatible_packages()
    |> propagate_skipped_optional_descendants(lockfile)
  end

  defp collect_all_packages(lockfile) do
    lockfile
    |> Enum.reduce(%{}, fn {name, entry}, acc ->
      Map.update(acc, name, [entry.version], &[entry.version | &1])
    end)
  end

  defp pick_hoisted_versions(packages) do
    Enum.map(packages, fn {name, versions} ->
      version =
        versions
        |> Enum.frequencies()
        |> Enum.max_by(&elem(&1, 1))
        |> elem(0)

      {name, version}
    end)
  end

  @doc """
  Remove packages from `node_modules` that are not in the expected set.

  Handles both regular and scoped packages (`@scope/pkg`).
  """
  @spec prune(String.t(), MapSet.t()) :: :ok
  def prune(node_modules_dir, expected_names) do
    entries = list_dir(node_modules_dir)
    {scopes, packages} = Enum.split_with(entries, &String.starts_with?(&1, "@"))

    packages
    |> Enum.reject(&(MapSet.member?(expected_names, &1) or String.starts_with?(&1, ".")))
    |> Enum.each(&File.rm_rf!(Path.join(node_modules_dir, &1)))

    Enum.each(scopes, &prune_scope(node_modules_dir, &1, expected_names))
  end

  defp prune_scope(node_modules_dir, scope, expected_names) do
    scope_dir = Path.join(node_modules_dir, scope)

    scope_dir
    |> list_dir()
    |> Enum.reject(&MapSet.member?(expected_names, "#{scope}/#{&1}"))
    |> Enum.each(&File.rm_rf!(Path.join(scope_dir, &1)))

    if list_dir(scope_dir) == [], do: File.rmdir(scope_dir)
  end

  @doc """
  Create `node_modules/.bin/` symlinks for packages with `bin` entries.

  Reads each package's `package.json` for the `bin` field and creates
  executable symlinks in `.bin/`.
  """
  @spec link_bins(String.t(), [{String.t(), String.t()}]) :: :ok
  def link_bins(node_modules_dir, tree) do
    bin_dir = Path.join(node_modules_dir, ".bin")
    bins = Enum.flat_map(tree, &read_package_bins(node_modules_dir, &1))

    if bins != [] do
      File.mkdir_p!(bin_dir)

      Enum.each(bins, fn {command, target_path} ->
        link = Path.join(bin_dir, command)
        File.rm(link)
        File.ln_s!(target_path, link)
        File.chmod(target_path, 0o755)
      end)
    end

    :ok
  end

  defp read_package_bins(node_modules_dir, {name, _version}) do
    pkg_json_path = Path.join([node_modules_dir, name, "package.json"])

    case File.read(pkg_json_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        pkg_dir = Path.join(node_modules_dir, name)
        parse_bin_field(data, pkg_dir)

      {:error, _} ->
        []
    end
  end

  defp parse_bin_field(%{"bin" => bin} = data, pkg_dir) when is_binary(bin) do
    [{bin_command_name(data, pkg_dir), Path.expand(bin, pkg_dir)}]
  end

  defp parse_bin_field(%{"bin" => bin}, pkg_dir) when is_map(bin) do
    Enum.map(bin, fn {command, path} -> {command, Path.expand(path, pkg_dir)} end)
  end

  defp parse_bin_field(%{"directories" => %{"bin" => bin_dir}}, pkg_dir) do
    dir = Path.join(pkg_dir, bin_dir)

    dir
    |> list_dir()
    |> Enum.map(fn file -> {Path.rootname(file), Path.join(dir, file)} end)
  end

  defp parse_bin_field(_data, _pkg_dir), do: []

  defp bin_command_name(%{"name" => name}, _pkg_dir) do
    case String.split(name, "/") do
      [_scope, pkg] -> pkg
      _ -> name
    end
  end

  defp bin_command_name(_data, pkg_dir), do: Path.basename(pkg_dir)

  defp install_nested_for_parents(nested_pkg, original_deps, flat_lockfile, nm_dir, strategy) do
    flat_lockfile
    |> Enum.each(fn {parent_name, parent_entry} ->
      version = parent_entry_version(parent_entry)
      range = if is_binary(version), do: Map.get(original_deps, "#{parent_name}@#{version}")

      if is_binary(range) do
        nested_version = resolve_nested_version(nested_pkg, range)
        install_single_nested(nested_pkg, nested_version, parent_name, nm_dir, strategy)
      end
    end)

    :ok
  end

  defp parent_entry_version(%{version: version}) when is_binary(version), do: version
  defp parent_entry_version(%{"version" => version}) when is_binary(version), do: version
  defp parent_entry_version(version) when is_binary(version), do: version
  defp parent_entry_version(_entry), do: nil

  @doc false
  def __parent_entry_version__(entry) do
    parent_entry_version(entry)
  end

  defp resolve_nested_version(name, range) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        packument.versions
        |> Map.keys()
        |> Enum.filter(fn v ->
          version_matches?(v, range) and match?({:ok, _}, Version.parse(v))
        end)
        |> Enum.sort(&version_gt?/2)
        |> List.first()

      _ ->
        nil
    end
  end

  defp version_matches?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    ArgumentError -> false
  end

  defp version_gt?(a, b) do
    Version.compare(Version.parse!(a), Version.parse!(b)) == :gt
  end

  defp platform_incompatible_packages(lockfile) do
    optional_names =
      lockfile
      |> Enum.flat_map(fn {_pkg, entry} ->
        Map.keys(Map.get(entry, :optional_dependencies, %{}))
      end)
      |> MapSet.new()
      |> then(fn names ->
        Enum.reduce(lockfile, names, fn {name, entry}, acc ->
          if Map.get(entry, :optional, false), do: MapSet.put(acc, name), else: acc
        end)
      end)

    lockfile
    |> Enum.filter(fn {name, _} -> MapSet.member?(optional_names, name) end)
    |> Enum.reject(fn {name, entry} -> platform_compatible?(name, entry.version) end)
    |> MapSet.new(fn {name, _} -> name end)
  end

  defp propagate_skipped_optional_descendants(skipped, lockfile) do
    descendants =
      skipped
      |> Enum.flat_map(fn name ->
        case Map.get(lockfile, name) do
          nil ->
            []

          entry ->
            Map.keys(entry.dependencies) ++
              Map.keys(Map.get(entry, :optional_dependencies, %{}))
        end
      end)
      |> Enum.filter(fn name ->
        case Map.get(lockfile, name) do
          nil -> false
          entry -> Map.get(entry, :optional, false)
        end
      end)
      |> MapSet.new()

    expanded = MapSet.union(skipped, descendants)

    if MapSet.equal?(expanded, skipped) do
      skipped
    else
      propagate_skipped_optional_descendants(expanded, lockfile)
    end
  end

  defp platform_compatible?(name, version) do
    with {:ok, packument} <- NPM.Registry.get_packument(name),
         %{} = info <- Map.get(packument.versions, version) do
      NPM.Platform.os_compatible?(info.os) and NPM.Platform.cpu_compatible?(info.cpu)
    else
      nil -> false
      _ -> true
    end
  end

  defp optional_dependency?(name, lockfile) do
    case Map.get(lockfile, name) do
      %{optional: true} ->
        true

      _entry ->
        Enum.any?(lockfile, fn {_pkg, entry} ->
          Map.has_key?(Map.get(entry, :optional_dependencies, %{}), name)
        end)
    end
  end

  defp nested_under_skipped?(location, flat_skipped, skipped_locations) do
    Enum.any?(flat_skipped, fn name ->
      String.starts_with?(location, "node_modules/#{name}/node_modules/")
    end) or
      Enum.any?(skipped_locations, fn skipped_location ->
        String.starts_with?(location, "#{skipped_location}/node_modules/")
      end)
  end

  defp nested_target(nm_dir, "node_modules/" <> relative_location) do
    Path.join(nm_dir, relative_location)
  end

  defp nested_target(nm_dir, location), do: Path.join(nm_dir, location)

  defp location_depth(location), do: location |> String.split("/") |> length()

  defp install_single_nested(_pkg, nil, _parent, _nm_dir, _strategy), do: :ok

  defp install_single_nested(pkg, version, parent, nm_dir, strategy) do
    with {:ok, packument} <- NPM.Registry.get_packument(pkg),
         %{} = info <- Map.get(packument.versions, version),
         {:ok, cache_result} <-
           NPM.Cache.ensure(pkg, version, info.dist.tarball, info.dist.integrity) do
      if cache_result != :missing_optional do
        cache_path = NPM.Cache.package_dir(pkg, version)
        target = Path.join([nm_dir, parent, "node_modules", pkg])
        link_package(cache_path, target, strategy)
      else
        :ok
      end
    else
      _ -> :ok
    end
  end

  defp list_dir(path) do
    case File.ls(path) do
      {:ok, entries} -> entries
      {:error, _} -> []
    end
  end

  defp default_strategy do
    case System.get_env("NPM_EX_LINK_STRATEGY") do
      "copy" -> :copy
      "symlink" -> :symlink
      nil -> :symlink
      _ -> :symlink
    end
  end

  defp cache_concurrency do
    case System.get_env("NPM_EX_CACHE_CONCURRENCY") do
      nil ->
        max(@default_cache_concurrency, System.schedulers_online() * 2)

      value ->
        case Integer.parse(value) do
          {concurrency, ""} when concurrency > 0 -> concurrency
          _ -> max(@default_cache_concurrency, System.schedulers_online() * 2)
        end
    end
  end

  defp run_concurrently(items, fun) do
    items
    |> Task.async_stream(fun,
      max_concurrency: @link_concurrency,
      ordered: false,
      timeout: :infinity
    )
    |> Enum.reduce_while(:ok, fn
      {:ok, :ok}, :ok -> {:cont, :ok}
      {:ok, nil}, :ok -> {:cont, :ok}
      {:ok, {:error, reason}}, :ok -> {:halt, {:error, reason}}
      {:ok, _result}, :ok -> {:cont, :ok}
      {:exit, reason}, :ok -> {:halt, {:error, reason}}
    end)
  end
end
