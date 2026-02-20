defmodule PhoenixDuskmoon.Component.DataEntry.SwitchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Switch

  test "renders basic switch with checkbox input" do
    result = render_component(&dm_switch/1, %{name: "notifications"})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "switch"
  end

  test "renders switch with name" do
    result = render_component(&dm_switch/1, %{name: "dark_mode"})

    assert result =~ ~s[name="dark_mode"]
  end

  test "renders switch with label" do
    result =
      render_component(&dm_switch/1, %{name: "notifications", label: "Enable notifications"})

    assert result =~ "Enable notifications"
    assert result =~ "<span"
  end

  test "renders switch without label span when no label" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    refute result =~ "<span"
  end

  test "renders switch with custom id" do
    result = render_component(&dm_switch/1, %{name: "opt", id: "my-switch"})

    assert result =~ ~s[id="my-switch"]
  end

  test "renders switch with switch-label wrapper" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "switch-label"
  end

  test "renders switch with default size md" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "switch-md"
  end

  test "renders switch with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_switch/1, %{name: "opt", size: size})
      assert result =~ "switch-#{size}"
    end
  end

  test "renders switch with default color primary" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "switch-primary"
  end

  test "renders switch with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_switch/1, %{name: "opt", color: color})
      assert result =~ "switch-#{color}"
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

  test "renders switch with form-group wrapper" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ "form-group"
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

  test "renders switch with label_class" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        label: "Dark mode",
        label_class: "font-bold"
      })

    assert result =~ "font-bold"
  end

  test "renders switch with rest attributes" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        "data-testid": "my-switch",
        "phx-change": "toggle"
      })

    assert result =~ "data-testid=\"my-switch\""
    assert result =~ "phx-change=\"toggle\""
  end

  test "renders unchecked switch by default" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    refute result =~ "checked=\"checked\""
  end

  test "renders switch with checked and disabled" do
    result = render_component(&dm_switch/1, %{name: "opt", checked: true, disabled: true})

    assert result =~ "checked"
    assert result =~ "disabled"
  end

  test "renders switch with label and label_class combined" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        label: "Enable",
        label_class: "text-sm text-gray-500"
      })

    assert result =~ "Enable"
    assert result =~ "text-sm text-gray-500"
    assert result =~ "<span"
  end

  test "renders switch label inside label element" do
    result =
      render_component(&dm_switch/1, %{name: "opt", label: "Notify"})

    assert result =~ "<label"
    assert result =~ "Notify"
  end

  test "renders switch with role=switch on checkbox" do
    result = render_component(&dm_switch/1, %{name: "opt"})

    assert result =~ ~s[role="switch"]
  end

  test "renders switch with form field extracting id and name" do
    field = Phoenix.Component.to_form(%{"enabled" => "true"}, as: "settings")[:enabled]

    result = render_component(&dm_switch/1, %{field: field})

    assert result =~ ~s(name="settings[enabled]")
    assert result =~ ~s(id="settings_enabled")
  end

  test "renders switch with form field multiple appends brackets" do
    field = Phoenix.Component.to_form(%{"roles" => []}, as: "user")[:roles]

    result = render_component(&dm_switch/1, %{field: field, multiple: true})

    assert result =~ ~s(name="user[roles][]")
  end

  test "renders switch with form field extracting value" do
    field = Phoenix.Component.to_form(%{"active" => "true"}, as: "cfg")[:active]

    result = render_component(&dm_switch/1, %{field: field})

    assert result =~ ~s(name="cfg[active]")
    assert result =~ ~s(id="cfg_active")
    assert result =~ ~s[value="true"]
  end

  test "renders switch with all options combined" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        id: "full-switch",
        label: "All options",
        size: "lg",
        color: "accent",
        checked: true,
        disabled: true,
        class: "wrapper-cls",
        label_class: "lbl-cls",
        switch_class: "sw-cls"
      })

    assert result =~ ~s[id="full-switch"]
    assert result =~ ~s[name="opt"]
    assert result =~ "All options"
    assert result =~ "switch-lg"
    assert result =~ "switch-accent"
    assert result =~ "checked"
    assert result =~ "disabled"
    assert result =~ "wrapper-cls"
    assert result =~ "lbl-cls"
    assert result =~ "sw-cls"
  end

  test "renders switch with aria-checked=true when checked" do
    result = render_component(&dm_switch/1, %{name: "opt", checked: true})

    assert result =~ ~s[aria-checked="true"]
  end

  test "renders switch with aria-checked=false when unchecked" do
    result = render_component(&dm_switch/1, %{name: "opt", checked: false})

    assert result =~ ~s[aria-checked="false"]
  end

  test "renders switch with aria-invalid and error messages when errors present" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        id: "opt-switch",
        errors: ["must be enabled"]
      })

    assert result =~ ~s[aria-invalid="true"]
    assert result =~ ~s[aria-describedby="opt-switch-errors"]
    assert result =~ ~s[id="opt-switch-errors"]
    assert result =~ "must be enabled"
  end

  test "renders switch without aria-invalid when no errors" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        id: "opt-switch"
      })

    refute result =~ "aria-invalid"
    refute result =~ "aria-describedby"
  end

  test "renders disabled switch with native disabled attribute" do
    result =
      render_component(&dm_switch/1, %{
        name: "opt",
        disabled: true
      })

    assert result =~ "disabled"
  end
end
