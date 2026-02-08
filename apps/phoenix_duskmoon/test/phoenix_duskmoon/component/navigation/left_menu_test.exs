defmodule PhoenixDuskmoon.Component.Navigation.LeftMenuTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.LeftMenu

  describe "dm_left_menu/1" do
    test "renders basic menu" do
      result =
        render_component(&dm_left_menu/1, %{
          class: "bg-base-200 rounded-box w-56",
          title: [%{inner_block: fn _, _ -> "Phx WebComponents" end, class: "menu-title"}],
          menu: [
            %{inner_block: fn _, _ -> "Actionbar" end, id: "actionbar"},
            %{inner_block: fn _, _ -> "Appbar" end, id: "appbar"}
          ]
        })

      assert result =~ "<nav"
      assert result =~ "dm-menu"
      assert result =~ "dm-menu--md"
      assert result =~ "bg-base-200"
      assert result =~ "rounded-box"
      assert result =~ "w-56"
      assert result =~ "menu-title"
      assert result =~ "Phx WebComponents"
      assert result =~ "Actionbar"
      assert result =~ "Appbar"
    end

    test "renders with different sizes" do
      sizes = ["xs", "sm", "md", "lg", "xl"]

      for size <- sizes do
        result =
          render_component(&dm_left_menu/1, %{
            size: size,
            menu: [%{inner_block: fn _, _ -> "Item" end}]
          })

        assert result =~ "dm-menu--#{size}"
      end
    end

    test "renders horizontal menu" do
      result =
        render_component(&dm_left_menu/1, %{
          horizontal: true,
          menu: [
            %{inner_block: fn _, _ -> "Item 1" end},
            %{inner_block: fn _, _ -> "Item 2" end}
          ]
        })

      assert result =~ "dm-menu--horizontal"
    end

    test "renders active menu item" do
      result =
        render_component(&dm_left_menu/1, %{
          active: "actionbar",
          menu: [
            %{inner_block: fn _, _ -> "Actionbar" end, id: "actionbar"},
            %{inner_block: fn _, _ -> "Appbar" end, id: "appbar"}
          ]
        })

      assert result =~ "dm-menu__item--active"
    end

    test "renders disabled menu item" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [
            %{inner_block: fn _, _ -> "Disabled Item" end, disabled: true},
            %{inner_block: fn _, _ -> "Regular Item" end}
          ]
        })

      assert result =~ "dm-menu__item--disabled"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_left_menu/1, %{
          id: "my-menu",
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ ~s(id="my-menu")
    end

    test "renders with custom classes" do
      result =
        render_component(&dm_left_menu/1, %{
          class: "custom-class another-class",
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "custom-class"
      assert result =~ "another-class"
    end

    test "renders empty menu" do
      result = render_component(&dm_left_menu/1, %{})

      assert result =~ "<nav"
      assert result =~ "dm-menu"
    end
  end

  describe "dm_left_menu_group/1" do
    test "renders basic menu group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "mdi",
          title: [%{inner_block: fn _, _ -> "Icons" end}],
          menu: [
            %{inner_block: fn _, _ -> "MD Icon" end, id: "mdi", to: "/icons/mdi"},
            %{inner_block: fn _, _ -> "BS Icon" end, id: "bsi", to: "/icons/bsi"}
          ]
        })

      assert result =~ "<div"
      assert result =~ "dm-menu"
      assert result =~ "dm-menu--md"
      assert result =~ "Icons"
      assert result =~ "MD Icon"
      assert result =~ "BS Icon"
      assert result =~ ~s(href="/icons/mdi")
      assert result =~ ~s(href="/icons/bsi")
    end

    test "renders collapsible menu group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          open: false,
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, id: "security", to: "/settings/security"}
          ]
        })

      assert result =~ "<details"
      refute result =~ ~s(open="true")
      assert result =~ "<summary"
      assert result =~ "Settings"
      assert result =~ "Profile"
      assert result =~ "Security"
    end

    test "renders collapsible menu group with open state" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          open: true,
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [%{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/settings/profile"}]
        })

      assert result =~ ~s(<details open>)
    end

    test "renders menu group with different sizes" do
      sizes = ["xs", "sm", "md", "lg", "xl"]

      for size <- sizes do
        result =
          render_component(&dm_left_menu_group/1, %{
            size: size,
            title: [%{inner_block: fn _, _ -> "Test" end}],
            menu: [%{inner_block: fn _, _ -> "Item" end}]
          })

        assert result =~ "dm-menu--#{size}"
      end
    end

    test "renders active menu item in group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "profile",
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, id: "security", to: "/settings/security"}
          ]
        })

      assert result =~ "dm-menu__item--active"
    end

    test "renders disabled menu item in group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, disabled: true, to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, to: "/settings/security"}
          ]
        })

      assert result =~ "dm-menu__item--disabled"
    end

    test "renders menu group with custom id" do
      result =
        render_component(&dm_left_menu_group/1, %{
          id: "my-menu-group",
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ ~s(id="my-menu-group")
    end

    test "renders menu group with custom classes" do
      result =
        render_component(&dm_left_menu_group/1, %{
          class: "custom-class another-class",
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "custom-class"
      assert result =~ "another-class"
    end

    test "renders empty menu group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Empty Group" end}]
        })

      assert result =~ "<div"
      assert result =~ "dm-menu"
      assert result =~ "Empty Group"
    end

    test "renders menu group without to attribute" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item without link" end}]
        })

      assert result =~ ~s(href="#")
      assert result =~ "Item without link"
    end
  end
end
