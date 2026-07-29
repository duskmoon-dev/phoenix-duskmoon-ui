defmodule OXC.BundleTest do
  use ExUnit.Case, async: true

  @app_dir Path.expand("../..", __DIR__)

  @tag :tmp_dir
  test "bundles a deeply nested expression without crashing the native runtime", %{
    tmp_dir: tmp_dir
  } do
    mix = System.find_executable("mix") || flunk("mix executable not found")

    expression =
      Enum.reduce(1..500, "0", fn _, expression ->
        "identity(#{expression})"
      end)

    source = """
    const identity = value => value;
    export const result = #{expression};
    """

    child_script = """
    source = System.fetch_env!("OXC_DEEP_EXPRESSION_SOURCE")

    case OXC.bundle([{"deep-expression.js", source}],
           entry: "deep-expression.js",
           format: :esm,
           treeshake: true
         ) do
      {:ok, bundle} when is_binary(bundle) ->
        if bundle =~ "identity" and bundle =~ "result" do
          IO.puts("bundle-ok")
        else
          System.halt(2)
        end

      result ->
        IO.inspect(result, label: "bundle-error")
        System.halt(3)
    end
    """

    assert {output, 0} =
             System.cmd(
               mix,
               ["run", "--no-compile", "-e", child_script],
               cd: @app_dir,
               env: [
                 {"MIX_ENV", "test"},
                 {"OXC_DEEP_EXPRESSION_SOURCE", source},
                 {"ERL_CRASH_DUMP", Path.join(tmp_dir, "erl_crash.dump")},
                 {"ERL_CRASH_DUMP_SECONDS", "0"}
               ],
               stderr_to_stdout: true
             )

    assert output =~ "bundle-ok"
  end
end
