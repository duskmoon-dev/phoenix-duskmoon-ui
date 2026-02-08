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

  test "renders radio with label" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", label: "Option A"})

    assert result =~ "Option A"
    assert result =~ ~s[type="radio"]
  end

  test "renders radio with color" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", color: "primary"})

    assert result =~ "dm-radio--primary"
  end

  test "renders radio with size" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", size: "lg"})

    assert result =~ "dm-radio--lg"
  end

  test "renders disabled radio" do
    result = render_component(&dm_radio/1, %{name: "choice", value: "a", disabled: true})

    assert result =~ "disabled"
  end
end
