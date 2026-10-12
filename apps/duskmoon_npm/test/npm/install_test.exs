defmodule NPM.InstallTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    old_cwd = File.cwd!()
    old_cache_dir = Application.get_env(:duskmoon_npm, :cache_dir)
    old_link_strategy = System.get_env("NPM_EX_LINK_STRATEGY")
    System.delete_env("NPM_EX_LINK_STRATEGY")

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
      restore_system_env("NPM_EX_LINK_STRATEGY", old_link_strategy)
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

    assert_copied_package(
      cache_path,
      Path.join([project_dir, "node_modules", package])
    )
  end

  test "relinks existing cache symlinks with the default copy strategy", %{
    project_dir: project_dir
  } do
    package = "legacy-symlink-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "legacy_symlink_project",
        "dependencies" => %{package => version}
      })
    )

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, version)})

    installed_path = Path.join([project_dir, "node_modules", package])
    File.mkdir_p!(Path.dirname(installed_path))
    File.ln_s!(cache_path, installed_path)

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    assert output =~ "Installing from current package-lock.json."
    assert_copied_package(cache_path, installed_path)
  end

  test "keeps existing cache symlinks with explicit symlink strategy", %{
    project_dir: project_dir
  } do
    System.put_env("NPM_EX_LINK_STRATEGY", "symlink")
    package = "explicit-symlink-package"
    version = "1.0.0"
    cache_path = write_cached_package!(package, version)

    write_package!(project_dir, %{
      "name" => "explicit_symlink_project",
      "dependencies" => %{package => version}
    })

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, version)})

    installed_path = Path.join([project_dir, "node_modules", package])
    File.mkdir_p!(Path.dirname(installed_path))
    File.ln_s!(cache_path, installed_path)

    output = capture_io(fn -> assert :ok = NPM.install() end)

    assert output =~ "Already up to date."
    assert_symlink_target!(installed_path, cache_path)
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
    assert_copied_package(dependency_cache_path, Path.join(node_modules, dependency))

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
    File.cp_r!(cache_path, Path.join(node_modules, package))

    output =
      capture_io(fn ->
        assert :ok = NPM.install()
      end)

    assert output =~ "Already up to date."
    refute File.exists?(Path.join([node_modules, optional_package, "package.json"]))
  end

  test "locks required dependencies of optional packages excluded from resolution", %{
    project_dir: project_dir
  } do
    package = "@duskmoon-dev/el-markdown-input"
    version = "1.5.5"
    current_mermaid = "mermaid-#{NPM.Platform.current_os()}-#{NPM.Platform.current_cpu()}"
    other_mermaid = "mermaid-darwin-arm64"
    parser = "@mermaid-js/parser"
    parser_dependency = "langium"

    other_mermaid =
      if other_mermaid == current_mermaid, do: "mermaid-linux-x64", else: other_mermaid

    Enum.each(
      [
        {package, version},
        {current_mermaid, "11.15.0"},
        {other_mermaid, "11.15.0"},
        {parser, "1.1.1"},
        {parser_dependency, "3.3.1"}
      ],
      fn {name, package_version} -> write_cached_package!(name, package_version) end
    )

    put_packument!(package, version,
      optional_dependencies: %{
        current_mermaid => "11.15.0",
        other_mermaid => "11.15.0"
      }
    )

    put_packument!(current_mermaid, "11.15.0")
    put_packument!(other_mermaid, "11.15.0", dependencies: %{parser => "1.1.1"})
    put_packument!(parser, "1.1.1", dependencies: %{parser_dependency => "3.3.1"})
    put_packument!(parser_dependency, "3.3.1")

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "mermaid_optional_dependency_project",
        "dependencies" => %{package => version}
      })
    )

    capture_io(fn ->
      assert :ok = NPM.install()
    end)

    assert {:ok, package_names} = NPM.Lockfile.all_package_names()

    assert MapSet.new(package_names) ==
             MapSet.new([
               package,
               current_mermaid,
               other_mermaid,
               parser,
               parser_dependency
             ])

    assert {:ok, %{"packages" => packages}} = NPM.JSON.read_file("package-lock.json")

    Enum.each([other_mermaid, parser, parser_dependency], fn name ->
      assert packages["node_modules/#{name}"]["optional"] == true
    end)

    capture_io(fn ->
      assert :ok = NPM.install(frozen: true)
    end)
  end

  test "nests marked 16 for optional mermaid beside flat marked 18", %{
    project_dir: project_dir
  } do
    markdown = "@duskmoon-dev/el-markdown"
    markdown_input = "@duskmoon-dev/el-markdown-input"
    mermaid = "mermaid"
    marked = "marked"

    platform_mermaid =
      "mermaid-#{NPM.Platform.current_os()}-#{NPM.Platform.current_cpu()}"

    Enum.each(
      [
        {markdown, "1.5.3"},
        {markdown_input, "1.5.3"},
        {platform_mermaid, "1.0.0"},
        {mermaid, "11.15.0"},
        {marked, "16.3.0"},
        {marked, "18.0.4"}
      ],
      fn {name, version} -> write_cached_package!(name, version) end
    )

    put_packument!(markdown, "1.5.3", dependencies: %{marked => "18.0.4"})

    put_packument!(markdown_input, "1.5.3",
      optional_dependencies: %{
        mermaid => "11.15.0",
        platform_mermaid => "1.0.0"
      }
    )

    put_packument!(platform_mermaid, "1.0.0")
    put_packument!(mermaid, "11.15.0", dependencies: %{marked => "^16.3.0"})

    put_packument_versions!(marked, [
      {"16.3.0", []},
      {"18.0.4", []}
    ])

    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{
        "name" => "marked_version_conflict_project",
        "dependencies" => %{
          markdown => "1.5.3",
          markdown_input => "1.5.3"
        }
      })
    )

    capture_io(fn ->
      assert :ok = NPM.install()
    end)

    assert {:ok, %{"packages" => packages}} = NPM.JSON.read_file("package-lock.json")
    assert packages["node_modules/marked"]["version"] == "18.0.4"
    assert packages["node_modules/mermaid"]["version"] == "11.15.0"
    assert packages["node_modules/mermaid"]["optional"] == true

    nested_marked = "node_modules/mermaid/node_modules/marked"
    assert packages[nested_marked]["version"] == "16.3.0"
    assert packages[nested_marked]["optional"] == true
    assert installed_version!(nested_marked) == "16.3.0"

    File.rm_rf!("node_modules")

    mermaid
    |> NPM.Cache.package_dir("11.15.0")
    |> Path.join("node_modules")
    |> File.rm_rf!()

    capture_io(fn ->
      assert :ok = NPM.install(frozen: true)
    end)

    assert installed_version!(nested_marked) == "16.3.0"
  end

  test "install and update complete required and optional trees of nested versions", context do
    write_nested_graph_fixture!(context.project_dir)

    for operation <- [&NPM.install/0, &NPM.update/0] do
      capture_io(fn -> assert :ok = operation.() end)
      assert_complete_nested_graph!()

      original_lock = File.read!("package-lock.json")
      File.rm_rf!("node_modules")
      capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
      assert File.read!("package-lock.json") == original_lock
      assert_complete_nested_graph!()
    end
  end

  test "optional dependency ranges replace duplicate required ranges", context do
    package = "optional-override-parent"
    leaf = "optional-override-leaf"

    put_packument!(package, "1.0.0",
      dependencies: %{leaf => "^1.0.0"},
      optional_dependencies: %{leaf => "^2.0.0"}
    )

    put_packument_versions!(leaf, [{"1.0.0", []}, {"2.0.0", []}])
    write_cached_package!(package, "1.0.0")
    write_cached_package!(leaf, "2.0.0")
    write_package!(context.project_dir, %{"dependencies" => %{package => "1.0.0"}})

    for operation <- [&NPM.install/0, &NPM.update/0] do
      capture_io(fn -> assert :ok = operation.() end)
      assert {:ok, %{^leaf => %{version: "2.0.0"}}} = NPM.Lockfile.read()
      assert {:ok, %{}} = NPM.Lockfile.read_nested()
      assert installed_version!("node_modules/#{leaf}") == "2.0.0"
      lock = File.read!("package-lock.json")
      capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
      assert File.read!("package-lock.json") == lock
    end
  end

  test "project overrides govern transitive ranges and stale lock validation", context do
    package = "project-override-parent"
    leaf = "project-override-leaf"
    put_packument!(package, "1.0.0", dependencies: %{leaf => "^1.0.0"})
    put_packument_versions!(leaf, [{"1.0.0", []}, {"2.0.0", []}])
    write_cached_package!(package, "1.0.0")
    write_cached_package!(leaf, "1.0.0")
    write_cached_package!(leaf, "2.0.0")
    manifest = %{"dependencies" => %{package => "1.0.0"}, "overrides" => %{leaf => "^2.0.0"}}
    write_package!(context.project_dir, manifest)

    for operation <- [&NPM.install/0, &NPM.update/0] do
      capture_io(fn -> assert :ok = operation.() end)
      assert {:ok, %{^leaf => %{version: "2.0.0"}}} = NPM.Lockfile.read()
      assert {:ok, %{}} = NPM.Lockfile.read_nested()
      assert installed_version!("node_modules/#{leaf}") == "2.0.0"
      lock = File.read!("package-lock.json")
      capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
      assert File.read!("package-lock.json") == lock
      output = capture_io(fn -> assert :ok = NPM.install() end)
      assert output =~ "Already up to date."
    end

    write_package!(context.project_dir, %{manifest | "overrides" => %{leaf => "^1.0.0"}})
    stale_lock = File.read!("package-lock.json")
    capture_io(:stderr, fn -> assert {:error, :frozen_lockfile} = NPM.install(frozen: true) end)
    assert File.read!("package-lock.json") == stale_lock
    capture_io(fn -> assert :ok = NPM.install() end)
    assert {:ok, %{^leaf => %{version: "1.0.0"}}} = NPM.Lockfile.read()
    capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
  end

  test "project overrides govern required and optional expansion beneath nested records",
       context do
    write_nested_graph_fixture!(context.project_dir)
    manifest = read_package!(context.project_dir)

    put_packument_versions!("nested-optional", [
      {"1.0.0", [dependencies: %{"nested-optional-leaf" => "1.0.0"}]},
      {"2.0.0", [dependencies: %{"nested-optional-leaf" => "1.0.0"}]}
    ])

    write_cached_package!("nested-optional", "2.0.0")

    overrides = %{
      "internmap" => "^3.0.0",
      "d3-path" => "^3.0.0",
      "layout-base" => "^2.0.0",
      "nested-optional" => "^2.0.0"
    }

    write_package!(context.project_dir, Map.put(manifest, "overrides", overrides))

    for operation <- [&NPM.install/0, &NPM.update/0] do
      capture_io(fn -> assert :ok = operation.() end)
      assert {:ok, %{"packages" => packages}} = NPM.JSON.read_file("package-lock.json")

      for {name, version} <- [
            {"internmap", "3.0.0"},
            {"d3-path", "3.1.0"},
            {"layout-base", "2.0.1"}
          ] do
        assert packages["node_modules/#{name}"]["version"] == version

        refute Enum.any?(packages, fn {location, _entry} ->
                 location != "node_modules/#{name}" and String.ends_with?(location, "/#{name}")
               end)
      end

      assert packages["node_modules/d3-sankey/node_modules/d3-array"]["dependencies"] ==
               %{"internmap" => "^1.0.0"}

      assert packages["node_modules/nested-optional"]["optional"] == true
      assert packages["node_modules/nested-optional"]["version"] == "2.0.0"
      lock = File.read!("package-lock.json")
      File.rm_rf!("node_modules")
      capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
      assert File.read!("package-lock.json") == lock
    end
  end

  test "ordinary install repairs missing and incompatible nested dependency records", context do
    write_nested_graph_fixture!(context.project_dir)
    capture_io(fn -> assert :ok = NPM.install() end)

    assert {:ok, %{"packages" => complete_packages} = document} =
             NPM.JSON.read_file("package-lock.json")

    for missing_name <- ["internmap", "layout-base", "d3-path"] do
      packages =
        Map.reject(complete_packages, fn {location, _entry} ->
          String.ends_with?(location, "/#{missing_name}") and
            location != "node_modules/#{missing_name}"
        end)

      File.write!(
        "package-lock.json",
        NPM.JSON.encode_pretty(%{document | "packages" => packages})
      )

      stale_lock = File.read!("package-lock.json")

      capture_io(:stderr, fn ->
        assert {:error, :frozen_lockfile} = NPM.install(frozen: true)
      end)

      assert File.read!("package-lock.json") == stale_lock
      output = capture_io(fn -> assert :ok = NPM.install() end)
      refute output =~ "Already up to date."
      assert_complete_nested_graph!()
      capture_io(fn -> assert :ok = NPM.install(frozen: true) end)
    end
  end

  test "does not write a successful lock when an expanded dependency cannot resolve", context do
    package = "unresolvable-optional-parent"
    other_os = if NPM.Platform.current_os() == "darwin", do: "linux", else: "darwin"
    optional = "unresolvable-#{other_os}-arm64"
    put_packument!(package, "1.0.0", optional_dependencies: %{optional => "1.0.0"})
    put_packument!(optional, "1.0.0", dependencies: %{"unresolvable-leaf" => "^2.0.0"})
    put_packument!("unresolvable-leaf", "1.0.0")
    write_package!(context.project_dir, %{"dependencies" => %{package => "1.0.0"}})

    capture_io(fn ->
      capture_io(:stderr, fn ->
        assert {:error, :resolution_failed} = NPM.install()
      end)
    end)

    refute File.exists?("package-lock.json")
    refute File.exists?("node_modules")
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

    assert_copied_package(
      cache_path,
      Path.join([project_dir, "node_modules", package])
    )

    assert_symlink_target!(Path.join([project_dir, "node_modules", "web"]), app_dir)
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
    assert_copied_package(new_cache_path, Path.join(node_modules, package))
    assert_symlink_target!(Path.join([node_modules, "web"]), app_dir)

    assert {:ok, lockfile} = NPM.Lockfile.read(Path.join(project_dir, "package-lock.json"))
    assert lockfile[package].version == new_version
  end

  test "update re-resolves matching workspace lock entries", %{project_dir: project_dir} do
    package = "workspace-update-package"
    range = "^1.0.0"
    old_version = "1.0.0"
    new_version = "1.1.0"
    write_cached_package!(package, old_version)
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
      "dependencies" => %{package => range}
    })

    assert :ok = NPM.Lockfile.write(%{package => lock_entry(package, old_version)})
    File.cd!(app_dir)

    capture_io(fn ->
      assert :ok = NPM.update()
    end)

    assert {:ok, %{^package => %{version: ^new_version}}} =
             NPM.Lockfile.read(Path.join(project_dir, "package-lock.json"))

    assert_copied_package(new_cache_path, Path.join([project_dir, "node_modules", package]))
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

    assert_copied_package(
      cache_path,
      Path.join([project_dir, "node_modules", package])
    )

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

  test "npm.ci starts SSL before installing", %{project_dir: project_dir} do
    File.write!(
      Path.join(project_dir, "package.json"),
      NPM.JSON.encode_pretty(%{"name" => "ssl_startup_project"})
    )

    {:ok, _started} = Application.ensure_all_started(:ssl)
    on_exit(fn -> Application.ensure_all_started(:ssl) end)
    assert :ok = Application.stop(:ssl)
    refute List.keymember?(Application.started_applications(), :ssl, 0)

    Mix.Task.reenable("npm.ci")

    capture_io(fn ->
      assert :ok = Mix.Tasks.Npm.Ci.run([])
    end)

    assert {:ssl, _description, _version} =
             List.keyfind(Application.started_applications(), :ssl, 0)

    assert :ssl in Application.spec(:duskmoon_npm, :applications)
  end

  # Reduced Sigma graph: conflicting D3 and Cytoscape versions retain the ranges
  # that previously produced missing internmap/layout-base and incompatible d3-path.
  defp write_nested_graph_fixture!(project_dir) do
    packages = [
      {"d3", [{"7.0.0", [dependencies: %{"d3-array" => "^3.0.0"}]}]},
      {"d3-sankey",
       [{"0.12.3", [dependencies: %{"d3-array" => "^2.0.0", "d3-shape" => "^1.0.0"}]}]},
      {"d3-array",
       [
         {"2.12.1",
          [
            dependencies: %{"internmap" => "^1.0.0"},
            optional_dependencies: %{"nested-optional" => "1.0.0"}
          ]},
         {"3.2.4", [dependencies: %{"internmap" => "1 - 2"}]}
       ]},
      {"d3-shape",
       [
         {"1.3.7", [dependencies: %{"d3-path" => "1", "nested-bridge" => "1.0.0"}]},
         {"3.2.0", [dependencies: %{"d3-path" => "^3.0.0"}]}
       ]},
      {"internmap", [{"1.0.0", []}, {"2.0.3", []}, {"3.0.0", []}]},
      {"d3-path", [{"1.0.9", []}, {"3.1.0", []}]},
      {"cytoscape-cose-bilkent", [{"4.1.0", [dependencies: %{"cose-base" => "^1.0.0"}]}]},
      {"cytoscape-fcose", [{"2.2.0", [dependencies: %{"cose-base" => "^2.0.0"}]}]},
      {"cose-base",
       [
         {"1.0.3", [dependencies: %{"layout-base" => "^1.0.0"}]},
         {"2.2.0", [dependencies: %{"layout-base" => "^2.0.0"}]}
       ]},
      {"layout-base", [{"1.0.2", []}, {"2.0.1", []}]},
      {"nested-optional", [{"1.0.0", [dependencies: %{"nested-optional-leaf" => "1.0.0"}]}]},
      {"nested-optional-leaf", [{"1.0.0", [dependencies: %{"nested-optional" => "1.0.0"}]}]},
      {"nested-bridge", [{"1.0.0", [dependencies: %{"d3-path" => "^3.0.0"}]}, {"2.0.0", []}]}
    ]

    Enum.each(packages, fn {name, versions} ->
      put_packument_versions!(name, versions)
      Enum.each(versions, fn {version, _opts} -> write_cached_package!(name, version) end)
    end)

    write_package!(project_dir, %{
      "name" => "sigma_nested_regression",
      "dependencies" => %{
        "d3" => "7.0.0",
        "d3-sankey" => "0.12.3",
        "d3-shape" => "3.2.0",
        "d3-path" => "3.1.0",
        "internmap" => "3.0.0",
        "layout-base" => "2.0.1",
        "nested-bridge" => "2.0.0",
        "cytoscape-cose-bilkent" => "4.1.0",
        "cytoscape-fcose" => "2.2.0"
      }
    })
  end

  defp assert_complete_nested_graph! do
    assert {:ok, %{"packages" => packages}} = NPM.JSON.read_file("package-lock.json")
    sankey_array = "node_modules/d3-sankey/node_modules/d3-array"
    sankey_shape = "node_modules/d3-sankey/node_modules/d3-shape"
    bilkent_base = "node_modules/cytoscape-cose-bilkent/node_modules/cose-base"
    fcose_base = "node_modules/cytoscape-fcose/node_modules/cose-base"

    for {location, version} <- [
          {sankey_array, "2.12.1"},
          {"#{sankey_array}/node_modules/internmap", "1.0.0"},
          {"#{sankey_shape}/node_modules/d3-path", "1.0.9"},
          {"#{bilkent_base}/node_modules/layout-base", "1.0.2"},
          {fcose_base, "2.2.0"},
          {"#{sankey_shape}/node_modules/nested-bridge/node_modules/d3-path", "3.1.0"},
          {"node_modules/d3-path", "3.1.0"},
          {"node_modules/internmap", "3.0.0"}
        ] do
      assert packages[location]["version"] == version
      refute packages[location]["optional"]
      assert installed_version!(location) == version
    end

    for name <- ["nested-optional", "nested-optional-leaf"] do
      assert packages["node_modules/#{name}"]["optional"] == true
      assert installed_version!("node_modules/#{name}") == "1.0.0"
    end
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
    put_packument_versions!(package, [{version, opts}])
  end

  defp put_packument_versions!(package, versions) do
    NPM.PackumentCache.put(package, %{
      name: package,
      versions:
        Map.new(versions, fn {version, opts} ->
          {version,
           %{
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
           }}
        end)
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

  defp assert_copied_package(cache_path, installed_path) do
    assert {:ok, %File.Stat{type: :directory}} = File.lstat(installed_path)

    assert File.read!(Path.join(installed_path, "package.json")) ==
             File.read!(Path.join(cache_path, "package.json"))
  end

  defp assert_symlink_target!(link_path, expected_target) do
    assert {:ok, actual_target} = File.read_link(link_path)

    assert canonicalize_path(Path.expand(actual_target, Path.dirname(link_path))) ==
             canonicalize_path(expected_target)
  end

  defp canonicalize_path(path) do
    path
    |> Path.expand()
    |> String.replace_prefix("/private", "")
  end

  defp installed_version!(package_dir) do
    package_dir
    |> Path.join("package.json")
    |> NPM.JSON.read_file()
    |> then(fn {:ok, %{"version" => version}} -> version end)
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)

  defp restore_system_env(key, nil), do: System.delete_env(key)
  defp restore_system_env(key, value), do: System.put_env(key, value)
end
