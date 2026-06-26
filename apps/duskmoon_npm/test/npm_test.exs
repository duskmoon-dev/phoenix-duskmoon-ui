defmodule NPMTest do
  use ExUnit.Case, async: true

  @bundler_mix_exs Path.expand("../../duskmoon_bundler/mix.exs", __DIR__)

  test "duskmoon_npm exposes the NPM public API" do
    assert {:module, NPM} = Code.ensure_loaded(NPM)
    assert NPM in Application.spec(:duskmoon_npm, :modules)
  end

  test "duskmoon_npm version matches duskmoon_bundler" do
    assert Application.spec(:duskmoon_npm, :vsn) |> to_string() == bundler_version()
  end

  test "empty dependency resolution succeeds without registry access" do
    assert {:ok, %{}} = NPM.Resolver.resolve(%{})
  end

  test "bundled npm semver parser supports npm ranges" do
    assert NPMSemver.matches?("1.2.3", "^1.0.0")
    refute NPMSemver.matches?("2.0.0", "^1.0.0")
    assert {:ok, ">= 1.2.3 and < 1.3.0-0"} = NPMSemver.to_elixir_requirement("~1.2.3")
  end

  defp bundler_version do
    [_, version] = Regex.run(~r/@version "([^"]+)"/, File.read!(@bundler_mix_exs))
    version
  end
end
