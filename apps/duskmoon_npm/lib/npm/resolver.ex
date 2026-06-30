defmodule NPM.Resolver do
  alias NPM.Security.ExoticDeps

  @moduledoc """
  `HexSolver.Registry` implementation for npm packages.

  Bridges the npm registry to hex_solver's PubGrub dependency resolver.
  Packuments are cached in an ETS table for the duration of a resolution.
  """

  @behaviour HexSolver.Registry

  @table :npm_resolver_cache
  @max_nesting_depth 128
  @max_prefetch_depth 10
  @prefetch_concurrency 16
  @fetch_timeout 30_000

  @doc """
  Resolve a set of root dependencies to exact versions.

  Uses a two-phase approach:
  1. Try flat resolution with PubGrub
  2. On conflict, identify conflicting packages and retry with
     those excluded, tracking them as nested dependencies

  Returns `{:ok, %{name => version}}` where the map includes
  a `:nested` key with nested package info when version conflicts exist.
  """
  @spec resolve(%{String.t() => String.t()}, keyword()) ::
          {:ok, %{String.t() => String.t()}} | {:error, String.t()}
  def resolve(root_deps, opts \\ [])
  def resolve(root_deps, _opts) when map_size(root_deps) == 0, do: {:ok, %{}}

  def resolve(root_deps, opts) do
    ensure_cache()
    overrides = Keyword.get(opts, :overrides, %{})
    if overrides != %{}, do: store_overrides(overrides)
    resolve_with_nesting(root_deps, MapSet.new(), %{}, 0)
  rescue
    error in ExoticDeps.Error -> {:error, Exception.message(error)}
  end

  defp store_overrides(overrides) do
    :ets.insert(@table, {:__overrides__, overrides})
  end

  defp get_overrides do
    case :ets.lookup(@table, :__overrides__) do
      [{_, overrides}] -> overrides
      [] -> %{}
    end
  end

  defp resolve_with_nesting(_root_deps, _excluded, _nested, depth)
       when depth > @max_nesting_depth do
    {:error, "Too many resolution retries — deeply conflicting dependencies"}
  end

  defp resolve_with_nesting(root_deps, excluded, nested, depth) do
    prefetch_tree(Map.keys(root_deps))
    dependencies = build_dependencies(root_deps)

    case run_solver(dependencies, excluded) do
      {:ok, result} ->
        final = if nested == %{}, do: result, else: Map.put(result, :nested, nested)
        {:ok, final}

      {:error, message} ->
        conflict_pkg = extract_conflict_package(message)

        if conflict_pkg && not MapSet.member?(excluded, conflict_pkg) do
          new_nested = collect_nested_versions(conflict_pkg, excluded)
          merged_nested = Map.merge(nested, new_nested)
          new_excluded = MapSet.put(excluded, conflict_pkg)
          resolve_with_nesting(root_deps, new_excluded, merged_nested, depth + 1)
        else
          {:error, message}
        end
    end
  end

  defp build_dependencies(root_deps) do
    Enum.map(root_deps, fn {name, range} ->
      {:ok, constraint} = normalize_range(range)

      %{
        repo: nil,
        name: name,
        constraint: constraint,
        optional: false,
        label: name,
        dependencies: []
      }
    end)
  end

  defp run_solver(dependencies, excluded) do
    ensure_cache()
    put_excluded(excluded)

    # Remove excluded packages from the version cache to prevent stale data
    if MapSet.size(excluded) > 0, do: strip_excluded_from_cache(excluded)

    case HexSolver.run(__MODULE__, dependencies, [], []) do
      {:ok, solution} ->
        result =
          for {name, {version, _repo}} <- solution, into: %{}, do: {name, to_string(version)}

        {:ok, result}

      {:error, message} ->
        {:error, message}
    end
  end

  defp put_excluded(excluded) do
    ensure_cache()
    :ets.insert(@table, {:__excluded_packages__, excluded})
  end

  defp get_excluded do
    case :ets.lookup(@table, :__excluded_packages__) do
      [{_, excluded}] -> excluded
      [] -> MapSet.new()
    end
  end

  defp strip_excluded_from_cache(excluded) do
    # Delete excluded packages entirely from the cache
    Enum.each(excluded, &:ets.delete(@table, &1))

    # Strip excluded deps from all cached packuments (skip non-packument entries)
    :ets.foldl(
      fn
        {_name, %{versions: _} = packument} = entry, acc ->
          stripped = strip_deps(packument, excluded)
          if stripped != packument, do: :ets.insert(@table, put_elem(entry, 1, stripped))
          acc

        _, acc ->
          acc
      end,
      :ok,
      @table
    )
  end

  defp strip_deps(packument, excluded) do
    versions =
      Map.new(packument.versions, fn {ver, info} ->
        deps = Map.drop(info.dependencies, MapSet.to_list(excluded))
        {ver, %{info | dependencies: deps}}
      end)

    %{packument | versions: versions}
  end

  @doc false
  def extract_conflict_package(message) do
    extract_repeated_dependency_target(message) ||
      extract_dependency_pair_conflict(message) ||
      extract_exact_version_conflict(message)
  end

  defp extract_repeated_dependency_target(message) do
    ~r/depends on "([^"]+)"/
    |> Regex.scan(message)
    |> Enum.map(fn [_, term] -> package_name_from_term(term) end)
    |> Enum.flat_map(fn
      {:ok, name} -> [name]
      :error -> []
    end)
    |> repeated_package_name()
  end

  defp extract_dependency_pair_conflict(message) do
    ~r/depends on "([^"]+)" and "[^"]+" depends on "([^"]+)"/
    |> Regex.scan(message)
    |> Enum.find_value(fn [_, left, right] ->
      with {:ok, left_name} <- package_name_from_term(left),
           {:ok, right_name} <- package_name_from_term(right),
           true <- left_name == right_name do
        left_name
      else
        _ -> nil
      end
    end)
  end

  defp extract_exact_version_conflict(message) do
    # Look for patterns like: "ms 2.0.0" and "ms 2.1.3" in the error
    case Regex.scan(~r/"(\S+) (\d+\.\d+\.\d+)"/, message) do
      [_, _ | _] = matches ->
        names = Enum.map(matches, fn [_, name, _] -> name end)
        repeated_package_name(names)

      _ ->
        nil
    end
  end

  defp package_name_from_term(term) do
    case Regex.run(~r/^(@[^\/\s]+\/[^\s]+|[^\s]+)\s+.+$/, term) do
      [_, name] -> {:ok, name}
      _ -> :error
    end
  end

  defp repeated_package_name(names) do
    names
    |> Enum.frequencies()
    |> Enum.filter(fn {_, count} -> count >= 2 end)
    |> Enum.map(&elem(&1, 0))
    |> List.first()
  end

  @doc false
  def get_original_deps(package) do
    ensure_cache()

    case :ets.lookup(@table, {:__original_deps__, package}) do
      [{_, deps}] -> deps
      [] -> %{}
    end
  end

  defp collect_nested_versions(package, _excluded) do
    # Before stripping, save the original dependency data
    # so the linker can look up which parents need which version
    save_original_deps(package)
    %{package => :nested}
  end

  defp save_original_deps(package) do
    parent_deps =
      :ets.foldl(
        fn
          {name, %{versions: _} = packument}, acc ->
            find_dependents(name, packument, package, acc)

          _, acc ->
            acc
        end,
        %{},
        @table
      )

    :ets.insert(@table, {{:__original_deps__, package}, parent_deps})
  end

  defp find_dependents(name, %{versions: versions}, package, acc) do
    Enum.reduce(versions, acc, fn {ver, info}, inner_acc ->
      case info |> version_dependencies() |> Map.get(package) do
        nil -> inner_acc
        range -> Map.put(inner_acc, "#{name}@#{ver}", range)
      end
    end)
  end

  defp find_dependents(_name, _packument, _package, acc), do: acc

  defp version_dependencies(%{dependencies: deps}) when is_map(deps), do: deps
  defp version_dependencies(%{"dependencies" => deps}) when is_map(deps), do: deps
  defp version_dependencies(_info), do: %{}

  @doc "Clear the packument cache."
  @spec clear_cache() :: :ok
  def clear_cache do
    if :ets.info(@table) != :undefined, do: :ets.delete_all_objects(@table)
    :ok
  end

  # --- HexSolver.Registry callbacks ---

  @impl true
  def versions(_repo, package) do
    case get_cached_packument(package) do
      {:ok, packument} -> {:ok, parse_sorted_versions(packument)}
      {:error, _} -> :error
    end
  end

  @impl true
  def dependencies(_repo, package, version) do
    case get_cached_packument(package) do
      {:ok, packument} -> deps_for_version(package, packument, to_string(version))
      {:error, _} -> :error
    end
  end

  @impl true
  def prefetch(packages) do
    packages
    |> Enum.map(fn {_repo, name} -> name end)
    |> Enum.reject(&cached?/1)
    |> Task.async_stream(&fetch_and_cache/1,
      max_concurrency: @prefetch_concurrency,
      timeout: @fetch_timeout
    )
    |> Stream.run()

    :ok
  end

  # --- Helpers ---

  defp parse_sorted_versions(packument) do
    packument.versions
    |> Enum.reject(fn {version_str, info} ->
      exotic_candidate?(packument.name, version_str, info)
    end)
    |> Enum.flat_map(fn {v, _info} ->
      case Version.parse(v) do
        {:ok, version} -> [version]
        :error -> []
      end
    end)
    |> Enum.sort(Version)
  end

  defp exotic_candidate?(package, version_str, info) do
    ExoticDeps.validate!(package, version_str, info)
    false
  rescue
    ExoticDeps.Error -> true
  end

  defp deps_for_version(package, packument, version_str) do
    excluded = get_excluded()

    case Map.get(packument.versions, version_str) do
      nil ->
        :error

      info ->
        ExoticDeps.validate!(package, version_str, info)
        overrides = get_overrides()

        deps =
          info
          |> solver_dependencies(package, excluded, overrides)

        {:ok, deps}
    end
  end

  defp solver_dependencies(info, self_name, excluded, overrides) do
    optional_dependency_names = Map.keys(info.optional_dependencies)

    required =
      info.dependencies
      |> Enum.reject(fn {name, _} ->
        name == self_name or name in optional_dependency_names or
          MapSet.member?(excluded, name)
      end)
      |> Enum.map(fn {name, range} -> {name, Map.get(overrides, name, range), false} end)

    optional =
      info.optional_dependencies
      |> NPM.PlatformOptional.select()
      |> Enum.reject(fn {name, _} ->
        name == self_name or MapSet.member?(excluded, name)
      end)
      |> Enum.map(fn {name, range} -> {name, Map.get(overrides, name, range), false} end)

    (required ++ optional)
    |> Enum.flat_map(&to_solver_dep/1)
  end

  defp to_solver_dep({name, range, optional?}) do
    case normalize_range(range) do
      {:ok, constraint} ->
        [
          %{
            repo: nil,
            name: name,
            constraint: constraint,
            optional: optional?,
            label: name,
            dependencies: []
          }
        ]

      :error ->
        []
    end
  end

  defp to_solver_dep({name, range}) do
    to_solver_dep({name, range, false})
  end

  defp normalize_range(range) when range in ["*", "", "latest"] do
    NPMSemver.to_hex_constraint(">=0.0.0")
  end

  defp normalize_range(range), do: NPMSemver.to_hex_constraint(range)

  # --- Cache ---

  defp ensure_cache do
    if :ets.whereis(@table) == :undefined do
      try do
        :ets.new(@table, [:named_table, :set, :public])
      rescue
        ArgumentError -> :ok
      end
    end
  end

  defp cached?(package) do
    :ets.info(@table) != :undefined and :ets.member(@table, package)
  end

  defp get_cached_packument(package) do
    ensure_cache()

    case :ets.lookup(@table, package) do
      [{^package, packument}] -> {:ok, packument}
      [] -> fetch_and_cache(package)
    end
  end

  defp fetch_and_cache(package) do
    case NPM.Registry.get_packument(package) do
      {:ok, packument} ->
        :ets.insert(@table, {package, packument})
        {:ok, packument}

      error ->
        error
    end
  end

  defp prefetch_tree(packages, depth \\ 0)
  defp prefetch_tree(_packages, depth) when depth > @max_prefetch_depth, do: :ok

  defp prefetch_tree(packages, depth) do
    to_fetch = Enum.reject(packages, &cached?/1)

    if to_fetch != [] do
      to_fetch
      |> Task.async_stream(&fetch_and_cache/1,
        max_concurrency: @prefetch_concurrency,
        timeout: @fetch_timeout
      )
      |> Stream.run()

      next_level =
        to_fetch
        |> Enum.flat_map(&dep_names_from_cache/1)
        |> Enum.uniq()
        |> Enum.reject(&cached?/1)

      if next_level != [], do: prefetch_tree(next_level, depth + 1)
    end
  end

  defp dep_names_from_cache(package) do
    case :ets.lookup(@table, package) do
      [{_, packument}] ->
        case latest_version_info(packument) do
          nil -> []
          info -> Map.keys(info.dependencies)
        end

      [] ->
        []
    end
  end

  defp latest_version_info(packument) do
    packument.versions
    |> Map.keys()
    |> Enum.flat_map(fn v ->
      case Version.parse(v) do
        {:ok, ver} -> [{v, ver}]
        :error -> []
      end
    end)
    |> Enum.reject(fn {_, ver} -> ver.pre != [] end)
    |> Enum.sort_by(&elem(&1, 1), {:desc, Version})
    |> case do
      [{latest_str, _} | _] -> Map.get(packument.versions, latest_str)
      [] -> nil
    end
  end
end
