defmodule Mix.Tasks.Npm.RebuildTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    old_cwd = File.cwd!()

    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_rebuild_test_#{System.unique_integer([:positive])}"
      ])

    project_dir = Path.join(tmp_dir, "project")
    File.mkdir_p!(project_dir)
    File.cd!(project_dir)

    write_package!(".", %{
      "name" => "rebuild-test",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(Path.join(["apps", "web"]), %{
      "name" => "web",
      "version" => "1.0.0"
    })

    on_exit(fn ->
      File.cd!(old_cwd)
      File.rm_rf!(tmp_dir)
    end)

    :ok
  end

  test "removes root and workspace-local node_modules before rebuilding" do
    root_node_modules = "node_modules"
    workspace_node_modules = Path.join(["apps", "web", "node_modules"])
    unmanaged_node_modules = Path.join(["vendor", "other", "node_modules"])

    File.mkdir_p!(Path.join(root_node_modules, "current"))
    File.mkdir_p!(Path.join(workspace_node_modules, "stale"))
    File.mkdir_p!(Path.join(unmanaged_node_modules, "preserved"))

    output =
      capture_io(fn ->
        assert :ok = Mix.Tasks.Npm.Rebuild.run([])
      end)

    refute File.exists?(root_node_modules)
    refute File.exists?(workspace_node_modules)
    assert File.exists?(unmanaged_node_modules)
    assert output =~ "Removed node_modules/"
    assert output =~ "Removed apps/web/node_modules/"
  end

  test "refuses to remove node_modules outside the workspace root" do
    outside_dir = Path.expand("../outside-workspace")
    root_node_modules = "node_modules"
    outside_node_modules = Path.join(outside_dir, "node_modules")

    write_package!(".", %{
      "name" => "rebuild-test",
      "private" => true,
      "workspaces" => ["../outside-workspace"]
    })

    write_package!(outside_dir, %{"name" => "outside-workspace", "version" => "1.0.0"})
    File.mkdir_p!(Path.join(root_node_modules, "preserved"))
    File.mkdir_p!(Path.join(outside_node_modules, "preserved"))

    assert_raise Mix.Error, ~r/npm\.rebuild refused workspace outside root/, fn ->
      Mix.Tasks.Npm.Rebuild.run([])
    end

    assert File.exists?(root_node_modules)
    assert File.exists?(outside_node_modules)
  end

  defp write_package!(dir, data) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "package.json"), NPM.JSON.encode_pretty(data))
  end
end
