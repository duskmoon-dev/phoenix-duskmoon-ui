defmodule PhoenixDuskmoon.Component.Navigation.AppbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Appbar

  test "renders basic appbar" do
    result = render_component(&dm_appbar/1, %{title: "MyApp"})

    assert result =~ "<app-bar"
    assert result =~ "MyApp"
  end

  test "renders appbar with custom class" do
    result = render_component(&dm_appbar/1, %{title: "App", class: "my-appbar"})

    assert result =~ "my-appbar"
  end

  test "renders appbar with id" do
    result = render_component(&dm_appbar/1, %{title: "App", id: "main-bar"})

    assert result =~ ~s[id="main-bar"]
  end

  test "renders simple appbar" do
    result = render_component(&dm_simple_appbar/1, %{title: "SimpleApp"})

    assert result =~ "<header"
    assert result =~ "SimpleApp"
  end

  test "renders simple appbar with menu items" do
    result =
      render_component(&dm_simple_appbar/1, %{
        title: "App",
        menu: [%{to: "/dashboard", inner_block: fn _, _ -> "Dashboard" end}]
      })

    assert result =~ "Dashboard"
  end
end
