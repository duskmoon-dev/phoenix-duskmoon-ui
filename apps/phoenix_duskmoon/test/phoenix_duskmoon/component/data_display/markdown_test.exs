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
end
