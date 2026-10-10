defmodule NPM.FrozenWorkspaceTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias NPM.Resolution.PackageResolver

  defmodule Server do
    @moduledoc false
    import Plug.Conn

    def init(opts), do: opts

    def call(conn, {archives, owner}) do
      send(owner, {:tarball_request, conn.request_path})

      case Map.fetch(archives, conn.request_path) do
        {:ok, archive} -> send_resp(conn, 200, archive)
        :error -> send_resp(conn, 404, "unknown package")
      end
    end
  end

  @moduletag :tmp_dir
  setup %{tmp_dir: tmp_dir} do
    old_cwd = File.cwd!()
    keys = [:cache_dir, :allowed_registries]
    old_config = Map.new(keys, &{&1, Application.get_env(:duskmoon_npm, &1)})
    env_keys = ["NPM_EX_ALLOWED_REGISTRIES", "NPM_EX_LINK_STRATEGY"]
    old_env = Map.new(env_keys, &{&1, System.get_env(&1)})
    Enum.each(env_keys, &System.delete_env/1)

    project_dir = Path.join(tmp_dir, "project")
    File.mkdir_p!(project_dir)
    File.cd!(project_dir)
    Application.put_env(:duskmoon_npm, :cache_dir, Path.join(tmp_dir, "cache"))

    on_exit(fn ->
      File.cd!(old_cwd)

      Enum.each(old_config, fn
        {key, nil} -> Application.delete_env(:duskmoon_npm, key)
        {key, value} -> Application.put_env(:duskmoon_npm, key, value)
      end)

      Enum.each(old_env, fn
        {key, nil} -> System.delete_env(key)
        {key, value} -> System.put_env(key, value)
      end)

      File.rm_rf!(tmp_dir)
    end)

    {:ok, project_dir: project_dir}
  end

  test "frozen install preserves workspace versions, nested imports, and lock bytes", context do
    write_fixture!(context)
    original = File.read!("package-lock.json")

    # Starting within a workspace must still install the root lockfile.
    File.cd!("apps/web")
    capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
    File.cd!(context.project_dir)

    assert File.read!("package-lock.json") == original

    Enum.each(package_records(), fn {location, {_name, version, _deps}} ->
      assert %{"version" => ^version} =
               location |> Path.join("package.json") |> File.read!() |> NPM.JSON.decode!()
    end)

    Enum.each([{"", "1.20.3"}, {"apps/web", "1.20.4"}, {"apps/admin", "1.21.0"}], fn
      {location, version} ->
        assert {:ok, entry} = PackageResolver.resolve("@scope/core", Path.expand(location))
        assert File.read!(entry) == "module.exports = #{inspect(version)};"
    end)

    web_core = Path.expand("apps/web/node_modules/@scope/core")
    assert {:ok, child} = PackageResolver.resolve("child", web_core)
    assert child == Path.expand("apps/web/node_modules/@scope/core/node_modules/child/index.js")
    assert {:ok, tool} = PackageResolver.resolve("tool", web_core)
    assert tool == Path.expand("apps/web/node_modules/tool/index.js")
    assert {:ok, hoisted} = PackageResolver.resolve("hoisted", web_core)
    assert hoisted == Path.expand("node_modules/hoisted/index.js")
    assert {:ok, leaf} = PackageResolver.resolve("leaf", Path.dirname(child))
    assert File.read!(leaf) == ~s[module.exports = "1.0.0";]
    assert {:ok, workspace_link} = File.read_link("node_modules/web")
    assert workspace_link == Path.expand("apps/web")

    # The fixture serves only tarballs; frozen installation never requests metadata.
    Enum.each(package_records(), fn {_location, {name, version, _deps}} ->
      path = archive_path(name, version)
      assert_received {:tarball_request, ^path}
    end)

    refute_received {:tarball_request, _}

    capture_io(fn -> assert :ok = Mix.Tasks.Npm.Verify.run([]) end)
    capture_io(fn -> assert :ok = Mix.Tasks.Npm.Rebuild.run([]) end)
    assert File.read!("package-lock.json") == original
    assert File.exists?("apps/web/node_modules/@scope/core/node_modules/child/index.js")
    refute_received {:tarball_request, _}

    write_json!("apps/web/node_modules/tool/package.json", %{
      "name" => "tool",
      "version" => "0.0.1"
    })

    output =
      capture_io(:stderr, fn ->
        assert_raise Mix.Error, ~r/node_modules does not match lockfile/, fn ->
          Mix.Tasks.Npm.Verify.run([])
        end
      end)

    assert output =~ "mismatch: apps/web/node_modules/tool"
  end

  test "workspace-only frozen locks do not require a hoisted registry package", context do
    document = write_fixture!(context)

    packages =
      document["packages"]
      |> Map.reject(fn {location, _} -> String.starts_with?(location, "node_modules/") end)
      |> put_in(["", "dependencies"], %{})
      |> Map.put("apps/web/node_modules/hoisted", document["packages"]["node_modules/hoisted"])

    write_json!("package.json", packages[""])
    write_json!("package-lock.json", Map.put(document, "packages", packages))
    capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
    assert File.exists?("apps/web/node_modules/@scope/core/package.json")
  end

  test "rejects missing, incompatible and shadowing workspace resolutions", context do
    original = write_fixture!(context)

    for packages <- [
          Map.delete(original["packages"], "apps/web/node_modules/@scope/core"),
          put_in(
            original["packages"],
            ["apps/web/node_modules/@scope/core", "version"],
            "1.20.2"
          ),
          put_in(
            original["packages"],
            ["apps/web/node_modules/@scope/core/node_modules/child", "version"],
            "1.0.0"
          ),
          Map.delete(
            original["packages"],
            "apps/web/node_modules/@scope/core/node_modules/child/node_modules/leaf"
          )
        ] do
      write_json!("package-lock.json", Map.put(original, "packages", packages))
      before = File.read!("package-lock.json")
      capture_io(:stderr, fn -> assert {:error, :frozen_lockfile} = NPM.install(frozen: true) end)
      assert File.read!("package-lock.json") == before
      refute File.exists?("node_modules")
      refute_received {:tarball_request, _}
    end
  end

  test "workspace tarballs retain integrity validation", context do
    document = write_fixture!(context)

    document =
      put_in(document, ["packages", "apps/web/node_modules/tool", "integrity"], "sha512-invalid")

    write_json!("package-lock.json", document)
    before = File.read!("package-lock.json")

    capture_io(fn ->
      assert {:error, {:fetch_failed, "tool", "2.0.0", :integrity_mismatch}} =
               NPM.install(frozen: true)
    end)

    assert File.read!("package-lock.json") == before
    refute File.exists?("apps/web/node_modules/tool/package.json")
  end

  test "workspace tarballs retain registry and policy validation", context do
    document = write_fixture!(context)

    blocked =
      put_in(
        document,
        ["packages", "apps/web/node_modules/tool", "resolved"],
        "https://blocked.example/tool.tgz"
      )

    write_json!("package-lock.json", blocked)

    capture_io(fn ->
      assert {:error, %NPM.Security.RegistryPolicy.Error{}} = NPM.install(frozen: true)
    end)

    policy = put_in(document, ["x-npm-ex", "policy", "allow_registry_redirects"], true)
    write_json!("package-lock.json", policy)
    capture_io(:stderr, fn -> assert {:error, :frozen_lockfile} = NPM.install(frozen: true) end)
  end

  defp write_fixture!(%{tmp_dir: tmp_dir}) do
    archives =
      Map.new(package_records(), fn {_location, {name, version, dependencies}} ->
        archive = Path.join(tmp_dir, "#{String.replace(name, "/", "-")}-#{version}.tgz")

        manifest = %{
          "name" => name,
          "version" => version,
          "main" => "index.js",
          "dependencies" => dependencies
        }

        :ok =
          :erl_tar.create(
            String.to_charlist(archive),
            [
              {~c"package/package.json", NPM.JSON.encode_pretty(manifest)},
              {~c"package/index.js", "module.exports = #{inspect(version)};"}
            ],
            [:compressed]
          )

        {archive_path(name, version), File.read!(archive)}
      end)

    server =
      start_supervised!({Bandit, plug: {Server, {archives, self()}}, ip: {127, 0, 0, 1}, port: 0})

    {:ok, {_ip, port}} = ThousandIsland.listener_info(server)
    origin = "http://127.0.0.1:#{port}"
    Application.put_env(:duskmoon_npm, :allowed_registries, [origin])

    manifests = %{
      "" => %{
        "name" => "root",
        "private" => true,
        "workspaces" => ["apps/*"],
        "dependencies" => %{"@scope/core" => "1.20.3", "tool" => "1.0.0"}
      },
      "apps/web" => %{
        "name" => "web",
        "version" => "1.0.0",
        "dependencies" => %{"@scope/core" => "1.20.4", "tool" => "2.0.0", "hoisted" => "1.0.0"}
      },
      "apps/admin" => %{
        "name" => "admin",
        "version" => "1.0.0",
        "dependencies" => %{"@scope/core" => "1.21.0", "tool" => "3.0.0"}
      }
    }

    Enum.each(manifests, fn {location, data} ->
      directory = if location == "", do: ".", else: location
      File.mkdir_p!(directory)
      write_json!(Path.join(directory, "package.json"), data)
    end)

    packages =
      Map.new(package_records(), fn {location, {name, version, dependencies}} ->
        path = archive_path(name, version)

        {location,
         %{
           "version" => version,
           "resolved" => origin <> path,
           "integrity" => "sha512-" <> Base.encode64(:crypto.hash(:sha512, archives[path])),
           "dependencies" => dependencies
         }}
      end)

    document = %{
      "lockfileVersion" => 3,
      "requires" => true,
      "packages" =>
        packages
        |> Map.merge(manifests)
        |> Map.put("node_modules/web", %{"link" => true, "resolved" => "apps/web"})
        |> Map.put("node_modules/admin", %{"link" => true, "resolved" => "apps/admin"}),
      "x-npm-ex" => %{"policy" => NPM.Lockfile.current_policy()}
    }

    write_json!("package-lock.json", document)
    document
  end

  defp package_records do
    %{
      "node_modules/@scope/core" => {"@scope/core", "1.20.3", %{}},
      "node_modules/tool" => {"tool", "1.0.0", %{}},
      "node_modules/hoisted" => {"hoisted", "1.0.0", %{}},
      "node_modules/child" => {"child", "1.0.0", %{}},
      "apps/web/node_modules/@scope/core" =>
        {"@scope/core", "1.20.4", %{"child" => "2.0.0", "tool" => "2.0.0", "hoisted" => "1.0.0"}},
      "apps/web/node_modules/tool" => {"tool", "2.0.0", %{}},
      "apps/admin/node_modules/@scope/core" => {"@scope/core", "1.21.0", %{}},
      "apps/admin/node_modules/tool" => {"tool", "3.0.0", %{}},
      "apps/web/node_modules/@scope/core/node_modules/child" =>
        {"child", "2.0.0", %{"leaf" => "1.0.0"}},
      "apps/web/node_modules/@scope/core/node_modules/child/node_modules/leaf" =>
        {"leaf", "1.0.0", %{}}
    }
  end

  defp archive_path(name, version), do: "/#{String.replace(name, "/", "-")}-#{version}.tgz"
  defp write_json!(path, data), do: File.write!(path, NPM.JSON.encode_pretty(data))
end
