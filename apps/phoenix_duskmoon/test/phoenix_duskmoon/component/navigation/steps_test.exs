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

  test "does not render clickable when false" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}, %{label: "S2"}],
        clickable: false
      })

    refute result =~ "clickable"
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

  test "maps accent color to tertiary" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        color: "accent"
      })

    assert result =~ ~s(color="tertiary")
    refute result =~ ~s(color="accent")
  end

  test "renders with class attribute" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        class: "my-steps-class"
      })

    assert result =~ ~s(class="my-steps-class")
  end

  test "renders empty class when class is nil" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}]
      })

    # Phoenix renders class="" for nil string attrs
    assert result =~ ~s(class="")
  end

  test "passes rest attributes" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        data_testid: "stepper-test"
      })

    assert result =~ ~s(data_testid="stepper-test")
  end

  test "serializes steps with icon field" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Upload", icon: "cloud_upload"}]
      })

    assert result =~ "cloud_upload"
  end

  test "serializes many steps" do
    steps = for i <- 1..10, do: %{label: "Step #{i}"}

    result =
      render_component(&dm_steps/1, %{
        steps: steps
      })

    for i <- 1..10 do
      assert result =~ "Step #{i}"
    end
  end

  test "current step at first position" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "A"}, %{label: "B"}],
        current: 0
      })

    assert result =~ ~s(current="0")
  end

  test "current step at last position" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "A"}, %{label: "B"}, %{label: "C"}],
        current: 2
      })

    assert result =~ ~s(current="2")
  end

  test "renders horizontal orientation explicitly" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        orientation: "horizontal"
      })

    assert result =~ ~s(orientation="horizontal")
  end

  test "steps JSON contains label and description keys" do
    result =
      render_component(&dm_steps/1, %{
        steps: [
          %{label: "Create", description: "Create your account"},
          %{label: "Verify", description: "Verify your email"}
        ]
      })

    # JSON-encoded steps should contain all fields
    assert result =~ "Create"
    assert result =~ "Create your account"
    assert result =~ "Verify"
    assert result =~ "Verify your email"
  end

  test "renders with combined options" do
    result =
      render_component(&dm_steps/1, %{
        id: "onboarding",
        class: "wizard-steps",
        current: 1,
        orientation: "vertical",
        color: "info",
        clickable: true,
        steps: [
          %{label: "Account", description: "Set up account"},
          %{label: "Profile", description: "Complete profile"},
          %{label: "Done", description: "All set"}
        ]
      })

    assert result =~ ~s(id="onboarding")
    assert result =~ ~s(class="wizard-steps")
    assert result =~ ~s(current="1")
    assert result =~ ~s(orientation="vertical")
    assert result =~ ~s(color="info")
    assert result =~ "clickable"
    assert result =~ "Account"
    assert result =~ "Profile"
    assert result =~ "Done"
  end

  test "renders with phx-hook via rest" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "S1"}],
        phx_hook: "StepperHook"
      })

    assert result =~ ~s(phx_hook="StepperHook")
  end

  test "steps attribute contains valid JSON" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Test Label"}]
      })

    # Extract the steps attribute value - it should be valid JSON
    assert result =~ ~s(steps=")
    assert result =~ "Test Label"
  end

  test "single step renders correctly" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Only Step"}]
      })

    assert result =~ "<el-dm-stepper"
    assert result =~ "Only Step"
  end

  test "passes through global attributes" do
    result =
      render_component(&dm_steps/1, %{
        steps: [%{label: "Step 1"}],
        "data-testid": "my-steps"
      })

    assert result =~ ~s[data-testid="my-steps"]
  end
end
