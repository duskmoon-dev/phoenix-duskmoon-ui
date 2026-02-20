defmodule PhoenixDuskmoon.Component.Navigation.BottomNavTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Navigation.BottomNav

  @basic_items [
    %{value: "home", label: "Home", icon: "home"},
    %{value: "search", label: "Search", icon: "magnify"},
    %{value: "profile", label: "Profile", icon: "account"}
  ]

  describe "dm_bottom_nav basic rendering" do
    test "renders el-dm-bottom-navigation element" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      assert result =~ "<el-dm-bottom-navigation"
      assert result =~ "</el-dm-bottom-navigation>"
    end

    test "renders with custom id" do
      result = render_component(&dm_bottom_nav/1, %{id: "main-nav", items: @basic_items})
      assert result =~ ~s(id="main-nav")
    end

    test "renders with custom class" do
      result = render_component(&dm_bottom_nav/1, %{class: "my-nav", items: @basic_items})
      assert result =~ "my-nav"
    end

    test "encodes items as JSON" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      # JSON should contain the item values and labels
      assert result =~ "home"
      assert result =~ "Home"
      assert result =~ "search"
      assert result =~ "Search"
    end

    test "converts icon names to SVG strings" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      # SVG path data for "home" icon (HTML-escaped inside JSON attr)
      assert result =~ "M10,20V14H14V20H19V12H22L12,3L2,12H5V20H10Z"
    end
  end

  describe "dm_bottom_nav value" do
    test "renders with selected value" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, value: "home"})

      assert result =~ ~s(value="home")
    end

    test "renders without value by default" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      # No explicit value attr when nil
      refute result =~ ~s(value="home")
    end
  end

  describe "dm_bottom_nav color" do
    test "defaults to primary" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      assert result =~ ~s(color="primary")
    end

    test "renders secondary color" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, color: "secondary"})

      assert result =~ ~s(color="secondary")
    end

    test "renders success color" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, color: "success"})

      assert result =~ ~s(color="success")
    end

    test "renders warning color" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, color: "warning"})

      assert result =~ ~s(color="warning")
    end

    test "renders error color" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, color: "error"})

      assert result =~ ~s(color="error")
    end
  end

  describe "dm_bottom_nav position" do
    test "defaults to fixed" do
      result = render_component(&dm_bottom_nav/1, %{items: @basic_items})
      assert result =~ ~s(position="fixed")
    end

    test "renders static position" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, position: "static"})

      assert result =~ ~s(position="static")
    end

    test "renders sticky position" do
      result =
        render_component(&dm_bottom_nav/1, %{items: @basic_items, position: "sticky"})

      assert result =~ ~s(position="sticky")
    end
  end

  describe "dm_bottom_nav items with disabled and href" do
    test "renders items with disabled flag" do
      items = [
        %{value: "home", label: "Home"},
        %{value: "settings", label: "Settings", disabled: true}
      ]

      result = render_component(&dm_bottom_nav/1, %{items: items})
      assert result =~ "disabled"
    end

    test "renders items with href" do
      items = [
        %{value: "home", label: "Home", href: "/"},
        %{value: "about", label: "About", href: "/about"}
      ]

      result = render_component(&dm_bottom_nav/1, %{items: items})
      assert result =~ "/about"
    end

    test "handles items without icons" do
      items = [%{value: "home", label: "Home"}, %{value: "search", label: "Search"}]
      result = render_component(&dm_bottom_nav/1, %{items: items})
      assert result =~ "home"
      assert result =~ "Home"
    end
  end

  describe "dm_bottom_nav combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_bottom_nav/1, %{
          id: "app-nav",
          class: "z-50",
          value: "search",
          color: "success",
          position: "sticky",
          items: @basic_items
        })

      assert result =~ ~s(id="app-nav")
      assert result =~ "z-50"
      assert result =~ ~s(value="search")
      assert result =~ ~s(color="success")
      assert result =~ ~s(position="sticky")
    end
  end
end
