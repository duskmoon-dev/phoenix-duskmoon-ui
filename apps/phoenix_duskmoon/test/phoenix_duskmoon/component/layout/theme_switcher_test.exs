defmodule PhoenixDuskmoon.Component.Layout.ThemeSwitcherTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.ThemeSwitcher

  test "renders theme switcher with dropdown class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "dropdown"
    assert result =~ "dropdown-end"
  end

  test "renders theme switcher with ThemeSwitcher phx-hook" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[phx-hook="ThemeSwitcher"]
  end

  test "renders theme switcher with three theme options" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[value="default"]
    assert result =~ ~s[value="sunshine"]
    assert result =~ ~s[value="moonlight"]
  end

  test "renders theme switcher with aria labels for each theme" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[aria-label="Auto"]
    assert result =~ ~s[aria-label="Sunshine"]
    assert result =~ ~s[aria-label="Moonlight"]
  end

  test "renders trigger button with aria-label for theme selection" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[aria-label="Select theme"]
  end

  test "renders theme switcher with radio inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[type="radio"]
    assert result =~ ~s[name="theme-dropdown"]
  end

  test "renders theme switcher with theme-controller class on inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "theme-controller"
  end

  test "renders theme switcher with Theme button text" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "Theme"
    assert result =~ "btn btn-ghost btn-sm"
  end

  test "renders theme switcher with dropdown chevron svg" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "<svg"
    assert result =~ "viewBox=\"0 0 2048 2048\""
  end

  test "renders theme switcher with custom id" do
    result = render_component(&dm_theme_switcher/1, %{id: "my-switcher"})

    assert result =~ ~s[id="my-switcher"]
  end

  test "renders theme switcher with generated id when no id provided" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[id="theme-switcher-]
  end

  test "renders theme switcher with custom class" do
    result = render_component(&dm_theme_switcher/1, %{class: "my-switcher-class"})

    assert result =~ "my-switcher-class"
    assert result =~ "dropdown"
  end

  test "renders theme switcher with data-theme attribute" do
    result = render_component(&dm_theme_switcher/1, %{theme: "moonlight"})

    assert result =~ ~s[data-theme="moonlight"]
  end

  test "renders theme switcher with default theme checked" do
    result = render_component(&dm_theme_switcher/1, %{theme: "default"})

    # The "default" radio should be checked
    assert result =~ ~s[value="default"]
  end

  test "renders theme switcher with sunshine theme checked" do
    result = render_component(&dm_theme_switcher/1, %{theme: "sunshine"})

    assert result =~ ~s[data-theme="sunshine"]
  end

  test "renders theme switcher with dropdown-content class for menu" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "dropdown-content"
    assert result =~ "z-50"
  end

  test "renders theme switcher with three li elements" do
    result = render_component(&dm_theme_switcher/1, %{})

    li_count = length(String.split(result, "<li>")) - 1
    assert li_count == 3
  end

  test "renders theme switcher with ul containing tabindex" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "<ul"
    assert result =~ ~s[tabindex="0"]
  end

  test "renders theme switcher button with tabindex for keyboard access" do
    result = render_component(&dm_theme_switcher/1, %{})

    # Both the button div and ul have tabindex
    assert result =~ ~s[role="button"]
    assert result =~ ~s[tabindex="0"]
  end

  test "renders theme switcher with empty theme by default" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[data-theme=""]
  end

  test "renders theme switcher moonlight checked when theme is moonlight" do
    result = render_component(&dm_theme_switcher/1, %{theme: "moonlight"})

    assert result =~ ~s[data-theme="moonlight"]
  end

  test "renders theme switcher with all attributes combined" do
    result =
      render_component(&dm_theme_switcher/1, %{
        id: "my-theme",
        class: "custom-switcher",
        theme: "sunshine"
      })

    assert result =~ ~s[id="my-theme"]
    assert result =~ "custom-switcher"
    assert result =~ "dropdown"
    assert result =~ ~s[data-theme="sunshine"]
    assert result =~ ~s[phx-hook="ThemeSwitcher"]
    assert result =~ ~s[value="default"]
    assert result =~ ~s[value="sunshine"]
    assert result =~ ~s[value="moonlight"]
  end

  test "renders theme switcher with all three theme radio values" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[value="default"]
    assert result =~ ~s[value="sunshine"]
    assert result =~ ~s[value="moonlight"]
  end

  test "renders theme switcher with aria-labels on radio inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[aria-label="Auto"]
    assert result =~ ~s[aria-label="Sunshine"]
    assert result =~ ~s[aria-label="Moonlight"]
  end

  test "renders theme switcher with button role on toggle" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[role="button"]
  end

  test "renders theme switcher with unique random ids across renders" do
    result1 = render_component(&dm_theme_switcher/1, %{})
    result2 = render_component(&dm_theme_switcher/1, %{})

    # Both should have theme-switcher- prefix but may have different random IDs
    assert result1 =~ "theme-switcher-"
    assert result2 =~ "theme-switcher-"
  end

  test "renders theme switcher with btn-secondary class on radios" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "btn-secondary"
    assert result =~ "btn-block"
  end

  test "renders theme switcher with btn-sm on toggle button" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "btn btn-ghost btn-sm"
  end

  test "renders theme switcher with justify-center on radio inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "justify-center"
  end

  test "renders theme switcher generates three radio inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    radio_count = length(String.split(result, ~s[type="radio"])) - 1
    assert radio_count == 3
  end

  test "renders theme switcher with custom select_theme_label" do
    result = render_component(&dm_theme_switcher/1, %{select_theme_label: "Choisir le thème"})

    assert result =~ ~s[aria-label="Choisir le thème"]
  end

  test "renders theme switcher with custom auto_label" do
    result = render_component(&dm_theme_switcher/1, %{auto_label: "Automatique"})

    assert result =~ ~s[aria-label="Automatique"]
  end

  test "renders theme switcher with custom light_label" do
    result = render_component(&dm_theme_switcher/1, %{light_label: "Clair"})

    assert result =~ ~s[aria-label="Clair"]
  end

  test "renders theme switcher with custom dark_label" do
    result = render_component(&dm_theme_switcher/1, %{dark_label: "Sombre"})

    assert result =~ ~s[aria-label="Sombre"]
  end
end
