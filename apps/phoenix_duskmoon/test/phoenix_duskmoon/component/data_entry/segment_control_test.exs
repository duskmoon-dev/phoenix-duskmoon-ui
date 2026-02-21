defmodule PhoenixDuskmoon.Component.DataEntry.SegmentControlTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.SegmentControl

  defp items_slot do
    [
      %{__slot__: :item, active: true, inner_block: fn _, _ -> "Day" end},
      %{__slot__: :item, inner_block: fn _, _ -> "Week" end},
      %{__slot__: :item, inner_block: fn _, _ -> "Month" end}
    ]
  end

  describe "dm_segment_control basic rendering" do
    test "renders segment-control container" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      assert result =~ "segment-control"
      assert result =~ ~s(role="group")
    end

    test "renders with custom id" do
      result = render_component(&dm_segment_control/1, %{id: "view-toggle", item: items_slot()})
      assert result =~ ~s(id="view-toggle")
    end

    test "renders with custom class" do
      result = render_component(&dm_segment_control/1, %{class: "my-class", item: items_slot()})
      assert result =~ "my-class"
    end

    test "renders all items as buttons" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      assert result =~ "Day"
      assert result =~ "Week"
      assert result =~ "Month"
      # 3 buttons
      assert length(String.split(result, "<button")) == 4
    end

    test "renders active item with segment-item-active class" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      assert result =~ "segment-item-active"
    end

    test "renders aria-pressed for active items" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      assert result =~ ~s(aria-pressed="true")
      assert result =~ ~s(aria-pressed="false")
    end
  end

  describe "dm_segment_control size" do
    test "no size class by default" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      refute result =~ "segment-control-sm"
      refute result =~ "segment-control-lg"
    end

    test "renders sm size" do
      result = render_component(&dm_segment_control/1, %{size: "sm", item: items_slot()})
      assert result =~ "segment-control-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_segment_control/1, %{size: "lg", item: items_slot()})
      assert result =~ "segment-control-lg"
    end
  end

  describe "dm_segment_control color" do
    test "no color class by default" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      refute result =~ "segment-control-primary"
    end

    test "renders primary color" do
      result = render_component(&dm_segment_control/1, %{color: "primary", item: items_slot()})
      assert result =~ "segment-control-primary"
    end

    test "renders secondary color" do
      result = render_component(&dm_segment_control/1, %{color: "secondary", item: items_slot()})
      assert result =~ "segment-control-secondary"
    end

    test "renders tertiary color" do
      result = render_component(&dm_segment_control/1, %{color: "tertiary", item: items_slot()})
      assert result =~ "segment-control-tertiary"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_segment_control/1, %{color: "accent", item: items_slot()})
      assert result =~ "segment-control-tertiary"
      refute result =~ "segment-control-accent"
    end

    test "renders info, success, warning, error colors" do
      for color <- ~w(info success warning error) do
        result = render_component(&dm_segment_control/1, %{color: color, item: items_slot()})
        assert result =~ "segment-control-#{color}"
      end
    end
  end

  describe "dm_segment_control variant" do
    test "no variant class by default" do
      result = render_component(&dm_segment_control/1, %{item: items_slot()})
      refute result =~ "segment-control-outlined"
      refute result =~ "segment-control-ghost"
    end

    test "renders outlined variant" do
      result = render_component(&dm_segment_control/1, %{variant: "outlined", item: items_slot()})
      assert result =~ "segment-control-outlined"
    end

    test "renders ghost variant" do
      result = render_component(&dm_segment_control/1, %{variant: "ghost", item: items_slot()})
      assert result =~ "segment-control-ghost"
    end
  end

  describe "dm_segment_control display options" do
    test "renders full width" do
      result = render_component(&dm_segment_control/1, %{full: true, item: items_slot()})
      assert result =~ "segment-control-full"
    end

    test "renders icon-only mode" do
      result = render_component(&dm_segment_control/1, %{icon_only: true, item: items_slot()})
      assert result =~ "segment-control-icon-only"
    end

    test "renders multi mode" do
      result = render_component(&dm_segment_control/1, %{multi: true, item: items_slot()})
      assert result =~ "segment-control-multi"
    end
  end

  describe "dm_segment_control item features" do
    test "renders disabled item" do
      items = [
        %{__slot__: :item, inner_block: fn _, _ -> "A" end},
        %{__slot__: :item, disabled: true, inner_block: fn _, _ -> "B" end}
      ]

      result = render_component(&dm_segment_control/1, %{item: items})
      assert result =~ "disabled"
    end

    test "renders item with value" do
      items = [
        %{__slot__: :item, value: "list", inner_block: fn _, _ -> "List" end},
        %{__slot__: :item, value: "grid", inner_block: fn _, _ -> "Grid" end}
      ]

      result = render_component(&dm_segment_control/1, %{item: items})
      assert result =~ ~s(value="list")
      assert result =~ ~s(value="grid")
    end

    test "renders item with icon" do
      items = [
        %{__slot__: :item, icon: "view-list", inner_block: fn _, _ -> "List" end}
      ]

      result = render_component(&dm_segment_control/1, %{item: items})
      assert result =~ "segment-icon"
      assert result =~ "<svg"
    end

    test "renders item with custom class" do
      items = [
        %{__slot__: :item, class: "font-bold", inner_block: fn _, _ -> "Bold" end}
      ]

      result = render_component(&dm_segment_control/1, %{item: items})
      assert result =~ "font-bold"
    end
  end

  describe "dm_segment_control combined" do
    test "renders with all options" do
      items = [
        %{
          __slot__: :item,
          active: true,
          icon: "view-list",
          value: "list",
          inner_block: fn _, _ -> "List" end
        },
        %{
          __slot__: :item,
          icon: "view-grid",
          value: "grid",
          inner_block: fn _, _ -> "Grid" end
        }
      ]

      result =
        render_component(&dm_segment_control/1, %{
          id: "view-mode",
          class: "mb-4",
          size: "lg",
          color: "primary",
          full: true,
          item: items
        })

      assert result =~ ~s(id="view-mode")
      assert result =~ "mb-4"
      assert result =~ "segment-control-lg"
      assert result =~ "segment-control-primary"
      assert result =~ "segment-control-full"
      assert result =~ "segment-item-active"
      assert result =~ ~s(value="list")
      assert result =~ ~s(value="grid")
    end
  end
end
