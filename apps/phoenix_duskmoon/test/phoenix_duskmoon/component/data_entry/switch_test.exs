defmodule PhoenixDuskmoon.Component.DataEntry.SwitchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Switch

  test "renders basic switch" do
    result =
      render_component(&dm_switch/1, %{
        id: "test-switch",
        name: "notifications",
        label: "Enable notifications"
      })

    assert result =~ ~s[<div class="dm-form-group]
    assert result =~ ~s[<label class="dm-switch]

    assert result =~
             ~s[<input type="checkbox" name="notifications" id="test-switch" value="true" class="dm-switch__input]

    assert result =~ ~s[<span class="dm-switch__track"]
    assert result =~ ~s[Enable notifications]
  end

  test "renders switch with custom size" do
    result =
      render_component(&dm_switch/1, %{
        id: "lg-switch",
        name: "dark_mode",
        label: "Dark mode",
        size: "lg"
      })

    assert result =~ ~s[dm-switch--lg]
  end

  test "renders switch with custom color" do
    result =
      render_component(&dm_switch/1, %{
        id: "success-switch",
        name: "feature",
        label: "Enable feature",
        color: "success"
      })

    assert result =~ ~s[dm-switch--success]
  end

  test "renders disabled switch" do
    result =
      render_component(&dm_switch/1, %{
        id: "disabled-switch",
        name: "disabled",
        label: "Disabled switch",
        disabled: true
      })

    assert result =~ ~s[disabled]
  end

  test "renders checked switch" do
    result =
      render_component(&dm_switch/1, %{
        id: "checked-switch",
        name: "checked",
        label: "Checked switch",
        checked: true
      })

    assert result =~ ~s[checked]
  end

  test "renders switch with custom classes" do
    result =
      render_component(&dm_switch/1, %{
        id: "custom-switch",
        name: "custom",
        label: "Custom switch",
        class: "my-switch-container",
        switch_class: "custom-switch"
      })

    assert result =~ ~s[my-switch-container]
    assert result =~ ~s[custom-switch]
  end
end
