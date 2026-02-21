defmodule PhoenixDuskmoon.Component.Action.MenuTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Action.Menu

  describe "dm_menu basic rendering" do
    test "renders el-dm-menu element" do
      result =
        render_component(&dm_menu/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ "<el-dm-menu"
      assert result =~ "</el-dm-menu>"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_menu/1, %{
          id: "my-menu",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ ~s(id="my-menu")
    end

    test "renders with custom class" do
      result =
        render_component(&dm_menu/1, %{
          class: "z-50",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ "z-50"
    end

    test "renders inner_block content" do
      result =
        render_component(&dm_menu/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Menu content" end}
          ]
        })

      assert result =~ "Menu content"
    end
  end

  describe "dm_menu anchor" do
    test "renders anchor attribute" do
      result =
        render_component(&dm_menu/1, %{
          anchor: "#trigger-btn",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ ~s(anchor="#trigger-btn")
    end

    test "no anchor by default" do
      result =
        render_component(&dm_menu/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      refute result =~ ~s(anchor=")
    end
  end

  describe "dm_menu placement" do
    test "defaults to bottom-start" do
      result =
        render_component(&dm_menu/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ ~s(placement="bottom-start")
    end

    for placement <- ~w(top bottom left right top-start top-end bottom-start bottom-end) do
      test "renders #{placement} placement" do
        result =
          render_component(&dm_menu/1, %{
            placement: unquote(placement),
            inner_block: [
              %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
            ]
          })

        assert result =~ ~s(placement="#{unquote(placement)}")
      end
    end
  end

  describe "dm_menu open state" do
    test "not open by default" do
      result =
        render_component(&dm_menu/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      refute result =~ ~s( open=")
    end

    test "renders open when true" do
      result =
        render_component(&dm_menu/1, %{
          open: true,
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ "open"
    end
  end

  describe "dm_menu rest attrs" do
    test "passes rest attributes through" do
      result =
        render_component(&dm_menu/1, %{
          "data-testid": "ctx-menu",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items" end}
          ]
        })

      assert result =~ ~s(data-testid="ctx-menu")
    end
  end

  describe "dm_menu combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_menu/1, %{
          id: "ctx-menu",
          class: "custom",
          open: true,
          anchor: "#my-btn",
          placement: "top-end",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "items here" end}
          ]
        })

      assert result =~ ~s(id="ctx-menu")
      assert result =~ "custom"
      assert result =~ ~s(anchor="#my-btn")
      assert result =~ ~s(placement="top-end")
      assert result =~ "items here"
    end
  end

  describe "dm_menu_item basic rendering" do
    test "renders el-dm-menu-item element" do
      result =
        render_component(&dm_menu_item/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Edit" end}
          ]
        })

      assert result =~ "<el-dm-menu-item"
      assert result =~ "</el-dm-menu-item>"
      assert result =~ "Edit"
    end

    test "renders with value" do
      result =
        render_component(&dm_menu_item/1, %{
          value: "edit",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Edit" end}
          ]
        })

      assert result =~ ~s(value="edit")
    end

    test "renders with custom class" do
      result =
        render_component(&dm_menu_item/1, %{
          class: "text-error",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Delete" end}
          ]
        })

      assert result =~ "text-error"
    end
  end

  describe "dm_menu_item disabled" do
    test "not disabled by default" do
      result =
        render_component(&dm_menu_item/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Item" end}
          ]
        })

      refute result =~ "disabled"
    end

    test "renders disabled when true" do
      result =
        render_component(&dm_menu_item/1, %{
          disabled: true,
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Disabled" end}
          ]
        })

      assert result =~ "disabled"
    end
  end

  describe "dm_menu_item icon" do
    test "no icon by default" do
      result =
        render_component(&dm_menu_item/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Item" end}
          ]
        })

      refute result =~ ~s(slot="icon")
    end

    test "renders icon when provided" do
      result =
        render_component(&dm_menu_item/1, %{
          icon: "pencil",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Edit" end}
          ]
        })

      assert result =~ ~s(slot="icon")
      # dm_mdi renders an SVG
      assert result =~ "<svg"
    end

    test "icon has sizing classes" do
      result =
        render_component(&dm_menu_item/1, %{
          icon: "cog",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Settings" end}
          ]
        })

      assert result =~ "w-5"
      assert result =~ "h-5"
    end
  end

  describe "dm_menu_item rest attrs" do
    test "passes rest attributes through" do
      result =
        render_component(&dm_menu_item/1, %{
          "data-action": "delete",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Delete" end}
          ]
        })

      assert result =~ ~s(data-action="delete")
    end
  end

  describe "dm_menu_item value" do
    test "no value attr when nil" do
      result =
        render_component(&dm_menu_item/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Item" end}
          ]
        })

      refute result =~ ~s(value=")
    end
  end

  describe "dm_menu_item combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_menu_item/1, %{
          value: "settings",
          disabled: false,
          icon: "cog",
          class: "font-bold",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Settings" end}
          ]
        })

      assert result =~ ~s(value="settings")
      assert result =~ "font-bold"
      assert result =~ ~s(slot="icon")
      assert result =~ "Settings"
    end
  end
end
