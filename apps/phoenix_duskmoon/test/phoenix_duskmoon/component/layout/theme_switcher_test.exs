defmodule PhoenixDuskmoon.Component.Layout.ThemeSwitcherTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.ThemeSwitcher

  test "renders theme switcher" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "dropdown"
  end

  test "renders theme switcher with current theme" do
    result = render_component(&dm_theme_switcher/1, %{theme: "dark"})

    assert result =~ "dropdown"
  end

  test "renders theme switcher with custom class" do
    result = render_component(&dm_theme_switcher/1, %{class: "my-switcher"})

    assert result =~ "my-switcher"
  end
end
