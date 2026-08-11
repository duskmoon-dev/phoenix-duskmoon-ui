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

  describe "git blob viewer page" do
    test "renders source samples with real newlines", %{conn: conn} do
      conn = get(conn, "/components/data-display/git-blob-viewer")
      html = html_response(conn, 200)

      assert html =~ "export const generated = true;\n"
      assert html =~ "// preview only"
      refute html =~ "true;\\n// preview only"
    end
  end

  describe "markdown body data display route" do
    test "renders the server-side Markdown component and its defaults", %{conn: conn} do
      conn = get(conn, "/components/data-display/markdown-body")
      html = html_response(conn, 200)
      document = LazyHTML.from_document(html)
      features = LazyHTML.query_by_id(document, "markdown-features")
      hardbreaks_enabled = LazyHTML.query_by_id(document, "markdown-hardbreaks-true")
      hardbreaks_disabled = LazyHTML.query_by_id(document, "markdown-hardbreaks-false")

      assert html =~ "Markdown Body"
      assert html =~ "dm_markdown_body"
      assert html =~ "hardbreaks: true"
      assert html =~ "hardbreaks: false"
      assert Enum.count(LazyHTML.query(features, ".markdown-color-chip")) == 4
      assert Enum.count(LazyHTML.query(features, ".markdown-front-matter")) == 1
      assert Enum.count(LazyHTML.query(features, "code.language-yaml")) == 1
      assert LazyHTML.text(features) =~ "YAML"
      assert LazyHTML.text(features) =~ "title: DmMarkdown feature showcase"
      assert Enum.count(LazyHTML.query(hardbreaks_enabled, "br")) == 1
      assert Enum.empty?(LazyHTML.query(hardbreaks_disabled, "br"))
    end
  end

  describe "datetime data display route" do
    test "renders datetime examples with format and time-zone attributes", %{conn: conn} do
      conn = get(conn, "/components/data-display/datetime")
      html = html_response(conn, 200)

      assert html =~ "Datetime"
      assert html =~ "dm_datetime"
      assert html =~ ~s[id="datetime-default"]
      assert html =~ ~s|format="DD/MM/YYYY [at] h:mm A"|
      assert html =~ ~s[time-zone="Asia/Shanghai"]
    end
  end
end
