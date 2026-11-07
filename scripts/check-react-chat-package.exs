# Run from the umbrella after mix hex.build in apps/phoenix_duskmoon:
# scripts/with-precompiled-toolchain.sh mix run --no-start scripts/check-react-chat-package.exs PACKAGE.tar
# Uses only the packaged Hex dependency for phoenix_duskmoon bare imports.
defmodule ReactChatPackageCheck do
  @moduledoc "Verifies the packaged React Chat entry and optional editor import boundaries."
  @doc "Builds ordinary and rich consumers from a Hex archive without an npm Phoenix install."
  def run(tarball) do
    root = File.cwd!()

    temporary =
      Path.join(
        System.tmp_dir!(),
        "phoenix-react-chat-package-#{System.unique_integer([:positive])}"
      )

    package = Path.join(temporary, "deps/phoenix_duskmoon")
    File.mkdir_p!(package)

    try do
      {:ok, archive} = :erl_tar.extract(String.to_charlist(tarball), [:memory])
      {_, contents} = Enum.find(archive, fn {name, _} -> to_string(name) == "contents.tar.gz" end)
      :ok = :erl_tar.extract({:binary, contents}, [:compressed, cwd: String.to_charlist(package)])
      manifest = package |> Path.join("package.json") |> File.read!() |> JSON.decode!()
      "./assets/js/react_chat/index.js" = manifest["exports"]["./react-chat"]
      true = File.regular?(Path.join(package, "assets/js/react_chat/protocol.js"))

      for {name, source} <- [
            {"ordinary",
             "import * as chat from 'phoenix_duskmoon/react-chat'; globalThis.chat = chat;"},
            {"hooks",
             "import * as hooks from 'phoenix_duskmoon/hooks'; globalThis.hooks = hooks;"},
            {"root", "import * as ui from 'phoenix_duskmoon'; globalThis.ui = ui;"},
            {"rich",
             "import {createDuskmoonReactChat} from 'phoenix_duskmoon/react-chat'; globalThis.hook = createDuskmoonReactChat(); globalThis.activateRich = () => import('@duskmoon-dev/components/chat/rich');"}
          ] do
        entry = Path.join(temporary, name <> ".js")
        outdir = Path.join(temporary, "built/" <> name)
        File.write!(entry, source)

        {:ok, _result} =
          DuskmoonBundler.Builder.build(
            entry: entry,
            outdir: outdir,
            root: temporary,
            resolve_dirs: [Path.join(temporary, "deps"), Path.join(root, "node_modules")],
            hash: false,
            minify: false,
            sourcemap: true,
            format: :esm,
            mode: "production",
            code_splitting: true
          )

        graphs =
          Path.wildcard(Path.join(outdir, "**/*.map"))
          |> Map.new(fn path ->
            {path, path |> File.read!() |> JSON.decode!() |> Map.fetch!("sources")}
          end)

        true = map_size(graphs) > 0
        sources = graphs |> Map.values() |> List.flatten() |> Enum.uniq()
        true = Enum.any?(sources, &String.starts_with?(&1, "deps/phoenix_duskmoon/"))
        lexical = Enum.filter(sources, &lexical_source?/1)

        if name == "rich" do
          true = lexical != []
          # Audit the emitted static closure, not just source dynamic imports.
          entry_js = Path.join(outdir, name <> ".js")
          eager = static_sources(entry_js, graphs, MapSet.new())
          false = Enum.any?(eager, &lexical_source?/1)
        else
          [] = lexical
        end

        react_roots =
          sources
          |> Enum.flat_map(fn source ->
            case Regex.run(~r{^(.*(?:^|/)react)/}, source) do
              [_, path] -> [path]
              nil -> []
            end
          end)
          |> Enum.uniq()

        true = length(react_roots) <= 1

        IO.puts(
          "#{name}: packaged resolution OK, #{length(sources)} source modules, #{length(lexical)} optional editor modules"
        )
      end
    after
      File.rm_rf!(temporary)
    end
  end

  # DuskmoonBundler normalizes node_modules sources to package-relative paths.
  defp lexical_source?(source), do: Regex.match?(~r{(?:^|/)(?:lexical|@lexical)/}, source)

  defp static_sources(path, graphs, visited) do
    if MapSet.member?(visited, path) do
      []
    else
      code = File.read!(path)

      children =
        for %{type: type, source: %{value: specifier}} <- OXC.parse!(code, path).body,
            type in [:import_declaration, :export_named_declaration, :export_all_declaration],
            String.starts_with?(specifier, "."),
            do: Path.expand(specifier, Path.dirname(path))

      Map.get(graphs, path <> ".map", []) ++
        Enum.flat_map(children, &static_sources(&1, graphs, MapSet.put(visited, path)))
    end
  end
end

[tarball] = System.argv()
{:ok, _} = Application.ensure_all_started(:duskmoon_bundler)
ReactChatPackageCheck.run(Path.expand(tarball))
