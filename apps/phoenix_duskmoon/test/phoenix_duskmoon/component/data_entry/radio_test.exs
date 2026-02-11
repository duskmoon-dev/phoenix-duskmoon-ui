defmodule PhoenixDuskmoon.Component.DataEntry.RadioTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Radio

  test "renders basic radio button" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ ~s[type="radio"]
    assert result =~ "dm-radio"
  end

  test "renders radio with name and value" do
    result = render_component(&dm_radio/1, %{name: "theme", value: "dark"})

    assert result =~ ~s[name="theme"]
    assert result =~ ~s[value="dark"]
  end

  test "renders radio with label" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", label: "Option A"})

    assert result =~ "Option A"
    assert result =~ "dm-label__text"
  end

  test "renders radio without label span when no label" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    refute result =~ "dm-label__text"
  end

  test "renders radio with custom id" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", id: "radio-1"})

    assert result =~ ~s[id="radio-1"]
  end

  test "renders radio with default size md" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "dm-radio--md"
  end

  test "renders radio with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_radio/1, %{name: "choice", value: "a", size: size})
      assert result =~ "dm-radio--#{size}"
    end
  end

  test "renders radio with default color primary" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "dm-radio--primary"
  end

  test "renders radio with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_radio/1, %{name: "choice", value: "a", color: color})
      assert result =~ "dm-radio--#{color}"
    end
  end

  test "renders checked radio" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", checked: true})

    assert result =~ "checked"
  end

  test "renders disabled radio" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", disabled: true})

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders radio with dm-form-group wrapper" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a"})

    assert result =~ "dm-form-group"
  end

  test "renders radio with custom class" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", class: "my-radio"})

    assert result =~ "my-radio"
  end

  test "renders radio with label_class" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        label: "Option",
        label_class: "text-lg"
      })

    assert result =~ "text-lg"
  end

  test "renders radio with radio_class" do
    result =
      render_component(&dm_radio/1, %{
        name: "choice",
        value: "a",
        radio_class: "custom-radio"
      })

    assert result =~ "custom-radio"
  end
end
