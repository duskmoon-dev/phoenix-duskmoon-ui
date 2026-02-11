defmodule PhoenixDuskmoon.Component.Navigation.NavbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Navbar

  test "renders basic navbar with nav element" do
    result = render_component(&dm_navbar/1, %{})

    assert result =~ "<nav"
    assert result =~ "dm-navbar"
    assert result =~ "</nav>"
  end

  test "renders navbar with three section containers" do
    result = render_component(&dm_navbar/1, %{})

    assert result =~ "dm-navbar__start"
    assert result =~ "dm-navbar__center"
    assert result =~ "dm-navbar__end"
  end

  test "renders navbar with start_part slot" do
    result =
      render_component(&dm_navbar/1, %{
        start_part: [%{inner_block: fn _, _ -> "Logo" end}]
      })

    assert result =~ "Logo"
    assert result =~ "dm-navbar__start"
  end

  test "renders navbar with center_part slot" do
    result =
      render_component(&dm_navbar/1, %{
        center_part: [%{inner_block: fn _, _ -> "Nav Links" end}]
      })

    assert result =~ "Nav Links"
    assert result =~ "dm-navbar__center"
  end

  test "renders navbar with end_part slot" do
    result =
      render_component(&dm_navbar/1, %{
        end_part: [%{inner_block: fn _, _ -> "User Menu" end}]
      })

    assert result =~ "User Menu"
    assert result =~ "dm-navbar__end"
  end

  test "renders navbar with all three parts populated" do
    result =
      render_component(&dm_navbar/1, %{
        start_part: [%{inner_block: fn _, _ -> "Brand" end}],
        center_part: [%{inner_block: fn _, _ -> "Navigation" end}],
        end_part: [%{inner_block: fn _, _ -> "Actions" end}]
      })

    assert result =~ "Brand"
    assert result =~ "Navigation"
    assert result =~ "Actions"
  end

  test "renders navbar with custom id" do
    result = render_component(&dm_navbar/1, %{id: "main-nav"})

    assert result =~ ~s[id="main-nav"]
  end

  test "renders navbar with custom class" do
    result = render_component(&dm_navbar/1, %{class: "bg-primary text-white"})

    assert result =~ "bg-primary text-white"
    assert result =~ "dm-navbar"
  end

  test "renders navbar with start_class" do
    result = render_component(&dm_navbar/1, %{start_class: "gap-4"})

    assert result =~ "gap-4"
  end

  test "renders navbar with center_class" do
    result = render_component(&dm_navbar/1, %{center_class: "flex-1"})

    assert result =~ "flex-1"
  end

  test "renders navbar with end_class" do
    result = render_component(&dm_navbar/1, %{end_class: "gap-2"})

    assert result =~ "gap-2"
  end

  test "renders navbar with all section classes" do
    result =
      render_component(&dm_navbar/1, %{
        start_class: "start-custom",
        center_class: "center-custom",
        end_class: "end-custom"
      })

    assert result =~ "start-custom"
    assert result =~ "center-custom"
    assert result =~ "end-custom"
  end

  test "renders navbar with empty slots by default" do
    result = render_component(&dm_navbar/1, %{})

    # All three section divs rendered even without content
    assert result =~ "dm-navbar__start"
    assert result =~ "dm-navbar__center"
    assert result =~ "dm-navbar__end"
  end

  test "renders navbar with rest attributes" do
    result =
      render_component(&dm_navbar/1, %{
        "data-testid": "nav-bar",
        "aria-label": "Main navigation"
      })

    assert result =~ "data-testid=\"nav-bar\""
    assert result =~ "aria-label=\"Main navigation\""
  end

  test "renders navbar with multiple elements in start_part" do
    result =
      render_component(&dm_navbar/1, %{
        start_part: [
          %{inner_block: fn _, _ -> "Logo" end},
          %{inner_block: fn _, _ -> "Brand Name" end}
        ]
      })

    assert result =~ "Logo"
    assert result =~ "Brand Name"
  end

  test "renders navbar with combined class and section classes" do
    result =
      render_component(&dm_navbar/1, %{
        class: "bg-base-200",
        start_class: "gap-4",
        center_class: "flex-1",
        end_class: "gap-2"
      })

    assert result =~ "bg-base-200"
    assert result =~ "dm-navbar"
    assert result =~ "gap-4"
    assert result =~ "flex-1"
    assert result =~ "gap-2"
  end

  test "renders navbar with text content in slots" do
    result =
      render_component(&dm_navbar/1, %{
        start_part: [%{inner_block: fn _, _ -> "Logo Text" end}],
        end_part: [%{inner_block: fn _, _ -> "Login Link" end}]
      })

    assert result =~ "Logo Text"
    assert result =~ "Login Link"
  end

  test "renders navbar with all attributes combined" do
    result =
      render_component(&dm_navbar/1, %{
        id: "full-nav",
        class: "bg-primary",
        start_class: "gap-4",
        center_class: "mx-auto",
        end_class: "gap-2",
        start_part: [%{inner_block: fn _, _ -> "Brand" end}],
        center_part: [%{inner_block: fn _, _ -> "Links" end}],
        end_part: [%{inner_block: fn _, _ -> "Profile" end}],
        "aria-label": "Main"
      })

    assert result =~ ~s[id="full-nav"]
    assert result =~ "bg-primary"
    assert result =~ "Brand"
    assert result =~ "Links"
    assert result =~ "Profile"
    assert result =~ "aria-label=\"Main\""
  end

  test "renders navbar with default aria-label" do
    result = render_component(&dm_navbar/1, %{})

    assert result =~ ~s[aria-label="Main navigation"]
  end

  test "renders navbar without id when not provided" do
    result = render_component(&dm_navbar/1, %{})

    refute result =~ ~s[id="]
  end

  test "renders navbar with multiple elements in center_part" do
    result =
      render_component(&dm_navbar/1, %{
        center_part: [
          %{inner_block: fn _, _ -> "Link 1" end},
          %{inner_block: fn _, _ -> "Link 2" end}
        ]
      })

    assert result =~ "Link 1"
    assert result =~ "Link 2"
  end

  test "renders navbar with multiple elements in end_part" do
    result =
      render_component(&dm_navbar/1, %{
        end_part: [
          %{inner_block: fn _, _ -> "Notifications" end},
          %{inner_block: fn _, _ -> "Profile" end}
        ]
      })

    assert result =~ "Notifications"
    assert result =~ "Profile"
  end

  test "renders navbar as nav HTML element" do
    result = render_component(&dm_navbar/1, %{})

    assert result =~ "<nav"
    assert result =~ "</nav>"
  end

  test "renders navbar with custom aria-label overriding default" do
    result =
      render_component(&dm_navbar/1, %{
        "aria-label": "Site navigation"
      })

    assert result =~ ~s[aria-label="Site navigation"]
  end
end
