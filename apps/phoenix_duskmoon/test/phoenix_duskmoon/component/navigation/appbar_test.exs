defmodule PhoenixDuskmoon.Component.Navigation.AppbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Appbar

  test "renders basic appbar with header element" do
    result = render_component(&dm_appbar/1, %{title: "MyApp"})

    assert result =~ "<header"
    assert result =~ "appbar"
    assert result =~ "MyApp"
  end

  test "renders appbar with title" do
    result = render_component(&dm_appbar/1, %{title: "Dashboard"})

    assert result =~ "appbar-title"
    assert result =~ "Dashboard"
  end

  test "renders appbar with sticky class by default" do
    result = render_component(&dm_appbar/1, %{title: "App"})

    assert result =~ "appbar-sticky"
  end

  test "renders appbar without sticky when disabled" do
    result = render_component(&dm_appbar/1, %{title: "App", sticky: false})

    refute result =~ "appbar-sticky"
  end

  test "renders appbar with custom class" do
    result =
      render_component(&dm_appbar/1, %{title: "App", class: "appbar-primary appbar-elevated"})

    assert result =~ "appbar-primary"
    assert result =~ "appbar-elevated"
  end

  test "renders appbar with custom id" do
    result = render_component(&dm_appbar/1, %{title: "App", id: "main-bar"})

    assert result =~ ~s[id="main-bar"]
  end

  test "renders appbar with brand area" do
    result = render_component(&dm_appbar/1, %{title: "App"})

    assert result =~ "appbar-brand"
  end

  test "renders appbar with trailing area" do
    result = render_component(&dm_appbar/1, %{title: "App"})

    assert result =~ "appbar-trailing"
  end

  test "renders appbar with menu items" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [
          %{to: "/dashboard", inner_block: fn _, _ -> "Dashboard" end},
          %{to: "/settings", inner_block: fn _, _ -> "Settings" end}
        ]
      })

    assert result =~ "Dashboard"
    assert result =~ "Settings"
    assert result =~ "appbar-action"
  end

  test "renders appbar with logo slot" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        logo: [%{inner_block: fn _, _ -> "Logo Content" end}]
      })

    assert result =~ "Logo Content"
    assert result =~ "appbar-brand"
  end

  test "renders appbar with user_profile slot" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        user_profile: [%{inner_block: fn _, _ -> "User Avatar" end}]
      })

    assert result =~ "User Avatar"
  end

  test "renders appbar with rest attributes" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        "data-testid": "app-header"
      })

    assert result =~ "data-testid=\"app-header\""
  end

  test "active menu item gets aria-current page" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [%{to: "/home", active: true, __slot__: :menu, inner_block: fn _, _ -> "Home" end}]
      })

    assert result =~ ~s(aria-current="page")
  end

  test "inactive menu item has no aria-current" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [%{to: "/about", __slot__: :menu, inner_block: fn _, _ -> "About" end}]
      })

    refute result =~ "aria-current"
  end

  describe "dm_simple_appbar/1" do
    test "renders simple appbar with header element" do
      result = render_component(&dm_simple_appbar/1, %{title: "SimpleApp"})

      assert result =~ "<header"
      assert result =~ "appbar"
      assert result =~ "SimpleApp"
    end

    test "renders simple appbar with sticky class" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})

      assert result =~ "appbar-sticky"
    end

    test "renders simple appbar with menu items" do
      result =
        render_component(&dm_simple_appbar/1, %{
          title: "App",
          menu: [%{to: "/dashboard", inner_block: fn _, _ -> "Dashboard" end}]
        })

      assert result =~ "Dashboard"
    end

    test "renders nav with aria-label for main navigation" do
      result =
        render_component(&dm_simple_appbar/1, %{
          title: "App",
          menu: [%{to: "/home", inner_block: fn _, _ -> "Home" end}]
        })

      assert result =~ ~s(aria-label="Main navigation")
    end

    test "renders simple appbar with mobile menu toggle" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})

      assert result =~ "appbar-mobile-menu"
      assert result =~ "md:hidden"
    end

    test "renders simple appbar with custom id" do
      result = render_component(&dm_simple_appbar/1, %{title: "App", id: "simple-bar"})

      assert result =~ ~s[id="simple-bar"]
    end

    test "renders simple appbar with custom class" do
      result =
        render_component(&dm_simple_appbar/1, %{title: "App", class: "bg-primary"})

      assert result =~ "bg-primary"
    end

    test "renders simple appbar with rest attributes" do
      result =
        render_component(&dm_simple_appbar/1, %{
          title: "App",
          "data-testid": "simple-header"
        })

      assert result =~ "data-testid=\"simple-header\""
    end

    test "renders simple appbar always sticky" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})

      assert result =~ "appbar-sticky"
    end

    test "renders mobile menu toggle with aria-label" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})

      assert result =~ ~s[aria-label="Toggle mobile menu"]
    end
  end

  test "renders appbar with default empty menu" do
    result = render_component(&dm_appbar/1, %{title: "App"})

    assert result =~ "appbar"
    assert result =~ "App"
  end

  test "renders appbar title in appbar-title div" do
    result = render_component(&dm_appbar/1, %{title: "My Dashboard"})

    assert result =~ "appbar-title"
    assert result =~ "My Dashboard"
  end

  test "renders appbar with menu item links" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [
          %{to: "/home", inner_block: fn _, _ -> "Home" end}
        ]
      })

    assert result =~ "Home"
    assert result =~ ~s[href="/home"]
  end

  test "renders appbar menu item with custom class combined with appbar-action" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [
          %{to: "/test", class: "font-bold", inner_block: fn _, _ -> "Test" end}
        ]
      })

    assert result =~ "appbar-action"
    assert result =~ "font-bold"
  end

  test "renders appbar with empty menu list" do
    result = render_component(&dm_appbar/1, %{title: "App", menu: []})

    assert result =~ "appbar-trailing"
    refute result =~ "appbar-action"
  end

  test "renders appbar with both logo and user_profile" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        logo: [%{inner_block: fn _, _ -> "Logo" end}],
        user_profile: [%{inner_block: fn _, _ -> "Profile" end}]
      })

    assert result =~ "Logo"
    assert result =~ "Profile"
    assert result =~ "appbar-brand"
    assert result =~ "appbar-trailing"
  end

  test "renders simple appbar with logo slot" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        logo: [%{inner_block: fn _, _ -> "MyLogo" end}]
      })

    assert result =~ "MyLogo"
    assert result =~ "appbar-brand"
  end

  test "renders simple appbar with user_profile slot" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        user_profile: [%{inner_block: fn _, _ -> "UserArea" end}]
      })

    assert result =~ "UserArea"
  end

  test "renders simple appbar with divider between menu and user_profile in mobile" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        menu: [%{to: "/a", inner_block: fn _, _ -> "A" end}],
        user_profile: [%{inner_block: fn _, _ -> "U" end}]
      })

    assert result =~ "divider"
  end

  test "renders appbar with all options combined" do
    result =
      render_component(&dm_appbar/1, %{
        id: "main-appbar",
        title: "Dashboard",
        class: "appbar-primary appbar-elevated",
        sticky: true,
        logo: [%{inner_block: fn _, _ -> "Logo" end}],
        menu: [
          %{to: "/home", class: "font-bold", inner_block: fn _, _ -> "Home" end},
          %{to: "/about", inner_block: fn _, _ -> "About" end}
        ],
        user_profile: [%{inner_block: fn _, _ -> "Avatar" end}],
        "data-testid": "main-bar"
      })

    assert result =~ ~s[id="main-appbar"]
    assert result =~ "Dashboard"
    assert result =~ "appbar-primary"
    assert result =~ "appbar-elevated"
    assert result =~ "appbar-sticky"
    assert result =~ "Logo"
    assert result =~ "Home"
    assert result =~ "About"
    assert result =~ ~s[href="/home"]
    assert result =~ ~s[href="/about"]
    assert result =~ "font-bold"
    assert result =~ "Avatar"
    assert result =~ "data-testid=\"main-bar\""
  end

  test "renders appbar menu item without to uses empty string" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [%{inner_block: fn _, _ -> "NoLink" end}]
      })

    assert result =~ "NoLink"
    assert result =~ "appbar-action"
  end

  test "renders appbar menu item without class uses empty fallback" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [%{to: "/x", inner_block: fn _, _ -> "X" end}]
      })

    assert result =~ "X"
    assert result =~ "appbar-action"
  end

  test "renders appbar with multiple menu items" do
    result =
      render_component(&dm_appbar/1, %{
        title: "App",
        menu: [
          %{to: "/a", inner_block: fn _, _ -> "A" end},
          %{to: "/b", inner_block: fn _, _ -> "B" end},
          %{to: "/c", inner_block: fn _, _ -> "C" end}
        ]
      })

    assert result =~ ~s[href="/a"]
    assert result =~ ~s[href="/b"]
    assert result =~ ~s[href="/c"]
  end

  test "renders simple appbar with all options combined" do
    result =
      render_component(&dm_simple_appbar/1, %{
        id: "simple-full",
        title: "FullApp",
        class: "bg-base-200",
        logo: [%{inner_block: fn _, _ -> "SimpleLogo" end}],
        menu: [
          %{to: "/dash", class: "text-primary", inner_block: fn _, _ -> "Dash" end},
          %{to: "/settings", inner_block: fn _, _ -> "Settings" end}
        ],
        user_profile: [%{inner_block: fn _, _ -> "Profile" end}],
        "data-testid": "simple-bar"
      })

    assert result =~ ~s[id="simple-full"]
    assert result =~ "FullApp"
    assert result =~ "bg-base-200"
    assert result =~ "SimpleLogo"
    assert result =~ "Dash"
    assert result =~ "Settings"
    assert result =~ ~s[href="/dash"]
    assert result =~ ~s[href="/settings"]
    assert result =~ "text-primary"
    assert result =~ "Profile"
    assert result =~ "data-testid=\"simple-bar\""
  end

  test "renders simple appbar menu items in both desktop and mobile" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        menu: [%{to: "/test", inner_block: fn _, _ -> "Test" end}]
      })

    # Menu item appears in desktop nav and mobile dropdown
    parts = String.split(result, "Test")
    assert length(parts) >= 3
  end

  test "renders simple appbar mobile menu with onclick toggle" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    assert result =~ "appbar-mobile-menu"
    assert result =~ "classList.toggle"
  end

  test "renders simple appbar title hidden on small screens" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    assert result =~ "hidden lg:inline-flex"
  end

  test "renders simple appbar desktop nav hidden on mobile" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    assert result =~ "hidden md:flex"
  end

  test "renders simple appbar mobile menu button with aria-expanded=false" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    assert result =~ ~s[aria-expanded="false"]
    assert result =~ ~s[aria-controls="appbar-mobile-menu"]
    assert result =~ ~s[aria-haspopup="true"]
  end

  test "mobile menu div has role=navigation and aria-label" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    assert result =~ ~s[id="appbar-mobile-menu"]
    assert result =~ ~s[role="navigation"]
  end

  test "mobile menu id derives from component id" do
    result = render_component(&dm_simple_appbar/1, %{id: "site-nav", title: "App"})

    assert result =~ ~s[id="site-nav-mobile-menu"]
    assert result =~ ~s[aria-controls="site-nav-mobile-menu"]
  end

  test "renders simple appbar with custom toggle_menu_label" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        toggle_menu_label: "Basculer le menu"
      })

    assert result =~ ~s[aria-label="Basculer le menu"]
  end

  test "mobile menu toggle button has type=button" do
    result = render_component(&dm_simple_appbar/1, %{title: "App"})

    # The mobile menu toggle should have type="button"
    assert result =~ ~s[type="button"]
  end

  test "simple appbar active menu item gets aria-current page" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        menu: [%{to: "/home", active: true, __slot__: :menu, inner_block: fn _, _ -> "Home" end}]
      })

    assert result =~ ~s(aria-current="page")
  end

  test "simple appbar inactive menu item has no aria-current" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        menu: [%{to: "/about", __slot__: :menu, inner_block: fn _, _ -> "About" end}]
      })

    refute result =~ "aria-current"
  end

  describe "nav_label i18n" do
    test "default nav label is Main navigation" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})
      assert result =~ ~s(aria-label="Main navigation")
    end

    test "custom nav_label" do
      result =
        render_component(&dm_simple_appbar/1, %{title: "App", nav_label: "Navigation principale"})

      assert result =~ ~s(aria-label="Navigation principale")
      refute result =~ ~s(aria-label="Main navigation")
    end
  end

  describe "dm_appbar nav landmark" do
    test "wraps menu links in nav element with default aria-label" do
      result =
        render_component(&dm_appbar/1, %{
          title: "App",
          menu: [%{to: "/home", inner_block: fn _, _ -> "Home" end}]
        })

      assert result =~ "<nav"
      assert result =~ ~s(aria-label="Main navigation")
    end

    test "custom nav_label on dm_appbar" do
      result =
        render_component(&dm_appbar/1, %{
          title: "App",
          nav_label: "Navigation du site",
          menu: [%{to: "/home", inner_block: fn _, _ -> "Home" end}]
        })

      assert result =~ ~s(aria-label="Navigation du site")
    end

    test "no nav element when menu is empty" do
      result = render_component(&dm_appbar/1, %{title: "App", menu: []})

      refute result =~ "<nav"
    end
  end

  describe "dm_appbar title_to" do
    test "renders title as link when title_to is set" do
      result =
        render_component(&dm_appbar/1, %{
          title: "MyApp",
          title_to: "/dashboard"
        })

      assert result =~ ~s(href="/dashboard")
      assert result =~ "MyApp"
    end

    test "renders title as plain div when title_to is nil" do
      result =
        render_component(&dm_appbar/1, %{
          title: "MyApp"
        })

      refute result =~ ~s(href=)
      assert result =~ "MyApp"
    end
  end
end
