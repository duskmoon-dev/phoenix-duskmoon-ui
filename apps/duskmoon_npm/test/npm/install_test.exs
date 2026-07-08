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

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    assert output =~ "Installing from current package-lock.json."
    assert output =~ "Installed 1 package"
    assert output =~ "* #{package} #{version} (npm registry)"
    assert {:ok, ^cache_path} = File.read_link(Path.join([project_dir, "node_modules", package]))
  end

  test "re-resolves a lockfile with missing transitive package records", %{
    project_dir: project_dir
  } do
    package = "root-package"
    dependency = "missing-transitive-package"
    version = "1.0.0"
    dependency_version = "2.0.0"
    root_cache_path = write_cached_package!(package, version)
    dependency_cache_path = write_cached_package!(dependency, dependency_version)

    put_packument!(package, version, dependencies: %{dependency => dependency_version})
    put_packument!(dependency, dependency_version)

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "incomplete_lockfile_project",
        "dependencies" => %{package => version}
      })
    )

    assert :ok =
             NPM.Lockfile.write(%{
               package =>
                 lock_entry(package, version, dependencies: %{dependency => dependency_version})
             })

    node_modules = Path.join(project_dir, "node_modules")
    File.mkdir_p!(node_modules)
    File.ln_s!(root_cache_path, Path.join(node_modules, package))

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    refute output =~ "Already up to date."
    assert {:ok, ^dependency_cache_path} = File.read_link(Path.join(node_modules, dependency))

    assert {:ok, lockfile} = NPM.Lockfile.read()
    assert Map.has_key?(lockfile, dependency)
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

  test "installs from workspace package using the workspace root", %{project_dir: project_dir} do
    package = "workspace-root-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)
    app_dir = Path.join([project_dir, "apps", "web"])

    write_package!(project_dir, %{
      "name" => "workspace_root",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(app_dir, %{
      "name" => "web",
      "version" => "1.0.0",
      "dependencies" => %{package => version}
    })

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, version)})
    File.cd!(app_dir)

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    assert output =~ "Installing from current package-lock.json."
    assert {:ok, ^cache_path} = File.read_link(Path.join([project_dir, "node_modules", package]))
    assert {:ok, ^app_dir} = File.read_link(Path.join([project_dir, "node_modules", "web"]))
    assert File.exists?(Path.join(project_dir, "package-lock.json"))
    refute File.exists?(Path.join(app_dir, "package-lock.json"))
    refute File.exists?(Path.join(app_dir, "node_modules"))
  end

  test "re-resolves stale workspace dependency ranges", %{project_dir: project_dir} do
    package = "workspace-stale-package"
    old_version = "0.2.0"
    new_version = "1.5.5"
    old_cache_path = write_cached_package!(package, old_version)
    new_cache_path = write_cached_package!(package, new_version)
    app_dir = Path.join([project_dir, "apps", "web"])

    put_packument!(package, new_version)

    write_package!(project_dir, %{
      "name" => "workspace_root",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(app_dir, %{
      "name" => "web",
      "version" => "1.0.0",
      "dependencies" => %{package => new_version}
    })

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, old_version)})

    node_modules = Path.join(project_dir, "node_modules")
    File.mkdir_p!(node_modules)
    File.ln_s!(old_cache_path, Path.join(node_modules, package))
    File.cd!(app_dir)

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    refute output =~ "Already up to date."
    assert {:ok, ^new_cache_path} = File.read_link(Path.join(node_modules, package))
    assert {:ok, ^app_dir} = File.read_link(Path.join([node_modules, "web"]))

    assert {:ok, lockfile} = NPM.Lockfile.read(Path.join(project_dir, "package-lock.json"))
    assert lockfile[package].version == new_version
  end

  test "adds dependencies to workspace package and installs at workspace root", %{
    project_dir: project_dir
  } do
    package = "workspace-added-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)
    app_dir = Path.join([project_dir, "apps", "web"])

    write_package!(project_dir, %{
      "name" => "workspace_root",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(app_dir, %{
      "name" => "web",
      "version" => "1.0.0"
    })

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, version)})
    File.cd!(app_dir)

    capture_io(fn ->
      assert :ok = NPM.add(package, version)
    end)

    assert %{"dependencies" => %{^package => ^version}} = read_package!(app_dir)
    refute Map.has_key?(read_package!(project_dir), "dependencies")
    assert {:ok, ^cache_path} = File.read_link(Path.join([project_dir, "node_modules", package]))
    assert File.exists?(Path.join(project_dir, "package-lock.json"))
    refute File.exists?(Path.join(app_dir, "package-lock.json"))
    refute File.exists?(Path.join(app_dir, "node_modules"))
  end

  test "npm.ci raises when frozen install fails", %{project_dir: project_dir} do
    Mix.Task.reenable("npm.ci")

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "missing_lockfile_project",
        "dependencies" => %{"lockfile-required" => "1.0.0"}
      })
    )

    output =
      capture_io(:stderr, fn ->
        assert_raise Mix.Error, ~r/npm\.ci failed: :no_lockfile/, fn ->
          Mix.Tasks.Npm.Ci.run([])
        end
      end)

    assert output =~ "package-lock.json not found. Run `mix npm.install` first."
  end

  defp write_cached_package!(name, version) do
    cache_path = NPM.Cache.package_dir(name, version)
    File.mkdir_p!(cache_path)

    File.write!(
      Path.join(cache_path, "package.json"),
      NPM.JSON.encode_pretty(%{"name" => name, "version" => version})
    )

    File.write!(Path.join(cache_path, ".npm-ex-cache-complete"), "1\n")

    cache_path
  end

  defp lock_entry(package, version, opts \\ []) do
    %{
      version: version,
      integrity: "",
      tarball: "https://registry.npmjs.org/#{package}/-/#{package}-#{version}.tgz",
      dependencies: Keyword.get(opts, :dependencies, %{}),
      optional_dependencies: Keyword.get(opts, :optional_dependencies, %{}),
      has_install_script: false
    }
  end

  defp put_packument!(package, version, opts \\ []) do
    NPM.PackumentCache.put(package, %{
      name: package,
      versions: %{
        version => %{
          os: [],
          cpu: [],
          dependencies: Keyword.get(opts, :dependencies, %{}),
          optional_dependencies: Keyword.get(opts, :optional_dependencies, %{}),
          peer_dependencies: %{},
          peer_dependencies_meta: %{},
          dist: %{
            tarball: "https://registry.npmjs.org/#{package}/-/#{package}-#{version}.tgz",
            integrity: ""
          },
          has_install_script: false,
          deprecated: nil,
          created_at: nil,
          published_at: nil
        }
      }
    })
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

  defp write_package!(dir, data) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "package.json"), NPM.JSON.encode_pretty(data))
  end

  defp read_package!(dir) do
    dir
    |> Path.join("package.json")
    |> NPM.JSON.read_file()
    |> then(fn {:ok, data} -> data end)
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
