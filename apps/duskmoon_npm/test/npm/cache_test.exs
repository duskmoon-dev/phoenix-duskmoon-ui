defmodule NPM.CacheTest do
  use ExUnit.Case, async: false

  alias NPM.Cache

  setup do
    old_env = System.get_env("NPM_EX_ALLOWED_REGISTRIES")
    old_allowed = Application.get_env(:duskmoon_npm, :allowed_registries)

    System.delete_env("NPM_EX_ALLOWED_REGISTRIES")

    on_exit(fn ->
      restore_env("NPM_EX_ALLOWED_REGISTRIES", old_env)
      restore_app_env(:allowed_registries, old_allowed)
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

  defp restore_env(key, nil), do: System.delete_env(key)
  defp restore_env(key, value), do: System.put_env(key, value)

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)
end
