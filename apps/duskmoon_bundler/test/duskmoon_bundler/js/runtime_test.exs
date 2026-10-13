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

  test "named ensure runtimes survive their creator shutdown", %{name: name, tmp_dir: tmp_dir} do
    opts = [
      name: name,
      packages: %{},
      install_dir: tmp_dir,
      apis: false,
      entry: {:source, "globalThis.answer = () => 42;", "answer.js"}
    ]

    {creator, creator_ref, runtime} = start_from_transient_creator(:ensure!, opts)
    runtime_ref = Process.monitor(runtime.pid)
    assert {:ok, 42} = QuickBEAM.eval(runtime.pid, "21 * 2")
    send(creator, :shutdown)

    assert_receive {:DOWN, ^creator_ref, :process, ^creator, :shutdown}
    refute_receive {:DOWN, ^runtime_ref, :process, _, _}
    assert {:ok, 42} = Runtime.call(runtime, "answer")
    Process.demonitor(runtime_ref, [:flush])
  end

  for function <- [:start, :start_link] do
    test "explicit #{function} runtimes retain their creator link", %{
      name: name,
      tmp_dir: tmp_dir
    } do
      {creator, creator_ref, runtime} =
        start_from_transient_creator(unquote(function),
          name: name,
          packages: %{},
          install_dir: tmp_dir,
          apis: false
        )

      runtime_ref = Process.monitor(runtime.pid)
      # A reply establishes the monitor before the creator's exit can reach the runtime.
      assert {:ok, 42} = QuickBEAM.eval(runtime.pid, "21 * 2")
      send(creator, :shutdown)

      assert_receive {:DOWN, ^creator_ref, :process, ^creator, :shutdown}
      assert_receive {:DOWN, ^runtime_ref, :process, _, :shutdown}
    end
  end

  test "unnamed ensure runtimes retain their creator link", %{tmp_dir: tmp_dir} do
    {creator, creator_ref, runtime} =
      start_from_transient_creator(:ensure!, packages: %{}, install_dir: tmp_dir, apis: false)

    runtime_ref = Process.monitor(runtime.pid)
    assert {:ok, 42} = QuickBEAM.eval(runtime.pid, "21 * 2")
    send(creator, :shutdown)

    assert_receive {:DOWN, ^creator_ref, :process, ^creator, :shutdown}
    assert_receive {:DOWN, ^runtime_ref, :process, _, :shutdown}
  end

  test "call returns runtime_down when the runtime pid is stale" do
    parent = self()
    pid = spawn(fn -> send(parent, :done) end)

    assert_receive :done
    refute Process.alive?(pid)
    assert {:error, {:runtime_down, :noproc}} = Runtime.call(%Runtime{pid: pid}, "noop", [])
  end

  defp start_from_transient_creator(function, opts) do
    parent = self()

    {creator, creator_ref} =
      spawn_monitor(fn ->
        runtime =
          case apply(Runtime, function, [opts]) do
            {:ok, %Runtime{} = runtime} -> runtime
            {:ok, pid} -> %Runtime{pid: pid}
            %Runtime{} = runtime -> runtime
          end

        send(parent, {:runtime_started, self(), runtime})

        receive do
          :shutdown -> exit(:shutdown)
        end
      end)

    on_exit(fn -> if Process.alive?(creator), do: Process.exit(creator, :shutdown) end)
    assert_receive {:runtime_started, ^creator, runtime}, 5_000
    {creator, creator_ref, runtime}
  end
end
