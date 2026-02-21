defmodule PhoenixDuskmoon.Component.Navigation.NestedMenuTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Navigation.NestedMenu

  defp basic_items do
    [
      %{__slot__: :item, to: "/home", inner_block: fn _, _ -> "Home" end},
      %{__slot__: :item, to: "/about", inner_block: fn _, _ -> "About" end}
    ]
  end

  describe "dm_nested_menu basic rendering" do
    test "renders nav with nested-menu class" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      assert result =~ "<nav"
      assert result =~ "nested-menu"
    end

    test "renders default aria-label on nav" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      assert result =~ ~s(aria-label="Navigation menu")
    end

    test "renders custom aria-label on nav" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items(), nav_label: "Sidebar"})
      assert result =~ ~s(aria-label="Sidebar")
    end

    test "renders items as links" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      assert result =~ ~s(href="/home")
      assert result =~ "Home"
      assert result =~ ~s(href="/about")
      assert result =~ "About"
    end

    test "renders with custom id" do
      result = render_component(&dm_nested_menu/1, %{id: "side-nav", item: basic_items()})
      assert result =~ ~s(id="side-nav")
    end

    test "renders with custom class" do
      result = render_component(&dm_nested_menu/1, %{class: "w-64", item: basic_items()})
      assert result =~ "w-64"
    end
  end

  describe "dm_nested_menu title" do
    test "renders title" do
      result =
        render_component(&dm_nested_menu/1, %{
          title: [%{__slot__: :title, inner_block: fn _, _ -> "Navigation" end}],
          item: basic_items()
        })

      assert result =~ "nested-menu-title"
      assert result =~ "Navigation"
    end

    test "no title by default" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      refute result =~ "nested-menu-title"
    end
  end

  describe "dm_nested_menu item states" do
    test "renders active item" do
      items = [
        %{__slot__: :item, to: "/home", active: true, inner_block: fn _, _ -> "Home" end}
      ]

      result = render_component(&dm_nested_menu/1, %{item: items})
      assert result =~ ~s(class="active")
      assert result =~ ~s(aria-current="page")
    end

    test "renders disabled item" do
      items = [
        %{__slot__: :item, to: "/admin", disabled: true, inner_block: fn _, _ -> "Admin" end}
      ]

      result = render_component(&dm_nested_menu/1, %{item: items})
      assert result =~ "disabled"
      assert result =~ ~s[aria-disabled="true"]
      assert result =~ ~s[tabindex="-1"]
    end
  end

  describe "dm_nested_menu groups" do
    test "renders group with details/summary" do
      result =
        render_component(&dm_nested_menu/1, %{
          item: [],
          group: [
            %{
              __slot__: :group,
              title: "Reports",
              inner_block: fn _, _ -> "<li><a>Sales</a></li>" end
            }
          ]
        })

      assert result =~ "<details"
      assert result =~ "<summary"
      assert result =~ "Reports"
    end

    test "renders group initially open" do
      result =
        render_component(&dm_nested_menu/1, %{
          item: [],
          group: [
            %{
              __slot__: :group,
              title: "Section",
              open: true,
              inner_block: fn _, _ -> "" end
            }
          ]
        })

      assert result =~ "open"
    end
  end

  describe "dm_nested_menu sizes" do
    test "no size by default" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      refute result =~ "nested-menu-xs"
      refute result =~ "nested-menu-sm"
      refute result =~ "nested-menu-lg"
    end

    test "renders xs size" do
      result = render_component(&dm_nested_menu/1, %{size: "xs", item: basic_items()})
      assert result =~ "nested-menu-xs"
    end

    test "renders sm size" do
      result = render_component(&dm_nested_menu/1, %{size: "sm", item: basic_items()})
      assert result =~ "nested-menu-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_nested_menu/1, %{size: "lg", item: basic_items()})
      assert result =~ "nested-menu-lg"
    end
  end

  describe "dm_nested_menu modifiers" do
    test "not bordered by default" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      refute result =~ "nested-menu-bordered"
    end

    test "renders bordered" do
      result = render_component(&dm_nested_menu/1, %{bordered: true, item: basic_items()})
      assert result =~ "nested-menu-bordered"
    end

    test "not compact by default" do
      result = render_component(&dm_nested_menu/1, %{item: basic_items()})
      refute result =~ "nested-menu-compact"
    end

    test "renders compact" do
      result = render_component(&dm_nested_menu/1, %{compact: true, item: basic_items()})
      assert result =~ "nested-menu-compact"
    end
  end

  describe "dm_nested_menu_item" do
    test "renders as list item with link" do
      result =
        render_component(&dm_nested_menu_item/1, %{
          to: "/page",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Page" end}]
        })

      assert result =~ "<li"
      assert result =~ "<a"
      assert result =~ ~s(href="/page")
      assert result =~ "Page"
    end

    test "renders active state" do
      result =
        render_component(&dm_nested_menu_item/1, %{
          to: "/current",
          active: true,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Current" end}]
        })

      assert result =~ ~s(class="active")
      assert result =~ ~s(aria-current="page")
    end

    test "renders disabled state" do
      result =
        render_component(&dm_nested_menu_item/1, %{
          to: "/locked",
          disabled: true,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Locked" end}]
        })

      assert result =~ "disabled"
      assert result =~ ~s[aria-disabled="true"]
      assert result =~ ~s[tabindex="-1"]
    end
  end

  describe "dm_nested_menu combined" do
    test "renders with all options" do
      result =
        render_component(&dm_nested_menu/1, %{
          id: "admin-nav",
          class: "w-64",
          size: "sm",
          bordered: true,
          compact: true,
          title: [%{__slot__: :title, inner_block: fn _, _ -> "Admin" end}],
          item: [
            %{
              __slot__: :item,
              to: "/dashboard",
              active: true,
              inner_block: fn _, _ -> "Dashboard" end
            },
            %{__slot__: :item, to: "/users", inner_block: fn _, _ -> "Users" end}
          ],
          group: [
            %{
              __slot__: :group,
              title: "Settings",
              open: true,
              inner_block: fn _, _ -> "<li><a href=\"/general\">General</a></li>" end
            }
          ]
        })

      assert result =~ ~s(id="admin-nav")
      assert result =~ "w-64"
      assert result =~ "nested-menu-sm"
      assert result =~ "nested-menu-bordered"
      assert result =~ "nested-menu-compact"
      assert result =~ "Admin"
      assert result =~ "Dashboard"
      assert result =~ ~s(aria-current="page")
      assert result =~ "Settings"
    end
  end

  test "passes through global attributes" do
    result = render_component(&dm_nested_menu/1, %{item: basic_items(), "data-testid": "my-menu"})
    assert result =~ ~s[data-testid="my-menu"]
  end
end
