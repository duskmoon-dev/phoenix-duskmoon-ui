defmodule PhoenixDuskmoon.Component.DataEntry.SelectTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Select

  test "renders basic select" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        options: [{"USA", "us"}, {"Canada", "ca"}]
      })

    assert result =~ "<select"
    assert result =~ "dm-select"
    assert result =~ "us"
    assert result =~ "ca"
  end

  test "renders select with prompt" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        prompt: "Select a country",
        options: [{"USA", "us"}]
      })

    assert result =~ "Select a country"
  end

  test "renders select with label" do
    result =
      render_component(&dm_select/1, %{
        name: "country",
        value: nil,
        label: "Country",
        options: [{"USA", "us"}]
      })

    assert result =~ "Country"
  end

  test "renders select with color" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        color: "primary",
        options: [{"One", "1"}]
      })

    assert result =~ "dm-select--primary"
  end

  test "renders select with size" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        size: "lg",
        options: [{"One", "1"}]
      })

    assert result =~ "dm-select--lg"
  end

  test "renders disabled select" do
    result =
      render_component(&dm_select/1, %{
        name: "opt",
        value: nil,
        disabled: true,
        options: [{"One", "1"}]
      })

    assert result =~ "disabled"
  end
end
