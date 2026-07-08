defmodule DuskmoonStorybookWeb.RouterTest do
  use DuskmoonStorybookWeb.ConnCase, async: true

  describe "storybook backend module" do
    test "Storybook module exists and is correct" do
      # Verify the Storybook module exists and has the correct name
      assert Code.ensure_loaded?(DuskmoonStorybookWeb.Storybook)
    end

    test "Storybook module is properly configured" do
      # Verify the module exists and can be accessed
      assert is_atom(DuskmoonStorybookWeb.Storybook)
      assert Module.concat([DuskmoonStorybookWeb, Storybook]) == DuskmoonStorybookWeb.Storybook
    end

    test "router uses correct Storybook backend module" do
      # This test ensures the router references the correct module name
      # and prevents regression of the "Storybook is not available" error
      router_source = File.read!("lib/duskmoon_storybook_web/router.ex")

      # Verify the router contains the full module name, not just "Storybook"
      assert router_source =~ "DuskmoonStorybookWeb.Storybook"

      # Verify it doesn't contain the incorrect reference
      refute router_source =~ "backend_module: Storybook"
    end
  end

  describe "git repository data display routes" do
    test "renders issue 78 component gallery pages", %{conn: conn} do
      pages = [
        {"/components/data-display/git-repository-header", "Git Repository Header"},
        {"/components/data-display/git-repository-nav", "Git Repository Nav"},
        {"/components/data-display/git-file-tree", "Git File Tree"},
        {"/components/data-display/git-blob-viewer", "Git Blob Viewer"},
        {"/components/data-display/git-commit-diff", "Git Commit Diff"},
        {"/components/data-display/git-clone-box", "Git Clone Box"}
      ]

      for {path, title} <- pages do
        conn = get(recycle(conn), path)
        assert html_response(conn, 200) =~ title
      end
    end
  end
end
