defmodule Mix.Tasks.Npm.VerifyTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    old_cwd = File.cwd!()

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_verify_test_#{System.unique_integer([:positive])}"
      ])

    File.mkdir_p!(tmp_dir)
    File.cd!(tmp_dir)
    File.write!("package.json", NPM.JSON.encode_pretty(%{"name" => "verify-test"}))

    on_exit(fn ->
      File.cd!(old_cwd)
      File.rm_rf!(tmp_dir)
    end)

    :ok
  end

  test "ignores an absent platform-incompatible optional package" do
    optional = "verify-optional-#{System.unique_integer([:positive])}"
    put_incompatible_packument!(optional, "1.0.0")

    write_lockfile!(%{
      "required" => lock_entry(optional_dependencies: %{optional => "1.0.0"}),
      optional => lock_entry()
    })

    File.mkdir_p!("node_modules/required")

    output =
      capture_io(fn ->
        assert :ok = Mix.Tasks.Npm.Verify.run([])
      end)

    assert output =~ "node_modules matches lockfile (1 packages)"
    refute output =~ "missing:"
  end

  test "accepts an installed platform-incompatible optional package" do
    optional = "verify-installed-optional-#{System.unique_integer([:positive])}"
    put_incompatible_packument!(optional, "1.0.0")

    write_lockfile!(%{
      "required" => lock_entry(optional_dependencies: %{optional => "1.0.0"}),
      optional => lock_entry(optional: true)
    })

    File.mkdir_p!("node_modules/required")
    File.mkdir_p!(Path.join("node_modules", optional))

    output =
      capture_io(fn ->
        assert :ok = Mix.Tasks.Npm.Verify.run([])
      end)

    assert output =~ "node_modules matches lockfile (1 packages)"
    refute output =~ "extra:"
  end

  test "raises when a required package is missing" do
    write_lockfile!(%{"required" => lock_entry()})

    output =
      capture_io(:stderr, fn ->
        assert_raise Mix.Error, ~r/node_modules does not match lockfile/, fn ->
          Mix.Tasks.Npm.Verify.run([])
        end
      end)

    assert output =~ "missing: required"
  end

  test "raises when an extraneous package is installed" do
    write_lockfile!(%{"required" => lock_entry()})
    File.mkdir_p!("node_modules/required")
    File.mkdir_p!("node_modules/extra")

    output =
      capture_io(:stderr, fn ->
        assert_raise Mix.Error, ~r/node_modules does not match lockfile/, fn ->
          Mix.Tasks.Npm.Verify.run([])
        end
      end)

    assert output =~ "extra: extra"
  end

  test "raises when workspace node_modules can shadow a root package" do
    package = "@duskmoon-dev/core"
    workspace_dir = Path.join(["apps", "sigma_web"])

    write_package!(".", %{
      "name" => "sigma",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(workspace_dir, %{
      "name" => "sigma-web",
      "version" => "1.0.0",
      "dependencies" => %{package => "1.18.4"}
    })

    write_lockfile!(%{package => lock_entry()})

    write_package!(Path.join(["node_modules", package]), %{
      "name" => package,
      "version" => "1.18.4"
    })

    write_package!(Path.join(["node_modules", "sigma-web"]), %{
      "name" => "sigma-web",
      "version" => "1.0.0"
    })

    write_package!(Path.join([workspace_dir, "node_modules", package]), %{
      "name" => package,
      "version" => "1.17.0"
    })

    output =
      capture_io(:stderr, fn ->
        assert_raise Mix.Error, ~r/node_modules does not match lockfile/, fn ->
          Mix.Tasks.Npm.Verify.run([])
        end
      end)

    assert output =~ "shadowing: apps/sigma_web/node_modules/@duskmoon-dev/core"
  end

  test "raises when the lockfile cannot be read" do
    File.mkdir_p!("package-lock.json")

    assert_raise Mix.Error, ~r/npm\.verify failed: :eisdir/, fn ->
      Mix.Tasks.Npm.Verify.run([])
    end
  end

  defp write_lockfile!(lockfile) do
    assert :ok = NPM.Lockfile.write(lockfile)
  end

  defp write_package!(dir, data) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "package.json"), NPM.JSON.encode_pretty(data))
  end

  defp lock_entry(opts \\ []) do
    %{
      version: "1.0.0",
      integrity: "",
      tarball: "https://registry.npmjs.org/verify-test/-/verify-test-1.0.0.tgz",
      dependencies: %{},
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
end
