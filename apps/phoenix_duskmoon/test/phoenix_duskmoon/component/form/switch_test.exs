defmodule PhoenixDuskmoon.Component.Form.SwitchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Form.Switch

  test "renders basic switch" do
    result =
      render_component(&dm_switch/1, %{
        id: "test-switch",
        name: "notifications",
        label: "Enable notifications"
      })

    assert result =~ ~s[<div class="]
    assert result =~ ~s[<label class="flex items-center gap-2 cursor-pointer">]

    assert result =~
             ~s[<input type="checkbox" name="notifications" id="test-switch" value="true" class="sr-only peer">]

    assert result =~
             ~s[<div class="relative w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer]

    assert result =~ ~s[<span class="label-text ]
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

    assert result =~ ~s[w-14 h-7]
    assert result =~ ~s[peer-checked:after:translate-x-7]
  end

  test "renders switch with custom color" do
    result =
      render_component(&dm_switch/1, %{
        id: "success-switch",
        name: "feature",
        label: "Enable feature",
        color: "success"
      })

    assert result =~ ~s[peer-checked:bg-success]
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
    assert result =~ ~s[opacity-50 cursor-not-allowed]
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

    assert result =~ ~s[<div class="my-switch-container">]
    assert result =~ ~s[custom-switch]
  end
end
