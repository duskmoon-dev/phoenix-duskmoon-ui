defmodule PhoenixDuskmoon.Component.Navigation.StepsTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Steps

  test "renders el-dm-stepper element" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Step 1"}, %{label: "Step 2"}]
      })

    assert result =~ "<el-dm-stepper"
  end

  test "serializes steps as JSON in steps attribute" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Account"}, %{label: "Profile"}]
      })

    assert result =~ "Account"
    assert result =~ "Profile"
  end

  test "renders with current step index" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "A"}, %{label: "B"}, %{label: "C"}],
        current: 2
      })

    assert result =~ ~s(current="2")
  end

  test "renders with vertical orientation" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        orientation: "vertical"
      })

    assert result =~ ~s(orientation="vertical")
  end

  test "renders with color variant" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        color: "success"
      })

    assert result =~ ~s(color="success")
  end

  test "renders with clickable attribute" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}, %{label: "S2"}],
        clickable: true
      })

    assert result =~ "clickable"
  end

  test "renders with id attribute" do
    result =
      render_component(&dm_steps/1, %{
        id: "wizard",
        steps: [%{label: "S1"}]
      })

    assert result =~ ~s(id="wizard")
  end

  test "serializes steps with description" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Step 1", description: "First step"}]
      })

    assert result =~ "First step"
  end

  test "default values for current, orientation, and color" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}]
      })

    assert result =~ ~s(current="0")
    assert result =~ ~s(orientation="horizontal")
    assert result =~ ~s(color="primary")
  end

  test "renders all color variants" do
    for color <- ~w(primary secondary tertiary success warning error info) do
      result =
        render_component(&dm_steps/1, %{
          steps: [%{label: "S1"}],
          color: color
        })

      assert result =~ ~s(color="#{color}")
    end
  end
end
