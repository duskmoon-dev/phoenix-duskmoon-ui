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
end
