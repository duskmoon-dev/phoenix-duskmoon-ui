defmodule DuskmoonBundler.HMR.ModuleGraphTest do
  use ExUnit.Case, async: false

  alias DuskmoonBundler.HMR.ModuleGraph

  setup do
    ModuleGraph.clear()
    :ok
  end

  test "tracks URL id file and importer links" do
    ModuleGraph.update_module("/assets/dep.ts", "/app/dep.ts", "/app/dep.ts", [])
    ModuleGraph.update_module("/assets/app.ts", "/app/app.ts", "/app/app.ts", ["/app/dep.ts"])

    dep = ModuleGraph.get_by_id("/app/dep.ts")
    app = ModuleGraph.get_by_url("/assets/app.ts")

    assert app.file == "/app/app.ts"
    assert MapSet.member?(app.imports, "/app/dep.ts")
    assert MapSet.member?(dep.importers, "/app/app.ts")
  end

  test "keeps query variants for the same file" do
    ModuleGraph.update_module("/assets/style.css", "/app/style.css", "/app/style.css", [],
      type: :css
    )

    ModuleGraph.update_module(
      "/assets/style.css?import",
      "/app/style.css?import",
      "/app/style.css",
      [],
      type: :js
    )

    nodes = ModuleGraph.get_by_file("/app/style.css")

    assert Enum.map(nodes, & &1.id) |> Enum.sort() == ["/app/style.css", "/app/style.css?import"]
  end

  test "invalidates all file variants" do
    ModuleGraph.update_module("/assets/style.css", "/app/style.css", "/app/style.css", [],
      type: :css
    )

    ModuleGraph.update_module(
      "/assets/style.css?import",
      "/app/style.css?import",
      "/app/style.css",
      [],
      type: :js
    )

    assert [_first, _second] = ModuleGraph.invalidate_file("/app/style.css", 123)
    assert Enum.all?(ModuleGraph.get_by_file("/app/style.css"), &(&1.last_invalidated_at == 123))
  end

  test "links importers when imported module is registered later" do
    ModuleGraph.update_module("/assets/app.ts", "/assets/app.ts", "/app/app.ts", [
      "/assets/dep.ts"
    ])

    ModuleGraph.update_module("/assets/dep.ts", "/assets/dep.ts", "/app/dep.ts", [])

    assert MapSet.member?(ModuleGraph.get_by_id("/assets/dep.ts").importers, "/assets/app.ts")
  end

  test "updates importer links when imports change" do
    ModuleGraph.update_module("/assets/a.ts", "/app/a.ts", "/app/a.ts", [])
    ModuleGraph.update_module("/assets/b.ts", "/app/b.ts", "/app/b.ts", [])
    ModuleGraph.update_module("/assets/app.ts", "/app/app.ts", "/app/app.ts", ["/app/a.ts"])
    ModuleGraph.update_module("/assets/app.ts", "/app/app.ts", "/app/app.ts", ["/app/b.ts"])

    refute MapSet.member?(ModuleGraph.get_by_id("/app/a.ts").importers, "/app/app.ts")
    assert MapSet.member?(ModuleGraph.get_by_id("/app/b.ts").importers, "/app/app.ts")
  end
end
