defmodule PhoenixDuskmoon.Component.DataDisplay.MarkdownTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Markdown

  test "renders el-dm-markdown element with content" do
    result = render_component(&dm_markdown/1, %{content: "# Hello"})

    assert result =~ "<el-dm-markdown"
    assert result =~ "# Hello"
    assert result =~ "</el-dm-markdown>"
  end

  test "renders markdown with exact output for simple content" do
    assert render_component(&dm_markdown/1, content: "value") ==
             ~s[<el-dm-markdown class="">value</el-dm-markdown>]
  end

  test "renders markdown with custom class" do
    result = render_component(&dm_markdown/1, %{class: "dark prose", content: "test"})

    assert result =~ ~s[class="dark prose"]
  end

  test "renders markdown with id" do
    result = render_component(&dm_markdown/1, %{id: "my-markdown", content: "test"})

    assert result =~ ~s[id="my-markdown"]
  end

  test "renders markdown without id by default" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    refute result =~ ~s[id="]
  end

  test "renders markdown with debug enabled" do
    result = render_component(&dm_markdown/1, %{debug: true, content: "test"})

    assert result =~ "debug"
  end

  test "renders markdown without debug by default" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    # debug=false should not render the attribute
    refute result =~ ~s[debug="]
  end

  test "renders markdown with empty content" do
    result = render_component(&dm_markdown/1, %{content: ""})

    assert result =~ "<el-dm-markdown"
    assert result =~ "</el-dm-markdown>"
  end

  test "renders markdown with multiline content" do
    content = "# Title\nSome paragraph text.\n- Item 1\n- Item 2"

    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "# Title"
    assert result =~ "Item 1"
    assert result =~ "Item 2"
  end

  test "renders markdown with special characters" do
    result = render_component(&dm_markdown/1, %{content: "Code: `var x = 1;`"})

    assert result =~ "Code:"
  end

  test "renders markdown with default empty class" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    assert result =~ ~s[class=""]
  end

  test "renders markdown with combined id and class" do
    result =
      render_component(&dm_markdown/1, %{
        id: "doc",
        class: "prose dark",
        content: "# Doc"
      })

    assert result =~ ~s[id="doc"]
    assert result =~ ~s[class="prose dark"]
    assert result =~ "# Doc"
  end

  test "renders markdown with HTML entities in content" do
    # HTML entities in content get double-escaped (& becomes &amp;) by Phoenix
    result = render_component(&dm_markdown/1, %{content: "1 < 2 & 3 > 0"})

    # Phoenix escapes < and > and &
    assert result =~ "1 &lt; 2"
    assert result =~ "&amp; 3"
    assert result =~ "&gt; 0"
  end

  test "renders markdown with code fences in content" do
    content = "```elixir\nIO.puts(\"hello\")\n```"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "```elixir"
    assert result =~ "IO.puts"
  end

  test "renders markdown with long content without truncation" do
    content = String.duplicate("A paragraph of text. ", 100)
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "A paragraph of text."
  end

  test "renders markdown with all attributes set" do
    result =
      render_component(&dm_markdown/1, %{
        id: "full-md",
        class: "prose lg:prose-xl",
        debug: true,
        content: "# Full Example"
      })

    assert result =~ ~s[id="full-md"]
    assert result =~ "prose lg:prose-xl"
    assert result =~ "debug"
    assert result =~ "# Full Example"
  end

  test "renders markdown preserving newlines in content" do
    content = "Line 1\nLine 2\nLine 3"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "Line 1"
    assert result =~ "Line 2"
    assert result =~ "Line 3"
  end

  test "renders markdown with default empty content" do
    result = render_component(&dm_markdown/1, %{})

    assert result =~ "<el-dm-markdown"
    assert result =~ "</el-dm-markdown>"
  end

  test "renders markdown with table syntax" do
    content = "| Name | Age |\n|------|-----|\n| Alice | 30 |"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "Alice"
    assert result =~ "30"
  end

  test "renders markdown with heading levels" do
    content = "# H1\n## H2\n### H3"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "# H1"
    assert result =~ "## H2"
    assert result =~ "### H3"
  end

  test "renders markdown with link syntax" do
    content = "[click here](https://example.com)"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "click here"
    assert result =~ "example.com"
  end

  test "renders markdown with bold and italic syntax" do
    content = "**bold** and *italic* text"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "**bold**"
    assert result =~ "*italic*"
  end

  test "renders markdown with closing el-dm-markdown tag" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    assert result =~ "</el-dm-markdown>"
  end

  test "renders markdown with debug false not adding debug attribute" do
    result = render_component(&dm_markdown/1, %{content: "test", debug: false})

    refute result =~ ~s[debug="true"]
    refute result =~ ~s[debug=""]
  end

  test "renders markdown with image syntax in content" do
    content = "![alt text](https://example.com/image.png)"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "alt text"
    assert result =~ "example.com/image.png"
  end

  test "renders markdown with blockquote syntax" do
    content = "> This is a blockquote"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "&gt; This is a blockquote"
  end

  test "renders markdown with horizontal rule syntax" do
    content = "Above\n---\nBelow"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "Above"
    assert result =~ "Below"
  end

  test "renders markdown with mermaid code block" do
    content = "```mermaid\ngraph TD;\n  A-->B;\n```"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "mermaid"
    assert result =~ "A--&gt;B"
  end

  test "renders markdown content is properly enclosed in custom element" do
    result = render_component(&dm_markdown/1, %{content: "# Test"})

    assert String.starts_with?(String.trim(result), "<el-dm-markdown")
    assert String.ends_with?(String.trim(result), "</el-dm-markdown>")
  end

  test "renders markdown with task list syntax" do
    content = "- [x] Done\n- [ ] Pending"
    result = render_component(&dm_markdown/1, %{content: content})

    assert result =~ "Done"
    assert result =~ "Pending"
  end

  test "renders markdown with src attribute" do
    result = render_component(&dm_markdown/1, %{src: "/docs/readme.md"})

    assert result =~ ~s[src="/docs/readme.md"]
  end

  test "renders markdown without src when nil" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    refute result =~ ~s[src="]
  end

  test "renders markdown with theme attribute" do
    result = render_component(&dm_markdown/1, %{theme: "github", content: "test"})

    assert result =~ ~s[theme="github"]
  end

  test "renders markdown with all theme options" do
    for theme <- ~w(github atom-one-dark atom-one-light auto) do
      result = render_component(&dm_markdown/1, %{theme: theme, content: "test"})
      assert result =~ ~s[theme="#{theme}"]
    end
  end

  test "renders markdown without theme when nil" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    refute result =~ ~s[theme="]
  end

  test "renders markdown with no-mermaid attribute" do
    result = render_component(&dm_markdown/1, %{no_mermaid: true, content: "test"})

    assert result =~ "no-mermaid"
  end

  test "renders markdown without no-mermaid by default" do
    result = render_component(&dm_markdown/1, %{content: "test"})

    refute result =~ "no-mermaid"
  end

  test "renders markdown with rest attributes" do
    result =
      render_component(&dm_markdown/1, %{
        content: "test",
        "data-testid": "md-viewer"
      })

    assert result =~ ~s[data-testid="md-viewer"]
  end

  test "renders markdown with src, theme, and no_mermaid combined" do
    result =
      render_component(&dm_markdown/1, %{
        src: "/api/docs",
        theme: "atom-one-dark",
        no_mermaid: true,
        class: "prose"
      })

    assert result =~ ~s[src="/api/docs"]
    assert result =~ ~s[theme="atom-one-dark"]
    assert result =~ "no-mermaid"
    assert result =~ "prose"
  end
end
