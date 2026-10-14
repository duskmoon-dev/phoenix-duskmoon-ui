defmodule PhoenixDuskmoon.Component.Navigation.LeftMenuTest do
  use ExUnit.Case, async: true

  use Phoenix.Component
  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip
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
    test "forwards public tooltip trigger attributes from a raw menu slot to its native link" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dm_tooltip id="dashboard-hint" content="Dashboard" position="right" :let={trigger_attrs}>
          <.dm_left_menu_group active="dashboard">
            <:title>Overview</:title>
            <:menu id="dashboard" to="/admin/dashboard" class="dashboard-link" {trigger_attrs}>
              Dashboard
            </:menu>
            <:menu id="settings" to="/admin/settings">Settings</:menu>
          </.dm_left_menu_group>
        </.dm_tooltip>
        """)
        |> LazyHTML.from_fragment()

      link = LazyHTML.query(html, ~s(a[href="/admin/dashboard"]))
      assert LazyHTML.attribute(link, "aria-describedby") == ["dashboard-hint-tooltip"]
      assert LazyHTML.attribute(link, "interestfor") == ["dashboard-hint-tooltip"]
      assert LazyHTML.attribute(link, "style") == ["anchor-name: --anchor-dashboard-hint-tooltip"]
      assert LazyHTML.attribute(link, "title") == ["Dashboard"]
      assert LazyHTML.attribute(link, "data-phx-link") == ["redirect"]
      assert LazyHTML.attribute(link, "data-phx-link-state") == ["push"]
      assert LazyHTML.attribute(link, "class") == ["dashboard-link active"]
      assert LazyHTML.attribute(link, "aria-current") == ["page"]
      assert LazyHTML.attribute(link, "aria-disabled") == []
      assert LazyHTML.attribute(link, "tabindex") == []

      for selector <- ["details", "summary", "ul", "li", ~s(a[href="/admin/settings"])],
          attribute <- ~w(aria-describedby interestfor style title) do
        assert LazyHTML.attribute(LazyHTML.query(html, selector), attribute) == []
      end

      assert Enum.empty?(LazyHTML.query(html, "[inner_block], [__slot__], [__changed__], a[to]"))
      assert LazyHTML.text(link) =~ "Dashboard"
    end

    test "forwards explicit rest attributes while retaining disabled and active link behavior" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dm_left_menu_group active="overview">
          <:title>Settings</:title>
          <:menu id="overview" to="/overview" class="overview-link">Overview</:menu>
          <:menu
            id="private"
            to="/settings/private"
            class="private-link"
            disabled={true}
            rest={%{
              "id" => "private-trigger",
              "aria-label" => "Private settings",
              "data-tracking" => "private-settings",
              "phx-click" => "audit-navigation",
              "phx-value-section" => "private",
              "style" => "color: rebeccapurple",
              "title" => "Unavailable settings",
              "tabindex" => "0"
            }}
          >
            Private
          </:menu>
        </.dm_left_menu_group>
        """)
        |> LazyHTML.from_fragment()

      disabled = LazyHTML.query(html, ~s(a[href="/settings/private"]))
      assert LazyHTML.attribute(disabled, "id") == ["private-trigger"]
      assert LazyHTML.attribute(disabled, "aria-label") == ["Private settings"]
      assert LazyHTML.attribute(disabled, "data-tracking") == ["private-settings"]
      assert LazyHTML.attribute(disabled, "phx-click") == ["audit-navigation"]
      assert LazyHTML.attribute(disabled, "phx-value-section") == ["private"]
      assert LazyHTML.attribute(disabled, "style") == ["color: rebeccapurple"]
      assert LazyHTML.attribute(disabled, "title") == ["Unavailable settings"]
      assert LazyHTML.attribute(disabled, "data-phx-link") == ["redirect"]
      assert LazyHTML.attribute(disabled, "class") == ["private-link"]
      assert LazyHTML.attribute(disabled, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(disabled, "aria-current") == []
      assert LazyHTML.attribute(disabled, "tabindex") == ["-1"]

      assert LazyHTML.attribute(LazyHTML.query(html, "li.disabled > a"), "href") ==
               ["/settings/private"]

      active = LazyHTML.query(html, ~s(a[href="/overview"]))
      assert LazyHTML.attribute(active, "class") == ["overview-link active"]
      assert LazyHTML.attribute(active, "aria-current") == ["page"]
      assert LazyHTML.attribute(active, "tabindex") == []

      for selector <- ["details", "summary", "ul", "li", ~s(a[href="/overview"])],
          attribute <- ~w(aria-label data-tracking phx-click phx-value-section style title) do
        assert LazyHTML.attribute(LazyHTML.query(html, selector), attribute) == []
      end

      assert Enum.empty?(
               LazyHTML.query(
                 html,
                 "[inner_block], [__slot__], [__changed__], a[to], a[disabled]"
               )
             )

      assert LazyHTML.text(disabled) =~ "Private"
    end

    test "forwards dynamic global attributes to an enabled native link" do
      assigns = %{
        link_attrs: %{
          "aria-label" => "Account settings",
          "data-tracking" => "account-settings",
          "phx-click" => "audit-navigation",
          "phx-value-section" => "account",
          "style" => "color: rebeccapurple",
          "title" => "Open account settings",
          "tabindex" => "2"
        }
      }

      html =
        rendered_to_string(~H"""
        <.dm_left_menu_group active="account">
          <:title>Settings</:title>
          <:menu id="account" to="/account" class="account-link" {@link_attrs}>
            Account
          </:menu>
          <:menu id="help" to="/help">Help</:menu>
        </.dm_left_menu_group>
        """)
        |> LazyHTML.from_fragment()

      link = LazyHTML.query(html, ~s(a[href="/account"]))

      for {attribute, value} <- assigns.link_attrs do
        assert LazyHTML.attribute(link, attribute) == [value]

        for selector <- ["details", "summary", "ul", "li", ~s(a[href="/help"])] do
          assert LazyHTML.attribute(LazyHTML.query(html, selector), attribute) == []
        end
      end

      assert LazyHTML.attribute(link, "data-phx-link") == ["redirect"]
      assert LazyHTML.attribute(link, "data-phx-link-state") == ["push"]
      assert LazyHTML.attribute(link, "class") == ["account-link active"]
      assert LazyHTML.attribute(link, "aria-current") == ["page"]
      assert LazyHTML.attribute(link, "aria-disabled") == []
      assert LazyHTML.attribute(link, "id") == []

      assert Enum.empty?(
               LazyHTML.query(html, "[inner_block], [__slot__], [__changed__], a[to], a[rest]")
             )
    end

    test "explicit rest attributes override dynamic attributes with equivalent string keys" do
      assigns = %{
        link_attrs: %{"title" => "Dynamic title", "style" => "color: red"}
      }

      html =
        rendered_to_string(~H"""
        <.dm_left_menu_group>
          <:title>Settings</:title>
          <:menu
            id="account"
            to="/account"
            rest={%{title: "Explicit title", style: "color: blue"}}
            {@link_attrs}
          >
            Account
          </:menu>
        </.dm_left_menu_group>
        """)
        |> LazyHTML.from_fragment()

      link = LazyHTML.query(html, ~s(a[href="/account"]))
      assert LazyHTML.attribute(link, "title") == ["Explicit title"]
      assert LazyHTML.attribute(link, "style") == ["color: blue"]
    end

    test "rest attributes cannot override navigation, classes, or active and disabled state" do
      raw_html =
        render_component(&dm_left_menu_group/1, %{
          active: "private",
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{
              inner_block: fn _, _ -> "Private" end,
              id: "private",
              to: "/settings/private",
              class: "private-link",
              disabled: true,
              rest: %{
                :class => "override-class",
                "navigate" => "/override-navigation",
                :patch => "/override-patch",
                "href" => "/override-href",
                "aria-current" => "step",
                :"aria-disabled" => "false",
                "data-phx-link" => "patch",
                :"data-phx-link-state" => "replace",
                :tabindex => "0"
              }
            }
          ]
        })

      [[raw_link]] = Regex.scan(~r/<a\b[^>]*href="\/settings\/private"[^>]*>/, raw_html)

      assert Regex.scan(~r/\sdata-phx-link="[^"]*"/, raw_link) == [
               [~s( data-phx-link="redirect")]
             ]

      assert Regex.scan(~r/\sdata-phx-link-state="[^"]*"/, raw_link) == [
               [~s( data-phx-link-state="push")]
             ]

      html = LazyHTML.from_fragment(raw_html)
      link = LazyHTML.query(html, "li.disabled > a")
      assert LazyHTML.attribute(link, "href") == ["/settings/private"]
      assert LazyHTML.attribute(link, "data-phx-link") == ["redirect"]
      assert LazyHTML.attribute(link, "data-phx-link-state") == ["push"]
      assert LazyHTML.attribute(link, "class") == ["private-link active"]
      assert LazyHTML.attribute(link, "aria-current") == ["page"]
      assert LazyHTML.attribute(link, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(link, "tabindex") == ["-1"]
      assert LazyHTML.attribute(link, "navigate") == []
      assert LazyHTML.attribute(link, "patch") == []
    end

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
      assert result =~ ~s[tabindex="-1"]
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
