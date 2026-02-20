defmodule PhoenixDuskmoon.Component.Navigation.LeftMenuTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.LeftMenu

  describe "dm_left_menu/1" do
    test "renders basic menu with nested-menu class" do
      result =
        render_component(&dm_left_menu/1, %{
          class: "bg-base-200 rounded-box w-56",
          title: [%{inner_block: fn _, _ -> "Phx WebComponents" end, class: "menu-title"}],
          menu: [
            %{inner_block: fn _, _ -> "Group Content" end}
          ]
        })

      assert result =~ "<nav"
      assert result =~ "nested-menu"
      assert result =~ "bg-base-200"
      assert result =~ "rounded-box"
      assert result =~ "w-56"
      assert result =~ "menu-title"
      assert result =~ "Phx WebComponents"
      assert result =~ "Group Content"
    end

    test "renders with different sizes" do
      # xs → nested-menu-xs
      result = render_component(&dm_left_menu/1, %{size: "xs", menu: []})
      assert result =~ "nested-menu-xs"

      # sm → nested-menu-sm
      result = render_component(&dm_left_menu/1, %{size: "sm", menu: []})
      assert result =~ "nested-menu-sm"

      # md → no size class (default)
      result = render_component(&dm_left_menu/1, %{size: "md", menu: []})
      assert result =~ "nested-menu"
      refute result =~ "nested-menu-md"

      # lg → nested-menu-lg
      result = render_component(&dm_left_menu/1, %{size: "lg", menu: []})
      assert result =~ "nested-menu-lg"

      # xl → nested-menu-lg (mapped)
      result = render_component(&dm_left_menu/1, %{size: "xl", menu: []})
      assert result =~ "nested-menu-lg"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_left_menu/1, %{
          id: "my-menu",
          menu: []
        })

      assert result =~ ~s(id="my-menu")
    end

    test "renders with custom classes" do
      result =
        render_component(&dm_left_menu/1, %{
          class: "custom-class another-class",
          menu: []
        })

      assert result =~ "custom-class"
      assert result =~ "another-class"
    end

    test "renders empty menu" do
      result = render_component(&dm_left_menu/1, %{})

      assert result =~ "<nav"
      assert result =~ "nested-menu"
    end

    test "renders rest attributes" do
      result =
        render_component(&dm_left_menu/1, %{
          "data-testid": "nav-menu",
          "aria-label": "Navigation",
          menu: []
        })

      assert result =~ "data-testid=\"nav-menu\""
      assert result =~ "aria-label=\"Navigation\""
    end

    test "renders title with nested-menu-title class" do
      result =
        render_component(&dm_left_menu/1, %{
          title: [%{inner_block: fn _, _ -> "Title" end}]
        })

      assert result =~ "nested-menu-title"
      assert result =~ "Title"
    end

    test "renders nav with default aria-label" do
      result = render_component(&dm_left_menu/1, %{})

      assert result =~ ~s[aria-label="Navigation menu"]
    end

    test "renders menu slot content as pass-through" do
      result =
        render_component(&dm_left_menu/1, %{
          menu: [
            %{inner_block: fn _, _ -> "<details>Group A</details>" end},
            %{inner_block: fn _, _ -> "<details>Group B</details>" end}
          ]
        })

      assert result =~ "Group A"
      assert result =~ "Group B"
    end

    test "renders with custom nav_label" do
      result =
        render_component(&dm_left_menu/1, %{
          nav_label: "Menu lateral",
          menu: []
        })

      assert result =~ ~s[aria-label="Menu lateral"]
    end

    test "renders title with custom class" do
      result =
        render_component(&dm_left_menu/1, %{
          title: [%{inner_block: fn _, _ -> "Title" end, class: "uppercase tracking-wide"}]
        })

      assert result =~ "uppercase tracking-wide"
    end

    test "renders multiple titles" do
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

    test "renders all options combined" do
      result =
        render_component(&dm_left_menu/1, %{
          id: "full-menu",
          class: "bg-base-200 rounded-box",
          size: "lg",
          active: "item2",
          title: [%{class: "text-sm", inner_block: fn _, _ -> "Nav" end}],
          menu: [
            %{inner_block: fn _, _ -> "Menu Content" end}
          ],
          "data-testid": "nav"
        })

      assert result =~ ~s[id="full-menu"]
      assert result =~ "bg-base-200 rounded-box"
      assert result =~ "nested-menu-lg"
      assert result =~ "text-sm"
      assert result =~ "Nav"
      assert result =~ "Menu Content"
      assert result =~ ~s[data-testid="nav"]
    end
  end

  describe "dm_left_menu_group/1" do
    test "renders as details element with summary" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "mdi",
          title: [%{inner_block: fn _, _ -> "Icons" end}],
          menu: [
            %{inner_block: fn _, _ -> "MD Icon" end, id: "mdi", to: "/icons/mdi"},
            %{inner_block: fn _, _ -> "BS Icon" end, id: "bsi", to: "/icons/bsi"}
          ]
        })

      assert result =~ "<details"
      assert result =~ "<summary"
      assert result =~ "Icons"
      assert result =~ "MD Icon"
      assert result =~ "BS Icon"
      assert result =~ ~s(href="/icons/mdi")
      assert result =~ ~s(href="/icons/bsi")
    end

    test "renders open by default" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Section" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end, to: "/item"}]
        })

      assert result =~ "<details"
      assert result =~ " open>"
    end

    test "renders closed when open is false" do
      result =
        render_component(&dm_left_menu_group/1, %{
          open: false,
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, id: "security", to: "/settings/security"}
          ]
        })

      assert result =~ "<details"
      refute result =~ ~s(open)
      assert result =~ "<summary"
      assert result =~ "Settings"
      assert result =~ "Profile"
      assert result =~ "Security"
    end

    test "renders active menu item with active class on link" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "profile",
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, id: "profile", to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, id: "security", to: "/settings/security"}
          ]
        })

      assert result =~ ~s(class="active")
      assert result =~ ~s[aria-current="page"]
    end

    test "renders disabled menu item with disabled class on li" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, disabled: true, to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, to: "/settings/security"}
          ]
        })

      assert result =~ ~s(class="disabled")
      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders with custom id" do
      result =
        render_component(&dm_left_menu_group/1, %{
          id: "my-menu-group",
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ ~s(id="my-menu-group")
    end

    test "renders with custom classes" do
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

      assert result =~ "<details"
      assert result =~ "<summary"
      assert result =~ "Empty Group"
    end

    test "renders menu item without to attribute as href=#" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item without link" end}]
        })

      assert result =~ ~s(href="#")
      assert result =~ "Item without link"
    end

    test "renders rest attributes" do
      result =
        render_component(&dm_left_menu_group/1, %{
          "data-testid": "menu-group",
          title: [%{inner_block: fn _, _ -> "Test" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end}]
        })

      assert result =~ "data-testid=\"menu-group\""
    end

    test "renders menu item links" do
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

    test "renders active menu item with aria-current page" do
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

    test "renders disabled menu item with aria-disabled" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Disabled" end, disabled: true, to: "/disabled"}
          ]
        })

      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders summary with title class" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{class: "uppercase font-bold", inner_block: fn _, _ -> "Title" end}],
          menu: [%{inner_block: fn _, _ -> "Item" end, to: "/item"}]
        })

      assert result =~ "uppercase font-bold"
      assert result =~ "<summary"
    end

    test "renders active and disabled items combined" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "a",
          title: [%{inner_block: fn _, _ -> "Group" end}],
          menu: [
            %{inner_block: fn _, _ -> "Active" end, id: "a", to: "/a"},
            %{inner_block: fn _, _ -> "Disabled" end, id: "b", to: "/b", disabled: true}
          ]
        })

      assert result =~ ~s(class="active")
      assert result =~ ~s(class="disabled")
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders group with all options combined" do
      result =
        render_component(&dm_left_menu_group/1, %{
          id: "full-group",
          class: "border-l",
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
      assert result =~ "<details"
      assert result =~ " open>"
      assert result =~ "text-lg"
      assert result =~ "Full"
      assert result =~ "custom-cls"
      assert result =~ ~s(class="disabled")
    end

    test "does not set active class when active is empty" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "",
          title: [%{inner_block: fn _, _ -> "Group" end}],
          menu: [
            %{inner_block: fn _, _ -> "Item" end, id: "", to: "/item"}
          ]
        })

      refute result =~ ~s(class="active")
      refute result =~ ~s[aria-current="page"]
    end

    test "does not set active class when no id matches" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "nonexistent",
          title: [%{inner_block: fn _, _ -> "Group" end}],
          menu: [
            %{inner_block: fn _, _ -> "A" end, id: "a", to: "/a"},
            %{inner_block: fn _, _ -> "B" end, id: "b", to: "/b"}
          ]
        })

      refute result =~ ~s(class="active")
    end

    test "renders only one active item" do
      result =
        render_component(&dm_left_menu_group/1, %{
          active: "b",
          title: [%{inner_block: fn _, _ -> "Group" end}],
          menu: [
            %{inner_block: fn _, _ -> "A" end, id: "a", to: "/a"},
            %{inner_block: fn _, _ -> "B" end, id: "b", to: "/b"},
            %{inner_block: fn _, _ -> "C" end, id: "c", to: "/c"}
          ]
        })

      # Only one link should have the active class
      parts = String.split(result, ~s(class="active"))
      assert length(parts) == 2
    end
  end
end
