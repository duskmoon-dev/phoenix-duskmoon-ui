defmodule DuskmoonBundler.ChunkGraph do
  @moduledoc """
  Build a chunk graph from module dependencies.

  Splits modules into chunks based on dynamic import boundaries:
  - The entry chunk contains all modules reachable via static imports
  - Each dynamic `import()` creates a new async chunk
  - Modules shared between multiple chunks are extracted into common chunks

  ## Chunk types

    * `:entry` — the main bundle, loaded synchronously
    * `:async` — loaded on demand via dynamic import
    * `:common` — shared code extracted to avoid duplication
    * `:manual` — user-defined chunk via `chunks` config

  ## Manual chunks

  Users can control chunk boundaries via config:

      config :duskmoon_bundler,
        chunks: %{
          "vendor" => ["vue", "vue-router", "pinia"],
          "ui" => ["assets/src/components"]
        }

  Patterns match module paths: bare specifiers match package names in
  `node_modules`, while path patterns match against the full module path.
  """

  defmodule Chunk do
    @moduledoc """
    A JavaScript output chunk in the production dependency graph.

    Chunks group module paths by loading behavior: the entry chunk loads first,
    async chunks are loaded by dynamic imports, common chunks contain shared code,
    and manual chunks follow user configured boundaries.
    """

    defstruct id: "", type: :async, modules: [], imports: [], dynamic_imports: []

    @type t :: %__MODULE__{
            id: String.t(),
            type: :entry | :async | :common | :manual,
            modules: [String.t()],
            imports: [String.t()],
            dynamic_imports: [String.t()]
          }
  end

  defstruct chunks: %{}, module_to_chunk: %{}

  @type chunk :: Chunk.t()

  @doc """
  Build chunks from a module graph.

  `modules` is a list of `{abs_path, label, source}` tuples in dependency order.
  `dep_map` maps `abs_path => %{static: [abs_path], dynamic: [abs_path]}`.
  `entry_path` is the absolute path of the entry file.

  ## Options

    * `:manual_chunks` — map of chunk name to list of patterns,
      e.g. `%{"vendor" => ["vue", "vue-router"]}`
  """
  def build(entry_path, modules, dep_map, opts \\ []) do
    module_set = MapSet.new(modules, fn {path, _, _} -> path end)

    entry_modules = reachable_static(entry_path, dep_map, module_set)
    async_chunks = discover_async_chunks(entry_modules, dep_map, module_set)

    dynamic_entry_set = async_chunks |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    shared =
      [entry_modules | Enum.map(async_chunks, &elem(&1, 2))]
      |> shared_modules()
      |> Enum.reject(&MapSet.member?(dynamic_entry_set, &1))

    {entry_modules, common_chunk} =
      if shared == [] do
        {entry_modules, nil}
      else
        shared_set = MapSet.new(shared)
        trimmed = MapSet.difference(entry_modules, shared_set)
        {trimmed, shared_set}
      end

    async_chunks =
      if common_chunk do
        Enum.map(async_chunks, fn {entry, id, mods} ->
          {entry, id, MapSet.difference(mods, common_chunk)}
        end)
      else
        async_chunks
      end

    module_order = modules |> Enum.with_index() |> Map.new(fn {{path, _, _}, i} -> {path, i} end)
    order = fn set -> set |> MapSet.to_list() |> Enum.sort_by(&Map.get(module_order, &1, 0)) end

    chunks = %{
      "entry" => %Chunk{
        id: "entry",
        type: :entry,
        modules: order.(entry_modules),
        imports: if(common_chunk, do: ["common"], else: [])
      }
    }

    chunks =
      if common_chunk do
        Map.put(chunks, "common", %Chunk{
          id: "common",
          type: :common,
          modules: order.(common_chunk),
          imports: []
        })
      else
        chunks
      end

    {chunks, module_to_chunk} =
      Enum.reduce(async_chunks, {chunks, %{}}, fn {dyn_entry, id, mods}, {ch, m2c} ->
        cond do
          MapSet.size(mods) == 0 and common_member?(common_chunk, dyn_entry) ->
            {ch, Map.put(m2c, dyn_entry, "common")}

          MapSet.size(mods) == 0 ->
            {ch, m2c}

          true ->
            id = unique_id(id, ch)
            deps = if common_chunk, do: ["common"], else: []

            chunk = %Chunk{
              id: id,
              type: :async,
              modules: order.(mods),
              imports: deps
            }

            {Map.put(ch, id, chunk), Map.put(m2c, dyn_entry, id)}
        end
      end)

    manual_chunks = Keyword.get(opts, :manual_chunks, %{})

    {chunks, module_to_chunk} =
      apply_manual_chunks(chunks, module_to_chunk, manual_chunks, order, dynamic_entry_set)

    module_to_chunk =
      Enum.reduce(Map.values(chunks), module_to_chunk, fn chunk, acc ->
        Enum.reduce(chunk.modules, acc, fn mod, a -> Map.put_new(a, mod, chunk.id) end)
      end)

    chunks = put_chunk_links(chunks, dep_map, module_to_chunk)

    %__MODULE__{chunks: chunks, module_to_chunk: module_to_chunk}
  end

  defp common_member?(nil, _module), do: false
  defp common_member?(common_chunk, module), do: MapSet.member?(common_chunk, module)

  defp put_chunk_links(chunks, dep_map, module_to_chunk) do
    Map.new(chunks, fn {chunk_id, chunk} ->
      {imports, dynamic_imports} = chunk_links(chunk, dep_map, module_to_chunk)
      {chunk_id, %{chunk | imports: imports, dynamic_imports: dynamic_imports}}
    end)
  end

  defp chunk_links(chunk, dep_map, module_to_chunk) do
    Enum.reduce(chunk.modules, {[], []}, fn module, {imports, dynamic_imports} ->
      deps = Map.get(dep_map, module, %DuskmoonBundler.Builder.Dependencies{})

      imports = collect_chunk_links(deps.static, module_to_chunk, chunk.id, imports)

      dynamic_imports =
        collect_chunk_links(deps.dynamic, module_to_chunk, chunk.id, dynamic_imports)

      {imports, dynamic_imports}
    end)
  end

  defp collect_chunk_links(deps, module_to_chunk, current_chunk_id, links) do
    deps
    |> Enum.reduce(links, fn dep, acc ->
      case Map.get(module_to_chunk, dep) do
        nil -> acc
        ^current_chunk_id -> acc
        chunk_id -> append_unique(acc, chunk_id)
      end
    end)
  end

  defp apply_manual_chunks(chunks, module_to_chunk, manual_chunks, _order, _dynamic_entry_set)
       when map_size(manual_chunks) == 0 do
    {chunks, module_to_chunk}
  end

  defp apply_manual_chunks(chunks, module_to_chunk, manual_chunks, order, dynamic_entry_set) do
    all_modules =
      chunks
      |> Map.values()
      |> Enum.flat_map(& &1.modules)

    assignments =
      Enum.reduce(all_modules, %{}, fn mod_path, acc ->
        if MapSet.member?(dynamic_entry_set, mod_path) do
          acc
        else
          case find_manual_chunk(mod_path, manual_chunks) do
            nil -> acc
            chunk_name -> Map.update(acc, chunk_name, [mod_path], &[mod_path | &1])
          end
        end
      end)

    Enum.reduce(assignments, {chunks, module_to_chunk}, fn {chunk_name, mod_paths}, {ch, m2c} ->
      mod_set = MapSet.new(mod_paths)

      ch =
        Map.new(ch, fn {id, chunk} ->
          {id, %{chunk | modules: Enum.reject(chunk.modules, &MapSet.member?(mod_set, &1))}}
        end)

      ch = Map.reject(ch, fn {id, chunk} -> chunk.modules == [] and id != "entry" end)

      entry_imports = append_unique(ch["entry"].imports, chunk_name)
      ch = put_in(ch["entry"].imports, entry_imports)

      manual = %Chunk{
        id: chunk_name,
        type: :manual,
        modules: order.(MapSet.new(mod_paths)),
        imports: []
      }

      m2c =
        Enum.reduce(mod_paths, m2c, fn mod, a ->
          Map.put(a, mod, chunk_name)
        end)

      {Map.put(ch, chunk_name, manual), m2c}
    end)
  end

  defp discover_async_chunks(entry_modules, dep_map, module_set) do
    entry_modules
    |> dynamic_entries(dep_map, module_set)
    |> do_discover_async_chunks(dep_map, module_set, MapSet.new(), [])
    |> Enum.reverse()
  end

  defp do_discover_async_chunks([], _dep_map, _module_set, _seen, chunks), do: chunks

  defp do_discover_async_chunks([entry | rest], dep_map, module_set, seen, chunks) do
    if MapSet.member?(seen, entry) do
      do_discover_async_chunks(rest, dep_map, module_set, seen, chunks)
    else
      modules = reachable_static(entry, dep_map, module_set)
      chunk = {entry, entry |> Path.basename() |> Path.rootname(), modules}
      nested = dynamic_entries(modules, dep_map, module_set)

      do_discover_async_chunks(rest ++ nested, dep_map, module_set, MapSet.put(seen, entry), [
        chunk | chunks
      ])
    end
  end

  defp dynamic_entries(modules, dep_map, module_set) do
    modules
    |> Enum.flat_map(fn module ->
      dep_map |> Map.get(module, %DuskmoonBundler.Builder.Dependencies{}) |> Map.get(:dynamic, [])
    end)
    |> Enum.filter(&MapSet.member?(module_set, &1))
    |> Enum.uniq()
  end

  defp shared_modules(module_sets) do
    module_sets
    |> Enum.reduce(%{}, fn modules, counts ->
      Enum.reduce(modules, counts, fn module, acc -> Map.update(acc, module, 1, &(&1 + 1)) end)
    end)
    |> Enum.filter(fn {_module, count} -> count > 1 end)
    |> Enum.map(fn {module, _count} -> module end)
  end

  defp append_unique(items, item) do
    if item in items do
      items
    else
      items |> Enum.reverse() |> then(&Enum.reverse([item | &1]))
    end
  end

  defp find_manual_chunk(mod_path, manual_chunks) do
    Enum.find_value(manual_chunks, fn {chunk_name, patterns} ->
      if Enum.any?(patterns, &matches_pattern?(mod_path, &1)) do
        chunk_name
      end
    end)
  end

  defp matches_pattern?(mod_path, pattern) do
    if path_pattern?(pattern) do
      expanded = Path.expand(pattern)
      String.starts_with?(mod_path, expanded <> "/") or mod_path == expanded
    else
      String.contains?(mod_path, "/node_modules/#{pattern}/") or
        String.ends_with?(mod_path, "/node_modules/#{pattern}")
    end
  end

  defp path_pattern?(pattern) do
    String.starts_with?(pattern, "/") or
      String.starts_with?(pattern, "./") or
      String.starts_with?(pattern, "../") or
      String.contains?(pattern, "/")
  end

  defp reachable_static(start, dep_map, module_set) do
    do_reachable([start], dep_map, module_set, MapSet.new())
  end

  defp do_reachable([], _dep_map, _module_set, visited), do: visited

  defp do_reachable([path | rest], dep_map, module_set, visited) do
    if MapSet.member?(visited, path) or not MapSet.member?(module_set, path) do
      do_reachable(rest, dep_map, module_set, visited)
    else
      visited = MapSet.put(visited, path)

      static_deps =
        dep_map |> Map.get(path, %DuskmoonBundler.Builder.Dependencies{}) |> Map.get(:static, [])

      do_reachable(static_deps ++ rest, dep_map, module_set, visited)
    end
  end

  defp unique_id(id, chunks) do
    if Map.has_key?(chunks, id) do
      unique_id(id <> "_", chunks)
    else
      id
    end
  end
end
