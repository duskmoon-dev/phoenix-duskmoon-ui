defmodule PhoenixDuskmoon.Component.Navigation.NavbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Navbar

  test "renders basic navbar" do
    result = render_component(&dm_navbar/1, %{})

    assert result =~ "dm-navbar"
  end

  test "renders navbar with start part" do
    result =
      render_component(&dm_navbar/1, %{
        start_part: [%{inner_block: fn _, _ -> "Logo" end}]
      })

    assert result =~ "Logo"
    assert result =~ "dm-navbar"
  end

  test "renders navbar with center part" do
    result =
      render_component(&dm_navbar/1, %{
        center_part: [%{inner_block: fn _, _ -> "Nav links" end}]
      })

    assert result =~ "Nav links"
  end

  test "renders navbar with end part" do
    result =
      render_component(&dm_navbar/1, %{
        end_part: [%{inner_block: fn _, _ -> "User menu" end}]
      })

    assert result =~ "User menu"
  end

  test "renders navbar with custom class" do
    result = render_component(&dm_navbar/1, %{class: "my-nav"})

    assert result =~ "my-nav"
  end
end
