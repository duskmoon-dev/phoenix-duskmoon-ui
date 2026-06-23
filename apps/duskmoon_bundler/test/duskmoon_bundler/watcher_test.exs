defmodule DuskmoonBundler.WatcherTest do
  use ExUnit.Case, async: false

  setup %{test: test_name} do
    watch_dir = Path.expand("fixtures/watcher_test/#{test_name}", __DIR__)
    File.mkdir_p!(watch_dir)
    DuskmoonBundler.HMR.ImportGraph.clear()
    DuskmoonBundler.Cache.clear()
    on_exit(fn -> File.rm_rf!(watch_dir) end)
    {:ok, watch_dir: watch_dir}
  end

  defp write_changed!(path, content) do
    File.write!(path, content)
    File.touch!(path, next_mtime())
  end

  defp next_mtime do
    count = Process.get(:watcher_test_mtime_count, 0)
    Process.put(:watcher_test_mtime_count, count + 1)
    {{2040, 1, 1}, {0, 0, rem(count, 60)}}
  end

  test "broadcasts via registry on dispatch" do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)

    Registry.dispatch(DuskmoonBundler.HMR.Registry, :clients, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:duskmoon_bundler_hmr, :update, %{path: "test.ts", changes: [:full]}})
      end
    end)

    assert_receive {:duskmoon_bundler_hmr, :update, %{path: "test.ts", changes: [:full]}}
  end

  test "starts and watches a directory", %{watch_dir: watch_dir} do
    {:ok, pid} = DuskmoonBundler.Watcher.start_link(root: watch_dir, name: :test_watcher)
    assert Process.alive?(pid)
    GenServer.stop(pid)
  end

  test "detects file changes and broadcasts update", %{watch_dir: watch_dir} do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)

    ts_file = Path.join(watch_dir, "app.ts")
    File.write!(ts_file, "export const x = 1;")

    {:ok, pid} = DuskmoonBundler.Watcher.start_link(root: watch_dir, name: :test_watcher_change)

    Process.sleep(100)
    write_changed!(ts_file, "export const x = 2;")

    assert_receive {:duskmoon_bundler_hmr, :update, %{path: "app.ts", changes: [:full]}}, 2000

    GenServer.stop(pid)
  end

  test "detects asset changes and broadcasts reload update", %{watch_dir: watch_dir} do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)

    File.mkdir_p!(Path.join(watch_dir, "images"))
    asset_file = Path.join(watch_dir, "images/logo.svg")
    File.write!(asset_file, "<svg></svg>")

    {:ok, pid} =
      DuskmoonBundler.Watcher.start_link(root: watch_dir, name: :test_watcher_asset_change)

    Process.sleep(100)
    write_changed!(asset_file, "<svg><circle /></svg>")

    assert_receive {:duskmoon_bundler_hmr, :update, %{path: "images/logo.svg", changes: [:full]}},
                   2000

    GenServer.stop(pid)
  end

  test "invalidates import.meta.glob importers when matching files are added", %{
    watch_dir: watch_dir
  } do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)

    File.mkdir_p!(Path.join(watch_dir, "pages"))
    routes_file = Path.join(watch_dir, "routes.ts")

    File.write!(routes_file, """
    export const pages = import.meta.glob('./pages/*.ts')
    """)

    dev_config = DuskmoonBundler.DevServer.init(root: watch_dir, prefix: "/assets")
    Plug.Test.conn(:get, "/assets/routes.ts") |> DuskmoonBundler.DevServer.call(dev_config)

    {:ok, pid} = DuskmoonBundler.Watcher.start_link(root: watch_dir, name: :test_watcher_glob_add)

    Process.sleep(100)
    File.write!(Path.join(watch_dir, "pages/home.ts"), "export const page = 'home'")

    assert_receive {:duskmoon_bundler_hmr, :update, %{path: "routes.ts", changes: [:full]}}, 2000

    GenServer.stop(pid)
  end

  test "triggers tailwind rebuild on template changes", %{watch_dir: watch_dir} do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)

    heex_file = Path.join(watch_dir, "page.heex")
    File.write!(heex_file, ~s(<div class="flex">hi</div>))

    outdir = Path.join(watch_dir, "css_out")

    {:ok, pid} =
      DuskmoonBundler.Watcher.start_link(
        root: watch_dir,
        watch_dirs: [watch_dir],
        tailwind: true,
        tailwind_outdir: outdir,
        name: :test_watcher_tw
      )

    Process.sleep(100)
    write_changed!(heex_file, ~s(<div class="flex mt-4 bg-blue-500">hi</div>))

    assert_receive {:duskmoon_bundler_hmr, :update,
                    %{path: "assets/css/app.css", changes: [:style]}},
                   3000

    assert File.exists?(Path.join(outdir, "app.css"))
    css = File.read!(Path.join(outdir, "app.css"))
    assert css =~ "tailwindcss"

    GenServer.stop(pid)
  end
end
