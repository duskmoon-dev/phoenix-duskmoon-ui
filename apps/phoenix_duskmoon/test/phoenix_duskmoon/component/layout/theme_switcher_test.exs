defmodule PhoenixDuskmoon.Component.Layout.ThemeSwitcherTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.ThemeSwitcher

  test "renders as details element with theme-controller-dropdown class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "<details"
    assert result =~ "theme-controller-dropdown"
    assert result =~ "theme-controller-dropdown-end"
  end

  test "renders trigger as summary with theme-controller-trigger class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "<summary"
    assert result =~ "theme-controller-trigger"
  end

  test "renders with ThemeSwitcher phx-hook" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[phx-hook="ThemeSwitcher"]
  end

  test "renders three theme radio options" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[value="default"]
    assert result =~ ~s[value="sunshine"]
    assert result =~ ~s[value="moonlight"]
  end

  test "renders radio inputs with theme-controller-item class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[type="radio"]
    assert result =~ "theme-controller-item"
  end

  test "renders labels with theme-controller-label class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "theme-controller-label"
  end

  test "renders theme menu with theme-controller-menu class" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "theme-controller-menu"
  end

  test "renders trigger with button text" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "Theme"
  end

  test "renders label text for each theme option" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ "Auto"
    assert result =~ "Sunshine"
    assert result =~ "Moonlight"
  end

  test "renders with custom id" do
    result = render_component(&dm_theme_switcher/1, %{id: "my-switcher"})

    assert result =~ ~s[id="my-switcher"]
  end

  test "renders with generated id when no id provided" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[id="theme-switcher-]
  end

  test "renders with custom class" do
    result = render_component(&dm_theme_switcher/1, %{class: "my-switcher-class"})

    assert result =~ "my-switcher-class"
    assert result =~ "theme-controller-dropdown"
  end

  test "renders with data-theme attribute" do
    result = render_component(&dm_theme_switcher/1, %{theme: "moonlight"})

    assert result =~ ~s[data-theme="moonlight"]
  end

  test "renders with empty theme by default" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[data-theme=""]
  end

  test "renders radio inputs with unique name scoped to component id" do
    result = render_component(&dm_theme_switcher/1, %{id: "my-theme"})

    assert result =~ ~s[name="theme-my-theme"]
  end

  test "renders radio inputs with for/id pairs for label association" do
    result = render_component(&dm_theme_switcher/1, %{id: "my-theme"})

    assert result =~ ~s[id="my-theme-default"]
    assert result =~ ~s[for="my-theme-default"]
    assert result =~ ~s[id="my-theme-sunshine"]
    assert result =~ ~s[for="my-theme-sunshine"]
    assert result =~ ~s[id="my-theme-moonlight"]
    assert result =~ ~s[for="my-theme-moonlight"]
  end

  test "renders three radio inputs" do
    result = render_component(&dm_theme_switcher/1, %{})

    radio_count = length(String.split(result, ~s[type="radio"])) - 1
    assert radio_count == 3
  end

  test "renders three labels" do
    result = render_component(&dm_theme_switcher/1, %{})

    label_count = length(String.split(result, "theme-controller-label")) - 1
    assert label_count == 3
  end

  test "renders trigger with aria-label" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[aria-label="Select theme"]
  end

  test "renders trigger with aria-haspopup" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[aria-haspopup="true"]
  end

  test "renders menu with radiogroup role" do
    result = render_component(&dm_theme_switcher/1, %{})

    assert result =~ ~s[role="radiogroup"]
  end

  test "renders with custom select_theme_label" do
    result = render_component(&dm_theme_switcher/1, %{select_theme_label: "Choisir le thème"})

    assert result =~ ~s[aria-label="Choisir le thème"]
  end

  test "renders with custom button_text" do
    result = render_component(&dm_theme_switcher/1, %{button_text: "Thème"})

    assert result =~ "Thème"
  end

  test "renders with custom auto_label" do
    result = render_component(&dm_theme_switcher/1, %{auto_label: "Automatique"})

    assert result =~ "Automatique"
  end

  test "renders with custom light_label" do
    result = render_component(&dm_theme_switcher/1, %{light_label: "Clair"})

    assert result =~ "Clair"
  end

  test "renders with custom dark_label" do
    result = render_component(&dm_theme_switcher/1, %{dark_label: "Sombre"})

    assert result =~ "Sombre"
  end

  test "renders unique random ids across renders" do
    result1 = render_component(&dm_theme_switcher/1, %{})
    result2 = render_component(&dm_theme_switcher/1, %{})

    assert result1 =~ "theme-switcher-"
    assert result2 =~ "theme-switcher-"
  end

  test "renders with all attributes combined" do
    result =
      render_component(&dm_theme_switcher/1, %{
        id: "my-theme",
        class: "custom-switcher",
        theme: "sunshine"
      })

    assert result =~ ~s[id="my-theme"]
    assert result =~ "custom-switcher"
    assert result =~ "theme-controller-dropdown"
    assert result =~ "theme-controller-dropdown-end"
    assert result =~ ~s[data-theme="sunshine"]
    assert result =~ ~s[phx-hook="ThemeSwitcher"]
    assert result =~ ~s[value="default"]
    assert result =~ ~s[value="sunshine"]
    assert result =~ ~s[value="moonlight"]
    assert result =~ "theme-controller-trigger"
    assert result =~ "theme-controller-item"
    assert result =~ "theme-controller-label"
    assert result =~ "theme-controller-menu"
  end
end
