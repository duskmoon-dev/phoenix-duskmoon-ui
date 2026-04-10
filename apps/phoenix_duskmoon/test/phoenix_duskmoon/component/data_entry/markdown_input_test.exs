defmodule PhoenixDuskmoon.Component.DataEntry.MarkdownInputTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.MarkdownInput

  test "renders el-dm-markdown-input element" do
    result = render_component(&dm_markdown_input/1, %{})

    assert result =~ "<el-dm-markdown-input"
    assert result =~ "</el-dm-markdown-input>"
  end

  test "renders with name attribute" do
    result = render_component(&dm_markdown_input/1, %{name: "body"})

    assert result =~ ~s[name="body"]
  end

  test "renders with value attribute" do
    result = render_component(&dm_markdown_input/1, %{value: "# Hello"})

    assert result =~ ~s[value="# Hello"]
  end

  test "renders with id attribute" do
    result = render_component(&dm_markdown_input/1, %{id: "editor-1"})

    assert result =~ ~s[id="editor-1"]
  end

  test "does not render id by default" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ ~s[id="]
  end

  test "renders with placeholder attribute" do
    result = render_component(&dm_markdown_input/1, %{placeholder: "Write here…"})

    assert result =~ ~s[placeholder="Write here…"]
  end

  test "renders with theme attribute" do
    result = render_component(&dm_markdown_input/1, %{theme: "atom-one-dark"})

    assert result =~ ~s[theme="atom-one-dark"]
  end

  test "renders all theme options" do
    for theme <- ~w(github atom-one-dark atom-one-light auto) do
      result = render_component(&dm_markdown_input/1, %{theme: theme})
      assert result =~ ~s[theme="#{theme}"]
    end
  end

  test "does not render theme when nil" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ ~s[theme="]
  end

  test "renders disabled attribute" do
    result = render_component(&dm_markdown_input/1, %{disabled: true})

    assert result =~ "disabled"
  end

  test "does not render disabled by default" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ ~s[disabled="true"]
    refute result =~ ~s[disabled=""]
  end

  test "renders readonly attribute" do
    result = render_component(&dm_markdown_input/1, %{readonly: true})

    assert result =~ "readonly"
  end

  test "does not render readonly by default" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ ~s[readonly="true"]
    refute result =~ ~s[readonly=""]
  end

  test "renders no-mermaid attribute" do
    result = render_component(&dm_markdown_input/1, %{no_mermaid: true})

    assert result =~ "no-mermaid"
  end

  test "does not render no-mermaid by default" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ "no-mermaid"
  end

  test "renders no-preview attribute" do
    result = render_component(&dm_markdown_input/1, %{no_preview: true})

    assert result =~ "no-preview"
  end

  test "does not render no-preview by default" do
    result = render_component(&dm_markdown_input/1, %{})

    refute result =~ "no-preview"
  end

  test "renders with custom class" do
    result = render_component(&dm_markdown_input/1, %{class: "h-96 w-full"})

    assert result =~ ~s[class="h-96 w-full"]
  end

  test "renders with rest attributes" do
    result = render_component(&dm_markdown_input/1, %{"data-testid": "md-editor"})

    assert result =~ ~s[data-testid="md-editor"]
  end

  test "renders with form field" do
    field = Phoenix.Component.to_form(%{"body" => "# Hi"}, as: "post")[:body]
    result = render_component(&dm_markdown_input/1, %{field: field})

    assert result =~ ~s(name="post[body]")
    assert result =~ ~s[id="post_body"]
    assert result =~ "# Hi"
  end

  test "form field id can be overridden" do
    field = Phoenix.Component.to_form(%{"body" => ""}, as: "post")[:body]
    result = render_component(&dm_markdown_input/1, %{field: field, id: "custom-id"})

    assert result =~ ~s[id="custom-id"]
  end
end
