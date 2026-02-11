defmodule PhoenixDuskmoon.Component.DataEntry.SwitchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Switch

  test "renders basic switch with checkbox input" do
    result = render_component(&dm_switch/1, %{name: "notifications"})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "dm-switch"
    assert result =~ "dm-switch__input"
  end

  test "renders switch with name" do
    result = render_component(&dm_switch/1, %{name: "dark_mode"})

    assert result =~ ~s[name="dark_mode"]
  end

  test "renders switch with label" do
    result =
      render_component(&dm_switch/1, %{name: "notifications", label: "Enable notifications"})

    assert result =~ "Enable notifications"
    assert result =~ "dm-label__text"
  end

  test "renders switch without label span when no label" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    refute result =~ "dm-label__text"
  end

  test "renders switch with custom id" do
    result = render_component(&dm_switch/1, %{name: "opt", id: "my-switch"})

    assert result =~ ~s[id="my-switch"]
  end

  test "renders switch with track element" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "dm-switch__track"
  end

  test "renders switch with default size md" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "dm-switch--md"
  end

  test "renders switch with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_switch/1, %{name: "opt", size: size})
      assert result =~ "dm-switch--#{size}"
    end
  end

  test "renders switch with default color primary" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "dm-switch--primary"
  end

  test "renders switch with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_switch/1, %{name: "opt", color: color})
      assert result =~ "dm-switch--#{color}"
    end
  end

  test "renders checked switch" do
    result = render_component(&dm_switch/1, %{name: "opt", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled switch" do
    result = render_component(&dm_switch/1, %{name: "opt", disabled: true})

    assert result =~ "disabled"
  end

  test "renders switch with dm-form-group wrapper" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "dm-form-group"
  end

  test "renders switch with custom class" do
    result = render_component(&dm_switch/1, %{name: "opt", class: "my-switch-wrapper"})

    assert result =~ "my-switch-wrapper"
  end

  test "renders switch with switch_class" do
    result = render_component(&dm_switch/1, %{name: "opt", switch_class: "custom-switch"})

    assert result =~ "custom-switch"
  end

  test "renders switch with value true" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ ~s[value="true"]
  end
end
