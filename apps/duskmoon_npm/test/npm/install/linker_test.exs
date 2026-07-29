defmodule NPM.Install.LinkerTest do
  use ExUnit.Case, async: false

  alias NPM.Install.Linker
  alias NPM.Resolution.PackageResolver

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

  test "copies cached packages so sibling dependencies resolve from node_modules", %{
    tmp_dir: tmp_dir
  } do
    importer = "importer-pkg"
    sibling = "sibling-pkg"
    importer_cache_path = write_cached_package!(importer, "1.0.0")
    sibling_cache_path = write_cached_package!(sibling, "2.0.0")
    node_modules = Path.join(tmp_dir, "node_modules")

    File.write!(
      Path.join(importer_cache_path, "index.js"),
      ~s[module.exports = require("#{sibling}");]
    )

    File.write!(Path.join(sibling_cache_path, "index.js"), ~s[module.exports = "resolved";])

    lockfile = %{
      importer => %{
        lock_entry(importer, "1.0.0")
        | dependencies: %{sibling => "2.0.0"}
      },
      sibling => lock_entry(sibling, "2.0.0")
    }

    assert :ok = Linker.link(lockfile, node_modules)

    installed_importer = Path.join(node_modules, importer)
    installed_sibling = Path.join(node_modules, sibling)

    assert {:ok, %File.Stat{type: :directory}} = File.lstat(installed_importer)
    assert {:ok, %File.Stat{type: :directory}} = File.lstat(installed_sibling)
    assert File.read!(Path.join(installed_importer, "index.js")) =~ sibling

    assert File.read!(Path.join(installed_importer, "package.json")) ==
             File.read!(Path.join(importer_cache_path, "package.json"))

    assert File.read!(Path.join(installed_sibling, "package.json")) ==
             File.read!(Path.join(sibling_cache_path, "package.json"))

    canonical_importer =
      case File.read_link(installed_importer) do
        {:ok, target} -> Path.expand(target, Path.dirname(installed_importer))
        {:error, :einval} -> installed_importer
      end

    assert {:ok, sibling_entry} = PackageResolver.resolve(sibling, canonical_importer)
    assert sibling_entry == Path.join(installed_sibling, "index.js")
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

    File.write!(Path.join(cache_path, ".npm-ex-cache-complete"), "1\n")

    cache_path
  end

  defp lock_entry(package, version) do
    %{
      version: version,
      integrity: "",
      tarball: "https://registry.npmjs.org/#{package}/-/#{package}-#{version}.tgz",
      dependencies: %{},
      optional_dependencies: %{},
      has_install_script: false
    }
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
