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

  test "renders checkbox with name" do
    result = render_component(&dm_checkbox/1, %{name: "subscribe"})

    assert result =~ ~s[name="subscribe"]
  end

  test "renders checkbox with label" do
    result = render_component(&dm_checkbox/1, %{name: "agree", label: "I agree to terms"})

    assert result =~ "I agree to terms"
    assert result =~ "dm-label__text"
  end

  test "renders checkbox without label span when no label" do
    result = render_component(&dm_checkbox/1, %{name: "agree"})

    refute result =~ "dm-label__text"
  end

  test "renders checkbox with custom id" do
    result = render_component(&dm_checkbox/1, %{name: "agree", id: "my-checkbox"})

    assert result =~ ~s[id="my-checkbox"]
  end

  test "renders checkbox with default size md" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "dm-checkbox--md"
  end

  test "renders checkbox with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_checkbox/1, %{name: "opt", size: size})
      assert result =~ "dm-checkbox--#{size}"
    end
  end

  test "renders checkbox with default color primary" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "dm-checkbox--primary"
  end

  test "renders checkbox with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_checkbox/1, %{name: "opt", color: color})
      assert result =~ "dm-checkbox--#{color}"
    end
  end

  test "renders checked checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled checkbox" do
    result = render_component(&dm_checkbox/1, %{name: "opt", disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders checkbox with indeterminate state" do
    result = render_component(&dm_checkbox/1, %{name: "opt", indeterminate: true})

    assert result =~ "phx-indeterminate"
  end

  test "renders checkbox with dm-form-group wrapper" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ "dm-form-group"
  end

  test "renders checkbox with custom class" do
    result = render_component(&dm_checkbox/1, %{name: "opt", class: "my-checkbox"})

    assert result =~ "my-checkbox"
  end

  test "renders checkbox with checkbox_class" do
    result = render_component(&dm_checkbox/1, %{name: "opt", checkbox_class: "custom-input"})

    assert result =~ "custom-input"
  end

  test "renders checkbox with value true" do
    result = render_component(&dm_checkbox/1, %{name: "opt"})

    assert result =~ ~s[value="true"]
  end
end
