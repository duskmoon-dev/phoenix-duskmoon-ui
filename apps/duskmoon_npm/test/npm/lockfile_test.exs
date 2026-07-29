defmodule NPM.LockfileTest do
  use ExUnit.Case, async: false

  setup do
    old_cwd = File.cwd!()

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_lockfile_test_#{System.unique_integer([:positive])}"
      ])

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)
    File.cd!(tmp_dir)

    on_exit(fn ->
      File.cd!(old_cwd)
      File.rm_rf!(tmp_dir)
    end)

    :ok
  end

  test "writes package-lock v3 with root and workspace package locations" do
    write_package!(".", %{
      "name" => "lockfile-root",
      "version" => "1.0.0",
      "private" => true,
      "workspaces" => ["apps/*"],
      "dependencies" => %{"registry-package" => "1.0.0"}
    })

    write_package!("apps/web", %{
      "name" => "web",
      "version" => "1.0.0",
      "dependencies" => %{"registry-package" => "1.0.0"}
    })

    assert :ok =
             NPM.Lockfile.write(%{
               "registry-package" => lock_entry("1.0.0", dependencies: %{"dep" => "^1.0.0"})
             })

    assert %{
             "name" => "lockfile-root",
             "version" => "1.0.0",
             "lockfileVersion" => 3,
             "requires" => true,
             "packages" => %{
               "" => %{
                 "name" => "lockfile-root",
                 "version" => "1.0.0",
                 "workspaces" => ["apps/*"],
                 "dependencies" => %{"registry-package" => "1.0.0"}
               },
               "apps/web" => %{
                 "name" => "web",
                 "version" => "1.0.0",
                 "dependencies" => %{"registry-package" => "1.0.0"}
               },
               "node_modules/registry-package" => %{
                 "version" => "1.0.0",
                 "resolved" =>
                   "https://registry.npmjs.org/registry-package/-/registry-package-1.0.0.tgz",
                 "integrity" => "sha512-test",
                 "dependencies" => %{"dep" => "^1.0.0"}
               },
               "node_modules/web" => %{
                 "resolved" => "apps/web",
                 "link" => true
               }
             },
             "x-npm-ex" => %{"policy" => policy}
           } = read_json!("package-lock.json")

    assert is_map(policy)

    assert {:ok,
            %{
              "registry-package" => %{
                version: "1.0.0",
                integrity: "sha512-test",
                tarball:
                  "https://registry.npmjs.org/registry-package/-/registry-package-1.0.0.tgz",
                dependencies: %{"dep" => "^1.0.0"}
              }
            }} = NPM.Lockfile.read()
  end

  test "reads package-lock v3 top-level registry packages and skips links and nested packages" do
    write_sample_package_lock!()

    assert {:ok,
            %{
              "@scope/pkg" => %{
                version: "2.0.0",
                tarball: "https://registry.npmjs.org/@scope/pkg/-/pkg-2.0.0.tgz",
                integrity: "sha512-scoped",
                optional_dependencies: %{"optional-pkg" => "^1.0.0"},
                has_install_script: true
              }
            }} = NPM.Lockfile.read()

    assert {:ok, ["@scope/pkg", "nested"]} = NPM.Lockfile.all_package_names()
  end

  test "writes nested package-lock entries without adding them to the flat read API" do
    write_package!(".", %{
      "name" => "nested-root",
      "version" => "1.0.0",
      "dependencies" => %{"parent" => "1.0.0"}
    })

    assert :ok =
             NPM.Lockfile.write(
               %{"parent" => lock_entry("1.0.0")},
               nested: %{
                 "node_modules/parent/node_modules/nested" =>
                   Map.put(lock_entry("2.0.0"), :optional, true)
               }
             )

    assert %{
             "packages" => %{
               "node_modules/parent" => %{"version" => "1.0.0"},
               "node_modules/parent/node_modules/nested" => %{
                 "version" => "2.0.0",
                 "optional" => true
               }
             }
           } = read_json!("package-lock.json")

    assert {:ok, ["nested", "parent"]} = NPM.Lockfile.all_package_names()
    assert {:ok, %{"parent" => %{version: "1.0.0"}}} = NPM.Lockfile.read()

    assert {:ok,
            %{
              "node_modules/parent/node_modules/nested" => %{
                version: "2.0.0",
                optional: true
              }
            }} = NPM.Lockfile.read_nested()
  end

  test "rejects unsafe nested package-lock locations while reading" do
    location = "node_modules/parent/node_modules/.."

    assert :ok =
             NPM.Lockfile.write(
               %{"parent" => lock_entry("1.0.0")},
               nested: %{location => lock_entry("2.0.0")}
             )

    assert {:error, {:invalid_nested_package_location, ^location}} =
             NPM.Lockfile.read_nested()
  end

  test "package-lock analyzer skips workspace links and nested packages" do
    write_sample_package_lock!()
    data = read_json!("package-lock.json")

    assert %{"@scope/pkg" => "2.0.0"} = NPM.Lockfile.PackageLock.packages(data)
  end

  test "package-lock import skips workspace links and nested packages" do
    write_sample_package_lock!()

    assert {:ok,
            %{
              "@scope/pkg" => %{
                version: "2.0.0",
                resolved: "https://registry.npmjs.org/@scope/pkg/-/pkg-2.0.0.tgz",
                integrity: "sha512-scoped",
                dependencies: %{}
              }
            }} = NPM.Import.from_package_lock("package-lock.json")
  end

  test "migrates legacy npm.lock to package-lock v3" do
    write_package!(".", %{
      "name" => "legacy-root",
      "version" => "1.0.0"
    })

    policy = %{
      "allowed_registries" => ["https://registry.npmjs.org"],
      "allow_registry_redirects" => false,
      "block_exotic_subdeps" => true,
      "exotic_deps" => []
    }

    write_json!("npm.lock", %{
      "lockfileVersion" => 1,
      "policy" => policy,
      "packages" => %{
        "legacy-package" => lock_entry("1.0.0")
      }
    })

    assert {:ok, %{"legacy-package" => %{version: "1.0.0"}}} = NPM.Lockfile.read()
    assert File.exists?("npm.lock")
    assert File.exists?("package-lock.json")
    assert NPM.Lockfile.version() == 3
    assert {:ok, ^policy} = NPM.Lockfile.read_policy()

    assert %{
             "lockfileVersion" => 3,
             "packages" => %{
               "" => %{"name" => "legacy-root", "version" => "1.0.0"},
               "node_modules/legacy-package" => %{"version" => "1.0.0"}
             },
             "x-npm-ex" => %{"policy" => ^policy}
           } = read_json!("package-lock.json")
  end

  defp lock_entry(version, opts \\ []) do
    %{
      version: version,
      integrity: "sha512-test",
      tarball: "https://registry.npmjs.org/registry-package/-/registry-package-#{version}.tgz",
      dependencies: Keyword.get(opts, :dependencies, %{}),
      optional_dependencies: Keyword.get(opts, :optional_dependencies, %{}),
      has_install_script: Keyword.get(opts, :has_install_script, false)
    }
  end

  defp write_package!(dir, data) do
    File.mkdir_p!(dir)
    write_json!(Path.join(dir, "package.json"), data)
  end

  defp write_sample_package_lock! do
    write_json!("package-lock.json", %{
      "name" => "root",
      "version" => "1.0.0",
      "lockfileVersion" => 3,
      "requires" => true,
      "packages" => %{
        "" => %{"name" => "root", "version" => "1.0.0"},
        "apps/workspace-package" => %{
          "name" => "workspace-package",
          "version" => "1.0.0"
        },
        "node_modules/@scope/pkg" => %{
          "version" => "2.0.0",
          "resolved" => "https://registry.npmjs.org/@scope/pkg/-/pkg-2.0.0.tgz",
          "integrity" => "sha512-scoped",
          "optionalDependencies" => %{"optional-pkg" => "^1.0.0"},
          "hasInstallScript" => true
        },
        "node_modules/@scope/pkg/node_modules/nested" => %{
          "version" => "1.0.0",
          "resolved" => "https://registry.npmjs.org/nested/-/nested-1.0.0.tgz"
        },
        "node_modules/workspace-package" => %{
          "resolved" => "apps/workspace-package",
          "link" => true
        }
      }
    })
  end

  defp write_json!(path, data), do: File.write!(path, NPM.JSON.encode_pretty(data))

  defp read_json!(path) do
    {:ok, data} = NPM.JSON.read_file(path)
    data
  end
end
