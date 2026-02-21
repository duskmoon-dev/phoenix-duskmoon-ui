defmodule PhoenixDuskmoon.Component.DataDisplay.AccordionTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Accordion

  defp item(value, header, content, opts \\ []) do
    Map.merge(
      %{
        value: value,
        header: header,
        inner_block: fn _, _ -> content end
      },
      Map.new(opts)
    )
  end

  test "renders el-dm-accordion with items" do
    result =
      render_component(&dm_accordion/1, %{
        item: [
          item("s1", "Section One", "Content one"),
          item("s2", "Section Two", "Content two")
        ]
      })

    assert result =~ "<el-dm-accordion"
    assert result =~ "<el-dm-accordion-item"
    assert result =~ ~s(value="s1")
    assert result =~ ~s(value="s2")
    assert result =~ "Section One"
    assert result =~ "Section Two"
    assert result =~ "Content one"
    assert result =~ "Content two"
  end

  test "renders with multiple attribute" do
    result =
      render_component(&dm_accordion/1, %{
        multiple: true,
        item: [item("a", "A", "A content")]
      })

    assert result =~ "multiple"
  end

  test "does not render multiple when false" do
    result =
      render_component(&dm_accordion/1, %{
        multiple: false,
        item: [item("a", "A", "A content")]
      })

    refute result =~ "multiple"
  end

  test "renders with value attribute for initially open items" do
    result =
      render_component(&dm_accordion/1, %{
        value: "s1,s3",
        item: [
          item("s1", "One", "One"),
          item("s2", "Two", "Two"),
          item("s3", "Three", "Three")
        ]
      })

    assert result =~ ~s(value="s1,s3")
  end

  test "renders disabled items" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("d1", "Disabled", "Disabled content", disabled: true)]
      })

    assert result =~ "disabled"
  end

  test "does not render disabled when not set" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("e1", "Enabled", "Enabled content")]
      })

    # The el-dm-accordion-item should not have a disabled attr
    refute result =~ ~s(disabled)
  end

  test "renders with id attribute" do
    result =
      render_component(&dm_accordion/1, %{
        id: "faq",
        item: [item("q1", "Question", "Answer")]
      })

    assert result =~ ~s(id="faq")
  end

  test "renders with class attribute" do
    result =
      render_component(&dm_accordion/1, %{
        class: "my-custom",
        item: [item("i1", "Item", "Content")]
      })

    assert result =~ ~s(class="my-custom")
  end

  test "header text appears in slot" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("h1", "My Header", "Body")]
      })

    assert result =~ ~s(slot="header")
    assert result =~ "My Header"
  end

  test "renders multiple items" do
    items =
      for i <- 1..5 do
        item("item#{i}", "Header #{i}", "Content #{i}")
      end

    result = render_component(&dm_accordion/1, %{item: items})

    for i <- 1..5 do
      assert result =~ "Header #{i}"
      assert result =~ "Content #{i}"
    end
  end

  test "passes rest attributes to el-dm-accordion" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("r1", "Rest", "Content")],
        data_testid: "my-accordion"
      })

    assert result =~ ~s(data_testid="my-accordion")
  end

  test "renders single value for initially open item" do
    result =
      render_component(&dm_accordion/1, %{
        value: "only-one",
        item: [
          item("only-one", "Only", "Single open item"),
          item("closed", "Closed", "Closed item")
        ]
      })

    assert result =~ ~s(value="only-one")
  end

  test "renders empty class when class is nil" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("a1", "A", "Content")]
      })

    # Phoenix renders class="" for nil string attrs
    assert result =~ ~s(class="")
  end

  test "mixed disabled and enabled items" do
    result =
      render_component(&dm_accordion/1, %{
        item: [
          item("e1", "Enabled", "Enabled content"),
          item("d1", "Disabled", "Disabled content", disabled: true),
          item("e2", "Also Enabled", "Also enabled content")
        ]
      })

    # All items should render
    assert result =~ "Enabled"
    assert result =~ "Disabled"
    assert result =~ "Also Enabled"
    # Only the disabled item should have the disabled attribute
    assert result =~ "disabled"
  end

  test "item values propagate to el-dm-accordion-item value attribute" do
    result =
      render_component(&dm_accordion/1, %{
        item: [
          item("unique-val-1", "First", "First content"),
          item("unique-val-2", "Second", "Second content")
        ]
      })

    assert result =~ ~s(value="unique-val-1")
    assert result =~ ~s(value="unique-val-2")
  end

  test "renders with multiple true and value set together" do
    result =
      render_component(&dm_accordion/1, %{
        multiple: true,
        value: "a,c",
        item: [
          item("a", "A", "A content"),
          item("b", "B", "B content"),
          item("c", "C", "C content")
        ]
      })

    assert result =~ "multiple"
    assert result =~ ~s(value="a,c")
    assert result =~ "A content"
    assert result =~ "B content"
    assert result =~ "C content"
  end

  test "each item wraps header in span with slot=header" do
    result =
      render_component(&dm_accordion/1, %{
        item: [
          item("x1", "Header Alpha", "Body Alpha"),
          item("x2", "Header Beta", "Body Beta")
        ]
      })

    assert result =~ ~s(<span slot="header">Header Alpha</span>)
    assert result =~ ~s(<span slot="header">Header Beta</span>)
  end

  test "item content renders outside header slot" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("c1", "Title", "Body text here")]
      })

    # Header is inside span[slot=header], body text should be outside it
    assert result =~ "Body text here"
    # Body should not be inside the header slot
    refute result =~ ~s(slot="header">Body text here)
  end

  test "renders with phx attributes via rest" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("p1", "Phx", "Content")],
        phx_hook: "AccordionHook"
      })

    assert result =~ ~s(phx_hook="AccordionHook")
  end

  test "renders single item" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("solo", "Only Item", "Only content")]
      })

    assert result =~ "<el-dm-accordion"
    assert result =~ "<el-dm-accordion-item"
    assert result =~ "Only Item"
    assert result =~ "Only content"
  end

  test "no value attribute on container when nil" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("a", "A", "Content")]
      })

    # The el-dm-accordion (not -item) should not have value="" since value is nil
    # Match only the container tag (ends with > before the first -item)
    [accordion_tag] = Regex.scan(~r/<el-dm-accordion\b(?!-)(?:[^>]*)>/, result) |> List.flatten()
    refute accordion_tag =~ ~s(value=")
  end

  test "closing tags render correctly" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("a", "A", "Content")]
      })

    assert result =~ "</el-dm-accordion-item>"
    assert result =~ "</el-dm-accordion>"
  end

  test "renders with combined id, class, and multiple" do
    result =
      render_component(&dm_accordion/1, %{
        id: "combined-test",
        class: "combined-class",
        multiple: true,
        value: "first",
        item: [
          item("first", "First", "First content"),
          item("second", "Second", "Second content")
        ]
      })

    assert result =~ ~s(id="combined-test")
    assert result =~ ~s(class="combined-class")
    assert result =~ "multiple"
    assert result =~ ~s(value="first")
  end

  test "passes through global attributes" do
    result =
      render_component(&dm_accordion/1, %{
        item: [item("s1", "Sec", "Content")],
        "data-testid": "my-accordion"
      })

    assert result =~ ~s[data-testid="my-accordion"]
  end
end
