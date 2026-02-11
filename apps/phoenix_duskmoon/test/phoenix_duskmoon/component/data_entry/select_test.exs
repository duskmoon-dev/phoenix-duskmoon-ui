defmodule PhoenixDuskmoon.Component.DataEntry.SelectTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Select

  test "renders basic select with options" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ "<select"
    assert result =~ "dm-select"
    assert result =~ "USA"
    assert result =~ "Canada"
  end

  test "renders select option values" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        options: [{"us", "USA"}, {"ca", "Canada"}]
      })

    assert result =~ ~s[value="us"]
    assert result =~ ~s[value="ca"]
  end

  test "renders select with prompt" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        prompt: "Select a country",
        options: [{"us", "USA"}]
      })

    assert result =~ "Select a country"
    assert result =~ ~s[value=""]
  end

  test "renders select with label" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        label: "Country",
        options: [{"us", "USA"}]
      })

    assert result =~ "Country"
    assert result =~ "dm-label"
  end

  test "renders select with custom id" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        id: "country-select",
        value: nil,
        options: [{"us", "USA"}]
      })

    assert result =~ ~s[id="country-select"]
  end

  test "renders select with default size md" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "dm-select--md"
  end

  test "renders select with all size options" do
    for size <- ~w(xs sm md lg) do
      result =
        render_component(&dm_select/1, %{
          name: "opt",
          value: nil,
          size: size,
          options: [{"1", "One"}]
        })

      assert result =~ "dm-select--#{size}"
    end
  end

  test "renders select with default color primary" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "dm-select--primary"
  end

  test "renders select with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result =
        render_component(&dm_select/1, %{
          name: "opt",
          value: nil,
          color: color,
          options: [{"1", "One"}]
        })

      assert result =~ "dm-select--#{color}"
    end
  end

  test "renders disabled select" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        disabled: true,
        options: [{"1", "One"}]
      })

    assert result =~ "disabled"
    assert result =~ "opacity-50"
  end

  test "renders select with dm-form-group wrapper" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        options: [{"1", "One"}]
      })

    assert result =~ "dm-form-group"
  end

  test "renders select with custom class" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        class: "my-select-wrapper",
        options: [{"1", "One"}]
      })

    assert result =~ "my-select-wrapper"
  end

  test "renders select with select_class" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        select_class: "custom-select",
        options: [{"1", "One"}]
      })

    assert result =~ "custom-select"
  end

  test "renders select with selected option" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: "b",
        options: [{"a", "Alpha"}, {"b", "Beta"}]
      })

    assert result =~ "selected"
  end
end
