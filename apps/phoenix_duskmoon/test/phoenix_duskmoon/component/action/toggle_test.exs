defmodule PhoenixDuskmoon.Component.Action.ToggleTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Action.Toggle

  defp basic_items do
    [
      %{__slot__: :item, inner_block: fn _, _ -> "Bold" end},
      %{__slot__: :item, inner_block: fn _, _ -> "Italic" end},
      %{__slot__: :item, inner_block: fn _, _ -> "Underline" end}
    ]
  end

  describe "dm_toggle_group basic rendering" do
    test "renders toggle group container" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      assert result =~ "toggle-group"
    end

    test "renders toggle buttons" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      assert result =~ "toggle-btn"
      assert result =~ "Bold"
      assert result =~ "Italic"
      assert result =~ "Underline"
    end

    test "renders with custom id" do
      result = render_component(&dm_toggle_group/1, %{id: "format-group", item: basic_items()})
      assert result =~ ~s(id="format-group")
    end

    test "renders with custom class" do
      result = render_component(&dm_toggle_group/1, %{class: "mt-4", item: basic_items()})
      assert result =~ "mt-4"
    end

    test "renders role=group" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      assert result =~ ~s(role="group")
    end

    test "buttons have type=button" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      assert result =~ ~s(type="button")
    end
  end

  describe "dm_toggle_group item states" do
    test "renders active item" do
      items = [
        %{__slot__: :item, active: true, inner_block: fn _, _ -> "Active" end},
        %{__slot__: :item, inner_block: fn _, _ -> "Inactive" end}
      ]

      result = render_component(&dm_toggle_group/1, %{item: items})
      assert result =~ "toggle-btn-active"
      assert result =~ ~s(aria-pressed="true")
    end

    test "renders disabled item" do
      items = [
        %{__slot__: :item, disabled: true, inner_block: fn _, _ -> "Disabled" end}
      ]

      result = render_component(&dm_toggle_group/1, %{item: items})
      assert result =~ "toggle-btn-disabled"
      assert result =~ "disabled"
    end

    test "renders item with value" do
      items = [
        %{__slot__: :item, value: "bold", inner_block: fn _, _ -> "B" end}
      ]

      result = render_component(&dm_toggle_group/1, %{item: items})
      assert result =~ ~s(value="bold")
    end

    test "renders item with icon" do
      items = [
        %{__slot__: :item, icon: "format-bold", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_toggle_group/1, %{item: items})
      assert result =~ "toggle-icon"
      assert result =~ "<svg"
    end

    test "renders icon-only item" do
      items = [
        %{__slot__: :item, icon: "format-bold", icon_only: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_toggle_group/1, %{item: items})
      assert result =~ "toggle-btn-icon-only"
    end
  end

  describe "dm_toggle_group variants" do
    test "no variant by default" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      refute result =~ "toggle-segmented"
      refute result =~ "toggle-outlined"
      refute result =~ "toggle-filled"
      refute result =~ "toggle-chip"
    end

    test "renders segmented variant" do
      result = render_component(&dm_toggle_group/1, %{variant: "segmented", item: basic_items()})
      assert result =~ "toggle-segmented"
    end

    test "renders outlined variant" do
      result = render_component(&dm_toggle_group/1, %{variant: "outlined", item: basic_items()})
      assert result =~ "toggle-outlined"
    end

    test "renders filled variant" do
      result = render_component(&dm_toggle_group/1, %{variant: "filled", item: basic_items()})
      assert result =~ "toggle-filled"
    end

    test "renders chip variant" do
      result = render_component(&dm_toggle_group/1, %{variant: "chip", item: basic_items()})
      assert result =~ "toggle-chip"
    end
  end

  describe "dm_toggle_group colors" do
    test "no color by default" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      refute result =~ "toggle-btn-secondary"
      refute result =~ "toggle-btn-tertiary"
    end

    test "renders secondary color" do
      result = render_component(&dm_toggle_group/1, %{color: "secondary", item: basic_items()})
      assert result =~ "toggle-btn-secondary"
    end

    test "renders tertiary color" do
      result = render_component(&dm_toggle_group/1, %{color: "tertiary", item: basic_items()})
      assert result =~ "toggle-btn-tertiary"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_toggle_group/1, %{color: "accent", item: basic_items()})
      assert result =~ "toggle-btn-tertiary"
      refute result =~ "toggle-btn-accent"
    end
  end

  describe "dm_toggle_group sizes" do
    test "no size by default" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      refute result =~ "toggle-btn-sm"
      refute result =~ "toggle-btn-lg"
    end

    test "renders sm size" do
      result = render_component(&dm_toggle_group/1, %{size: "sm", item: basic_items()})
      assert result =~ "toggle-btn-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_toggle_group/1, %{size: "lg", item: basic_items()})
      assert result =~ "toggle-btn-lg"
    end
  end

  describe "dm_toggle_group layout" do
    test "not vertical by default" do
      result = render_component(&dm_toggle_group/1, %{item: basic_items()})
      refute result =~ "toggle-group-vertical"
    end

    test "renders vertical layout" do
      result = render_component(&dm_toggle_group/1, %{vertical: true, item: basic_items()})
      assert result =~ "toggle-group-vertical"
    end

    test "renders exclusive mode" do
      result = render_component(&dm_toggle_group/1, %{exclusive: true, item: basic_items()})
      assert result =~ "toggle-group-exclusive"
    end

    test "renders full width" do
      result = render_component(&dm_toggle_group/1, %{full: true, item: basic_items()})
      assert result =~ "toggle-group-full"
    end
  end

  describe "dm_toggle_group combined" do
    test "renders with all options" do
      items = [
        %{
          __slot__: :item,
          active: true,
          value: "left",
          icon: "format-align-left",
          icon_only: true,
          inner_block: fn _, _ -> "" end
        },
        %{
          __slot__: :item,
          value: "center",
          icon: "format-align-center",
          icon_only: true,
          inner_block: fn _, _ -> "" end
        },
        %{
          __slot__: :item,
          value: "right",
          icon: "format-align-right",
          icon_only: true,
          inner_block: fn _, _ -> "" end
        }
      ]

      result =
        render_component(&dm_toggle_group/1, %{
          id: "align-group",
          class: "mx-auto",
          variant: "segmented",
          color: "secondary",
          size: "lg",
          exclusive: true,
          item: items
        })

      assert result =~ ~s(id="align-group")
      assert result =~ "mx-auto"
      assert result =~ "toggle-segmented"
      assert result =~ "toggle-group-exclusive"
      assert result =~ "toggle-btn-secondary"
      assert result =~ "toggle-btn-lg"
      assert result =~ "toggle-btn-active"
      assert result =~ "toggle-btn-icon-only"
    end
  end
end
