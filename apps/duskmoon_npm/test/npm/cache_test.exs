defmodule NPM.CacheTest do
  use ExUnit.Case, async: false

  alias NPM.Cache

  setup do
    old_env = System.get_env("NPM_EX_ALLOWED_REGISTRIES")
    old_allowed = Application.get_env(:duskmoon_npm, :allowed_registries)
    old_cache_dir = Application.get_env(:duskmoon_npm, :cache_dir)

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_cache_test_#{System.unique_integer([:positive])}"
      ])

    System.delete_env("NPM_EX_ALLOWED_REGISTRIES")
    Application.put_env(:duskmoon_npm, :cache_dir, Path.join(tmp_dir, "cache-root"))
    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      restore_env("NPM_EX_ALLOWED_REGISTRIES", old_env)
      restore_app_env(:allowed_registries, old_allowed)
      restore_app_env(:cache_dir, old_cache_dir)
      File.rm_rf!(tmp_dir)
    end)
  end

  test "uses allowed registry origins as integrity-protected tarball fallbacks" do
    original =
      "https://nexus.gsmlg.net/repository/npm/rehype-parse/-/rehype-parse-9.0.1.tgz"

    Application.put_env(:duskmoon_npm, :allowed_registries, [
      "https://nexus.gsmlg.net",
      "https://registry.npmjs.org",
      "https://registry.npmmirror.com"
    ])

    assert Cache.__candidate_tarball_urls__("rehype-parse", "9.0.1", original, "sha512-hash") ==
             [
               original,
               "https://registry.npmjs.org/rehype-parse/-/rehype-parse-9.0.1.tgz",
               "https://registry.npmmirror.com/rehype-parse/-/rehype-parse-9.0.1.tgz"
             ]
  end

  test "does not add fallback tarball URLs without integrity" do
    original =
      "https://nexus.gsmlg.net/repository/npm/rehype-parse/-/rehype-parse-9.0.1.tgz"

    Application.put_env(:duskmoon_npm, :allowed_registries, [
      "https://nexus.gsmlg.net",
      "https://registry.npmjs.org"
    ])

    assert Cache.__candidate_tarball_urls__("rehype-parse", "9.0.1", original, "") == [original]
  end

  test "honors allowed registry order for integrity-protected tarballs" do
    original =
      "https://nexus.gsmlg.net/repository/npm/rehype-parse/-/rehype-parse-9.0.1.tgz"

    Application.put_env(:duskmoon_npm, :allowed_registries, [
      "https://registry.npmjs.org",
      "https://nexus.gsmlg.net"
    ])

    assert Cache.__candidate_tarball_urls__("rehype-parse", "9.0.1", original, "sha512-hash") ==
             [
               "https://registry.npmjs.org/rehype-parse/-/rehype-parse-9.0.1.tgz",
               original
             ]
  end

  test "builds fallback tarball URLs for scoped packages" do
    original =
      "https://nexus.gsmlg.net/repository/npm/@scope/package/-/package-1.2.3.tgz"

    Application.put_env(:duskmoon_npm, :allowed_registries, [
      "https://nexus.gsmlg.net",
      "https://registry.npmjs.org"
    ])

    assert Cache.__candidate_tarball_urls__("@scope/package", "1.2.3", original, "sha512-hash") ==
             [
               original,
               "https://registry.npmjs.org/@scope%2fpackage/-/package-1.2.3.tgz"
             ]
  end

  test "does not reuse partially extracted package caches" do
    cache_path = Cache.package_dir("partial-package", "1.0.0")
    File.mkdir_p!(cache_path)

    File.write!(
      Path.join(cache_path, "package.json"),
      NPM.JSON.encode_pretty(%{"name" => "partial-package", "version" => "1.0.0"})
    )

    refute Cache.cached?("partial-package", "1.0.0")

    File.write!(Path.join(cache_path, ".npm-ex-cache-complete"), "1\n")

    assert Cache.cached?("partial-package", "1.0.0")
  end

  defp restore_env(key, nil), do: System.delete_env(key)
  defp restore_env(key, value), do: System.put_env(key, value)

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
