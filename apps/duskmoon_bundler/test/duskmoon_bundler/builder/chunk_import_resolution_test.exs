defmodule DuskmoonBundler.Builder.ChunkImportResolutionTest do
  use ExUnit.Case, async: false

  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    File.write!(Path.join(tmp_dir, "package.json"), JSON.encode!(%{"type" => "module"}))

    for {package, value} <- [{"alpha-markdown", "alpha"}, {"beta-markdown", "beta"}] do
      directory = Path.join([tmp_dir, "node_modules", package])
      File.mkdir_p!(Path.join(directory, "lib"))

      File.write!(
        Path.join(directory, "package.json"),
        JSON.encode!(%{
          "name" => package,
          "type" => "module",
          "exports" => %{"." => "./index.js", "./lib/index.js" => "./lib/index.js"}
        })
      )

      File.write!(
        Path.join(directory, "index.js"),
        "export { Widget as default } from './lib/index.js';"
      )

      File.write!(
        Path.join(directory, "lib/index.js"),
        "export const Widget = #{JSON.encode!(value)};"
      )
    end

    source_dir = Path.join(tmp_dir, "src")
    File.mkdir_p!(source_dir)
    entry = Path.join(source_dir, "app.js")

    File.write!(entry, """
    import alpha from 'alpha-markdown';
    import beta from 'beta-markdown';
    import data from './data.json';
    console.log(alpha, beta, data.value);
    import('./lazy.js').then(({ value }) => console.log('async', value));
    """)

    File.write!(Path.join(source_dir, "data.json"), JSON.encode!(%{"value" => "fixture"}))

    File.write!(Path.join(source_dir, "lazy.js"), """
    import { Widget } from 'beta-markdown/lib/index.js';
    export const value = Widget;
    """)

    {:ok, entry: entry}
  end

  for minify <- [false, true] do
    @minify minify
    test "external chunk imports do not shadow another package's local re-export, minify=#{minify}",
         ctx do
      outdir = Path.join(ctx.tmp_dir, "dist")

      assert {:ok, result} =
               DuskmoonBundler.Builder.build(
                 entry: ctx.entry,
                 outdir: outdir,
                 format: :esm,
                 hash: false,
                 minify: @minify,
                 sourcemap: false
               )

      assert result.chunks
      source = File.read!(result.js.path)
      refute source =~ "alpha-markdown/lib/index.js"
      node = System.find_executable("node") || flunk("node executable not found")

      script = """
      globalThis.document = {
        querySelector: () => null,
        createElement: () => ({}),
        head: { appendChild() {} }
      };
      await import(#{JSON.encode!("file://" <> result.js.path)});
      """

      assert {"alpha beta fixture\nasync beta\n", 0} =
               System.cmd(node, ["--input-type=module", "-e", script], stderr_to_stdout: true)
    end

    test "lazy registration executes its root and preloads resolve against the bundle, minify=#{minify}",
         ctx do
      source_dir = Path.dirname(ctx.entry)

      File.write!(ctx.entry, """
      globalThis.registration = Promise.all([import('./early.js'), import('./register.js')]);
      """)

      File.write!(Path.join(source_dir, "early.js"), "import('./helper.js');")
      File.write!(Path.join(source_dir, "helper.js"), "export const value = 7;")

      File.write!(Path.join(source_dir, "register.js"), """
      import { value } from './helper.js';
      customElements.define('fixture-registered', { value });
      """)

      outdir = Path.join(ctx.tmp_dir, "dist")

      assert {:ok, result} =
               DuskmoonBundler.Builder.build(
                 entry: ctx.entry,
                 outdir: outdir,
                 format: :esm,
                 hash: false,
                 minify: @minify,
                 sourcemap: false
               )

      node = System.find_executable("node") || flunk("node executable not found")

      script = """
      const definitions = new Map(), links = [];
      globalThis.customElements = { define: (name, value) => definitions.set(name, value) };
      globalThis.document = {
        querySelector: () => null,
        createElement: () => ({}),
        head: { appendChild(link) { links.push(link.href); } }
      };
      await import(#{JSON.encode!("file://" <> result.js.path)});
      await globalThis.registration;
      if (definitions.get('fixture-registered')?.value !== 7) throw new Error('Registration root did not execute');
      if (!links.length || links.some(url => !url.startsWith(#{JSON.encode!("file://" <> outdir <> "/")}))) {
        throw new Error('Preload URLs did not resolve against the bundle: ' + JSON.stringify(links));
      }
      console.log('registered 7');
      """

      assert {"registered 7\n", 0} =
               System.cmd(node, ["--input-type=module", "-e", script], stderr_to_stdout: true)
    end
  end
end
