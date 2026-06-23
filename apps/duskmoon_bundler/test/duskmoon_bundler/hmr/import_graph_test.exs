defmodule DuskmoonBundler.HMR.ImportGraphTest do
  use ExUnit.Case, async: false

  setup do
    DuskmoonBundler.HMR.ImportGraph.clear()
    :ok
  end

  test "tracks imports for a file" do
    DuskmoonBundler.HMR.ImportGraph.update("/src/App.vue", ["vue", "./utils"])
    assert DuskmoonBundler.HMR.ImportGraph.imports_of("/src/App.vue") == ["vue", "./utils"]
  end

  test "finds dependents of a specifier" do
    DuskmoonBundler.HMR.ImportGraph.update("/src/App.vue", ["./utils", "vue"])
    DuskmoonBundler.HMR.ImportGraph.update("/src/Page.vue", ["./utils"])
    DuskmoonBundler.HMR.ImportGraph.update("/src/main.ts", ["vue"])

    dependents = DuskmoonBundler.HMR.ImportGraph.dependents("./utils")
    assert "/src/App.vue" in dependents
    assert "/src/Page.vue" in dependents
    refute "/src/main.ts" in dependents
  end

  test "update replaces previous imports" do
    DuskmoonBundler.HMR.ImportGraph.update("/src/App.vue", ["vue", "./old"])
    DuskmoonBundler.HMR.ImportGraph.update("/src/App.vue", ["vue", "./new"])
    assert DuskmoonBundler.HMR.ImportGraph.imports_of("/src/App.vue") == ["vue", "./new"]
  end

  test "update_from_compiled extracts imports" do
    compiled = """
    import './setup'
    const pages = { './pages/home.ts': () => import('./pages/home.ts') }
    """

    DuskmoonBundler.HMR.ImportGraph.update_from_compiled("/src/routes.ts", compiled)

    assert "./setup" in DuskmoonBundler.HMR.ImportGraph.imports_of("/src/routes.ts")
  end

  test "remove deletes a file from the graph" do
    DuskmoonBundler.HMR.ImportGraph.update("/src/App.vue", ["vue"])
    DuskmoonBundler.HMR.ImportGraph.remove("/src/App.vue")
    assert DuskmoonBundler.HMR.ImportGraph.imports_of("/src/App.vue") == []
  end
end
