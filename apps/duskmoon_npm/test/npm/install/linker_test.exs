defmodule NPM.Install.LinkerTest do
  use ExUnit.Case, async: false

  alias NPM.Install.Linker

  setup do
    old_cache_dir = Application.get_env(:duskmoon_npm, :cache_dir)

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_linker_test_#{System.unique_integer([:positive])}"
      ])

    cache_dir = Path.join(tmp_dir, "cache-root")
    Application.put_env(:duskmoon_npm, :cache_dir, cache_dir)
    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      restore_app_env(:cache_dir, old_cache_dir)
      File.rm_rf!(tmp_dir)
    end)

    {:ok, tmp_dir: tmp_dir}
  end

  describe "__parent_entry_version__/1" do
    test "accepts resolver flat entries and lockfile entries" do
      assert Linker.__parent_entry_version__("1.2.3") == "1.2.3"
      assert Linker.__parent_entry_version__(%{version: "1.2.3"}) == "1.2.3"
      assert Linker.__parent_entry_version__(%{"version" => "1.2.3"}) == "1.2.3"
      assert Linker.__parent_entry_version__(%{}) == nil
    end
  end

  test "nested linking accepts resolver flat output without matching parents" do
    NPM.Resolver.clear_cache()

    assert :ok =
             Linker.link_nested(
               %{"nested-dep" => :nested},
               %{"parent-dep" => "1.2.3"},
               System.tmp_dir!()
             )
  end

  test "links cached packages with symlinks by default", %{tmp_dir: tmp_dir} do
    cache_path = write_cached_package!("cached-pkg", "1.0.0")
    node_modules = Path.join(tmp_dir, "node_modules")

    assert :ok = Linker.link(%{"cached-pkg" => lock_entry("1.0.0")}, node_modules)
    assert {:ok, ^cache_path} = File.read_link(Path.join(node_modules, "cached-pkg"))
  end

  test "returns cache population errors directly", %{tmp_dir: tmp_dir} do
    node_modules = Path.join(tmp_dir, "node_modules")

    entry = %{
      version: "1.0.0",
      integrity: "",
      tarball: "https://blocked.example/blocked-pkg-1.0.0.tgz",
      dependencies: %{},
      optional_dependencies: %{},
      has_install_script: false
    }

    assert {:error, %NPM.Security.RegistryPolicy.Error{}} =
             Linker.link(%{"blocked-pkg" => entry}, node_modules)
  end

  test "skips optional descendants of a platform-incompatible package", %{
    tmp_dir: tmp_dir
  } do
    root = "root-pkg"
    optional = "other-platform-pkg"
    descendant = "optional-descendant-pkg"
    shared = "shared-required-pkg"
    node_modules = Path.join(tmp_dir, "node_modules")

    write_cached_package!(root, "1.0.0")
    write_cached_package!(shared, "1.0.0")
    put_incompatible_packument!(optional, "1.0.0")

    lockfile = %{
      root =>
        lock_entry("1.0.0",
          tarball: "https://registry.npmjs.org/root-pkg/-/root-pkg-1.0.0.tgz",
          dependencies: %{shared => "1.0.0"},
          optional_dependencies: %{optional => "1.0.0"}
        ),
      optional =>
        lock_entry("1.0.0",
          tarball: "https://blocked.example/other-platform-pkg-1.0.0.tgz",
          dependencies: %{descendant => "1.0.0", shared => "1.0.0"},
          optional: true
        ),
      descendant =>
        lock_entry("1.0.0",
          tarball: "https://blocked.example/optional-descendant-pkg-1.0.0.tgz",
          optional: true
        ),
      shared =>
        lock_entry("1.0.0",
          tarball:
            "https://registry.npmjs.org/shared-required-pkg/-/shared-required-pkg-1.0.0.tgz"
        )
    }

    assert :ok = Linker.link(lockfile, node_modules)
    assert File.exists?(Path.join([node_modules, root, "package.json"]))
    assert File.exists?(Path.join([node_modules, shared, "package.json"]))
    refute File.exists?(Path.join([node_modules, optional, "package.json"]))
    refute File.exists?(Path.join([node_modules, descendant, "package.json"]))
  end

  test "rejects unsafe nested lockfile locations before filesystem access", %{
    tmp_dir: tmp_dir
  } do
    node_modules = Path.join(tmp_dir, "node_modules")
    entry = lock_entry("1.0.0")

    unsafe_locations = [
      "node_modules/parent/node_modules/..",
      "node_modules/parent/node_modules/",
      "node_modules/parent/extra/node_modules/child",
      "node_modules/../../escaped/node_modules/child",
      "/node_modules/parent/node_modules/child"
    ]

    Enum.each(unsafe_locations, fn location ->
      assert {:error, {:invalid_nested_package_location, ^location}} =
               Linker.link_nested_lockfile(%{location => entry}, node_modules)
    end)

    refute File.exists?(Path.join(tmp_dir, "escaped"))
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

  defp lock_entry(version, opts \\ []) do
    %{
      version: version,
      integrity: "",
      tarball:
        Keyword.get(
          opts,
          :tarball,
          "https://registry.npmjs.org/cached-pkg/-/cached-pkg-#{version}.tgz"
        ),
      dependencies: Keyword.get(opts, :dependencies, %{}),
      optional_dependencies: Keyword.get(opts, :optional_dependencies, %{}),
      has_install_script: false
    }
    |> maybe_put_optional(Keyword.get(opts, :optional, false))
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

  defp maybe_put_optional(entry, true), do: Map.put(entry, :optional, true)
  defp maybe_put_optional(entry, false), do: entry

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
