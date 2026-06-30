defmodule NPM.WorkspaceTest do
  use ExUnit.Case, async: true

  setup do
    tmp_dir =
      Path.join([
        System.tmp_dir!(),
        "npm_workspace_test_#{System.unique_integer([:positive])}"
      ])

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, tmp_dir: tmp_dir}
  end

  test "reads root and workspace package manifests", %{tmp_dir: tmp_dir} do
    write_package!(tmp_dir, %{
      "name" => "umbrella",
      "private" => true,
      "workspaces" => ["apps/*"],
      "dependencies" => %{"tailwindcss" => "4.3.0"}
    })

    write_package!(Path.join([tmp_dir, "apps", "ui"]), %{
      "name" => "ui",
      "version" => "1.0.0",
      "dependencies" => %{"lit" => "^3.0.0"}
    })

    write_package!(Path.join([tmp_dir, "apps", "web"]), %{
      "name" => "web",
      "private" => true,
      "dependencies" => %{
        "axios" => "^1.0.0",
        "phoenix_html" => "file:../../deps/phoenix_html",
        "ui" => "workspace:*"
      },
      "devDependencies" => %{"postcss" => "8.5.15"}
    })

    write_package!(Path.join([tmp_dir, "deps", "phoenix_html"]), %{
      "name" => "phoenix_html",
      "version" => "4.3.0"
    })

    assert {:ok, project} = NPM.Workspace.read_all(tmp_dir)

    assert project.dependencies == %{
             "axios" => "^1.0.0",
             "lit" => "^3.0.0",
             "tailwindcss" => "4.3.0"
           }

    assert project.dev_dependencies == %{"postcss" => "8.5.15"}
    assert project.optional_dependencies == %{}

    assert %{
             "phoenix_html" => phoenix_html_path,
             "ui" => ui_path,
             "web" => web_path
           } = project.local_links

    assert phoenix_html_path == Path.join([tmp_dir, "deps", "phoenix_html"])
    assert ui_path == Path.join([tmp_dir, "apps", "ui"])
    assert web_path == Path.join([tmp_dir, "apps", "web"])

    assert {:ok, deps} = NPM.Workspace.install_dependencies(project)
    assert Map.keys(deps) |> Enum.sort() == ["axios", "lit", "postcss", "tailwindcss"]
  end

  test "reports workspace protocol dependencies outside configured workspaces", %{
    tmp_dir: tmp_dir
  } do
    write_package!(tmp_dir, %{
      "name" => "umbrella",
      "private" => true,
      "workspaces" => ["apps/*"]
    })

    write_package!(Path.join([tmp_dir, "apps", "web"]), %{
      "name" => "web",
      "dependencies" => %{"missing" => "workspace:*"}
    })

    assert {:error, {:unknown_workspace_dependency, "missing", package_path}} =
             NPM.Workspace.read_all(tmp_dir)

    assert package_path == Path.join([tmp_dir, "apps", "web", "package.json"])
  end

  defp write_package!(dir, data) do
    File.mkdir_p!(dir)
    File.write!(Path.join(dir, "package.json"), NPM.JSON.encode_pretty(data))
  end
end
