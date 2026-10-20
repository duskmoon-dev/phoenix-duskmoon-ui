defmodule PhoenixDuskmoon.Component.Navigation.LeftMenuTest do
  use ExUnit.Case, async: true

  use Phoenix.Component
  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip
  import PhoenixDuskmoon.Component.Navigation.LeftMenu

  describe "dm_left_menu/1" do
    @groups [
      %{
        id: "workspace",
        label: "Workspace",
        open: false,
        items: [
          %{
            id: "dashboard",
            label: "Dashboard",
            to: "/dashboard",
            icon: "home",
            rest: %{"data-test" => "dashboard"}
          }
        ]
      }
    ]

    test "data groups render canonical links, branding and footer without custom slots" do
      html =
        render_component(&dm_left_menu/1, %{
          id: "sidebar",
          groups: @groups,
          active: "dashboard",
          brand: %{label: "My app", to: "/", icon: "home", version: "v1"},
          footer_text: "Account"
        })
        |> LazyHTML.from_fragment()

      assert LazyHTML.text(LazyHTML.query(html, "a[href='/']")) =~ "My app"
      assert LazyHTML.text(LazyHTML.query(html, "a[href='/']")) =~ "v1"
      assert LazyHTML.text(html) =~ "Account"
      assert Enum.count(LazyHTML.query(html, "#sidebar-group-workspace:not([open])")) == 1
      assert Enum.count(LazyHTML.query(html, "a[data-test=dashboard][aria-current=page]")) == 1

      assert Enum.count(
               LazyHTML.query(html, "[id=sidebar-group-workspace-dashboard-hint-tooltip]")
             ) ==
               1
    end

    test "disabled data items accept missing, nil and empty destinations" do
      for destination <- [%{}, %{to: nil}, %{to: ""}, %{to: "/unavailable"}] do
        item = Map.merge(%{id: "planned", label: "Planned", disabled: true}, destination)

        html =
          render_component(&dm_left_menu/1, %{
            id: "sidebar",
            groups: [%{id: "workspace", label: "Workspace", items: [item]}]
          })
          |> LazyHTML.from_fragment()

        assert Enum.count(LazyHTML.query(html, "li > button[aria-disabled=true]")) == 1
        assert LazyHTML.text(html) =~ "Planned"
        assert Enum.empty?(LazyHTML.query(html, "a, [href], [data-phx-link]"))
      end
    end

    test "enabled data items still require a nonempty string destination" do
      for destination <- [%{}, %{to: nil}, %{to: ""}, %{to: false}, %{to: 123}],
          disabled <- [%{}, %{disabled: false}] do
        item = Map.merge(%{id: "planned", label: "Planned"}, Map.merge(destination, disabled))

        assert_raise ArgumentError, ~r/requires a non-empty string for to/, fn ->
          render_component(&dm_left_menu/1, %{
            id: "sidebar",
            groups: [%{id: "workspace", label: "Workspace", items: [item]}]
          })
        end
      end
    end

    test "data groups require stable unique ids and cannot be mixed with menu slots" do
      assert_raise ArgumentError, ~r/requires a stable id/, fn ->
        render_component(&dm_left_menu/1, %{groups: @groups})
      end

      assert_raise ArgumentError, ~r/either groups or :menu slots/, fn ->
        render_component(&dm_left_menu/1, %{
          id: "sidebar",
          groups: @groups,
          menu: [%{inner_block: fn _, _ -> "Other menu" end}]
        })
      end

      assert_raise ArgumentError, ~r/group ids must be unique/, fn ->
        render_component(&dm_left_menu/1, %{id: "sidebar", groups: @groups ++ @groups})
      end

      assert_raise ArgumentError, ~r/item ids must be unique/, fn ->
        render_component(&dm_left_menu/1, %{
          id: "sidebar",
          groups: @groups ++ [%{hd(@groups) | id: "other"}]
        })
      end
    end

    test "sticky mode requires a LiveView socket and rejects captured HEEx slots" do
      assert_raise ArgumentError, ~r/requires socket/, fn ->
        render_component(&dm_left_menu/1, %{id: "sidebar", sticky: true, groups: @groups})
      end

      assert_raise ArgumentError, ~r/instead of slots/, fn ->
        render_component(&dm_left_menu/1, %{
          id: "sidebar",
          sticky: true,
          socket: %Phoenix.LiveView.Socket{},
          groups: @groups,
          header: [%{inner_block: fn _, _ -> "Brand" end}]
        })
      end
    end

    test "collapsible menus require a stable hook id" do
      assert_raise ArgumentError, ~r/requires a stable id/, fn ->
        render_component(&dm_left_menu/1, %{collapsible: true})
      end
    end

    test "collapse is opt-in and keeps the ordinary menu free of hook controls" do
      html = render_component(&dm_left_menu/1, %{}) |> LazyHTML.from_fragment()
      assert Enum.empty?(LazyHTML.query(html, "[phx-hook], [data-left-menu-scroll], button"))
    end

    test "controlled collapse renders distinct server input and an optional user event" do
      html =
        render_component(&dm_left_menu/1, %{
          id: "controlled-sidebar",
          collapsible: true,
          collapse_controlled: true,
          collapsed: false,
          collapse_event: "app:sidebar-collapse"
        })
        |> LazyHTML.from_fragment()

      nav = LazyHTML.query(html, "nav")
      assert LazyHTML.attribute(nav, "data-server-collapsed") == ["false"]
      assert LazyHTML.attribute(nav, "data-collapsed") == ["false"]
      assert LazyHTML.attribute(nav, "data-collapse-event") == ["app:sidebar-collapse"]

      ordinary = render_component(&dm_left_menu/1, %{id: "sidebar", collapsible: true})
      refute ordinary =~ "data-server-collapsed"
      refute ordinary =~ "data-collapse-event"
    end

    test "renders bounded scroll area with header and footer outside it and labelled toggle" do
      html =
        render_component(&dm_left_menu/1, %{
          id: "sidebar",
          collapsible: true,
          collapsed: true,
          storage_key: "app:sidebar",
          expand_label: "展开菜单",
          collapse_label: "收起菜单",
          class: "sticky top-0 h-dvh",
          header: [%{inner_block: fn _, _ -> "Brand" end}],
          footer: [%{inner_block: fn _, _ -> "Account" end}],
          menu: [%{inner_block: fn _, _ -> "Navigation" end}]
        })
        |> LazyHTML.from_fragment()

      nav = LazyHTML.query(html, "nav")
      assert LazyHTML.attribute(nav, "phx-hook") == ["DuskmoonLeftMenu"]
      assert LazyHTML.attribute(nav, "data-collapsed") == ["true"]
      assert LazyHTML.attribute(nav, "data-storage-key") == ["app:sidebar"]
      scroller = LazyHTML.query(html, "#sidebar-scroll[data-left-menu-scroll]")
      assert LazyHTML.text(scroller) =~ "Navigation"
      refute LazyHTML.text(scroller) =~ "Brand"
      refute LazyHTML.text(scroller) =~ "Account"
      toggle = LazyHTML.query(html, "button[data-left-menu-toggle]")
      assert LazyHTML.attribute(toggle, "type") == ["button"]
      assert LazyHTML.attribute(toggle, "aria-expanded") == ["false"]
      assert LazyHTML.attribute(toggle, "aria-label") == ["展开菜单"]
      assert LazyHTML.attribute(toggle, "aria-controls") == ["sidebar-scroll"]
    end

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
    test "icon items keep accessible names and stable tooltips outside navigation links" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <.dm_left_menu id="sidebar" collapsible>
          <:menu>
            <.dm_left_menu_group id="workspace" active="home">
              <:title>Workspace</:title>
              <:menu id="home" to="/home" icon="home" label="Home" rest={%{"aria-describedby" => "help", "style" => "color: red"}}>
                Home
              </:menu>
              <:menu id="settings" to="/settings" icon="cog" label="Settings">Settings</:menu>
            </.dm_left_menu_group>
          </:menu>
        </.dm_left_menu>
        """)
        |> LazyHTML.from_fragment()

      link = LazyHTML.query(html, ~s(a[href="/home"]))
      assert LazyHTML.attribute(link, "aria-label") == ["Home"]
      assert LazyHTML.attribute(link, "aria-current") == ["page"]
      assert LazyHTML.attribute(link, "interestfor") == ["workspace-home-hint-tooltip"]
      assert LazyHTML.attribute(link, "aria-describedby") == ["help workspace-home-hint-tooltip"]
      assert LazyHTML.attribute(link, "style") |> hd() =~ "color: red"
      assert LazyHTML.text(LazyHTML.query(link, "[data-left-menu-label]")) =~ "Home"
      assert LazyHTML.attribute(LazyHTML.query(link, "svg"), "aria-hidden") == ["true"]
      assert Enum.empty?(LazyHTML.query(html, "a [popover], a[icon], a[label], ul > details"))

      assert LazyHTML.attribute(LazyHTML.query(html, "[role=tooltip]"), "id") == [
               "workspace-home-hint-tooltip",
               "workspace-settings-hint-tooltip"
             ]
    end

    test "disabled slots keep labels, explanations, icons and tooltips without navigation" do
      for destination <- [%{}, %{to: nil}, %{to: ""}, %{to: "/services"}] do
        assigns = %{destination: destination}

        html =
          rendered_to_string(~H"""
          <.dm_left_menu id="sidebar" collapsible>
            <:menu>
              <.dm_left_menu_group id="workers">
                <:title>Workers</:title>
                <:menu id="services" disabled icon="cog" label="Services" rest={%{"aria-describedby" => "scope-help"}} {@destination}>
                  Services <span id="scope-help">Requires scope</span>
                </:menu>
              </.dm_left_menu_group>
            </:menu>
          </.dm_left_menu>
          """)
          |> LazyHTML.from_fragment()

        item = LazyHTML.query(html, "li > button[aria-disabled=true]")
        assert Enum.count(item) == 1
        assert LazyHTML.attribute(item, "type") == ["button"]
        assert LazyHTML.attribute(item, "disabled") == []
        assert Enum.flat_map(LazyHTML.attribute(item, "class"), &String.split/1) == ["menu-item"]
        assert LazyHTML.attribute(item, "aria-label") == ["Services"]
        assert LazyHTML.attribute(item, "tabindex") == ["-1"]
        assert LazyHTML.attribute(item, "interestfor") == ["workers-services-hint-tooltip"]

        assert LazyHTML.attribute(item, "data-left-menu-tooltip") == [
                 "workers-services-hint-tooltip"
               ]

        assert LazyHTML.attribute(item, "aria-describedby") == [
                 "scope-help workers-services-hint-tooltip"
               ]

        assert LazyHTML.attribute(LazyHTML.query(item, "svg"), "aria-hidden") == ["true"]
        assert LazyHTML.text(LazyHTML.query(item, "[data-left-menu-label]")) =~ "Services"
        assert LazyHTML.text(LazyHTML.query(item, "#scope-help")) == "Requires scope"

        assert Enum.count(
                 LazyHTML.query(html, "[id=workers-services-hint-tooltip][role=tooltip]")
               ) == 1

        assert Enum.empty?(LazyHTML.query(item, "[href], [data-phx-link], [data-phx-link-state]"))
        assert Enum.empty?(LazyHTML.query(html, "a"))
      end
    end

    test "disabled slots strip dynamic and explicit event handlers while preserving attributes" do
      assigns = %{
        item_attrs: %{
          "onclick" => "alert('click')",
          "onmouseover" => "alert('hover')",
          "phx-click" => "navigate",
          "phx-keydown" => "navigate",
          "phx-hook" => "Navigation",
          "phx-value-id" => "services",
          "data-phx-link" => "redirect",
          "data-phx-click" => "navigate",
          "aria-describedby" => "scope-help",
          "data-tracking" => "services"
        }
      }

      html =
        rendered_to_string(~H"""
        <.dm_left_menu_group>
          <:title>Workers</:title>
          <:menu id="services" to="/services" disabled rest={%{onfocus: "alert('focus')", "phx-blur": "navigate", "data-note": "planned"}} {@item_attrs}>
            Services
          </:menu>
        </.dm_left_menu_group>
        """)
        |> LazyHTML.from_fragment()

      item = LazyHTML.query(html, "li > button[aria-disabled=true]")
      assert Enum.count(item) == 1
      assert LazyHTML.attribute(item, "aria-describedby") == ["scope-help"]
      assert LazyHTML.attribute(item, "data-tracking") == ["services"]
      assert LazyHTML.attribute(item, "data-note") == ["planned"]

      for attr <-
            ~w(href data-phx-link data-phx-click onclick onmouseover onfocus phx-click phx-keydown phx-hook phx-blur phx-value-id) do
        assert LazyHTML.attribute(item, attr) == []
      end
    end

    test "disabled items discard reserved navigation and activation attributes regardless of case" do
      reserved =
        ~w(class navigate patch href aria-current aria-disabled data-phx-link data-phx-link-state type disabled tabindex popovertarget popovertargetaction command commandfor onclick phx-click data-phx-click)

      for casing <- [&Function.identity/1, &String.upcase/1, &String.capitalize/1] do
        attrs = Map.new(reserved, &{casing.(&1), "override"})

        html =
          render_component(&dm_left_menu_group/1, %{
            title: [%{inner_block: fn _, _ -> "Workers" end}],
            menu: [
              %{
                id: "services",
                to: "/services",
                disabled: true,
                rest: attrs,
                inner_block: fn _, _ -> "Services" end
              }
            ]
          })
          |> LazyHTML.from_fragment()

        item = LazyHTML.query(html, "button[aria-disabled=true]")
        assert Enum.count(item) == 1
        assert Enum.flat_map(LazyHTML.attribute(item, "class"), &String.split/1) == ["menu-item"]
        assert LazyHTML.attribute(item, "type") == ["button"]
        assert LazyHTML.attribute(item, "tabindex") == ["-1"]

        for attr <- reserved -- ~w(class aria-disabled type tabindex) do
          assert LazyHTML.attribute(item, attr) == []
        end
      end
    end

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

    test "forwards explicit non-event attributes to disabled items and retains active links" do
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

      disabled = LazyHTML.query(html, "#private-trigger")
      assert LazyHTML.attribute(disabled, "id") == ["private-trigger"]
      assert LazyHTML.attribute(disabled, "aria-label") == ["Private settings"]
      assert LazyHTML.attribute(disabled, "data-tracking") == ["private-settings"]
      assert LazyHTML.attribute(disabled, "phx-click") == []
      assert LazyHTML.attribute(disabled, "phx-value-section") == []
      assert LazyHTML.attribute(disabled, "style") == ["color: rebeccapurple"]
      assert LazyHTML.attribute(disabled, "title") == ["Unavailable settings"]
      assert LazyHTML.attribute(disabled, "data-phx-link") == []
      assert LazyHTML.attribute(disabled, "class") == ["menu-item private-link"]
      assert LazyHTML.attribute(disabled, "aria-disabled") == ["true"]
      assert LazyHTML.attribute(disabled, "aria-current") == []
      assert LazyHTML.attribute(disabled, "tabindex") == ["-1"]

      assert Enum.count(LazyHTML.query(html, "li > button[aria-disabled=true]#private-trigger")) ==
               1

      assert LazyHTML.attribute(disabled, "href") == []

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
                :type => "submit",
                "disabled" => false,
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

      html = LazyHTML.from_fragment(raw_html)
      link = LazyHTML.query(html, "li > button[aria-disabled=true]")
      assert Enum.count(link) == 1
      assert LazyHTML.attribute(link, "href") == []
      assert LazyHTML.attribute(link, "data-phx-link") == []
      assert LazyHTML.attribute(link, "data-phx-link-state") == []
      assert LazyHTML.attribute(link, "type") == ["button"]
      assert LazyHTML.attribute(link, "class") == ["menu-item private-link active"]
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

    test "renders disabled menu item as an ARIA-disabled button" do
      result =
        render_component(&dm_left_menu_group/1, %{
          title: [%{inner_block: fn _, _ -> "Settings" end}],
          menu: [
            %{inner_block: fn _, _ -> "Profile" end, disabled: true, to: "/settings/profile"},
            %{inner_block: fn _, _ -> "Security" end, to: "/settings/security"}
          ]
        })

      assert result =~ ~s(<button)
      refute result =~ ~s( disabled)
      refute result =~ ~s(class="disabled")
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
      assert result =~ ~s(<button)
      refute result =~ ~s( disabled)
      refute result =~ ~s(class="disabled")
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
      assert result =~ ~s(<button)
      refute result =~ ~s( disabled)
      refute result =~ ~s(class="disabled")
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
