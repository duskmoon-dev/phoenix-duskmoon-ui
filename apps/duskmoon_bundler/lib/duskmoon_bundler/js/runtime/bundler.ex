defmodule DuskmoonBundler.JS.Runtime.Bundler do
  @moduledoc "Bundles QuickBEAM runtime entry files and their dependencies."

  alias DuskmoonBundler.JS.Transforms.Specifiers

  @resolve_opts [
    extensions: DuskmoonBundler.JS.Extensions.node_resolvable(),
    conditions: DuskmoonBundler.JS.Resolution.browser_conditions()
  ]

  @spec bundle_file(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def bundle_file(entry_path, opts \\ []) do
    entry_path = Path.expand(entry_path)

    node_modules =
      Keyword.get(opts, :node_modules) ||
        NPM.Resolution.PackageResolver.find_node_modules(Path.dirname(entry_path))

    project_root = project_root(entry_path, node_modules)
    entry_label = posix_relative_to(entry_path, project_root)

    bundle_opts =
      opts
      |> Keyword.drop([:node_modules])
      |> Keyword.put_new(:entry, entry_label)

    case collect_modules(entry_path, project_root) do
      {:ok, files} -> OXC.bundle(files, bundle_opts)
      {:error, _} = error -> error
    end
  end

  defp collect_modules(entry_path, project_root) do
    case do_collect(entry_path, project_root, [], MapSet.new()) do
      {:ok, files, _seen} -> {:ok, Enum.reverse(files)}
      {:error, _} = error -> error
    end
  end

  defp do_collect(abs_path, project_root, files, seen) do
    if MapSet.member?(seen, abs_path) do
      {:ok, files, seen}
    else
      with {:ok, source} <- File.read(abs_path),
           {:ok, rewritten, resolved_paths} <- rewrite_and_resolve(source, abs_path, project_root) do
        label = posix_relative_to(abs_path, project_root)
        seen = MapSet.put(seen, abs_path)
        files = [{label, rewritten} | files]
        collect_deps(resolved_paths, project_root, files, seen)
      else
        {:error, reason} when is_atom(reason) -> {:error, {:file_read_error, abs_path, reason}}
        {:error, _} = error -> error
      end
    end
  end

  defp collect_deps([], _project_root, files, seen), do: {:ok, files, seen}

  defp collect_deps([path | rest], project_root, files, seen) do
    case do_collect(path, project_root, files, seen) do
      {:ok, files, seen} -> collect_deps(rest, project_root, files, seen)
      {:error, _} = error -> error
    end
  end

  defp rewrite_and_resolve(source, importer, project_root) do
    Specifiers.rewrite(source, importer, project_root, &rewrite_specifier/3)
  end

  defp rewrite_specifier(specifier, importer, project_root) do
    from_dir = Path.dirname(importer)

    case NPM.Resolution.PackageResolver.resolve(specifier, from_dir, @resolve_opts) do
      {:builtin, _} ->
        :skip

      {:ok, resolved_path} ->
        replacement =
          NPM.Resolution.PackageResolver.relative_import_path(
            importer,
            resolved_path,
            project_root
          )

        {:ok, replacement, resolved_path}

      :error ->
        throw({:error, {:module_not_found, specifier, "could not resolve"}})
    end
  end

  defp posix_relative_to(path, root) do
    path
    |> Path.relative_to(root)
    |> Path.split()
    |> Enum.join("/")
  end

  defp project_root(entry_path, nil), do: Path.dirname(entry_path)

  defp project_root(entry_path, node_modules) do
    [entry_path, node_modules]
    |> Enum.map(&Path.split/1)
    |> shared_segments()
    |> Path.join()
  end

  defp shared_segments([first | rest]) do
    rest_tuples = Enum.map(rest, &List.to_tuple/1)

    first
    |> Enum.with_index()
    |> Enum.take_while(fn {segment, index} ->
      Enum.all?(rest_tuples, fn t -> index < tuple_size(t) and elem(t, index) == segment end)
    end)
    |> Enum.map(&elem(&1, 0))
  end
end
