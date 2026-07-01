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

  defp write_cached_package!(name, version) do
    cache_path = NPM.Cache.package_dir(name, version)
    File.mkdir_p!(cache_path)

    File.write!(
      Path.join(cache_path, "package.json"),
      NPM.JSON.encode_pretty(%{"name" => name, "version" => version})
    )

    cache_path
  end

  defp lock_entry(version) do
    %{
      version: version,
      integrity: "",
      tarball: "https://registry.npmjs.org/cached-pkg/-/cached-pkg-#{version}.tgz",
      dependencies: %{},
      optional_dependencies: %{},
      has_install_script: false
    }
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
