defmodule NPM do
  alias NPM.Install.Linker
  alias NPM.Install.LockfileBuilder
  alias NPM.Install.ScriptInstall
  alias NPM.Package.JSON
  alias NPM.Security.Age
  alias NPM.Security.ExoticDeps

  @moduledoc """
  npm package manager for Elixir.

  Resolves, fetches, and installs npm packages using Mix tasks.
  Dependencies are declared in `package.json` files and locked in `package-lock.json`.

  ## Mix tasks

      mix npm.install              # Install all deps from package.json/workspaces
      mix npm.install lodash       # Add latest version
      mix npm.install lodash@^4.0  # Add with specific range
      mix npm.install --frozen     # Fail if lockfile is stale (CI mode)
      mix npm.get                  # Fetch locked deps without resolving
      mix npm.remove lodash        # Remove a package
      mix npm.list                 # List installed packages

  Packages are cached globally in `~/.npm_ex/cache/` and copied into
  `node_modules/` so Node-compatible tools resolve sibling dependencies
  from the installed dependency tree.
  """

  @node_modules "node_modules"

  @doc """
  Install npm packages in a script context, without a Mix project.

  Works like `Mix.install/2` — installs to a content-addressed cache directory,
  is idempotent, and can only be called once per VM (raises on different deps).

      NPM.install(%{"tailwindcss" => "^4.2.2"})

  After installation, use `NPM.install_dir!/0` and `NPM.node_modules_dir!/0`
  to locate the installed packages.

  ## Options

    * `:force` — reinstall even if cached (default: `false`)
  """
  @spec install(map(), keyword()) :: :ok
  def install(deps, opts) when is_map(deps) do
    ScriptInstall.install(deps, opts)
  end

  @doc """
  Returns whether `NPM.install/2` has been called in this VM.
  """
  @spec installed? :: boolean()
  defdelegate installed?, to: ScriptInstall

  @doc """
  Returns the root directory of the current `NPM.install/2` installation.

  Raises if `NPM.install/2` has not been called.
  """
  @spec install_dir! :: String.t()
  defdelegate install_dir!, to: ScriptInstall

  @doc """
  Returns the `node_modules` path of the current `NPM.install/2` installation.

  Raises if `NPM.install/2` has not been called.
  """
  @spec node_modules_dir! :: String.t()
  defdelegate node_modules_dir!, to: ScriptInstall

  @doc """
  Install all dependencies from `package.json` and configured workspaces.

  ## Options

    * `:frozen` - when `true`, fails if `package-lock.json` doesn't match
      `package.json` instead of re-resolving. Useful for CI.
    * `:production` - when `true`, skips `devDependencies`.
  """
  @spec install(keyword()) :: :ok | {:error, term()}
  def install(opts \\ []) when is_list(opts) do
    with_root_dir(fn ->
      with {:ok, project} <- NPM.Workspace.read_all(),
           {:ok, deps} <- NPM.Workspace.install_dependencies(project, opts) do
        do_install(deps, Keyword.put(opts, :local_links, project.local_links))
      end
    end)
  end

  @doc """
  Add a package to `package.json` and install all dependencies.

  ## Options

    * `:dev` - when `true`, adds to `devDependencies` instead of `dependencies`
  """
  @spec add(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
  def add(name, range \\ "latest", opts \\ []) do
    range = if range == "latest", do: resolve_latest(name, opts), else: range

    with range_str when is_binary(range_str) <- range,
         {:ok, package_dir} <- NPM.Workspace.package_dir(),
         package_path <- Path.join(package_dir, "package.json"),
         :ok <- JSON.add_dep(name, range_str, package_path, opts) do
      install([])
    end
  end

  @doc """
  Remove a package from `package.json` and re-install.
  """
  @spec remove(String.t()) :: :ok | {:error, term()}
  def remove(name) do
    with {:ok, package_dir} <- NPM.Workspace.package_dir(),
         package_path <- Path.join(package_dir, "package.json"),
         :ok <- JSON.remove_dep(name, package_path) do
      install([])
    end
  end

  @doc """
  Update all packages to the latest versions matching their ranges.

  Clears the resolver cache and re-resolves from scratch.
  """
  @spec update :: :ok | {:error, term()}
  def update do
    with_root_dir(fn ->
      with {:ok, project} <- NPM.Workspace.read_all(),
           {:ok, deps} <- NPM.Workspace.install_dependencies(project) do
        do_install(deps, local_links: project.local_links)
      end
    end)
  end

  @doc """
  Update a specific package to the latest version matching its range.

  Only re-resolves the named package; other locked versions are preserved.
  """
  @spec update(String.t()) :: :ok | {:error, term()}
  def update(name) do
    with_root_dir(fn ->
      with {:ok, project} <- NPM.Workspace.read_all(),
           {:ok, all_deps} <- NPM.Workspace.install_dependencies(project),
           {:ok, lockfile} <- NPM.Lockfile.read() do
        if Map.has_key?(all_deps, name) do
          updated_lock = Map.delete(lockfile, name)
          NPM.Lockfile.write(updated_lock)
          do_install(all_deps, local_links: project.local_links)
        else
          Mix.shell().error("Package #{name} not found in package.json.")
          {:error, {:not_found, name}}
        end
      end
    end)
  end

  @doc """
  Fetch locked dependencies without re-resolving.

  Reads `package-lock.json` and populates the global cache and `node_modules/`
  for any missing packages.
  """
  @spec get :: :ok | {:error, term()}
  def get do
    with_root_dir(fn ->
      case NPM.Lockfile.read() do
        {:ok, lockfile} when lockfile == %{} ->
          Mix.shell().info("No package-lock.json found, run `mix npm.install` first.")
          :ok

        {:ok, lockfile} ->
          with {:ok, project} <- NPM.Workspace.read_all() do
            link_from_lockfile(lockfile, project.local_links)
          end

        error ->
          error
      end
    end)
  end

  @doc """
  List installed packages with versions.

  Returns a list of `{name, version}` tuples.
  """
  @spec list :: {:ok, [{String.t(), String.t()}]} | {:error, term()}
  def list do
    with_root_dir(fn ->
      case NPM.Lockfile.read() do
        {:ok, lockfile} when lockfile == %{} ->
          {:ok, []}

        {:ok, lockfile} ->
          packages =
            lockfile
            |> Enum.map(fn {name, entry} -> {name, entry.version} end)
            |> Enum.sort_by(&elem(&1, 0))

          {:ok, packages}

        error ->
          error
      end
    end)
  end

  # --- Private ---

  defp with_root_dir(fun) do
    with {:ok, root_dir} <- NPM.Workspace.root_dir() do
      File.cd!(root_dir, fun)
    end
  end

  defp do_install(deps, opts) when map_size(deps) == 0 do
    local_links = Keyword.get(opts, :local_links, %{})

    if local_links == %{} do
      Mix.shell().info("No npm dependencies found in package.json.")
      :ok
    else
      with :ok <- Linker.link(%{}, @node_modules),
           :ok <- Linker.link_local_packages(local_links, @node_modules) do
        Mix.shell().info(
          "Linked #{map_size(local_links)} local npm package#{plural(local_links)}."
        )

        :ok
      end
    end
  end

  defp do_install(deps, opts) do
    if opts[:frozen] do
      frozen_install(deps, Keyword.get(opts, :local_links, %{}))
    else
      full_install(deps, Keyword.get(opts, :local_links, %{}))
    end
  end

  defp frozen_install(deps, local_links) do
    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().error("package-lock.json not found. Run `mix npm.install` first.")
        {:error, :no_lockfile}

      {:ok, lockfile} ->
        if lockfile_matches?(lockfile, deps) and lockfile_policy_current?() do
          link_from_lockfile(lockfile, local_links)
        else
          Mix.shell().error(
            "package-lock.json is out of date with package.json or current security policy.\n" <>
              "Run `mix npm.install` to update the lockfile."
          )

          {:error, :frozen_lockfile}
        end

      error ->
        error
    end
  end

  defp lockfile_policy_current? do
    case NPM.Lockfile.read_policy() do
      {:ok, nil} -> true
      {:ok, policy} -> NPM.Lockfile.policy_matches?(policy)
      _ -> false
    end
  end

  defp lockfile_matches?(lockfile, deps) do
    lockfile_root_deps_satisfied?(lockfile, deps) and
      lockfile_dependency_records_complete?(lockfile)
  end

  defp lockfile_root_deps_satisfied?(lockfile, deps) do
    Enum.all?(deps, fn {name, range} ->
      case Map.get(lockfile, name) do
        nil -> false
        entry -> lockfile_entry_satisfies_range?(entry, range)
      end
    end)
  end

  defp lockfile_entry_satisfies_range?(_entry, range) when range in ["", "*", "latest"],
    do: true

  defp lockfile_entry_satisfies_range?(entry, range) do
    case NPM.Alias.parse(range) do
      {:alias, _package, alias_range} -> NPMSemver.matches?(entry.version, alias_range)
      {:normal, normal_range} -> NPMSemver.matches?(entry.version, normal_range)
    end
  end

  defp lockfile_dependency_records_complete?(lockfile) do
    package_names =
      case NPM.Lockfile.all_package_names() do
        {:ok, names} when names != [] -> MapSet.new(names)
        _ -> MapSet.new(Map.keys(lockfile))
      end

    lockfile
    |> Enum.flat_map(fn {_name, entry} -> lockfile_entry_dependency_names(entry) end)
    |> Enum.all?(&MapSet.member?(package_names, &1))
  end

  defp lockfile_entry_dependency_names(entry) do
    Map.keys(entry.dependencies) ++ Map.keys(Map.get(entry, :optional_dependencies, %{}))
  end

  defp full_install(deps, local_links) do
    validate_direct_exotic_deps!(deps)
    {:ok, old_lockfile} = NPM.Lockfile.read()

    matches? = old_lockfile != %{} and lockfile_matches?(old_lockfile, deps)
    policy_ok? = lockfile_policy_current?()
    policy_reasons = lockfile_policy_mismatch_reasons()
    cache_ok? = matches? and cache_covers_lockfile?(old_lockfile)
    nm_intact? = matches? and node_modules_intact?(old_lockfile, local_links)

    cond do
      old_lockfile == %{} ->
        resolve_and_install(deps, old_lockfile, local_links)

      matches? and policy_ok? and nm_intact? ->
        Mix.shell().info("Already up to date.")
        :ok

      matches? and policy_ok? ->
        Mix.shell().info("Installing from current package-lock.json.")
        link_from_lockfile(old_lockfile, local_links)

      matches? and cache_ok? ->
        warn_policy_mismatch(policy_reasons)
        Mix.shell().info("Installing from cached packages without re-resolving.")

        with :ok <- link_from_lockfile(old_lockfile, local_links) do
          _ = NPM.Lockfile.refresh_policy()
          :ok
        end

      true ->
        if policy_reasons != [] and matches? do
          warn_policy_mismatch(policy_reasons)
          Mix.shell().info("Cache incomplete — re-resolving dependencies.")
        end

        resolve_and_install(deps, old_lockfile, local_links)
    end
  end

  defp lockfile_policy_mismatch_reasons do
    case NPM.Lockfile.read_policy() do
      {:ok, nil} -> []
      {:ok, policy} -> NPM.Lockfile.policy_mismatch_reasons(policy)
      _ -> ["unable to read lockfile policy"]
    end
  end

  defp warn_policy_mismatch(reasons) do
    Mix.shell().info("Lockfile security policy differs from current settings:")

    Enum.each(reasons, fn reason ->
      Mix.shell().info("  - #{reason}")
    end)
  end

  defp cache_covers_lockfile?(lockfile) do
    skipped = Linker.skipped_packages(lockfile)

    Enum.all?(lockfile, fn {name, entry} ->
      MapSet.member?(skipped, name) or NPM.Cache.cached?(name, entry.version)
    end)
  end

  defp validate_direct_exotic_deps!(deps) do
    Enum.each(deps, fn {name, spec} -> ExoticDeps.validate_direct!(name, spec) end)
  end

  defp node_modules_intact?(lockfile, local_links) do
    skipped = Linker.skipped_packages(lockfile)
    linkable_lockfile = linkable_lockfile(lockfile, skipped)
    strategy = Linker.strategy()

    lockfile_intact? =
      Enum.all?(linkable_lockfile, fn {name, _entry} ->
        registry_package_intact?(Path.join(@node_modules, name), strategy)
      end)

    local_links_intact? =
      Enum.all?(local_links, fn {name, _path} ->
        Path.join([@node_modules, name, "package.json"]) |> File.exists?()
      end)

    nested_lockfile_intact? =
      case NPM.Lockfile.read_nested() do
        {:ok, nested_lockfile} ->
          Enum.all?(nested_lockfile, fn {location, _entry} ->
            nested_location_skipped?(location, skipped) or
              registry_package_intact?(location, strategy)
          end)

        {:error, _reason} ->
          false
      end

    lockfile_intact? and nested_lockfile_intact? and local_links_intact?
  end

  defp nested_location_skipped?(location, skipped) do
    Enum.any?(skipped, fn name ->
      String.starts_with?(location, "node_modules/#{name}/node_modules/")
    end)
  end

  defp resolve_and_install(deps, old_lockfile, local_links) do
    {:ok, overrides} = JSON.read_overrides()

    {resolve_us, result} =
      :timer.tc(fn ->
        NPM.Resolver.clear_cache()
        NPM.Resolver.resolve(deps, overrides: overrides)
      end)

    case result do
      {:ok, resolved} ->
        {nested_info, flat} = Map.pop(resolved, :nested, %{})
        pkg_count = map_size(flat)
        Mix.shell().info("Resolved #{pkg_count} packages in #{format_ms(resolve_us)}")

        if nested_info != %{} do
          Mix.shell().info("  (#{map_size(nested_info)} packages with nested versions)")
        end

        nested_lockfile = build_nested_lockfile(nested_info, flat)
        lockfile = build_lockfile(flat)
        {lockfile, nested_lockfile} = expand_all_optional_deps(lockfile, nested_lockfile)
        print_lockfile_diff(old_lockfile, lockfile)
        NPM.Lockfile.write(lockfile, nested: nested_lockfile)
        link_from_lockfile(lockfile, local_links, nested_lockfile)

      {:error, message} ->
        Mix.shell().error("Resolution failed:\n#{message}")
        {:error, :resolution_failed}
    end
  end

  defp link_from_lockfile(lockfile, local_links, nested_lockfile \\ :read)

  defp link_from_lockfile(lockfile, local_links, :read) do
    with {:ok, nested_lockfile} <- NPM.Lockfile.read_nested() do
      link_from_lockfile(lockfile, local_links, nested_lockfile)
    end
  end

  defp link_from_lockfile(lockfile, local_links, nested_lockfile) do
    skipped = Linker.skipped_packages(lockfile)
    linkable_lockfile = linkable_lockfile(lockfile, skipped)
    total = length(linkable_lockfile)

    cached =
      Enum.count(linkable_lockfile, fn {name, entry} -> NPM.Cache.cached?(name, entry.version) end)

    to_fetch = total - cached

    if to_fetch > 0 do
      Mix.shell().info("Fetching #{to_fetch} package#{if to_fetch != 1, do: "s", else: ""}...")
    end

    strategy = Linker.strategy()

    {link_us, result} =
      :timer.tc(fn ->
        with :ok <- Linker.link(lockfile, @node_modules, strategy, skipped),
             :ok <-
               Linker.link_nested_lockfile(
                 nested_lockfile,
                 @node_modules,
                 strategy,
                 skipped
               ) do
          NPM.Install.Linker.link_local_packages(local_links, @node_modules)
        end
      end)

    case result do
      :ok ->
        ms = div(link_us, 1000)
        Mix.shell().info(NPM.DepsOutput.format_summary(total, ms))
        warn_ignored_install_scripts(lockfile)
        Mix.shell().info(NPM.DepsOutput.format_lockfile(lockfile))
        :ok

      error ->
        error
    end
  end

  defp linkable_lockfile(lockfile, skipped) do
    Enum.reject(lockfile, fn {name, _entry} -> MapSet.member?(skipped, name) end)
  end

  defp registry_package_intact?(package_dir, strategy) do
    case File.lstat(package_dir) do
      {:ok, %File.Stat{type: :directory}} ->
        File.exists?(Path.join(package_dir, "package.json"))

      {:ok, %File.Stat{type: :symlink}} when strategy == :symlink ->
        File.exists?(Path.join(package_dir, "package.json"))

      _ ->
        false
    end
  end

  defp plural(map) do
    if map_size(map) == 1, do: "", else: "s"
  end

  defp build_lockfile(resolved) do
    lockfile = LockfileBuilder.build(resolved, &warn_age_heuristics/3)

    warn_unmet_peers(resolved)
    lockfile
  end

  defp build_nested_lockfile(nested_info, _flat) when map_size(nested_info) == 0, do: %{}

  defp build_nested_lockfile(nested_info, flat) do
    Enum.reduce(nested_info, %{}, fn {nested_pkg, _}, acc ->
      original_deps = NPM.Resolver.get_original_deps(nested_pkg)

      Enum.reduce(flat, acc, fn {parent_name, parent_version}, inner_acc ->
        range = Map.get(original_deps, "#{parent_name}@#{parent_version}")

        case nested_lockfile_entry(nested_pkg, range) do
          {:ok, entry} ->
            Map.put(
              inner_acc,
              "node_modules/#{parent_name}/node_modules/#{nested_pkg}",
              entry
            )

          :error ->
            inner_acc
        end
      end)
    end)
  end

  defp nested_lockfile_entry(_name, nil), do: :error

  defp nested_lockfile_entry(name, range) do
    case resolve_version(name, range) do
      {:ok, version_str, info} ->
        {:ok,
         %{
           version: version_str,
           integrity: info.dist.integrity,
           tarball: info.dist.tarball,
           dependencies: info.dependencies,
           optional_dependencies: Map.get(info, :optional_dependencies, %{}),
           has_install_script: Map.get(info, :has_install_script, false)
         }}

      :error ->
        :error
    end
  end

  defp expand_all_optional_deps(lockfile, nested_lockfile) do
    Enum.reduce(lockfile, {lockfile, nested_lockfile}, fn {name, entry}, acc ->
      entry
      |> Map.get(:optional_dependencies, %{})
      |> Enum.reduce(acc, fn dependency, state ->
        expand_dependency(dependency, "node_modules/#{name}", state)
      end)
    end)
  end

  defp expand_dependency({name, range}, parent_location, {flat, nested} = state) do
    if dependency_satisfied?(name, range, parent_location, flat, nested) do
      state
    else
      case resolve_version(name, range) do
        {:ok, version_str, info} ->
          warn_age_heuristics(name, version_str, info)

          entry = %{
            version: version_str,
            integrity: info.dist.integrity,
            tarball: info.dist.tarball,
            dependencies: info.dependencies,
            optional_dependencies: Map.get(info, :optional_dependencies, %{}),
            has_install_script: Map.get(info, :has_install_script, false),
            optional: true
          }

          {state, installed_location} =
            put_expanded_dependency(name, entry, parent_location, flat, nested)

          entry.dependencies
          |> Map.merge(entry.optional_dependencies)
          |> Enum.reduce(state, fn dependency, acc ->
            expand_dependency(dependency, installed_location, acc)
          end)

        :error ->
          state
      end
    end
  end

  defp dependency_satisfied?(name, range, parent_location, flat, nested) do
    parent_location
    |> dependency_locations(name)
    |> Enum.any?(fn location ->
      case dependency_entry(location, name, flat, nested) do
        nil -> false
        entry -> lockfile_entry_satisfies_range?(entry, range)
      end
    end)
  end

  defp dependency_entry("node_modules/" <> rest = location, name, flat, nested) do
    if rest == name, do: Map.get(flat, name), else: Map.get(nested, location)
  end

  defp put_expanded_dependency(name, entry, parent_location, flat, nested) do
    if Map.has_key?(flat, name) do
      location = "#{parent_location}/node_modules/#{name}"
      {{flat, Map.put(nested, location, entry)}, location}
    else
      location = "node_modules/#{name}"
      {{Map.put(flat, name, entry), nested}, location}
    end
  end

  defp dependency_locations(parent_location, name) do
    parent_segments = String.split(parent_location, "/", trim: true)
    package_segments = String.split(name, "/", trim: true)

    ancestors =
      parent_segments
      |> Enum.with_index()
      |> Enum.filter(fn {segment, _index} -> segment == "node_modules" end)
      |> Enum.map(fn {_segment, index} ->
        Enum.take(parent_segments, index) ++ ["node_modules"] ++ package_segments
      end)
      |> Enum.reverse()

    [
      parent_segments ++ ["node_modules"] ++ package_segments
      | ancestors
    ]
    |> Enum.map(&Enum.join(&1, "/"))
    |> Enum.uniq()
  end

  defp resolve_version(name, range) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        packument.versions
        |> Enum.filter(fn {v, _} ->
          NPMSemver.matches?(v, range) and match?({:ok, _}, Version.parse(v))
        end)
        |> Enum.sort_by(fn {v, _} -> Version.parse!(v) end, {:desc, Version})
        |> case do
          [{version_str, info} | _] -> {:ok, version_str, info}
          [] -> :error
        end

      _ ->
        :error
    end
  end

  defp warn_age_heuristics(name, version, info) do
    info
    |> Age.warnings()
    |> Enum.each(fn warning ->
      Mix.shell().info("Warning: #{Age.format(name, version, warning)}")
    end)
  end

  defp warn_unmet_peers(resolved) do
    Enum.each(resolved, fn {name, version_str} ->
      case NPM.Registry.get_packument(name) do
        {:ok, packument} ->
          info = Map.fetch!(packument.versions, version_str)
          check_peers(name, info, resolved)
          check_deprecated(name, version_str, info)

        _ ->
          :ok
      end
    end)
  end

  defp warn_ignored_install_scripts(lockfile) do
    packages =
      lockfile
      |> Enum.filter(fn {_name, entry} -> Map.get(entry, :has_install_script, false) end)
      |> Enum.map_join(", ", fn {name, entry} -> "#{name}@#{entry.version}" end)

    if packages != "" do
      Mix.shell().info(
        "npm WARN ignored lifecycle scripts for #{packages}. " <>
          "npm_ex never runs preinstall/install/postinstall hooks automatically."
      )
    end
  end

  defp check_deprecated(name, version, info) do
    case Map.get(info, :deprecated) do
      nil ->
        :ok

      false ->
        :ok

      msg when is_binary(msg) ->
        Mix.shell().info("npm WARN #{name}@#{version} is deprecated: #{msg}")

      _ ->
        :ok
    end
  end

  defp check_peers(name, info, resolved) do
    peers = Map.get(info, :peer_dependencies, %{})
    meta = Map.get(info, :peer_dependencies_meta, %{})

    Enum.each(peers, fn {peer_name, peer_range} ->
      optional? = get_in(meta, [peer_name, "optional"]) == true

      case Map.get(resolved, peer_name) do
        nil when not optional? ->
          Mix.shell().info(
            "npm WARN #{name} requires peer #{peer_name}@#{peer_range} — not installed"
          )

        _ ->
          :ok
      end
    end)
  end

  defp resolve_latest(name, opts) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} -> latest_stable_range(packument, opts)
      {:error, reason} -> {:error, reason}
    end
  end

  defp latest_stable_range(packument, opts) do
    packument.versions
    |> Map.keys()
    |> Enum.flat_map(&parse_stable_version/1)
    |> Enum.sort(Version)
    |> List.last()
    |> case do
      nil -> {:error, :no_versions}
      v -> if opts[:exact], do: "#{v}", else: "^#{v}"
    end
  end

  defp parse_stable_version(v) do
    case Version.parse(v) do
      {:ok, ver} -> if ver.pre == [], do: [ver], else: []
      :error -> []
    end
  end

  defp print_lockfile_diff(old, new) when old == %{}, do: new
  defp print_lockfile_diff(old, new) when old == new, do: :ok

  defp print_lockfile_diff(old, new) do
    diff = NPM.DepsOutput.format_diff(old, new)
    if diff != "", do: Mix.shell().info(diff)
  end

  defp format_ms(microseconds) do
    ms = div(microseconds, 1000)
    if ms < 1000, do: "#{ms}ms", else: "#{Float.round(ms / 1000, 1)}s"
  end
end
