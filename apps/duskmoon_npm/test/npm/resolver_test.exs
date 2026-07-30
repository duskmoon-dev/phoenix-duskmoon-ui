defmodule NPM.ResolverTest do
  use ExUnit.Case, async: false

  setup do
    ensure_resolver_cache()
    NPM.Resolver.clear_cache()
    on_exit(&NPM.Resolver.clear_cache/0)
  end

  test "stable ranges ignore prerelease-heavy package versions" do
    cache_packument(%{
      "1.0.0" => version_info(),
      "1.1.0-beta.1" => version_info(),
      "1.1.0-beta.2" => version_info()
    })

    assert {:ok, %{"version-heavy-package" => "1.0.0"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.0.0"})
  end

  test "ranges that explicitly request a prerelease keep prerelease versions" do
    cache_packument(%{
      "1.0.0" => version_info(),
      "1.1.0-beta.1" => version_info(),
      "1.1.0-beta.2" => version_info()
    })

    assert {:ok, %{"version-heavy-package" => "1.1.0-beta.2"}} =
             NPM.Resolver.resolve(%{"version-heavy-package" => "^1.1.0-beta.1"})
  end

  defp ensure_resolver_cache do
    if :ets.whereis(:npm_resolver_cache) == :undefined do
      :ets.new(:npm_resolver_cache, [:named_table, :set, :public])
    end
  end

  defp cache_packument(versions) do
    :ets.insert(
      :npm_resolver_cache,
      {"version-heavy-package", %{name: "version-heavy-package", versions: versions}}
    )
  end

  defp version_info do
    %{
      dependencies: %{},
      optional_dependencies: %{},
      peer_dependencies: %{},
      peer_dependencies_meta: %{},
      os: [],
      cpu: []
    }
  end
end
