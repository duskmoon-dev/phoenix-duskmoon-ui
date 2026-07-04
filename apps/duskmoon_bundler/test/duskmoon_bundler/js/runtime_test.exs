defmodule DuskmoonBundler.JS.RuntimeTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.JS.Runtime

  setup do
    name = String.to_atom("volt_runtime_test_#{System.unique_integer([:positive])}")
    tmp_dir = Path.join(System.tmp_dir!(), Atom.to_string(name))

    on_exit(fn ->
      if pid = GenServer.whereis(name), do: Runtime.stop(pid)
      File.rm_rf!(tmp_dir)
    end)

    %{name: name, tmp_dir: tmp_dir}
  end

  test "named runtimes reject mismatched options", %{name: name, tmp_dir: tmp_dir} do
    first_dir = Path.join(tmp_dir, "first")
    second_dir = Path.join(tmp_dir, "second")

    runtime = Runtime.ensure!(name: name, packages: %{}, install_dir: first_dir)

    assert is_pid(runtime.pid)

    assert_raise ArgumentError, ~r/already started with different options/, fn ->
      Runtime.ensure!(name: name, packages: %{}, install_dir: second_dir)
    end
  end

  test "call returns runtime_down when the runtime pid is stale" do
    parent = self()
    pid = spawn(fn -> send(parent, :done) end)

    assert_receive :done
    refute Process.alive?(pid)
    assert {:error, {:runtime_down, :noproc}} = Runtime.call(%Runtime{pid: pid}, "noop", [])
  end
end
