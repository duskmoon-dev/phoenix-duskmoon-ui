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
end
