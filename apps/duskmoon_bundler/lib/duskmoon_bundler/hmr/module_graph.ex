defmodule DuskmoonBundler.HMR.ModuleGraph do
  @moduledoc """
  ETS-backed dev-server module graph.

  The graph is keyed by served URL, resolved module id, and source file. It is
  the primary source for HMR boundary lookup: served modules record their
  resolved imports, importers, query variants, and whether the module accepts
  itself with `import.meta.hot.accept()`.
  """

  @table :duskmoon_bundler_hmr_module_graph

  defmodule Node do
    @moduledoc "A dev-server module graph node."

    defstruct url: nil,
              id: nil,
              file: nil,
              type: :js,
              imports: MapSet.new(),
              importers: MapSet.new(),
              self_accepting: false,
              last_invalidated_at: nil
  end

  @doc "Create the module graph ETS table."
  def create_table, do: DuskmoonBundler.ETS.create_named_set(@table)

  @doc "Upsert a module and update importer links for its resolved imports."
  def update_module(url, id, file, imports, opts \\ []) do
    old_node = get_by_id(id)
    remove_old_importer_links(old_node, id)

    node = %Node{
      url: url,
      id: id,
      file: file,
      type: Keyword.get(opts, :type, module_type(url)),
      imports: MapSet.new(imports),
      importers: existing_importers(id, old_node),
      self_accepting: Keyword.get(opts, :self_accepting, false)
    }

    put_node(node)
    Enum.each(node.imports, &put_importer_link(&1, id))
    :ok
  end

  def get_by_url(url), do: lookup({:url, url})
  def get_by_id(id), do: lookup({:id, id})

  def get_by_file(file) do
    case :ets.lookup(@table, {:file, file}) do
      [{_, ids}] -> Enum.flat_map(ids, &List.wrap(get_by_id(&1)))
      [] -> []
    end
  end

  @doc "Mark every graph node for a file as invalidated and return affected nodes."
  def invalidate_file(file, timestamp \\ System.system_time(:millisecond)) do
    nodes = get_by_file(file)

    Enum.each(nodes, fn node ->
      put_node(%{node | last_invalidated_at: timestamp})
    end)

    nodes
  end

  @doc "Remove all nodes for a file and unlink them from importers/imports."
  def remove_file(file) do
    file
    |> get_by_file()
    |> Enum.each(&remove_node/1)

    :ets.delete(@table, {:file, file})
    :ok
  end

  def clear do
    DuskmoonBundler.ETS.clear(@table)
  end

  defp put_node(node) do
    :ets.insert(@table, {{:url, node.url}, node.id})
    :ets.insert(@table, {{:id, node.id}, node})
    :ets.insert(@table, {{:file, node.file}, file_ids(node.file, node.id)})
  end

  defp existing_importers(id, nil), do: existing_importers(id, %Node{})

  defp existing_importers(id, old_node) do
    @table
    |> :ets.tab2list()
    |> Enum.reduce(old_node.importers, fn
      {{:id, importer_id}, %Node{imports: imports}}, acc when importer_id != id ->
        if MapSet.member?(imports, id), do: MapSet.put(acc, importer_id), else: acc

      _entry, acc ->
        acc
    end)
  end

  defp put_importer_link(import_id, importer_id) do
    case get_by_id(import_id) do
      nil -> :ok
      node -> put_node(%{node | importers: MapSet.put(node.importers, importer_id)})
    end
  end

  defp remove_old_importer_links(nil, _id), do: :ok

  defp remove_old_importer_links(node, id) do
    Enum.each(node.imports, fn import_id ->
      case get_by_id(import_id) do
        nil -> :ok
        imported -> put_node(%{imported | importers: MapSet.delete(imported.importers, id)})
      end
    end)
  end

  defp remove_node(node) do
    remove_old_importer_links(node, node.id)

    Enum.each(node.importers, fn importer_id ->
      case get_by_id(importer_id) do
        nil -> :ok
        importer -> put_node(%{importer | imports: MapSet.delete(importer.imports, node.id)})
      end
    end)

    :ets.delete(@table, {:url, node.url})
    :ets.delete(@table, {:id, node.id})
  end

  defp file_ids(file, id) do
    existing =
      case :ets.lookup(@table, {:file, file}) do
        [{_, ids}] -> ids
        [] -> MapSet.new()
      end

    MapSet.put(existing, id)
  end

  defp lookup(key) do
    case :ets.lookup(@table, key) do
      [{_, %Node{} = node}] -> node
      [{_, id}] when elem(key, 0) == :url -> get_by_id(id)
      [] -> nil
    end
  end

  defp module_type(url) do
    cond do
      String.contains?(url, ".css") -> :css
      DuskmoonBundler.Assets.asset?(url) -> :asset
      true -> :js
    end
  end
end
