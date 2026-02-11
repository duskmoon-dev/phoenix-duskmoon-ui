defmodule PhoenixDuskmoon.Component.Navigation.PageHeaderTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.PageHeader

  defp inner_block(text \\ "Content") do
    %{inner_block: fn _, _ -> text end}
  end

  test "renders page header with header and nav elements" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block("Page Title")})

    assert result =~ "<header"
    assert result =~ "<nav"
    assert result =~ "Page Title"
  end

  test "renders page header with default ids" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ ~s[id="wc-page-header-header"]
    assert result =~ ~s[id="wc-page-header-nav"]
  end

  test "renders page header with custom id" do
    result =
      render_component(&dm_page_header/1, %{
        id: "custom-header",
        inner_block: inner_block()
      })

    assert result =~ ~s[id="custom-header"]
  end

  test "renders page header with custom nav_id" do
    result =
      render_component(&dm_page_header/1, %{
        nav_id: "custom-nav",
        inner_block: inner_block()
      })

    assert result =~ ~s[id="custom-nav"]
  end

  test "renders page header with phx-hook PageHeader" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ ~s[phx-hook="PageHeader"]
    assert result =~ ~s[data-nav-id="wc-page-header-nav"]
  end

  test "renders page header with custom class" do
    result =
      render_component(&dm_page_header/1, %{
        class: "bg-primary",
        inner_block: inner_block()
      })

    assert result =~ "bg-primary"
  end

  test "renders page header with nav_class" do
    result =
      render_component(&dm_page_header/1, %{
        nav_class: "bg-base-200",
        inner_block: inner_block()
      })

    assert result =~ "bg-base-200"
  end

  test "renders page header with menu items as links" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/home", inner_block: fn _, _ -> "Home" end},
          %{to: "/about", inner_block: fn _, _ -> "About" end}
        ],
        inner_block: inner_block()
      })

    assert result =~ "Home"
    assert result =~ "About"
    assert result =~ ~s[href="/home"]
    assert result =~ ~s[href="/about"]
  end

  test "renders page header with menu item class" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/test", class: "menu-item-custom", inner_block: fn _, _ -> "Test" end}
        ],
        inner_block: inner_block()
      })

    assert result =~ "menu-item-custom"
  end

  test "renders page header with user_profile slot" do
    result =
      render_component(&dm_page_header/1, %{
        user_profile: [%{inner_block: fn _, _ -> "Avatar" end}],
        inner_block: inner_block()
      })

    assert result =~ "Avatar"
  end

  test "renders page header with user_profile class" do
    result =
      render_component(&dm_page_header/1, %{
        user_profile: [
          %{class: "profile-section", inner_block: fn _, _ -> "User" end}
        ],
        inner_block: inner_block()
      })

    assert result =~ "profile-section"
  end

  test "renders mobile menu toggle" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "mobile-menu"
  end

  test "renders mobile menu label with aria-label" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ ~s[aria-label="Toggle mobile menu"]
  end

  test "renders inner_block content in center area" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: inner_block("Hero Content")
      })

    assert result =~ "Hero Content"
    assert result =~ "flex-1 flex flex-col justify-center"
  end

  test "renders page header with both menu and user_profile" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/dashboard", inner_block: fn _, _ -> "Dashboard" end}
        ],
        user_profile: [
          %{class: "profile-area", inner_block: fn _, _ -> "User" end}
        ],
        inner_block: inner_block("Main")
      })

    assert result =~ "Dashboard"
    assert result =~ "User"
    assert result =~ "Main"
    assert result =~ "profile-area"
  end

  test "renders page header with data-nav-id matching nav_id" do
    result =
      render_component(&dm_page_header/1, %{
        nav_id: "my-nav",
        inner_block: inner_block()
      })

    assert result =~ ~s[data-nav-id="my-nav"]
  end

  test "renders page header with empty menu and user_profile" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [],
        user_profile: [],
        inner_block: inner_block()
      })

    assert result =~ "<header"
    assert result =~ "<nav"
    assert result =~ "flex-1 flex flex-col"
  end

  test "renders menu items with base styling classes" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{to: "/test", inner_block: fn _, _ -> "Test" end}],
        inner_block: inner_block()
      })

    assert result =~ "py-2 px-6"
    assert result =~ "hover:opacity-50"
  end

  test "renders mobile menu items with full width" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{to: "/mobile", inner_block: fn _, _ -> "Mobile" end}],
        inner_block: inner_block()
      })

    assert result =~ "px-12 w-full"
  end

  test "renders hr element between menu and user_profile in mobile" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{to: "/", inner_block: fn _, _ -> "Menu" end}],
        user_profile: [%{inner_block: fn _, _ -> "Profile" end}],
        inner_block: inner_block()
      })

    assert result =~ "<hr"
  end

  test "renders inner_block with centering wrapper" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: inner_block("Centered")
      })

    assert result =~ "flex-1"
    assert result =~ "justify-center items-center"
    assert result =~ "Centered"
  end

  test "renders both mobile menu checkboxes" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ ~s[id="mobile-menu"]
    assert result =~ ~s[id="dm-mobile-menu-control"]
  end

  test "renders fixed hidden navigation" do
    result = render_component(&dm_page_header/1, %{inner_block: inner_block()})

    assert result =~ "fixed hidden"
    assert result =~ "w-full h-12"
  end

  test "renders multiple menu items in desktop and mobile" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/a", inner_block: fn _, _ -> "A" end},
          %{to: "/b", inner_block: fn _, _ -> "B" end},
          %{to: "/c", inner_block: fn _, _ -> "C" end}
        ],
        inner_block: inner_block()
      })

    assert result =~ ~s[href="/a"]
    assert result =~ ~s[href="/b"]
    assert result =~ ~s[href="/c"]
    assert result =~ "A"
    assert result =~ "B"
    assert result =~ "C"
  end

  test "both mobile menu labels have aria-label" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{to: "/a", inner_block: fn _, _ -> "A" end}],
        inner_block: inner_block()
      })

    # Count occurrences of aria-label="Toggle mobile menu"
    toggle_count =
      length(String.split(result, ~s[aria-label="Toggle mobile menu"])) - 1

    assert toggle_count == 2
  end

  test "renders menu item without to attribute uses false href" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{inner_block: fn _, _ -> "No Link" end}],
        inner_block: inner_block()
      })

    assert result =~ "No Link"
    assert result =~ "<a"
  end

  test "renders menu item without class uses empty string fallback" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [%{to: "/test", inner_block: fn _, _ -> "Test" end}],
        inner_block: inner_block()
      })

    assert result =~ "Test"
    assert result =~ ~s[href="/test"]
  end

  test "renders user_profile without class uses empty string fallback" do
    result =
      render_component(&dm_page_header/1, %{
        user_profile: [%{inner_block: fn _, _ -> "Profile" end}],
        inner_block: inner_block()
      })

    assert result =~ "Profile"
  end

  test "renders data-nav-id matching custom nav_id" do
    result =
      render_component(&dm_page_header/1, %{
        nav_id: "special-nav",
        inner_block: inner_block()
      })

    assert result =~ ~s[id="special-nav"]
    assert result =~ ~s[data-nav-id="special-nav"]
  end

  test "renders header with all options combined" do
    result =
      render_component(&dm_page_header/1, %{
        id: "my-header",
        nav_id: "my-nav",
        class: "bg-gradient",
        nav_class: "bg-base-100",
        menu: [
          %{to: "/a", class: "menu-a", inner_block: fn _, _ -> "A" end},
          %{to: "/b", class: "menu-b", inner_block: fn _, _ -> "B" end}
        ],
        user_profile: [%{class: "profile-cls", inner_block: fn _, _ -> "User" end}],
        inner_block: inner_block("Hero")
      })

    assert result =~ ~s[id="my-header"]
    assert result =~ ~s[id="my-nav"]
    assert result =~ "bg-gradient"
    assert result =~ "bg-base-100"
    assert result =~ "menu-a"
    assert result =~ "menu-b"
    assert result =~ ~s[href="/a"]
    assert result =~ ~s[href="/b"]
    assert result =~ "profile-cls"
    assert result =~ "User"
    assert result =~ "Hero"
  end

  test "renders nav_class in both fixed nav and mobile dropdown" do
    result =
      render_component(&dm_page_header/1, %{
        nav_class: "bg-base-300",
        menu: [%{to: "/x", inner_block: fn _, _ -> "X" end}],
        inner_block: inner_block()
      })

    # nav_class appears in fixed nav and mobile dropdown
    parts = String.split(result, "bg-base-300")
    assert length(parts) >= 3
  end

  test "nav elements have aria-label for screen readers" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: inner_block()
      })

    assert result =~ ~s[aria-label="Site navigation"]
  end

  test "renders page header with custom nav_label" do
    result =
      render_component(&dm_page_header/1, %{
        nav_label: "Navigation du site",
        inner_block: inner_block()
      })

    assert result =~ ~s[aria-label="Navigation du site"]
  end

  test "renders page header with custom toggle_menu_label" do
    result =
      render_component(&dm_page_header/1, %{
        toggle_menu_label: "Menu mobile",
        inner_block: inner_block()
      })

    toggle_count =
      length(String.split(result, ~s[aria-label="Menu mobile"])) - 1

    assert toggle_count == 2
  end
end
