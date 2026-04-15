defmodule PhoenixDuskmoon.Component.DataEntry.CodeEngineTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.CodeEngine

  test "renders el-dm-code-engine element" do
    result = render_component(&dm_code_engine/1, %{})

    assert result =~ "<el-dm-code-engine"
    assert result =~ "</el-dm-code-engine>"
  end

  test "renders with id attribute" do
    result = render_component(&dm_code_engine/1, %{id: "editor-1"})

    assert result =~ ~s[id="editor-1"]
  end

  test "does not render id by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ ~s[id="]
  end

  test "renders with name attribute" do
    result = render_component(&dm_code_engine/1, %{name: "source"})

    assert result =~ ~s[name="source"]
  end

  test "renders with value attribute" do
    result = render_component(&dm_code_engine/1, %{value: "console.log('hi');"})

    assert result =~ "console.log(&#39;hi&#39;);"
  end

  test "renders with language attribute" do
    result = render_component(&dm_code_engine/1, %{language: "javascript"})

    assert result =~ ~s[language="javascript"]
  end

  test "renders with theme attribute" do
    result = render_component(&dm_code_engine/1, %{theme: "one-dark"})

    assert result =~ ~s[theme="one-dark"]
  end

  test "renders all theme options" do
    for theme <- ~w(duskmoon sunshine moonlight one-dark) do
      result = render_component(&dm_code_engine/1, %{theme: theme})
      assert result =~ ~s[theme="#{theme}"]
    end
  end

  test "does not render theme when nil" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ ~s[theme="]
  end

  test "renders readonly attribute" do
    result = render_component(&dm_code_engine/1, %{readonly: true})

    assert result =~ "readonly"
  end

  test "does not render readonly by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ ~s[readonly="true"]
    refute result =~ ~s[readonly=""]
  end

  test "renders wrap attribute" do
    result = render_component(&dm_code_engine/1, %{wrap: true})

    assert result =~ "wrap"
  end

  test "does not render wrap by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ ~s[wrap="true"]
    refute result =~ ~s[wrap=""]
  end

  test "renders show-topbar attribute" do
    result = render_component(&dm_code_engine/1, %{show_topbar: true})

    assert result =~ "show-topbar"
  end

  test "does not render show-topbar by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ "show-topbar"
  end

  test "renders show-bottombar attribute" do
    result = render_component(&dm_code_engine/1, %{show_bottombar: true})

    assert result =~ "show-bottombar"
  end

  test "does not render show-bottombar by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ "show-bottombar"
  end

  test "renders title attribute" do
    result = render_component(&dm_code_engine/1, %{title: "app.js"})

    assert result =~ ~s[title="app.js"]
  end

  test "does not render title by default" do
    result = render_component(&dm_code_engine/1, %{})

    refute result =~ ~s[title="]
  end

  test "renders with custom class" do
    result = render_component(&dm_code_engine/1, %{class: "h-96 w-full"})

    assert result =~ ~s[class="h-96 w-full"]
  end

  test "renders with rest attributes" do
    result = render_component(&dm_code_engine/1, %{"data-testid": "code-editor"})

    assert result =~ ~s[data-testid="code-editor"]
  end

  test "renders with form field" do
    field = Phoenix.Component.to_form(%{"source" => "fn main() {}"}, as: "snippet")[:source]
    result = render_component(&dm_code_engine/1, %{field: field})

    assert result =~ ~s(name="snippet[source]")
    assert result =~ ~s[id="snippet_source"]
    assert result =~ "fn main() {}"
  end

  test "form field id can be overridden" do
    field = Phoenix.Component.to_form(%{"source" => ""}, as: "snippet")[:source]
    result = render_component(&dm_code_engine/1, %{field: field, id: "custom-id"})

    assert result =~ ~s[id="custom-id"]
  end
end
