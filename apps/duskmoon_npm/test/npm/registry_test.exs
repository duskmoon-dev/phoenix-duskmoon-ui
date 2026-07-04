defmodule NPM.RegistryTest do
  use ExUnit.Case, async: false

  setup do
    old_registry = Application.get_env(:duskmoon_npm, :registry)
    old_allowed = Application.get_env(:duskmoon_npm, :allowed_registries)
    old_env_allowed = System.get_env("NPM_EX_ALLOWED_REGISTRIES")

    System.delete_env("NPM_EX_ALLOWED_REGISTRIES")

    on_exit(fn ->
      restore_app_env(:registry, old_registry)
      restore_app_env(:allowed_registries, old_allowed)
      restore_env("NPM_EX_ALLOWED_REGISTRIES", old_env_allowed)
    end)

    :ok
  end

  test "rewrites integrity-protected tarballs to the configured registry origin" do
    Application.put_env(:duskmoon_npm, :registry, "https://npm.gsmlg.dev")
    Application.put_env(:duskmoon_npm, :allowed_registries, ["https://npm.gsmlg.dev"])

    assert NPM.Registry.__normalized_tarball_url__(
             "@scope/pkg",
             "1.2.3",
             "https://registry.npmjs.org/@scope/pkg/-/pkg-1.2.3.tgz",
             "sha512-hash"
           ) == "https://npm.gsmlg.dev/@scope%2fpkg/-/pkg-1.2.3.tgz"
  end

  test "keeps no-integrity cross-origin tarballs for later fetch-time validation" do
    Application.put_env(:duskmoon_npm, :registry, "https://npm.gsmlg.dev")
    Application.put_env(:duskmoon_npm, :allowed_registries, ["https://npm.gsmlg.dev"])

    assert NPM.Registry.__normalized_tarball_url__(
             "pkg",
             "1.2.3",
             "https://registry.npmjs.org/pkg/-/pkg-1.2.3.tgz",
             ""
           ) == "https://registry.npmjs.org/pkg/-/pkg-1.2.3.tgz"
  end

  defp restore_app_env(key, nil), do: Application.delete_env(:duskmoon_npm, key)
  defp restore_app_env(key, value), do: Application.put_env(:duskmoon_npm, key, value)

  defp restore_env(key, nil), do: System.delete_env(key)
  defp restore_env(key, value), do: System.put_env(key, value)
end
