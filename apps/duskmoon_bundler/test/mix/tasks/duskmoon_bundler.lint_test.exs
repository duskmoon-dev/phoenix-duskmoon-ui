defmodule DuskmoonBundler.LintTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tmp_dir "tmp/lint_test_#{:erlang.unique_integer([:positive])}"

  setup do
    File.mkdir_p!(@tmp_dir)
    on_exit(fn -> File.rm_rf!(@tmp_dir) end)
    original_root = Application.get_env(:duskmoon_bundler, :root)
    original_lint = Application.get_env(:duskmoon_bundler, :lint)
    Application.put_env(:duskmoon_bundler, :root, @tmp_dir)

    on_exit(fn ->
      if original_root,
        do: Application.put_env(:duskmoon_bundler, :root, original_root),
        else: Application.delete_env(:duskmoon_bundler, :root)

      if original_lint,
        do: Application.put_env(:duskmoon_bundler, :lint, original_lint),
        else: Application.delete_env(:duskmoon_bundler, :lint)
    end)

    :ok
  end

  test "reports no issues for clean code" do
    File.write!(Path.join(@tmp_dir, "clean.ts"), "export const x = 1;\n")
    Application.put_env(:duskmoon_bundler, :lint, plugins: [:typescript])

    output = capture_io(fn -> Mix.Tasks.DuskmoonBundler.Lint.run([]) end)
    assert output =~ "No issues found"
  end

  test "detects eqeqeq violation" do
    File.write!(Path.join(@tmp_dir, "bad.js"), "export const y = x == 1;\n")
    Application.put_env(:duskmoon_bundler, :lint, rules: %{"eqeqeq" => :deny})

    output =
      capture_io(fn ->
        catch_exit(Mix.Tasks.DuskmoonBundler.Lint.run([]))
      end)

    assert output =~ "eqeqeq"
    assert output =~ "error"
  end

  test "detects typescript rule" do
    File.write!(Path.join(@tmp_dir, "typed.ts"), "export function foo(x: any) { return x; }\n")

    Application.put_env(:duskmoon_bundler, :lint,
      plugins: [:typescript],
      rules: %{"typescript/no-explicit-any" => :warn}
    )

    output = capture_io(fn -> Mix.Tasks.DuskmoonBundler.Lint.run([]) end)
    assert output =~ "no-explicit-any"
  end

  test "CLI --plugin flag overrides config" do
    File.write!(Path.join(@tmp_dir, "typed.ts"), "export function foo(x: any) { return x; }\n")

    Application.put_env(:duskmoon_bundler, :lint,
      plugins: [],
      rules: %{"typescript/no-explicit-any" => :warn}
    )

    output = capture_io(fn -> Mix.Tasks.DuskmoonBundler.Lint.run(["--plugin", "typescript"]) end)
    assert output =~ "no-explicit-any"
  end

  test "skips node_modules" do
    File.mkdir_p!(Path.join(@tmp_dir, "node_modules/pkg"))
    File.write!(Path.join([@tmp_dir, "node_modules", "pkg", "bad.js"]), "debugger;\n")
    Application.put_env(:duskmoon_bundler, :lint, rules: %{"no-debugger" => :deny})

    output = capture_io(fn -> Mix.Tasks.DuskmoonBundler.Lint.run([]) end)
    assert output =~ "No lintable files"
  end

  test "reports correct file location" do
    File.write!(Path.join(@tmp_dir, "loc.js"), "const a = 1;\nexport const b = x == y;\n")
    Application.put_env(:duskmoon_bundler, :lint, rules: %{"eqeqeq" => :deny})

    output =
      capture_io(fn ->
        catch_exit(Mix.Tasks.DuskmoonBundler.Lint.run([]))
      end)

    assert output =~ "loc.js:2:"
  end

  test "custom rules via config" do
    defmodule TestNoDebugger do
      @behaviour OXC.Lint.Rule

      @impl true
      def meta,
        do: %{
          name: "test/no-debugger-custom",
          description: "custom",
          category: :correctness,
          fixable: false
        }

      @impl true
      def run(ast, _ctx) do
        OXC.collect(ast, fn
          %{type: :debugger_statement, start: s, end: e} ->
            {:keep, %{span: {s, e}, message: "custom debugger ban"}}

          _ ->
            :skip
        end)
      end
    end

    File.write!(Path.join(@tmp_dir, "dbg.js"), "export function f() { debugger; }\n")
    Application.put_env(:duskmoon_bundler, :lint, custom_rules: [{TestNoDebugger, :deny}])

    output =
      capture_io(fn ->
        catch_exit(Mix.Tasks.DuskmoonBundler.Lint.run([]))
      end)

    assert output =~ "custom debugger ban"
    assert output =~ "test/no-debugger-custom"
  end
end
