defmodule PhoenixDuskmoon.Component.Navigation.PageHeaderTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.PageHeader

  test "renders basic page header with inner_block" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: %{inner_block: fn _, _ -> "Page Title" end}
      })

    assert result =~ "<header"
    assert result =~ "<nav"
    assert result =~ "Page Title"
  end

  test "renders page header with default ids" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[id="wc-page-header-header"]
    assert result =~ ~s[id="wc-page-header-nav"]
  end

  test "renders page header with custom id" do
    result =
      render_component(&dm_page_header/1, %{
        id: "custom-header",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[id="custom-header"]
  end

  test "renders page header with custom nav_id" do
    result =
      render_component(&dm_page_header/1, %{
        nav_id: "custom-nav",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[id="custom-nav"]
  end

  test "renders page header with custom class" do
    result =
      render_component(&dm_page_header/1, %{
        class: "bg-primary",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "bg-primary"
  end

  test "renders page header with nav_class" do
    result =
      render_component(&dm_page_header/1, %{
        nav_class: "bg-base-200",
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "bg-base-200"
  end

  test "renders page header with menu items" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/home", inner_block: fn _, _ -> "Home" end},
          %{to: "/about", inner_block: fn _, _ -> "About" end}
        ],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "Home"
    assert result =~ "About"
    assert result =~ ~s[href="/home"]
    assert result =~ ~s[href="/about"]
  end

  test "renders page header with user_profile slot" do
    result =
      render_component(&dm_page_header/1, %{
        user_profile: [%{inner_block: fn _, _ -> "Avatar" end}],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "Avatar"
  end

  test "renders page header with menu class" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/test", class: "menu-item-custom", inner_block: fn _, _ -> "Test" end}
        ],
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ "menu-item-custom"
  end

  test "renders page header with phx-hook PageHeader" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    assert result =~ ~s[phx-hook="PageHeader"]
    assert result =~ ~s[data-nav-id="wc-page-header-nav"]
  end

  test "renders mobile menu toggle" do
    result =
      render_component(&dm_page_header/1, %{
        inner_block: %{inner_block: fn _, _ -> "Content" end}
      })

    # Mobile menu uses a checkbox toggle
    assert result =~ ~s[type="checkbox"]
    assert result =~ "mobile-menu"
  end

  test "renders page header with both menu and user_profile" do
    result =
      render_component(&dm_page_header/1, %{
        menu: [
          %{to: "/dashboard", inner_block: fn _, _ -> "Dashboard" end}
        ],
        user_profile: [
          %{class: "profile-section", inner_block: fn _, _ -> "User" end}
        ],
        inner_block: %{inner_block: fn _, _ -> "Main Content" end}
      })

    assert result =~ "Dashboard"
    assert result =~ "User"
    assert result =~ "Main Content"
    assert result =~ "profile-section"
  end
end
