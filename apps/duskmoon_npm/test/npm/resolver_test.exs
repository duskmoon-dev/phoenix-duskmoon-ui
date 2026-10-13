defmodule NPM.ResolverTest do
  use ExUnit.Case, async: false

  @moduletag :tmp_dir

  defmodule Server do
    import Plug.Conn

    def init(owner), do: owner

    def call(conn, owner) do
      if conn.request_path == "/missing" do
        send_resp(conn, 404, "missing")
      else
        send(owner, {:registry_blocked, self(), conn.request_path})

        receive do
          :release ->
            body =
              JSON.encode!(%{
                "name" => "blocked",
                "versions" => %{"1.0.0" => %{"dependencies" => %{"child" => "*"}}}
              })

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, body)
        after
          5000 -> send_resp(conn, 500, "registry test timed out")
        end
      end
    end
  end

  setup %{tmp_dir: dir} do
    on_exit(fn -> File.rm_rf!(dir) end)

    for key <- ["NPM_REGISTRY", "NPM_EX_CACHE_DIR", "NPM_EX_ALLOWED_REGISTRIES"] do
      original = System.get_env(key)
      System.delete_env(key)
      on_exit(fn -> restore_env(key, original) end)
    end

    for {key, value} <- [cache_dir: dir, registry: "https://registry.npmjs.org"] do
      original = Application.get_env(:duskmoon_npm, key)
      Application.put_env(:duskmoon_npm, key, value)
      on_exit(fn -> restore_config(key, original) end)
    end

    NPM.Resolver.clear_cache()
    :ok
  end

  test "stable ranges ignore prerelease-heavy package versions" do
    cache_packument(%{
      "1.0.0" => version_info(),
      "1.1.0-beta.1" => version_info(),
      "1.1.0-beta.2" => version_info()
    })

    assert {:ok, %{"version-heavy-package" => "1.0.0"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.0.0"})
  end

  test "ranges that explicitly request a prerelease keep prerelease versions" do
    cache_packument(%{
      "1.0.0" => version_info(),
      "1.1.0-beta.1" => version_info(),
      "1.1.0-beta.2" => version_info()
    })

    assert {:ok, %{"version-heavy-package" => "1.1.0-beta.2"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.1.0-beta.1"})
  end

  test "resolution survives an earlier cache caller exiting during prefetch" do
    cache_packument(%{"1.0.0" => version_info()})
    cache_child_versions()
    configure_registry()
    parent = self()

    {owner, ref} =
      spawn_monitor(fn ->
        result = NPM.Resolver.resolve(%{"version-heavy-package" => "1.0.0"})
        send(parent, {:owner_resolved, result})

        receive do
          :exit -> :ok
        end
      end)

    assert_receive {:owner_resolved, {:ok, %{"version-heavy-package" => "1.0.0"}}}
    resolution = Task.async(fn -> NPM.Resolver.resolve(%{"blocked" => "1.0.0"}) end)
    assert_receive {:registry_blocked, request, "/blocked"}, 5000
    send(owner, :exit)
    assert_receive {:DOWN, ^ref, :process, ^owner, :normal}
    send(request, :release)

    assert {:ok, %{"blocked" => "1.0.0", "child" => "2.0.0"}} = Task.await(resolution)
  end

  test "simultaneous resolutions keep overrides and cache state isolated" do
    cache_child_versions()
    configure_registry()

    first =
      Task.async(fn ->
        NPM.Resolver.resolve(%{"blocked" => "1.0.0"}, overrides: %{"child" => "1.0.0"})
      end)

    assert_receive {:registry_blocked, first_request, "/blocked"}, 5000

    second =
      Task.async(fn ->
        NPM.Resolver.resolve(%{"blocked" => "1.0.0"}, overrides: %{"child" => "2.0.0"})
      end)

    assert_receive {:registry_blocked, second_request, "/blocked"}, 5000

    NPM.Resolver.clear_cache()
    send(first_request, :release)
    assert {:ok, %{"blocked" => "1.0.0", "child" => "1.0.0"}} = Task.await(first)
    send(second_request, :release)
    assert {:ok, %{"blocked" => "1.0.0", "child" => "2.0.0"}} = Task.await(second)
  end

  test "resolution deletes its ETS table and keeps nested ranges only in the caller" do
    cache_nested_conflict()
    before = owned_tables()
    assert {:ok, %{nested: %{"child" => :nested}}} = resolve_nested_conflict()
    assert owned_tables() == before

    assert NPM.Resolver.get_original_deps("child") == %{
             "parent-a@1.0.0" => "1.0.0",
             "parent-b@1.0.0" => "2.0.0"
           }

    assert Task.await(Task.async(fn -> NPM.Resolver.get_original_deps("child") end)) == %{}
    NPM.Resolver.clear_cache()
    assert NPM.Resolver.get_original_deps("child") == %{}
  end

  test "failed and empty resolutions clear saved nested ranges and leave no ETS tables" do
    cache_nested_conflict()
    configure_registry()
    before = owned_tables()
    assert {:ok, _} = resolve_nested_conflict()
    assert {:error, _} = NPM.Resolver.resolve(%{"missing" => "1.0.0"})
    assert NPM.Resolver.get_original_deps("child") == %{}
    assert owned_tables() == before

    assert {:ok, _} = resolve_nested_conflict()
    assert {:ok, %{}} = NPM.Resolver.resolve(%{})
    assert NPM.Resolver.get_original_deps("child") == %{}
    assert owned_tables() == before
  end

  test "repeated resolutions do not retain overrides, prerelease flags, or exclusions" do
    cache_packument(%{"1.0.0" => version_info(), "1.1.0-beta.1" => version_info()})

    assert {:ok, %{"version-heavy-package" => "1.1.0-beta.1"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.1.0-beta.1"})

    assert {:ok, %{"version-heavy-package" => "1.0.0"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.0.0"})

    cache_nested_conflict()
    assert {:ok, _} = resolve_nested_conflict()

    assert {:ok, %{"parent-a" => "1.0.0", "child" => "2.0.0"}} =
             NPM.Resolver.resolve(%{"parent-a" => "1.0.0"}, overrides: %{"child" => "2.0.0"})

    assert {:ok, %{"parent-a" => "1.0.0", "child" => "1.0.0"}} =
             NPM.Resolver.resolve(%{"parent-a" => "1.0.0"})
  end

  test "standalone registry callbacks use caller-owned caches" do
    cache_packument(%{"1.0.0" => version_info()})
    assert {:ok, [version]} = NPM.Resolver.versions(nil, "version-heavy-package")
    assert to_string(version) == "1.0.0"
    assert :ok = NPM.Resolver.prefetch([{nil, "version-heavy-package"}])
    assert {:ok, []} = NPM.Resolver.dependencies(nil, "version-heavy-package", version)
    NPM.Resolver.clear_cache()
  end

  defp owned_tables do
    :ets.all()
    |> Enum.filter(&(:ets.info(&1, :owner) == self()))
    |> MapSet.new()
  end

  defp configure_registry do
    server = start_supervised!({Bandit, plug: {Server, self()}, ip: {127, 0, 0, 1}, port: 0})
    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    registry = "http://127.0.0.1:#{port}"
    original = Application.get_env(:duskmoon_npm, :allowed_registries)
    Application.put_env(:duskmoon_npm, :registry, registry)
    Application.put_env(:duskmoon_npm, :allowed_registries, [registry])
    on_exit(fn -> restore_config(:allowed_registries, original) end)
  end

  defp cache_child_versions do
    NPM.PackumentCache.put("child", %{
      name: "child",
      versions: %{
        "1.0.0" => version_info(),
        "2.0.0" => version_info()
      }
    })
  end

  defp cache_nested_conflict do
    cache_child_versions()

    for {parent, version} <- [{"parent-a", "1.0.0"}, {"parent-b", "2.0.0"}] do
      NPM.PackumentCache.put(parent, %{
        name: parent,
        versions: %{
          "1.0.0" => %{version_info() | dependencies: %{"child" => version}}
        }
      })
    end
  end

  defp resolve_nested_conflict do
    NPM.Resolver.resolve(%{"parent-a" => "1.0.0", "parent-b" => "1.0.0"})
  end

  defp restore_config(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_config(key, value), do: Application.put_env(:duskmoon_npm, key, value)
  defp restore_env(key, nil), do: System.delete_env(key)
  defp restore_env(key, value), do: System.put_env(key, value)

  defp cache_packument(versions) do
    NPM.PackumentCache.put("version-heavy-package", %{
      name: "version-heavy-package",
      versions: versions
    })
  end

  defp version_info do
    %{
      dependencies: %{},
      optional_dependencies: %{},
      peer_dependencies: %{},
      peer_dependencies_meta: %{},
      os: [],
      cpu: []
    }
  end
end
