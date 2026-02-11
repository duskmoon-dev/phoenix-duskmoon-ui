defmodule PhoenixDuskmoon.Component.Navigation.ActionbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Actionbar

  test "renders basic actionbar" do
    result = render_component(&dm_actionbar/1, %{})

    assert result =~ "dm-actionbar"
  end

  test "renders actionbar with left and right sections" do
    result = render_component(&dm_actionbar/1, %{})

    assert result =~ "dm-actionbar__left"
    assert result =~ "dm-actionbar__right"
  end

  test "renders actionbar with left slot" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{inner_block: fn _, _ -> "Title" end}]
      })

    assert result =~ "Title"
  end

  test "renders actionbar with right slot" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [%{inner_block: fn _, _ -> "Action Button" end}]
      })

    assert result =~ "Action Button"
  end

  test "renders actionbar with both left and right" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{inner_block: fn _, _ -> "Page Title" end}],
        right: [%{inner_block: fn _, _ -> "Save" end}]
      })

    assert result =~ "Page Title"
    assert result =~ "Save"
  end

  test "renders actionbar with multiple right slots" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [
          %{inner_block: fn _, _ -> "Edit" end},
          %{inner_block: fn _, _ -> "Delete" end}
        ]
      })

    assert result =~ "Edit"
    assert result =~ "Delete"
  end

  test "renders actionbar with custom id" do
    result = render_component(&dm_actionbar/1, %{id: "action-1"})

    assert result =~ ~s[id="action-1"]
  end

  test "renders actionbar with custom class" do
    result = render_component(&dm_actionbar/1, %{class: "shadow-lg"})

    assert result =~ "shadow-lg"
    assert result =~ "dm-actionbar"
  end

  test "renders actionbar with left_class" do
    result = render_component(&dm_actionbar/1, %{left_class: "font-bold"})

    assert result =~ "font-bold"
  end

  test "renders actionbar with right_class" do
    result = render_component(&dm_actionbar/1, %{right_class: "gap-2"})

    assert result =~ "gap-2"
  end

  test "renders actionbar left slot with id and class" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{id: "left-1", class: "left-custom", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[id="left-1"]
    assert result =~ "left-custom"
  end

  test "renders actionbar right slot with id and class" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [%{id: "right-1", class: "right-custom", inner_block: fn _, _ -> "Action" end}]
      })

    assert result =~ ~s[id="right-1"]
    assert result =~ "right-custom"
  end

  test "renders actionbar with rest attributes" do
    result =
      render_component(&dm_actionbar/1, %{
        "data-testid": "action-toolbar",
        "aria-label": "Page actions"
      })

    assert result =~ "data-testid=\"action-toolbar\""
    assert result =~ "aria-label=\"Page actions\""
  end

  test "renders actionbar with multiple left slots" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [
          %{inner_block: fn _, _ -> "Title" end},
          %{inner_block: fn _, _ -> "Subtitle" end}
        ]
      })

    assert result =~ "Title"
    assert result =~ "Subtitle"
  end

  test "renders actionbar with all attributes combined" do
    result =
      render_component(&dm_actionbar/1, %{
        id: "full-bar",
        class: "shadow-lg border",
        left_class: "font-bold",
        right_class: "gap-2",
        left: [%{inner_block: fn _, _ -> "Title" end}],
        right: [%{inner_block: fn _, _ -> "Action" end}],
        "data-testid": "toolbar"
      })

    assert result =~ ~s[id="full-bar"]
    assert result =~ "shadow-lg border"
    assert result =~ "font-bold"
    assert result =~ "gap-2"
    assert result =~ "Title"
    assert result =~ "Action"
    assert result =~ "data-testid=\"toolbar\""
  end

  test "renders actionbar with no slots as empty sections" do
    result = render_component(&dm_actionbar/1, %{})

    # Both sections render but with no inner divs
    assert result =~ "dm-actionbar__left"
    assert result =~ "dm-actionbar__right"
  end

  test "renders actionbar left slot with class but no id" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{class: "text-lg", inner_block: fn _, _ -> "Heading" end}]
      })

    assert result =~ "text-lg"
    assert result =~ "Heading"
  end

  test "renders actionbar right slot with id but no class" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [%{id: "action-btn", inner_block: fn _, _ -> "Save" end}]
      })

    assert result =~ ~s[id="action-btn"]
    assert result =~ "Save"
  end

  test "renders actionbar wrapper as div element" do
    result = render_component(&dm_actionbar/1, %{})

    assert result =~ "<div"
  end

  test "renders actionbar with left_class and right_class combined" do
    result =
      render_component(&dm_actionbar/1, %{
        left_class: "font-semibold text-lg",
        right_class: "flex gap-4"
      })

    assert result =~ "font-semibold text-lg"
    assert result =~ "flex gap-4"
  end

  test "renders actionbar with three right slot items" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [
          %{inner_block: fn _, _ -> "Edit" end},
          %{inner_block: fn _, _ -> "Copy" end},
          %{inner_block: fn _, _ -> "Delete" end}
        ]
      })

    assert result =~ "Edit"
    assert result =~ "Copy"
    assert result =~ "Delete"
  end

  test "renders actionbar without id when not provided" do
    result = render_component(&dm_actionbar/1, %{})

    refute result =~ ~s[id="]
  end

  test "renders actionbar base class always present" do
    result = render_component(&dm_actionbar/1, %{class: "extra"})

    assert result =~ "dm-actionbar"
    assert result =~ "extra"
  end

  test "renders actionbar left slot items as separate divs" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [
          %{id: "a", inner_block: fn _, _ -> "First" end},
          %{id: "b", inner_block: fn _, _ -> "Second" end}
        ]
      })

    assert result =~ ~s[id="a"]
    assert result =~ ~s[id="b"]
    assert result =~ "First"
    assert result =~ "Second"
  end

  test "renders actionbar with role=toolbar" do
    result = render_component(&dm_actionbar/1, %{})

    assert result =~ ~s[role="toolbar"]
  end

  test "renders actionbar with left slot item without id uses nil" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{inner_block: fn _, _ -> "No ID" end}]
      })

    assert result =~ "No ID"
  end

  test "renders actionbar with right slot item without class uses nil" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [%{inner_block: fn _, _ -> "No Class" end}]
      })

    assert result =~ "No Class"
  end

  test "renders actionbar with empty left and right slots" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [],
        right: []
      })

    assert result =~ "dm-actionbar__left"
    assert result =~ "dm-actionbar__right"
  end

  test "renders actionbar left slot items each as separate wrapping div" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [
          %{class: "item-a", inner_block: fn _, _ -> "A" end},
          %{class: "item-b", inner_block: fn _, _ -> "B" end},
          %{class: "item-c", inner_block: fn _, _ -> "C" end}
        ]
      })

    assert result =~ "item-a"
    assert result =~ "item-b"
    assert result =~ "item-c"
  end

  test "renders actionbar with phx-click rest attribute" do
    result =
      render_component(&dm_actionbar/1, %{
        "phx-click": "toolbar-action"
      })

    assert result =~ ~s[phx-click="toolbar-action"]
  end
end
