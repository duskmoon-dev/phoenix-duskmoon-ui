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
end
