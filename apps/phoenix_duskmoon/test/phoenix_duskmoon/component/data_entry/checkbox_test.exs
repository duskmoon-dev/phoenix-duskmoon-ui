defmodule PhoenixDuskmoon.Component.DataEntry.CheckboxTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Checkbox

  test "renders basic checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "agree"})

    assert result =~ ~s[type="checkbox"]
    assert result =~ "dm-checkbox"
  end

  test "renders checkbox with label" do
    result = render_component(&dm_checkbox/1, %{name: "agree", label: "I agree"})

    assert result =~ "I agree"
    assert result =~ ~s[type="checkbox"]
  end

  test "renders checkbox with color" do
    result = render_component(&dm_checkbox/1, %{name: "opt", color: "success"})

    assert result =~ "dm-checkbox"
    assert result =~ "dm-checkbox--success"
  end

  test "renders checkbox with size" do
    result = render_component(&dm_checkbox/1, %{name: "opt", size: "lg"})

    assert result =~ "dm-checkbox--lg"
  end

  test "renders checked checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", disabled: true})

    assert result =~ "disabled"
  end
end
