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

    test "renders rest attributes" do
      result =
        render_component(&dm_left_menu/1, %{
          "data-testid": "nav-menu",
          "aria-label": "Navigation",
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "data-testid=\"nav-menu\""
      assert result =~ "aria-label=\"Navigation\""
    end

    test "renders non-horizontal menu by default" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      refute result =~ "dm-menu--horizontal"
    end

    test "renders title with dm-menu__title class" do
      result =
        render_component(&dm_left_menu/1, %{
          title: [%{inner_block: fn _, _ -> "Title" end}]
        })

      assert result =~ "dm-menu__title"
      assert result =~ "Title"
    end

    test "renders menu item with dm-menu__item class" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "dm-menu__item"
    end

    test "renders only active item with active class" do
      result =
        render_component(&dm_left_menu/1, %{
          active: "b",
          menu: [
            %{inner_block: fn _, _ -> "A" end, id: "a"},
            %{inner_block: fn _, _ -> "B" end, id: "b"}
          ]
        })

      # Only one active
      parts = String.split(result, "dm-menu__item--active")
      assert length(parts) == 2
    end

    test "renders nav with default aria-label" do
      result = render_component(&dm_left_menu/1, %{})

      assert result =~ ~s[aria-label="Navigation menu"]
    end

    test "renders active menu item with aria-current page" do
      result =
        render_component(&dm_left_menu/1, %{
          active: "item1",
          menu: [
            %{inner_block: fn _, _ -> "Item 1" end, id: "item1"},
            %{inner_block: fn _, _ -> "Item 2" end, id: "item2"}
          ]
        })

      assert result =~ ~s[aria-current="page"]
    end

    test "renders disabled menu item with aria-disabled" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [
            %{inner_block: fn _, _ -> "Disabled" end, disabled: true},
            %{inner_block: fn _, _ -> "Normal" end}
          ]
        })

      assert result =~ ~s[aria-disabled="true"]
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

    test "renders non-collapsible group as li with title" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: false,
          title: [%{inner_block: fn _, _ -> "Section" end}]
        })

      refute result =~ "<details"
      refute result =~ "<summary"
      assert result =~ "dm-menu__title"
      assert result =~ "Section"
    end

    test "renders menu group with rest attributes" do
      result =
        render_component(&dm_left_menu_group/1, %{
          "data-testid": "menu-group",
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "data-testid=\"menu-group\""
    end

    test "renders menu group with menu item links" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Nav" end}],
          menu: [
            %{inner_block: fn _, _ -> "Page A" end, to: "/page-a"},
            %{inner_block: fn _, _ -> "Page B" end, to: "/page-b"}
          ]
        })

      assert result =~ ~s(href="/page-a")
      assert result =~ ~s(href="/page-b")
      assert result =~ "Page A"
      assert result =~ "Page B"
    end

    test "renders collapsible group with summary element" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          title: [%{inner_block: fn _, _ -> "Collapsible" end}]
        })

      assert result =~ "<details"
      assert result =~ "<summary"
      assert result =~ "Collapsible"
    end

    test "renders active menu item with aria-current page in group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "profile",
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/profile"},
            %{inner_block: fn _, _ -> "Security" end, id: "security", to: "/security"}
          ]
        })

      assert result =~ ~s[aria-current="page"]
    end

    test "renders disabled menu item with aria-disabled in group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Disabled" end, disabled: true, to: "/disabled"}
          ]
        })

      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders active item with aria-current in collapsible group" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          active: "mdi",
          title: [%{inner_block: fn _, _ -> "Icons" end}],
          menu: [
            %{inner_block: fn _, _ -> "MDI" end, id: "mdi", to: "/icons/mdi"},
            %{inner_block: fn _, _ -> "BSI" end, id: "bsi", to: "/icons/bsi"}
          ]
        })

      assert result =~ ~s[aria-current="page"]
    end

    test "renders collapsible group with title class" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          title: [%{class: "uppercase font-bold", inner_block: fn _, _ -> "Title" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end, to: "/item"}]
        })

      assert result =~ "uppercase font-bold"
      assert result =~ "<summary"
    end

    test "renders collapsible group with active and disabled items combined" do
      result =
        render_component(&dm_left_menu_group/1, %{
          collapsible: true,
          active: "a",
          title: [%{inner_block: fn _, _ -> "Group" end}],
          menu: [
            %{inner_block: fn _, _ -> "Active" end, id: "a", to: "/a"},
            %{inner_block: fn _, _ -> "Disabled" end, id: "b", to: "/b", disabled: true}
          ]
        })

      assert result =~ "dm-menu__item--active"
      assert result =~ "dm-menu__item--disabled"
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders group with all options combined" do
      result =
        render_component(&dm_left_menu_group/1, %{
          id: "full-group",
          class: "border-l",
          size: "sm",
          collapsible: true,
          open: true,
          active: "item1",
          title: [%{class: "text-lg", inner_block: fn _, _ -> "Full" end}],
          menu: [
            %{inner_block: fn _, _ -> "Item 1" end, id: "item1", to: "/1", class: "custom-cls"},
            %{inner_block: fn _, _ -> "Item 2" end, id: "item2", to: "/2", disabled: true}
          ]
        })

      assert result =~ ~s[id="full-group"]
      assert result =~ "border-l"
      assert result =~ "dm-menu--sm"
      assert result =~ ~s(<details open>)
      assert result =~ "text-lg"
      assert result =~ "Full"
      assert result =~ "dm-menu__item--active"
      assert result =~ "custom-cls"
      assert result =~ "dm-menu__item--disabled"
    end
  end

  describe "dm_left_menu/1 edge cases" do
    test "renders menu with item class attribute" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [
            %{inner_block: fn _, _ -> "Styled" end, class: "text-primary font-bold"}
          ]
        })

      assert result =~ "text-primary font-bold"
    end

    test "renders menu with title class attribute" do
      result =
        render_component(&dm_left_menu/1, %{
          title: [%{inner_block: fn _, _ -> "Title" end, class: "uppercase tracking-wide"}]
        })

      assert result =~ "uppercase tracking-wide"
    end

    test "renders menu with multiple titles" do
      result =
        render_component(&dm_left_menu/1, %{
          title: [
            %{inner_block: fn _, _ -> "Title 1" end},
            %{inner_block: fn _, _ -> "Title 2" end}
          ]
        })

      assert result =~ "Title 1"
      assert result =~ "Title 2"
    end

    test "renders menu with no active match does not add active class" do
      result =
        render_component(&dm_left_menu/1, %{
          active: "nonexistent",
          menu: [
            %{inner_block: fn _, _ -> "A" end, id: "a"},
            %{inner_block: fn _, _ -> "B" end, id: "b"}
          ]
        })

      refute result =~ "dm-menu__item--active"
    end

    test "renders menu with empty active string does not set aria-current" do
      result =
        render_component(&dm_left_menu/1, %{
          active: "",
          menu: [
            %{inner_block: fn _, _ -> "Item" end, id: ""}
          ]
        })

      # active: "" and id: "" match, but the guard @active != "" prevents aria-current
      refute result =~ ~s[aria-current="page"]
    end

    test "renders menu with all options combined" do
      result =
        render_component(&dm_left_menu/1, %{
          id: "full-menu",
          class: "bg-base-200 rounded-box",
          size: "lg",
          horizontal: true,
          active: "item2",
          title: [%{class: "text-sm", inner_block: fn _, _ -> "Nav" end}],
          menu: [
            %{inner_block: fn _, _ -> "Item 1" end, id: "item1", class: "cls-1"},
            %{inner_block: fn _, _ -> "Item 2" end, id: "item2"},
            %{inner_block: fn _, _ -> "Item 3" end, id: "item3", disabled: true}
          ],
          "data-testid": "nav"
        })

      assert result =~ ~s[id="full-menu"]
      assert result =~ "bg-base-200 rounded-box"
      assert result =~ "dm-menu--lg"
      assert result =~ "dm-menu--horizontal"
      assert result =~ "text-sm"
      assert result =~ "Nav"
      assert result =~ "cls-1"
      assert result =~ "dm-menu__item--active"
      assert result =~ "dm-menu__item--disabled"
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[aria-disabled="true"]
      assert result =~ ~s[data-testid="nav"]
    end

    test "renders menu with custom nav_label" do
      result =
        render_component(&dm_left_menu/1, %{
          nav_label: "Menu lateral",
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ ~s[aria-label="Menu lateral"]
    end
  end
end
