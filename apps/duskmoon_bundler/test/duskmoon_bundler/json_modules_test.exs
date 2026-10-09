defmodule DuskmoonBundler.JSONModulesTest do
  use ExUnit.Case, async: false

  defmodule TransformJSON do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "transform-json"

    def transform(code, path) do
      if Path.extname(path) == ".json", do: {:ok, String.replace(code, "original", "transformed")}
    end
  end

  defmodule CompileJSON do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "compile-json"

    def compile(path, _source, _opts) do
      if Path.extname(path) == ".json",
        do: {:ok, %{type: :js, code: ~s(export default {name: "compiled"};)}}
    end
  end

  defmodule LoadJSONAsJS do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "load-json-as-js"

    def load(path) do
      if Path.extname(path) == ".json",
        do: {:ok, ~s(export default {name: "loaded"};), "application/javascript"}
    end
  end

  defmodule UnrelatedPlugin do
    @behaviour DuskmoonBundler.Plugin
    def name, do: "unrelated"
    def transform(_code, _path), do: nil
  end

  setup do
    root = Path.join(System.tmp_dir!(), "bundler-json-#{System.unique_integer([:positive])}")
    File.mkdir_p!(root)
    on_exit(fn -> File.rm_rf!(root) end)
    runtime = start_supervised!({QuickBEAM, apis: false})
    %{root: root, runtime: runtime}
  end

  test "CommonJS schema consumers receive JSON values, not ESM namespaces", ctx do
    write(ctx, "first.json", ~s({"$id":"first","type":"object"}))
    write(ctx, "second.json", ~s({"$id":"second","type":"string"}))

    write(ctx, "schemas.js", """
    const first = require('./first.json');
    const second = require('./second.json');
    const schemas = new Map();
    for (const schema of [first, second]) {
      if (schemas.has(schema.$id)) throw new Error('duplicate schema id: ' + schema.$id);
      schemas.set(schema.$id, schema.type);
    }
    module.exports = { first, schemas: [...schemas] };
    """)

    write(ctx, "app.js", """
    import first from './first.json';
    import consumer from './schemas.js';
    globalThis.result = { same: first === consumer.first, schemas: consumer.schemas };
    """)

    assert {:ok, %{"same" => true, "schemas" => [["first", "object"], ["second", "string"]]}} =
             build_and_eval(ctx, plugins: [UnrelatedPlugin])
  end

  test "JSON objects support ESM default, named and namespace imports", ctx do
    write(ctx, "data.json", ~s({"name":"schema","nested":{"enabled":true}}))

    write(ctx, "app.js", """
    import data, { name, nested } from './data.json';
    import * as namespace from './data.json';
    globalThis.result = {
      name, enabled: nested.enabled,
      sameDefault: namespace.default === data,
      sameNested: nested === data.nested
    };
    """)

    assert {:ok,
            %{"name" => "schema", "enabled" => true, "sameDefault" => true, "sameNested" => true}} =
             build_and_eval(ctx)
  end

  test "CommonJS and ESM JSON imports preserve primitive and array values", ctx do
    for {name, json} <- [{"number", "42"}, {"null", "null"}, {"array", "[1,2]"}] do
      write(ctx, "#{name}.json", json)
    end

    write(ctx, "app.js", """
    import number from './number.json';
    import nothing from './null.json';
    import array from './array.json';
    globalThis.result = {
      number, nothing, array,
      same: number === require('./number.json') && nothing === require('./null.json') && array === require('./array.json')
    };
    """)

    assert {:ok, %{"number" => 42, "nothing" => nil, "array" => [1, 2], "same" => true}} =
             build_and_eval(ctx)
  end

  test "shared JSON retains its default and named exports across lazy chunks", ctx do
    write(ctx, "data.json", ~s({"name":"shared-schema"}))

    write(ctx, "first.js", """
    import data from './data.json';
    export const value = data.name;
    """)

    write(ctx, "second.js", """
    import { name } from './data.json';
    export const value = name;
    """)

    write(ctx, "app.js", """
    globalThis.loadFirst = () => import('./first.js');
    globalThis.loadSecond = () => import('./second.js');
    """)

    assert {:ok, result} =
             DuskmoonBundler.Builder.build(
               entry: Path.join(ctx.root, "app.js"),
               outdir: Path.join(ctx.root, "dist"),
               format: :esm,
               hash: false,
               minify: false,
               sourcemap: false
             )

    assert Enum.count(result.chunks) >= 3

    # Resolve the emitted chunk links as an actual consumer, including the
    # common chunk's default facade and named JSON export.
    lazy_chunks = Enum.filter(result.chunks, &(&1.type == :async))
    assert length(lazy_chunks) == 2

    for chunk <- lazy_chunks do
      consumer = Path.join(ctx.root, "dist/consumer.js")

      File.write!(consumer, """
      import { value } from './#{Path.basename(chunk.path)}';
      globalThis.result = value;
      """)

      {:ok, bundled} =
        DuskmoonBundler.JS.Runtime.Bundler.bundle_file(consumer, format: :iife)

      assert {:ok, _} = QuickBEAM.eval(ctx.runtime, bundled)

      assert {:ok, "shared-schema"} = QuickBEAM.eval(ctx.runtime, "globalThis.result")
    end
  end

  for {plugin, expected} <- [
        {TransformJSON, "transformed"},
        {CompileJSON, "compiled"},
        {LoadJSONAsJS, "loaded"}
      ] do
    test "preserves JSON plugin #{inspect(plugin)}", ctx do
      write(ctx, "data.json", ~s({"name":"original"}))

      write(ctx, "app.js", """
      import data from './data.json';
      globalThis.result = data.name;
      """)

      assert {:ok, unquote(expected)} = build_and_eval(ctx, plugins: [unquote(plugin)])
    end
  end

  test "JSON query imports keep the existing ESM compilation path", ctx do
    write(ctx, "data.json", ~s({"name":"query-data"}))

    write(ctx, "app.js", """
    import raw from './data.json?raw';
    import url from './data.json?url';
    globalThis.result = [raw.name, url.name];
    """)

    assert {:ok, ["query-data", "query-data"]} = build_and_eval(ctx)
  end

  defp write(ctx, path, source), do: File.write!(Path.join(ctx.root, path), source)

  defp build_and_eval(ctx, opts \\ []) do
    assert {:ok, result} =
             DuskmoonBundler.Builder.build(
               Keyword.merge(
                 [
                   entry: Path.join(ctx.root, "app.js"),
                   outdir: Path.join(ctx.root, "dist"),
                   format: :iife,
                   minify: false,
                   sourcemap: false
                 ],
                 opts
               )
             )

    with {:ok, _} <- QuickBEAM.eval(ctx.runtime, File.read!(result.js.path)) do
      QuickBEAM.eval(ctx.runtime, "globalThis.result")
    end
  end
end
