defmodule DuskmoonBundler.NestedPackageResolutionTest do
  use ExUnit.Case, async: false

  @moduletag :tmp_dir
  @package "@fixture/nested-consumer"
  @dependency "@fixture/core/components/pin-input"

  setup %{tmp_dir: tmp_dir} do
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    node_modules = Path.join(tmp_dir, "node_modules")
    consumer_dir = Path.join(node_modules, @package)
    root_core_dir = Path.join(node_modules, "@fixture/core")
    nested_core_dir = Path.join(consumer_dir, "node_modules/@fixture/core")
    src_dir = Path.join(tmp_dir, "src")
    File.mkdir_p!(src_dir)
    File.mkdir_p!(consumer_dir)
    File.mkdir_p!(root_core_dir)
    File.mkdir_p!(nested_core_dir)

    File.write!(
      Path.join(consumer_dir, "package.json"),
      ~s({"name":"#{@package}","type":"module","exports":"./index.js"})
    )

    File.write!(
      Path.join(consumer_dir, "index.js"),
      "import { value } from '#{@dependency}'; export { value };"
    )

    File.write!(
      Path.join(root_core_dir, "package.json"),
      ~s({"name":"@fixture/core","type":"module","exports":{".":"./index.js"}})
    )

    File.write!(Path.join(root_core_dir, "index.js"), "export const value = 'root-version';")

    File.write!(
      Path.join(nested_core_dir, "package.json"),
      ~s({"name":"@fixture/core","type":"module","exports":{"./components/pin-input":{"browser":"./pin-input.js","default":"./node.js"}}})
    )

    File.write!(
      Path.join(nested_core_dir, "pin-input.js"),
      "export const value = 'nested-browser-version';"
    )

    File.write!(
      Path.join(nested_core_dir, "node.js"),
      "export const value = 'nested-node-version';"
    )

    entry = Path.join(src_dir, "app.js")
    File.write!(entry, "import { value } from '#{@package}'; console.log(value);")

    {:ok, node_modules: node_modules, src_dir: src_dir, entry: entry}
  end

  test "dev prebundle honors nested exports before the root version", ctx do
    assert {:ok, vendors} =
             DuskmoonBundler.JS.Vendor.prebundle(
               root: ctx.src_dir,
               node_modules: ctx.node_modules,
               force: true
             )

    assert %{@package => path} = vendors
    assert_vendor_runtime(File.read!(path))
  end

  test "on-demand dev bundle honors nested exports before the root version", ctx do
    assert {:ok, source} =
             DuskmoonBundler.JS.Vendor.bundle_on_demand(@package, ctx.node_modules)

    assert_vendor_runtime(source)
  end

  test "an unavailable nested export does not fall back to another root version", ctx do
    consumer_dir = Path.join(ctx.node_modules, @package)
    nested_core_dir = Path.join(consumer_dir, "node_modules/@fixture/core")
    root_core_dir = Path.join(ctx.node_modules, "@fixture/core")

    File.write!(
      Path.join(nested_core_dir, "package.json"),
      ~s({"name":"@fixture/core","exports":{".":"./node.js"}})
    )

    File.write!(
      Path.join(root_core_dir, "package.json"),
      ~s({"name":"@fixture/core","exports":{"./components/pin-input":"./index.js"}})
    )

    resolver_ctx = %DuskmoonBundler.Builder.Context{node_modules: ctx.node_modules}

    assert {:error, {:not_found, @dependency}} =
             DuskmoonBundler.Builder.Resolver.resolve(
               @dependency,
               Path.join(consumer_dir, "index.js"),
               resolver_ctx
             )
  end

  for code_splitting <- [false, true] do
    @code_splitting code_splitting

    test "production bundle with code_splitting=#{code_splitting} emits executable nested imports",
         ctx do
      assert {:ok, result} =
               DuskmoonBundler.Builder.build(
                 entry: ctx.entry,
                 outdir: Path.join(ctx.tmp_dir, "dist"),
                 node_modules: ctx.node_modules,
                 code_splitting: @code_splitting,
                 format: :esm,
                 minify: true,
                 sourcemap: false,
                 hash: false
               )

      source = File.read!(result.js.path)
      refute source =~ @dependency
      refute source =~ "root-version"

      node = System.find_executable("node") || flunk("node executable not found")
      assert {"nested-browser-version\n", 0} = System.cmd(node, [result.js.path])
    end
  end

  defp assert_vendor_runtime(source) do
    refute source =~ @dependency
    refute source =~ "root-version"
    node = System.find_executable("node") || flunk("node executable not found")
    url = "data:text/javascript;base64," <> Base.encode64(source)
    script = "const { value } = await import(#{JSON.encode!(url)}); console.log(value);"

    assert {"nested-browser-version\n", 0} =
             System.cmd(node, ["--input-type=module", "-e", script], stderr_to_stdout: true)
  end
end
