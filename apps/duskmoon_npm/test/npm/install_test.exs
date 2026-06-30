defmodule NPM.InstallTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    old_cwd = File.cwd!()
    old_cache_dir = Application.get_env(:duskmoon_npm, :cache_dir)

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_install_test_#{System.unique_integer([:positive])}"
      ])

    cache_dir = Path.join(tmp_dir, "cache-root")
    project_dir = Path.join(tmp_dir, "project")

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(project_dir)
    Application.put_env(:duskmoon_npm, :cache_dir, cache_dir)
    File.cd!(project_dir)

    on_exit(fn ->
      File.cd!(old_cwd)
      restore_app_env(:cache_dir, old_cache_dir)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, project_dir: project_dir}
  end

  test "uses a current lockfile without re-resolving", %{project_dir: project_dir} do
    package = "lockfile-only-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "lockfile_project",
        "dependencies" => %{package => version}
      })
    )

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, version)})
    assert :ok = NPM.install()
    assert {:ok, ^cache_path} = File.read_link(Path.join([project_dir, "node_modules", package]))
  end

  test "current lockfile stays up to date with skipped platform optional packages", %{
    project_dir: project_dir
  } do
    package = "root-package"
    optional_package = "other-platform-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)
    put_incompatible_packument!(optional_package, version)

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "platform_optional_project",
        "dependencies" => %{package => version}
      })
    )

    assert :ok =
             NPM.Lockfile.write(%{
               package =>
                 lock_entry(package, version,
                   optional_dependencies: %{optional_package => version}
                 ),
               optional_package => lock_entry(optional_package, version)
             })

    node_modules = Path.join(project_dir, "node_modules")
    File.mkdir_p!(node_modules)
    File.ln_s!(cache_path, Path.join(node_modules, package))

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    assert output =~ "Already up to date."
    refute File.exists?(Path.join([node_modules, optional_package, "package.json"]))
  end

  defp write_cached_package!(name, version) do
    cache_path = NPM.Cache.package_dir(name, version)
    File.mkdir_p!(cache_path)

    File.write!(
      Path.join(cache_path, "package.json"),
      NPM.JSON.encode_pretty(%{"name" => name, "version" => version})
    )

    cache_path
  end

  defp lock_entry(package, version, opts \\ []) do
    %{
      version: version,
      integrity: "",
      tarball: "https://registry.npmjs.org/#{package}/-/#{package}-#{version}.tgz",
      dependencies: %{},
      optional_dependencies: Keyword.get(opts, :optional_dependencies, %{}),
      has_install_script: false
    }
  end

  defp put_incompatible_packument!(package, version) do
    other_os = if NPM.Platform.current_os() == "darwin", do: "linux", else: "darwin"

    NPM.PackumentCache.put(package, %{
      name: package,
      versions: %{
        version => %{
          os: [other_os],
          cpu: [],
          dependencies: %{},
          optional_dependencies: %{},
          dist: %{tarball: "", integrity: ""}
        }
      }
    })
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
