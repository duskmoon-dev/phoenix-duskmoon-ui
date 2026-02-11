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

    test "renders simple appbar with mobile menu toggle" do
      result = render_component(&dm_simple_appbar/1, %{title: "App"})

      assert result =~ "header-md-menu"
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

    assert result =~ "dm-divider"
  end
end
