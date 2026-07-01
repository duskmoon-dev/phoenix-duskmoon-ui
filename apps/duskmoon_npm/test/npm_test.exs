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

  test "resolver keeps async prefetch failures" do
    error = %NPM.Security.RegistryPolicy.Error{
      url: "https://registry.npmjs.org/pkg/-/pkg-1.0.0.tgz",
      allowed: ["https://npm.gsmlg.dev"]
    }

    assert {:error, {^error, []}} = NPM.Resolver.collect_prefetch_results([{:exit, {error, []}}])

    assert {:error, {^error, []}} =
             NPM.Resolver.collect_prefetch_results([{:ok, {:error, {error, []}}}])

    assert NPM.Resolver.format_prefetch_reason({error, []}) ==
             "untrusted npm registry URL https://registry.npmjs.org/pkg/-/pkg-1.0.0.tgz. Allowed registry origins: https://npm.gsmlg.dev."
  end

  test "resolver prefetch timeout can be configured per call" do
    original_timeout = Application.get_env(:duskmoon_npm, :prefetch_timeout)

    Application.put_env(:duskmoon_npm, :prefetch_timeout, 45_000)

    try do
      assert NPM.Resolver.prefetch_timeout([]) == 45_000
      assert NPM.Resolver.prefetch_timeout(prefetch_timeout: 120_000) == 120_000
    after
      case original_timeout do
        nil -> Application.delete_env(:duskmoon_npm, :prefetch_timeout)
        value -> Application.put_env(:duskmoon_npm, :prefetch_timeout, value)
      end
    end
  end

  test "bundled npm semver parser supports npm ranges" do
    assert NPMSemver.matches?("1.2.3", "^1.0.0")
    refute NPMSemver.matches?("2.0.0", "^1.0.0")
    assert {:ok, ">= 1.2.3 and < 1.3.0-0"} = NPMSemver.to_elixir_requirement("~1.2.3")
    assert {:ok, _} = NPMSemver.to_hex_constraint(">=1.0.0 <2.0.0 >=1.5.0")
    assert {:ok, _} = NPMSemver.to_hex_constraint("^11.1.0 || ^12 || ^13 || ^14.0.0")
  end

  test "resolver detects nested conflicts with range constraints" do
    message = """
    Because "@duskmoon-dev/el-markdown >= 1.5.0" depends on "marked 18.0.4" and "mermaid >= 11.13.0" depends on "marked ~> 16.3", "@duskmoon-dev/el-markdown >= 1.5.0" is incompatible with "mermaid >= 11.13.0".
    """

    assert NPM.Resolver.extract_conflict_package(message) == "marked"
  end

  test "resolver detects nested conflicts through dependency chains" do
    message = """
    Because "d3 >= 7.0.0" depends on "d3-dsv ~> 3.0" which depends on "commander ~> 7.0", "d3 >= 7.0.0" requires "commander ~> 7.0".
    And because "katex >= 0.16.5" depends on "commander ~> 8.3", "d3 >= 7.0.0" is incompatible with "katex >= 0.16.5".
    """

    assert NPM.Resolver.extract_conflict_package(message) == "commander"
  end

  test "resolver extracts all nested conflicts from one solver message" do
    message = """
    Because "pkg-a >= 1.0.0" depends on "left-pad 1.0.0" and "pkg-b >= 1.0.0" depends on "left-pad 2.0.0", "pkg-a >= 1.0.0" is incompatible with "pkg-b >= 1.0.0".
    And because "pkg-c >= 1.0.0" depends on "right-pad 1.0.0" and "pkg-d >= 1.0.0" depends on "right-pad 2.0.0", "pkg-c >= 1.0.0" is incompatible with "pkg-d >= 1.0.0".
    """

    assert NPM.Resolver.extract_conflict_packages(message) == ["left-pad", "right-pad"]
  end

  defp bundler_version do
    [_, version] = Regex.run(~r/@version "([^"]+)"/, File.read!(@bundler_mix_exs))
    version
  end
end
