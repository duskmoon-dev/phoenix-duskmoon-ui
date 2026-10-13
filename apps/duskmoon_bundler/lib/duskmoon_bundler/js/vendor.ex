defmodule DuskmoonBundler.JS.Vendor do
  @moduledoc """
  Pre-bundle vendor (node_modules) dependencies for dev mode.

  Follows application entries and their local static imports, identifies bare specifiers
  (non-relative, non-URL), resolves them through module directories, and
  bundles each into a single ESM file with `OXC.bundle/2`.

  CJS packages (e.g. React) are automatically converted to ESM during
  bundling. `process.env.NODE_ENV` is replaced with `"development"`
  so conditional CJS branches resolve correctly.

  Bundled files are cached on disk in the Mix build root under
  `_build/<environment>/duskmoon_bundler/vendor/`.
  """

  require Logger

  alias OXC.Bundle

  defp cache_dir do
    Path.join(build_root(), "duskmoon_bundler/vendor")
  end

  defp build_root do
    if Mix.Project.get() do
      Mix.Project.build_path()
    else
      Path.expand("_build")
    end
  end

  @doc """
  Follow application entries and pre-bundle their reachable static npm imports.

  Returns a map of `specifier → vendor_path` for import rewriting.

  ## Options

    * `:root` — source directory containing the application
    * `:entry` — entry path or list of paths; defaults to `app.*` in root, `js/` or `src/`
    * `:aliases` — import aliases used by the application
    * `:node_modules` — path to node_modules (default: auto-detect)
    * `:resolve_dirs` — additional package directories to resolve from
    * `:vendor_source` — specifiers to serve as source ESM with import rewriting
    * `:force` — rebuild even if cached (default: `false`)
  """
  @spec prebundle(keyword()) :: {:ok, %{String.t() => String.t()}} | {:error, term()}
  def prebundle(opts) do
    root = Keyword.fetch!(opts, :root)
    force = Keyword.get(opts, :force, false)
    node_modules = opts[:node_modules] || NPM.Resolution.PackageResolver.find_node_modules(root)
    module_dirs = module_dirs(node_modules, Keyword.get(opts, :resolve_dirs, []))

    plugins = Keyword.get(opts, :plugins, [])
    module_types = Keyword.get(opts, :module_types, %{})
    source_specifiers = Keyword.get(opts, :vendor_source, [])

    with {:ok, specifiers} <- scan_bare_imports(root, plugins, opts),
         :ok <- ensure_cache_dir() do
      specifiers =
        specifiers
        |> Enum.map(&DuskmoonBundler.PluginRunner.prebundle_alias(plugins, &1))
        |> Enum.uniq()

      prebundle_vendors(specifiers, module_dirs, force, plugins, module_types, source_specifiers)
    end
  end

  @doc """
  Bundle a single vendor specifier on demand.

  Used by the dev server when a `/@vendor/` request arrives for a
  specifier that wasn't caught by `prebundle/1` (e.g. transitive
  dependency, or newly added import).
  """
  @spec bundle_on_demand(String.t(), String.t() | nil, keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def bundle_on_demand(specifier, node_modules, opts \\ []) do
    ensure_cache_dir()

    opts =
      if Keyword.keyword?(opts), do: Keyword.put(opts, :node_modules, node_modules), else: opts

    {plugins, resolve_dirs, module_types, source_specifiers, browser_token} =
      normalize_on_demand_opts(opts)

    module_dirs = module_dirs(node_modules, resolve_dirs)
    specifier = DuskmoonBundler.PluginRunner.prebundle_alias(plugins, specifier)
    root = if Keyword.keyword?(opts), do: opts[:root]

    result =
      if source_vendor?(specifier, source_specifiers) do
        source_vendor(
          specifier,
          module_dirs,
          false,
          plugins,
          module_types,
          source_specifiers,
          browser_token
        )
      else
        :global.trans({{__MODULE__, cache_dir()}, self()}, fn ->
          known = known_vendor_specifiers(module_dirs, plugins, module_types, source_specifiers)

          cond do
            is_binary(root) and Enum.all?(known, &source_vendor?(&1, source_specifiers)) ->
              # Build the initial static application graph before any of its
              # modules escape to the browser. Dynamic imports remain lazy.
              with {:ok, specifiers} <- scan_bare_imports(root, plugins, opts) do
                specifiers =
                  [specifier | specifiers]
                  |> Enum.map(&DuskmoonBundler.PluginRunner.prebundle_alias(plugins, &1))
                  |> Enum.uniq()
                  |> Enum.reject(&source_vendor?(&1, source_specifiers))

                vendor_map = Map.new(specifiers, &{&1, cache_path(&1)})

                with {:ok, vendors} <-
                       bundle_vendors(
                         specifiers,
                         module_dirs,
                         plugins,
                         module_types,
                         source_specifiers,
                         vendor_map,
                         false
                       ) do
                  {:ok, Map.fetch!(vendors, specifier)}
                end
              end

            specifier in known and
                not cache_fresh?(
                  specifier,
                  module_dirs,
                  plugins,
                  module_types,
                  source_specifiers,
                  browser_token
                ) ->
              # A missing/stale entry must retain the shared graph it belonged to.
              with {:ok, vendors} <-
                     prebundle_vendors(
                       known,
                       module_dirs,
                       true,
                       plugins,
                       module_types,
                       source_specifiers
                     ) do
                {:ok, Map.fetch!(vendors, specifier)}
              end

            true ->
              bundle_vendor(
                specifier,
                module_dirs,
                false,
                plugins,
                module_types,
                source_specifiers,
                browser_token,
                if(Keyword.keyword?(opts), do: opts[:browser_hash])
              )
          end
        end)
      end

    case result do
      {:ok, path} -> read_vendor_output(File.read(path), opts)
      {:error, _} = error -> error
    end
  end

  @doc """
  Get the URL path for a vendor module.
  """
  @spec vendor_url(String.t()) :: String.t()
  def vendor_url(specifier), do: "/@vendor/#{encode_specifier(specifier)}.js"

  @doc "Get the URL path for a vendor module with a cache-busting browser hash."
  @spec vendor_url(String.t(), keyword()) :: String.t()
  def vendor_url(specifier, opts) do
    specifier
    |> vendor_url()
    |> DuskmoonBundler.URL.append_query("v=#{browser_hash_for_url(opts)}")
    |> append_browser_token(Keyword.get(opts, :browser_token))
  end

  @doc "Return whether a request browser hash matches the current optimized dependency state."
  @spec current_browser_hash?(String.t() | nil, keyword()) :: boolean()
  def current_browser_hash?(nil, _opts), do: true
  def current_browser_hash?(hash, opts), do: hash == browser_hash_for_url(opts)

  @doc "Return the current browser hash for optimized dependency requests."
  @spec browser_hash(keyword()) :: String.t()
  def browser_hash(opts) do
    {plugins, resolve_dirs, module_types, source_specifiers, _browser_token} =
      normalize_on_demand_opts(opts)

    node_modules = Keyword.get(opts, :node_modules)
    module_dirs = module_dirs(node_modules, resolve_dirs)

    browser_hash(module_dirs, plugins, module_types, source_specifiers)
  end

  defp browser_hash_for_url(opts) do
    case Keyword.get(opts, :browser_hash) do
      hash when is_binary(hash) and hash != "" -> hash
      _ -> browser_hash(opts)
    end
  end

  defp browser_hash(module_dirs, plugins, module_types, source_specifiers) do
    :crypto.hash(
      :sha256,
      :erlang.term_to_binary(
        browser_signature(module_dirs, plugins, module_types, source_specifiers)
      )
    )
    |> Base.encode16(case: :lower)
    |> binary_part(0, 8)
  end

  @doc """
  Read a pre-bundled vendor file by specifier.
  """
  @spec read(String.t()) :: {:ok, String.t()} | {:error, :not_found}
  def read(specifier), do: read_cached(specifier)

  @doc "Read a pre-bundled vendor file when its cache signature matches the current options."
  @spec read(String.t(), keyword()) :: {:ok, String.t()} | {:error, :not_found}
  def read("chunks/" <> _ = specifier, opts),
    do: read_vendor_output(read_cached(specifier), opts)

  def read(specifier, opts) do
    {plugins, resolve_dirs, module_types, source_specifiers, browser_token} =
      normalize_on_demand_opts(opts)

    node_modules = Keyword.get(opts, :node_modules)
    module_dirs = module_dirs(node_modules, resolve_dirs)
    specifier = DuskmoonBundler.PluginRunner.prebundle_alias(plugins, specifier)

    if cache_fresh?(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
      read_vendor_output(read_cached(specifier), opts)
    else
      {:error, :not_found}
    end
  end

  defp read_vendor_output({:ok, code}, opts) do
    if Keyword.keyword?(opts) and String.contains?(code, "/@vendor/") do
      OXC.rewrite_specifiers(code, "vendor.js", fn
        "/@vendor/" <> _ = specifier ->
          uri = URI.parse(specifier)
          query = URI.decode_query(uri.query || "") |> Map.drop(["v", "t"])

          url =
            URI.to_string(%{uri | query: nil})
            |> DuskmoonBundler.URL.append_query("v=#{browser_hash_for_url(opts)}")
            |> append_browser_token(opts[:browser_token])

          url =
            if map_size(query) == 0,
              do: url,
              else: DuskmoonBundler.URL.append_query(url, URI.encode_query(query))

          {:rewrite, url}

        _ ->
          :keep
      end)
    else
      {:ok, code}
    end
  end

  defp read_vendor_output(error, _opts), do: error

  # ── Scanning ──────────────────────────────────────────────────────

  defp scan_bare_imports(root, plugins, opts) do
    entries =
      case opts[:entry] do
        nil ->
          for dir <- [root, Path.join(root, "js"), Path.join(root, "src")],
              ext <- DuskmoonBundler.JS.Extensions.scannable(plugins),
              path = Path.join(dir, "app" <> ext),
              File.regular?(path),
              do: path

        entry ->
          entry |> List.wrap() |> Enum.map(&Path.expand/1)
      end

    ctx = %DuskmoonBundler.Builder.Context{
      plugins: plugins,
      aliases: Keyword.get(opts, :aliases, %{})
    }

    scan_source_files(entries, ctx, MapSet.new(), MapSet.new())
  end

  defp scan_source_files([], _ctx, _seen, specifiers), do: {:ok, MapSet.to_list(specifiers)}

  defp scan_source_files([module_id | rest], ctx, seen, specifiers) do
    {file, _query} = DuskmoonBundler.URL.split_query(module_id)

    if MapSet.member?(seen, file) do
      scan_source_files(rest, ctx, seen, specifiers)
    else
      with {:ok, source} <- File.read(file),
           {:ok, imports} <- extract_imports(source, file, ctx.plugins, :static),
           {:ok, files, specifiers} <- scan_imports(imports, file, ctx, specifiers) do
        scan_source_files(files ++ rest, ctx, MapSet.put(seen, file), specifiers)
      else
        {:error, reason} -> {:error, {:scan_error, file, reason}}
      end
    end
  end

  defp scan_imports(imports, importer, ctx, specifiers) do
    Enum.reduce_while(imports, {:ok, [], specifiers}, fn specifier, {:ok, files, specs} ->
      {path_specifier, _query} = DuskmoonBundler.URL.split_query(specifier)

      if NPM.Resolution.PackageResolver.bare?(path_specifier) and
           DuskmoonBundler.JS.Resolver.resolve(path_specifier, ctx.aliases) == :pass do
        {:cont, {:ok, files, MapSet.put(specs, path_specifier)}}
      else
        case DuskmoonBundler.Builder.Resolver.resolve(specifier, importer, ctx) do
          {:ok, resolved} ->
            {path, _query} = DuskmoonBundler.URL.split_query(resolved)

            files =
              if Path.extname(path) in DuskmoonBundler.JS.Extensions.scannable(ctx.plugins),
                do: [resolved | files],
                else: files

            {:cont, {:ok, files, specs}}

          :skip ->
            {:cont, {:ok, files, specs}}

          {:error, _} = error ->
            {:halt, error}
        end
      end
    end)
  end

  defp extract_imports(source, path, plugins, mode) do
    case DuskmoonBundler.PluginRunner.extract_imports(plugins, path, source, []) do
      {:ok, %{imports: imports}} ->
        {:ok, for({type, spec} <- imports, mode == :all or type == :static, do: spec)}

      nil when mode == :static ->
        with {:ok, ast} <- OXC.parse(source, Path.basename(path)) do
          {:ok,
           for(
             %{type: type, source: %{value: specifier}} <- ast.body,
             type in [:import_declaration, :export_named_declaration, :export_all_declaration],
             do: specifier
           )}
        end

      nil ->
        OXC.select(source, Path.basename(path), :import_specifiers)

      {:error, _} = error ->
        error
    end
  end

  # ── Bundling ──────────────────────────────────────────────────────

  defp prebundle_vendors([], _module_dirs, _force, _plugins, _module_types, _source_specifiers),
    do: {:ok, %{}}

  defp prebundle_vendors(specifiers, module_dirs, force, plugins, module_types, source_specifiers) do
    vendor_map = Map.new(specifiers, &{&1, cache_path(&1)})

    if not force and
         Enum.all?(
           specifiers,
           &cache_fresh?(&1, module_dirs, plugins, module_types, source_specifiers, nil)
         ) do
      {:ok, vendor_map}
    else
      {source_specs, bundle_specs} =
        Enum.split_with(specifiers, &source_vendor?(&1, source_specifiers))

      with {:ok, source_map} <-
             source_vendors(
               source_specs,
               module_dirs,
               force,
               plugins,
               module_types,
               source_specifiers
             ),
           {:ok, bundle_map} <-
             safe_bundle_vendors(
               bundle_specs,
               module_dirs,
               plugins,
               module_types,
               source_specifiers,
               vendor_map
             ) do
        {:ok, Map.merge(source_map, bundle_map)}
      end
    end
  end

  defp source_vendors([], _module_dirs, _force, _plugins, _module_types, _source_specifiers),
    do: {:ok, %{}}

  defp source_vendors(specifiers, module_dirs, force, plugins, module_types, source_specifiers) do
    Enum.reduce_while(specifiers, {:ok, %{}}, fn specifier, {:ok, acc} ->
      case source_vendor(
             specifier,
             module_dirs,
             force,
             plugins,
             module_types,
             source_specifiers,
             nil
           ) do
        {:ok, path} -> {:cont, {:ok, Map.put(acc, specifier, path)}}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp safe_bundle_vendors(
         [],
         _module_dirs,
         _plugins,
         _module_types,
         _source_specifiers,
         _vendor_map
       ),
       do: {:ok, %{}}

  defp safe_bundle_vendors(
         specifiers,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         vendor_map
       ) do
    bundle_vendors(specifiers, module_dirs, plugins, module_types, source_specifiers, vendor_map)
  rescue
    exception ->
      Logger.debug(
        "[DuskmoonBundler] Vendor prebundle fell back to per-package bundling: #{Exception.message(exception)}"
      )

      fallback_bundle_vendors(specifiers, module_dirs, plugins, module_types, source_specifiers)
  end

  defp bundle_vendors(
         specifiers,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         vendor_map,
         fallback? \\ true
       ) do
    entries =
      Enum.reduce_while(specifiers, {:ok, []}, fn specifier, {:ok, entries} ->
        case bundle_entry_for(specifier, module_dirs, plugins) do
          {:ok, specifier, entry} -> {:cont, {:ok, [{specifier, entry} | entries]}}
          {:error, _} = error -> {:halt, error}
        end
      end)

    with {:ok, entries} <- entries do
      run_vendor_bundle(
        Enum.reverse(entries),
        specifiers,
        module_dirs,
        plugins,
        module_types,
        source_specifiers,
        vendor_map,
        fallback?
      )
    end
  end

  defp run_vendor_bundle(
         entries,
         specifiers,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         vendor_map,
         fallback?
       ) do
    bundled_specifiers = Enum.map(entries, fn {specifier, _entry} -> specifier end)
    bundle_entries = Enum.map(entries, fn {_specifier, entry} -> entry end)

    bundle =
      Bundle.new()
      |> Bundle.entries(bundle_entries)
      |> Bundle.cwd(project_root(module_dirs))
      |> Bundle.outdir(cache_dir())
      |> Bundle.format(:esm)
      |> Bundle.resolve(
        conditions: DuskmoonBundler.JS.Resolution.browser_conditions(),
        modules: ["node_modules" | module_dirs]
      )
      |> Bundle.transform(
        define: %{"process.env.NODE_ENV" => ~s("development")},
        module_types: module_types
      )
      |> Bundle.output(
        entry_file_names: "[name].js",
        chunk_file_names: "chunks/[name]-[hash].js",
        exports: :named,
        preserve_entry_signatures: :strict
      )

    case Bundle.run(bundle) do
      {:ok, result} ->
        record_bundle_dependencies(
          bundled_specifiers,
          entries,
          result,
          module_dirs,
          plugins,
          module_types,
          source_specifiers
        )

        write_vendor_cache_metadata(
          bundled_specifiers,
          module_dirs,
          plugins,
          module_types,
          source_specifiers
        )

        {:ok, Map.take(vendor_map, bundled_specifiers)}

      {:error, errors} ->
        Logger.debug("[DuskmoonBundler] Vendor multi-entry prebundle failed: #{inspect(errors)}")

        if fallback?,
          do:
            fallback_bundle_vendors(
              specifiers,
              module_dirs,
              plugins,
              module_types,
              source_specifiers
            ),
          else: {:error, errors}
    end
  end

  defp write_vendor_cache_metadata(
         specifiers,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token \\ nil
       ) do
    Enum.each(specifiers, fn specifier ->
      if File.regular?(cache_path(specifier)) do
        File.write!(
          cache_meta_path(specifier),
          cache_signature(
            specifier,
            module_dirs,
            plugins,
            module_types,
            source_specifiers,
            browser_token
          )
        )
      end
    end)
  end

  defp fallback_bundle_vendors(specifiers, module_dirs, plugins, module_types, source_specifiers) do
    {vendor_map, errors} =
      Enum.reduce(specifiers, {%{}, []}, fn specifier, {acc, errors} ->
        case bundle_vendor(
               specifier,
               module_dirs,
               false,
               plugins,
               module_types,
               source_specifiers,
               nil
             ) do
          {:ok, path} -> {Map.put(acc, specifier, path), errors}
          {:error, reason} -> {acc, [{specifier, reason} | errors]}
        end
      end)

    case errors do
      [] -> {:ok, vendor_map}
      errors -> {:error, {:vendor_bundle_failed, Enum.reverse(errors)}}
    end
  end

  defp bundle_entry_for(specifier, module_dirs, plugins) do
    case DuskmoonBundler.PluginRunner.prebundle_entry(plugins, specifier) do
      {:source, filename, source} ->
        {:ok, specifier, %{name: encode_specifier(specifier), import: filename, source: source}}

      {:proxy, filename, _opts} = entry ->
        {:ok, specifier,
         %{
           name: encode_specifier(specifier),
           import: filename,
           source: proxy_source(entry, module_dirs)
         }}

      nil ->
        case resolve_package_entry(specifier, module_dirs) do
          {:ok, entry_path} ->
            names = DuskmoonBundler.JS.PrebundleEntry.CommonJS.exports(entry_path)

            if names == [] do
              {:ok, specifier, %{name: encode_specifier(specifier), import: entry_path}}
            else
              source =
                DuskmoonBundler.JS.PrebundleEntry.source(
                  {:proxy, "entry.js",
                   imports: [
                     DuskmoonBundler.JS.PrebundleEntry.Import.default("entry", from: entry_path)
                   ],
                   exports: [
                     DuskmoonBundler.JS.PrebundleEntry.Export.default("entry"),
                     DuskmoonBundler.JS.PrebundleEntry.Export.named_from(entry_path, names)
                   ]}
                )

              {:ok, specifier,
               %{
                 name: encode_specifier(specifier),
                 import: "__duskmoon_cjs__#{encode_specifier(specifier)}.mjs",
                 source: source
               }}
            end

          :error ->
            {:error, {:not_found, specifier}}
        end
    end
  end

  defp proxy_source({:proxy, filename, opts}, module_dirs) do
    {exports, _names} =
      Enum.reduce(Keyword.get(opts, :exports, []), {[], MapSet.new()}, fn export,
                                                                          {exports, seen} ->
        case export do
          %{all_from: specifier} when is_binary(specifier) ->
            with {:ok, path} <- resolve_package_entry(specifier, module_dirs),
                 [_ | _] = names <- DuskmoonBundler.JS.PrebundleEntry.CommonJS.exports(path) do
              names = Enum.reject(names, &MapSet.member?(seen, &1))

              next =
                if names == [],
                  do: [],
                  else: [DuskmoonBundler.JS.PrebundleEntry.Export.named_from(specifier, names)]

              {exports ++ next, MapSet.union(seen, MapSet.new(names))}
            else
              _ -> {exports ++ [export], seen}
            end

          _ ->
            {exports ++ [export], seen}
        end
      end)

    DuskmoonBundler.JS.PrebundleEntry.source(
      {:proxy, filename, Keyword.put(opts, :exports, exports)}
    )
  end

  defp bundle_vendor(
         specifier,
         module_dirs,
         force,
         plugins,
         module_types,
         source_specifiers,
         browser_token,
         fixed_browser_hash \\ nil
       ) do
    path = cache_path(specifier)

    if not force and File.regular?(path) and
         cache_fresh?(
           specifier,
           module_dirs,
           plugins,
           module_types,
           source_specifiers,
           browser_token
         ) do
      {:ok, path}
    else
      do_bundle_vendor(
        specifier,
        module_dirs,
        path,
        plugins,
        module_types,
        source_specifiers,
        browser_token,
        fixed_browser_hash
      )
    end
  end

  defp known_vendor_specifiers(module_dirs, plugins, module_types, source_specifiers) do
    case File.ls(dependency_dir(module_dirs, plugins, module_types, source_specifiers)) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".meta"))
        |> Enum.map(&(Path.rootname(&1) |> decode_specifier()))
        |> Enum.filter(&match?({:ok, _, _}, bundle_entry_for(&1, module_dirs, plugins)))
        |> Enum.sort()

      _ ->
        []
    end
  end

  defp known_vendor_externals(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token,
         fixed_browser_hash
       ) do
    module_dirs
    |> known_vendor_specifiers(plugins, module_types, source_specifiers)
    |> Enum.reject(&(&1 == specifier or not File.regular?(cache_path(&1))))
    |> Enum.flat_map(fn known ->
      {references, default_export?} =
        case DuskmoonBundler.PluginRunner.prebundle_entry(plugins, known) do
          {:proxy, _, opts} = entry ->
            {:ok, imports} =
              OXC.select(
                DuskmoonBundler.JS.PrebundleEntry.source(entry),
                "entry.js",
                :import_specifiers
              )

            {imports, Enum.any?(Keyword.get(opts, :exports, []), &is_binary(&1.default))}

          _ ->
            {[known], true}
        end

      Enum.flat_map(references, fn reference ->
        case resolve_package_entry(reference, module_dirs) do
          {:ok, path} ->
            [
              {path,
               %{
                 url:
                   vendor_url(known,
                     browser_hash:
                       fixed_browser_hash ||
                         browser_hash(module_dirs, plugins, module_types, source_specifiers),
                     browser_token: browser_token
                   ),
                 default:
                   default_export? and reference == known and
                     DuskmoonBundler.JS.PrebundleEntry.CommonJS.common_js?(path)
               }}
            ]

          _ ->
            []
        end
      end)
    end)
    |> Map.new()
  end

  defp rewrite_external_vendors(result, externals) when map_size(externals) == 0, do: result

  defp rewrite_external_vendors(result, externals) do
    outputs =
      Enum.map(result.outputs, fn output ->
        # Rolldown leaves require(external) calls in bundled CommonJS dependencies.
        # Resolve those statically through ESM imports instead of a browser require.
        calls = output.code |> OXC.parse!(output.file_name) |> external_require_calls(externals)

        bindings =
          calls
          |> Enum.map(& &1.specifier)
          |> Enum.uniq()
          |> Enum.with_index()
          |> Map.new(fn {specifier, index} ->
            {specifier, "__duskmoon_vendor_external_#{index}"}
          end)

        imports =
          Enum.map(bindings, fn {specifier, binding} ->
            "import * as #{binding} from #{Jason.encode!(externals[specifier].url)};\n"
          end)

        patches =
          Enum.map(calls, fn call ->
            binding = Map.fetch!(bindings, call.specifier)

            expression =
              if externals[call.specifier].default,
                do: "#{binding}.default",
                else: binding

            %{start: call.start, end: call.end, change: expression}
          end)

        code = IO.iodata_to_binary(imports) <> OXC.patch_string(output.code, patches)

        code =
          OXC.rewrite_specifiers!(code, output.file_name, fn specifier ->
            case Map.fetch(externals, specifier) do
              {:ok, external} -> {:rewrite, external.url}
              :error -> :keep
            end
          end)

        File.write!(output.path, code)
        %{output | code: code}
      end)

    %{result | outputs: outputs}
  end

  defp external_require_calls(node, externals) when is_map(node) do
    calls =
      case node do
        %{
          type: :call_expression,
          callee: %{name: name},
          arguments: [%{value: specifier}],
          start: start,
          end: finish
        }
        when is_binary(name) and is_binary(specifier) ->
          if (name == "require" or String.starts_with?(name, "__require")) and
               Map.has_key?(externals, specifier),
             do: [%{specifier: specifier, start: start, end: finish}],
             else: []

        _ ->
          []
      end

    calls ++ Enum.flat_map(Map.values(node), &external_require_calls(&1, externals))
  end

  defp external_require_calls(nodes, externals) when is_list(nodes),
    do: Enum.flat_map(nodes, &external_require_calls(&1, externals))

  defp external_require_calls(_, _), do: []

  defp do_bundle_vendor(
         specifier,
         module_dirs,
         output_path,
         plugins,
         module_types,
         source_specifiers,
         browser_token,
         fixed_browser_hash
       ) do
    case bundle_entry_for(specifier, module_dirs, plugins) do
      {:ok, ^specifier, entry} ->
        externals =
          known_vendor_externals(
            specifier,
            module_dirs,
            plugins,
            module_types,
            source_specifiers,
            browser_token,
            fixed_browser_hash
          )

        bundle =
          Bundle.new()
          |> Bundle.entry(entry)
          |> Bundle.cwd(project_root(module_dirs))
          |> Bundle.outdir(cache_dir())
          |> Bundle.format(:esm)
          |> Bundle.resolve(
            conditions: DuskmoonBundler.JS.Resolution.browser_conditions(),
            modules: ["node_modules" | module_dirs],
            external: Map.keys(externals)
          )
          |> Bundle.transform(
            define: %{"process.env.NODE_ENV" => ~s("development")},
            module_types: module_types
          )
          |> Bundle.output(
            entry_file_names: "[name].js",
            chunk_file_names: "chunks/[name]-[hash].js",
            exports: :named,
            preserve_entry_signatures: :strict
          )

        case Bundle.run(bundle) do
          {:ok, result} ->
            result = rewrite_external_vendors(result, externals)

            record_bundle_dependencies(
              [specifier],
              [{specifier, entry}],
              result,
              module_dirs,
              plugins,
              module_types,
              source_specifiers
            )

            write_vendor_cache_metadata(
              [specifier],
              module_dirs,
              plugins,
              module_types,
              source_specifiers,
              browser_token
            )

            if File.regular?(output_path) do
              {:ok, output_path}
            else
              {:error, {:not_found, specifier}}
            end

          {:error, _} = error ->
            error
        end

      {:error, _} = error ->
        error
    end
  end

  defp source_vendor(
         specifier,
         module_dirs,
         force,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    path = cache_path(specifier)

    if not force and File.regular?(path) and
         cache_fresh?(
           specifier,
           module_dirs,
           plugins,
           module_types,
           source_specifiers,
           browser_token
         ) do
      {:ok, path}
    else
      do_source_vendor(
        specifier,
        module_dirs,
        path,
        plugins,
        module_types,
        source_specifiers,
        browser_token
      )
    end
  end

  defp do_source_vendor(
         specifier,
         module_dirs,
         output_path,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    with {:ok, entry_path, _project_root} <- prebundle_entry(specifier, module_dirs, plugins),
         {:ok, source} <- File.read(entry_path),
         :ok <-
           record_dependency_paths(
             [specifier],
             [entry_path],
             module_dirs,
             plugins,
             module_types,
             source_specifiers
           ),
         {:ok, code} <-
           DuskmoonBundler.JS.Transforms.Imports.rewrite(
             source,
             Path.basename(entry_path),
             &rewrite_source_import(
               &1,
               module_dirs,
               plugins,
               module_types,
               source_specifiers,
               browser_token
             )
           ) do
      write_cache_files!(
        output_path,
        code,
        specifier,
        module_dirs,
        plugins,
        module_types,
        source_specifiers,
        browser_token
      )

      {:ok, output_path}
    else
      :error -> {:error, {:not_found, specifier}}
      {:error, _} = error -> error
    end
  end

  defp prebundle_entry(specifier, module_dirs, plugins) do
    case DuskmoonBundler.PluginRunner.prebundle_entry(plugins, specifier) do
      {:source, filename, source} ->
        synthetic_prebundle_entry(specifier, filename, source, module_dirs)

      {:proxy, filename, _opts} = entry ->
        synthetic_prebundle_entry(
          specifier,
          filename,
          DuskmoonBundler.JS.PrebundleEntry.source(entry),
          module_dirs
        )

      nil ->
        package_prebundle_entry(specifier, module_dirs)
    end
  end

  defp synthetic_prebundle_entry(specifier, filename, source, _module_dirs) do
    dir = Path.expand(Path.join([cache_dir(), "entries", encode_specifier(specifier)]))
    path = Path.join(dir, filename)
    File.mkdir_p!(dir)
    File.write!(path, source)
    {:ok, path, dir}
  end

  defp package_prebundle_entry(specifier, module_dirs) do
    case resolve_package_entry(specifier, module_dirs) do
      {:ok, entry_path} -> {:ok, entry_path, package_project_root(entry_path, module_dirs)}
      :error -> :error
    end
  end

  defp package_project_root(entry_path, module_dirs) do
    entry_path
    |> Path.dirname()
    |> NPM.Resolution.PackageResolver.nearest_package()
    |> case do
      {:ok, package_dir, _package} -> Path.dirname(package_dir)
      :error -> project_root(module_dirs)
    end
  end

  # ── Helpers ───────────────────────────────────────────────────────

  defp resolve_package_entry(specifier, module_dirs) do
    Enum.find_value(module_dirs, :error, fn module_dir ->
      result =
        with :error <- resolve_from_node_modules(specifier, module_dir) do
          resolve_from_module_dir(specifier, module_dir)
        else
          {:ok, _path} = ok -> ok
        end

      case result do
        {:ok, _path} = ok -> ok
        :error -> nil
      end
    end)
  end

  defp resolve_from_node_modules(specifier, module_dir) do
    NPM.Resolution.PackageResolver.resolve(specifier, module_dir,
      extensions: DuskmoonBundler.JS.Extensions.resolvable(),
      conditions: DuskmoonBundler.JS.Resolution.browser_conditions()
    )
  end

  defp resolve_from_module_dir(specifier, module_dir) do
    {package_name, subpath} = split_specifier(specifier)
    package_dir = Path.join(module_dir, package_name)

    if File.dir?(package_dir) do
      extensions = DuskmoonBundler.JS.Extensions.resolvable()

      case NPM.Resolution.PackageResolver.resolve_entry(package_dir,
             subpath: subpath || ".",
             extensions: extensions,
             conditions: DuskmoonBundler.JS.Resolution.browser_conditions()
           ) do
        {:ok, _path} = ok -> ok
        :error -> resolve_module_dir_subpath(package_dir, subpath || ".", extensions)
      end
    else
      :error
    end
  end

  defp resolve_module_dir_subpath(package_dir, subpath, extensions) do
    path =
      subpath
      |> String.trim_leading("./")
      |> then(&Path.join(package_dir, &1))

    resolve_file_or_directory(path, extensions)
  end

  defp resolve_file_or_directory(path, extensions) do
    cond do
      File.regular?(path) ->
        {:ok, path}

      match = resolve_with_extensions(path, extensions) ->
        {:ok, match}

      File.dir?(path) ->
        resolve_with_extensions(Path.join(path, "index"), extensions)
        |> case do
          nil -> :error
          match -> {:ok, match}
        end

      true ->
        :error
    end
  end

  defp resolve_with_extensions(path, extensions) do
    Enum.find(extensions, &File.regular?(path <> &1))
    |> case do
      nil -> nil
      extension -> path <> extension
    end
  end

  defp split_specifier("@" <> rest = specifier) do
    case String.split(rest, "/", parts: 3) do
      [_scope, _name] -> {specifier, nil}
      [scope, name, subpath] -> {"@#{scope}/#{name}", "./#{subpath}"}
    end
  end

  defp split_specifier(specifier) do
    case String.split(specifier, "/", parts: 2) do
      [name] -> {name, nil}
      [name, subpath] -> {name, "./#{subpath}"}
    end
  end

  defp normalize_on_demand_opts(opts) do
    if Keyword.keyword?(opts) do
      {Keyword.get(opts, :plugins, []), Keyword.get(opts, :resolve_dirs, []),
       Keyword.get(opts, :module_types, %{}), Keyword.get(opts, :vendor_source, []),
       Keyword.get(opts, :browser_token)}
    else
      {opts, [], %{}, [], nil}
    end
  end

  defp source_vendor?(specifier, source_specifiers), do: specifier in List.wrap(source_specifiers)

  defp rewrite_source_import(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    cond do
      NPM.Resolution.PackageResolver.node_builtin?(specifier) ->
        :keep

      NPM.Resolution.PackageResolver.bare?(specifier) ->
        specifier = DuskmoonBundler.PluginRunner.prebundle_alias(plugins, specifier)

        {:rewrite,
         vendor_url(
           specifier,
           module_dirs,
           plugins,
           module_types,
           source_specifiers,
           browser_token
         )}

      true ->
        :keep
    end
  end

  defp vendor_url(specifier, module_dirs, plugins, module_types, source_specifiers, browser_token) do
    specifier
    |> vendor_url()
    |> DuskmoonBundler.URL.append_query(
      "v=#{browser_hash(module_dirs, plugins, module_types, source_specifiers)}"
    )
    |> append_browser_token(browser_token)
  end

  defp append_browser_token(url, nil), do: url
  defp append_browser_token(url, ""), do: url
  defp append_browser_token(url, token), do: DuskmoonBundler.URL.append_query(url, "t=#{token}")

  defp module_dirs(node_modules, resolve_dirs) do
    node_modules
    |> node_modules_dirs_for()
    |> Kernel.++(List.wrap(resolve_dirs))
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&Path.expand/1)
    |> Enum.uniq()
  end

  defp node_modules_dirs_for(nil), do: []

  defp node_modules_dirs_for(node_modules) do
    node_modules
    |> Path.dirname()
    |> ancestors()
    |> Enum.map(&Path.join(&1, "node_modules"))
    |> Enum.filter(&File.dir?/1)
  end

  defp ancestors(path) do
    parent = Path.dirname(path)

    if parent == path do
      [path]
    else
      [path | ancestors(parent)]
    end
  end

  defp project_root([module_dir | _]), do: Path.dirname(module_dir)
  defp project_root([]), do: File.cwd!()

  defp ensure_cache_dir do
    File.mkdir_p!(cache_dir())
    :ok
  end

  defp read_cached("chunks/" <> _ = specifier) do
    Path.join(cache_dir(), specifier <> ".js")
    |> File.read()
    |> case do
      {:ok, _} = ok -> ok
      {:error, _} -> {:error, :not_found}
    end
  end

  defp read_cached(specifier) do
    specifier
    |> cache_path()
    |> File.read()
    |> case do
      {:ok, _} = ok -> ok
      {:error, _} -> {:error, :not_found}
    end
  end

  defp cache_fresh?(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    File.regular?(cache_path(specifier)) and
      File.read(cache_meta_path(specifier)) ==
        {:ok,
         cache_signature(
           specifier,
           module_dirs,
           plugins,
           module_types,
           source_specifiers,
           browser_token
         )}
  end

  defp write_cache_files!(
         output_path,
         code,
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    meta_path = cache_meta_path(specifier)
    nonce = cache_nonce()
    tmp_output = "#{output_path}.#{nonce}.tmp"
    tmp_meta = "#{meta_path}.#{nonce}.tmp"

    try do
      File.write!(tmp_output, code)

      File.write!(
        tmp_meta,
        cache_signature(
          specifier,
          module_dirs,
          plugins,
          module_types,
          source_specifiers,
          browser_token
        )
      )

      File.rename!(tmp_output, output_path)
      File.rename!(tmp_meta, meta_path)
    after
      File.rm(tmp_output)
      File.rm(tmp_meta)
    end
  end

  defp cache_signature(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    :crypto.hash(
      :sha256,
      :erlang.term_to_binary(
        signature_terms(
          specifier,
          module_dirs,
          plugins,
          module_types,
          source_specifiers,
          browser_token
        )
      )
    )
    |> Base.encode16(case: :lower)
  end

  defp cache_nonce do
    random =
      6
      |> :crypto.strong_rand_bytes()
      |> Base.url_encode64(padding: false)

    [System.os_time(:nanosecond), System.unique_integer([:positive]), random]
    |> Enum.join("-")
  end

  defp signature_terms(
         specifier,
         module_dirs,
         plugins,
         module_types,
         source_specifiers,
         browser_token
       ) do
    browser_signature(module_dirs, plugins, module_types, source_specifiers)
    |> Map.put(:specifier, specifier)
    |> Map.put(:plugins, Enum.map(plugins, &plugin_signature(&1, specifier)))
    |> Map.put(:package, package_signature(specifier, module_dirs))
    |> Map.put(:source_vendor, source_vendor?(specifier, source_specifiers))
    |> Map.put(:browser_token, source_browser_token(specifier, source_specifiers, browser_token))
  end

  defp source_browser_token(specifier, source_specifiers, browser_token) do
    if source_vendor?(specifier, source_specifiers),
      do: browser_token,
      else: nil
  end

  defp browser_signature(module_dirs, plugins, module_types, source_specifiers) do
    %{
      lockfiles: lockfile_signature(module_dirs),
      module_dirs: module_dirs,
      resolve_modules: ["node_modules" | module_dirs],
      dependency_tracking: :module_ids,
      prebundle_format: 4,
      dependencies: dependency_revision(module_dirs, plugins, module_types, source_specifiers),
      module_types: module_types,
      plugins: Enum.map(plugins, &base_plugin_signature/1),
      vendor_source: List.wrap(source_specifiers)
    }
  end

  # Track Rolldown's actual module graph rather than reading unrelated installed
  # dependency trees on every request. These IDs also include empty modules that
  # produce no source-map mappings. Ancestor manifests and lookup directory
  # listings detect exports changes and newly installed nearer package versions.
  defp record_bundle_dependencies(
         specifiers,
         entries,
         result,
         module_dirs,
         plugins,
         module_types,
         source_specifiers
       ) do
    sources = Enum.flat_map(result.outputs, & &1.module_ids)
    sources = sources ++ Enum.map(entries, fn {_specifier, entry} -> entry.import end)

    record_dependency_paths(
      specifiers,
      sources,
      module_dirs,
      plugins,
      module_types,
      source_specifiers
    )
  end

  defp record_dependency_paths(
         specifiers,
         sources,
         module_dirs,
         plugins,
         module_types,
         source_specifiers
       ) do
    dir = dependency_dir(module_dirs, plugins, module_types, source_specifiers)
    File.mkdir_p!(dir)

    contents =
      sources
      |> Enum.filter(&File.regular?/1)
      |> Enum.uniq()
      |> Enum.sort()
      |> :erlang.term_to_binary()

    Enum.each(specifiers, fn specifier ->
      path = Path.join(dir, encode_specifier(specifier) <> ".meta")
      temp = path <> "." <> cache_nonce() <> ".tmp"

      try do
        File.write!(temp, contents)
        File.rename!(temp, path)
      after
        File.rm(temp)
      end
    end)

    :ok
  end

  defp dependency_dir(module_dirs, plugins, module_types, source_specifiers) do
    key = :erlang.term_to_binary({module_dirs, plugins, module_types, source_specifiers})
    hash = :crypto.hash(:sha256, key) |> Base.encode16(case: :lower)
    Path.join([cache_dir(), "dependencies", hash])
  end

  defp dependency_signature(module_dirs, plugins, module_types, source_specifiers) do
    dir = dependency_dir(module_dirs, plugins, module_types, source_specifiers)

    sources =
      case File.ls(dir) do
        {:ok, entries} ->
          entries
          |> Enum.filter(&String.ends_with?(&1, ".meta"))
          |> Enum.flat_map(&read_dependency_paths(Path.join(dir, &1)))
          |> Enum.uniq()
          |> Enum.sort()

        {:error, _} ->
          []
      end

    ancestors = sources |> Enum.flat_map(&ancestors(Path.dirname(&1))) |> Enum.uniq()
    manifests = Enum.map(ancestors, &Path.join(&1, "package.json"))
    lookup_dirs = Enum.map(ancestors, &Path.join(&1, "node_modules")) ++ module_dirs

    %{
      files: Enum.map(Enum.uniq(sources ++ manifests), &{&1, file_signature(&1)}),
      lookup_dirs:
        lookup_dirs |> Enum.uniq() |> Enum.sort() |> Enum.map(&{&1, directory_signature(&1)})
    }
  end

  defp dependency_revision(module_dirs, plugins, module_types, source_specifiers) do
    dir = dependency_dir(module_dirs, plugins, module_types, source_specifiers)

    :global.trans({{__MODULE__, :dependency_revision, dir}, self()}, fn ->
      signature = dependency_signature(module_dirs, plugins, module_types, source_specifiers)

      current =
        Map.new(
          Enum.map(signature.files, fn {path, value} -> {{:file, path}, value} end) ++
            Enum.map(signature.lookup_dirs, fn {path, value} -> {{:directory, path}, value} end)
        )

      path = Path.join(dir, "revision")
      {previous, revision} = read_dependency_revision(path)

      # Discovery extends the graph, but must not replace modules already loaded
      # by the browser. Only changes to previously observed inputs advance it.
      revision =
        if Enum.any?(previous, fn {key, value} -> Map.get(current, key) != value end),
          do: :crypto.hash(:sha256, :erlang.term_to_binary({revision, current})),
          else: revision

      if current != previous do
        File.mkdir_p!(dir)
        temp = path <> "." <> cache_nonce() <> ".tmp"

        try do
          File.write!(temp, :erlang.term_to_binary({current, revision}))
          File.rename!(temp, path)
        after
          File.rm(temp)
        end
      end

      revision
    end)
  end

  defp read_dependency_revision(path) do
    with {:ok, contents} <- File.read(path),
         {signature, revision} when is_map(signature) and is_binary(revision) <-
           :erlang.binary_to_term(contents, [:safe]) do
      {signature, revision}
    else
      _ -> {%{}, ""}
    end
  rescue
    ArgumentError -> {%{}, ""}
  end

  defp read_dependency_paths(path) do
    with {:ok, contents} <- File.read(path),
         sources when is_list(sources) <- :erlang.binary_to_term(contents, [:safe]) do
      Enum.filter(sources, &is_binary/1)
    else
      _ -> []
    end
  rescue
    ArgumentError -> []
  end

  defp directory_signature(path) do
    case File.ls(path) do
      {:ok, entries} ->
        entries
        |> Enum.sort()
        |> Enum.map(fn entry ->
          if String.starts_with?(entry, "@") do
            {entry,
             case File.ls(Path.join(path, entry)) do
               {:ok, scoped} -> Enum.sort(scoped)
               {:error, _} -> nil
             end}
          else
            entry
          end
        end)

      {:error, _} ->
        nil
    end
  end

  defp base_plugin_signature({module, opts}), do: {module, opts}
  defp base_plugin_signature(module), do: module

  defp plugin_signature({module, opts}, specifier),
    do: {module, opts, plugin_entry_signature(module, specifier)}

  defp plugin_signature(module, specifier),
    do: {module, plugin_entry_signature(module, specifier)}

  defp plugin_entry_signature(module, specifier) do
    if function_exported?(module, :prebundle_entry, 1) do
      module.prebundle_entry(specifier)
    end
  end

  defp package_signature(specifier, module_dirs) do
    case resolve_package_entry(specifier, module_dirs) do
      {:ok, entry_path} ->
        {entry_path, file_signature(entry_path), package_json_signature(entry_path)}

      :error ->
        :error
    end
  end

  defp package_json_signature(entry_path) do
    entry_path
    |> Path.dirname()
    |> NPM.Resolution.PackageResolver.nearest_package()
    |> case do
      {:ok, package_dir, _package} -> file_signature(Path.join(package_dir, "package.json"))
      :error -> nil
    end
  end

  @lockfiles ~w(package-lock.json pnpm-lock.yaml yarn.lock bun.lock bun.lockb)

  defp lockfile_signature(module_dirs) do
    module_dirs
    |> lockfile_roots()
    |> Enum.flat_map(&lockfiles_in/1)
  end

  defp lockfile_roots([]), do: [File.cwd!()]

  defp lockfile_roots(module_dirs) do
    module_dirs
    |> Enum.map(&Path.dirname/1)
    |> Kernel.++([File.cwd!()])
    |> Enum.uniq()
  end

  defp lockfiles_in(root) do
    @lockfiles
    |> Enum.map(&Path.join(root, &1))
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&{&1, file_signature(&1)})
  end

  defp file_signature(path) do
    case File.read(path) do
      {:ok, contents} -> :crypto.hash(:sha256, contents) |> Base.encode16(case: :lower)
      {:error, _} -> nil
    end
  end

  defp cache_path(specifier) do
    Path.join(cache_dir(), encode_specifier(specifier) <> ".js")
  end

  defp cache_meta_path(specifier), do: cache_path(specifier) <> ".meta"

  @doc "Encode a specifier for use in URLs (escaping @ and /)."
  def encode_specifier(specifier) do
    specifier
    |> String.replace("@", "__at__")
    |> String.replace("/", "__slash__")
  end

  @doc "Decode a URL-safe specifier back to its original form."
  def decode_specifier(encoded) do
    encoded
    |> String.replace("__slash__", "/")
    |> String.replace("__at__", "@")
  end
end
