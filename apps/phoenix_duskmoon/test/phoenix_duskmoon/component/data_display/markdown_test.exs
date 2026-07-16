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

  describe "dm_markdown_body/1" do
    test "renders Markdown source as semantic HTML" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "# Hello\n\nThis is **Markdown**."
        })

      assert result =~ ~s[<div class="markdown-body">]
      assert result =~ "<h1>Hello</h1>"
      assert result =~ "<strong>Markdown</strong>"
      refute result =~ "# Hello"
    end

    test "enables GitHub Flavored Markdown by default" do
      source = """
      | Feature | Status |
      | ------- | ------ |
      | Tables  | Ready  |

      - [x] Plugins

      https://example.com
      """

      result = render_component(&dm_markdown_body/1, %{source: source})

      assert result =~ "<table>"
      assert result =~ "<th>Feature</th>"
      assert result =~ ~s[type="checkbox"]
      assert result =~ "checked"
      assert result =~ "disabled"
      assert result =~ ~s[<a href="https://example.com"]
    end

    test "enables Mermaid by default" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "```mermaid\ngraph TD;\nA-->B;\n```"
        })

      assert result =~ ~s[<pre id="mermaid-1" class="mermaid" phx-update="ignore">]
      assert result =~ "graph TD;"
      assert result =~ "mermaid.initialize"
      refute result =~ ~s[<code class="language-mermaid">]
    end

    test "enables hard line breaks by default" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "first line\nsecond line"
        })

      assert result =~ "first line<br />\nsecond line"
    end

    test "allows hard line breaks to be disabled" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "first line\nsecond line",
          options: [render: [hardbreaks: false]]
        })

      assert result =~ "first line\nsecond line"
      refute result =~ "<br"
    end

    test "omits front matter from rendered HTML by default" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "---\ntitle: Release notes\nstatus: published\n---\n# Changes"
        })

      assert result =~ "<h1>Changes</h1>"
      refute result =~ "title: Release notes"
      refute result =~ "status: published"
    end

    test "allows front matter support to be disabled" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "---\ntitle: Release notes\n---\n# Changes",
          options: [extension: [front_matter_delimiter: nil]]
        })

      assert result =~ "title: Release notes"
      assert result =~ "<h1>Changes</h1>"
    end

    test "renders color chips for supported inline color values" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "`#0969DA` `rgb(9, 105, 218)` `hsl(212, 92%, 45%)`"
        })

      assert length(Regex.scan(~r/class="markdown-color-chip"/, result)) == 3
      assert result =~ "background-color: #0969DA;"
      assert result =~ "background-color: rgb(9, 105, 218);"
      assert result =~ "background-color: hsl(212, 92%, 45%);"
    end

    test "does not render color chips for unsupported or fenced color values" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "`#12345`\n\n```css\n#0969DA\n```"
        })

      assert result =~ "#12345"
      assert result =~ "#0969DA"
      refute result =~ "markdown-color-chip"
    end

    test "accepts a custom MDEx plugin list" do
      underline_plugin = fn document ->
        MDEx.Document.put_extension_options(document, underline: true)
      end

      result =
        render_component(&dm_markdown_body/1, %{
          source: "__underlined__ `#0969DA`",
          plugins: [underline_plugin]
        })

      assert result =~ "<u>underlined</u>"
      refute result =~ "<strong>underlined</strong>"
      refute result =~ "markdown-color-chip"
    end

    test "source and plugins attributes override matching MDEx options" do
      underline_plugin = fn document ->
        MDEx.Document.put_extension_options(document, underline: true)
      end

      result =
        render_component(&dm_markdown_body/1, %{
          source: "__underlined__",
          plugins: [underline_plugin],
          options: [
            markdown: "ignored",
            plugins: [MDExGFM]
          ]
        })

      assert result =~ "<u>underlined</u>"
      refute result =~ "<strong>underlined</strong>"
      refute result =~ "ignored"
    end

    test "renders allowed HTML tags while sanitizing unsafe HTML" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "<article><mark>Safe content</mark><script>alert('unsafe')</script></article>",
          plugins: [MDExGFM],
          options: [
            render: [unsafe: true],
            sanitize: MDEx.Document.default_sanitize_options()
          ]
        })

      assert result =~ "<article><mark>Safe content</mark></article>"
      refute result =~ "<script"
      refute result =~ "alert('unsafe')"
      refute result =~ "&lt;article"
    end

    test "renders wrapper attributes and additional classes" do
      result =
        render_component(&dm_markdown_body/1, %{
          source: "Body",
          id: "readme",
          class: "max-w-none",
          "data-testid": "markdown-body"
        })

      assert result =~ ~s[id="readme"]
      assert result =~ ~s[class="markdown-body max-w-none"]
      assert result =~ ~s[data-testid="markdown-body"]
    end

    test "renders an empty source" do
      assert render_component(&dm_markdown_body/1, %{source: ""}) ==
               ~s[<div class="markdown-body"></div>]
    end
  end
end
