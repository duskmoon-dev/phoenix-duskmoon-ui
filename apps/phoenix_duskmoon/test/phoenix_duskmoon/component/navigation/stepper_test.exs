defmodule PhoenixDuskmoon.Component.Navigation.StepperTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Navigation.Stepper

  defp basic_steps do
    [
      %{__slot__: :step, label: "Step 1", inner_block: fn _, _ -> "" end},
      %{__slot__: :step, label: "Step 2", inner_block: fn _, _ -> "" end},
      %{__slot__: :step, label: "Step 3", inner_block: fn _, _ -> "" end}
    ]
  end

  describe "dm_stepper basic rendering" do
    test "renders stepper container" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ "stepper"
    end

    test "renders all steps" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ "Step 1"
      assert result =~ "Step 2"
      assert result =~ "Step 3"
    end

    test "renders step icons with numbers" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ "stepper-step-icon"
    end

    test "renders step labels" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ "stepper-step-label"
    end

    test "renders connectors between steps" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ "stepper-step-connector"
    end

    test "connectors are aria-hidden with presentation role" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ ~s(class="stepper-step-connector" role="presentation" aria-hidden="true")
    end

    test "renders with custom id" do
      result = render_component(&dm_stepper/1, %{id: "checkout", step: basic_steps()})
      assert result =~ ~s(id="checkout")
    end

    test "renders with custom class" do
      result = render_component(&dm_stepper/1, %{class: "mt-8", step: basic_steps()})
      assert result =~ "mt-8"
    end
  end

  describe "dm_stepper step states" do
    test "renders active step" do
      steps = [
        %{__slot__: :step, label: "Done", completed: true, inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Current", active: true, inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Next", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-active"
    end

    test "renders completed step" do
      steps = [
        %{__slot__: :step, label: "Done", completed: true, inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Next", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-completed"
    end

    test "renders error step" do
      steps = [
        %{__slot__: :step, label: "Error", error: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-error"
    end

    test "renders disabled step" do
      steps = [
        %{__slot__: :step, label: "Disabled", disabled: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-disabled"
    end

    test "renders optional step" do
      steps = [
        %{__slot__: :step, label: "Optional", optional: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-optional"
    end
  end

  describe "dm_stepper step description" do
    test "renders description" do
      steps = [
        %{
          __slot__: :step,
          label: "Account",
          description: "Create your account",
          inner_block: fn _, _ -> "" end
        }
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ "stepper-step-description"
      assert result =~ "Create your account"
    end

    test "no description by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-step-description"
    end
  end

  describe "dm_stepper layout" do
    test "horizontal by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-vertical"
    end

    test "renders vertical layout" do
      result = render_component(&dm_stepper/1, %{vertical: true, step: basic_steps()})
      assert result =~ "stepper-vertical"
    end
  end

  describe "dm_stepper variants" do
    test "no variant by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-dots"
      refute result =~ "stepper-alt-labels"
      refute result =~ "stepper-icons"
    end

    test "renders dots variant" do
      result = render_component(&dm_stepper/1, %{variant: "dots", step: basic_steps()})
      assert result =~ "stepper-dots"
    end

    test "renders alt-labels variant" do
      result = render_component(&dm_stepper/1, %{variant: "alt-labels", step: basic_steps()})
      assert result =~ "stepper-alt-labels"
    end

    test "renders icons variant" do
      result = render_component(&dm_stepper/1, %{variant: "icons", step: basic_steps()})
      assert result =~ "stepper-icons"
    end
  end

  describe "dm_stepper colors" do
    test "no color by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-secondary"
      refute result =~ "stepper-tertiary"
    end

    test "renders secondary color" do
      result = render_component(&dm_stepper/1, %{color: "secondary", step: basic_steps()})
      assert result =~ "stepper-secondary"
    end

    test "renders tertiary color" do
      result = render_component(&dm_stepper/1, %{color: "tertiary", step: basic_steps()})
      assert result =~ "stepper-tertiary"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_stepper/1, %{color: "accent", step: basic_steps()})
      assert result =~ "stepper-tertiary"
      refute result =~ "stepper-accent"
    end
  end

  describe "dm_stepper sizes" do
    test "no size by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-sm"
      refute result =~ "stepper-lg"
    end

    test "renders sm size" do
      result = render_component(&dm_stepper/1, %{size: "sm", step: basic_steps()})
      assert result =~ "stepper-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_stepper/1, %{size: "lg", step: basic_steps()})
      assert result =~ "stepper-lg"
    end
  end

  describe "dm_stepper clickable" do
    test "not clickable by default" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      refute result =~ "stepper-clickable"
    end

    test "renders clickable" do
      result = render_component(&dm_stepper/1, %{clickable: true, step: basic_steps()})
      assert result =~ "stepper-clickable"
    end
  end

  describe "dm_stepper accessibility" do
    test "active step has aria-current=step" do
      steps = [
        %{__slot__: :step, label: "Done", completed: true, inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Current", active: true, inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Next", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ ~s(aria-current="step")
    end

    test "non-active steps do not have aria-current" do
      steps = [
        %{__slot__: :step, label: "Step 1", inner_block: fn _, _ -> "" end},
        %{__slot__: :step, label: "Step 2", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      refute result =~ "aria-current"
    end

    test "disabled step has aria-disabled=true" do
      steps = [
        %{__slot__: :step, label: "Step 1", disabled: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      assert result =~ ~s(aria-disabled="true")
    end

    test "non-disabled steps do not have aria-disabled" do
      steps = [
        %{__slot__: :step, label: "Step 1", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_stepper/1, %{step: steps})
      refute result =~ "aria-disabled"
    end

    test "stepper container has role list" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ ~s(role="list")
    end

    test "steps have role listitem" do
      result = render_component(&dm_stepper/1, %{step: basic_steps()})
      assert result =~ ~s(role="listitem")
    end
  end

  describe "dm_stepper combined" do
    test "renders with all options" do
      steps = [
        %{
          __slot__: :step,
          label: "Account",
          description: "Create account",
          completed: true,
          inner_block: fn _, _ -> "" end
        },
        %{
          __slot__: :step,
          label: "Details",
          description: "Fill in details",
          active: true,
          inner_block: fn _, _ -> "" end
        },
        %{
          __slot__: :step,
          label: "Review",
          description: "Final review",
          inner_block: fn _, _ -> "" end
        }
      ]

      result =
        render_component(&dm_stepper/1, %{
          id: "signup",
          class: "max-w-lg",
          vertical: true,
          color: "secondary",
          size: "lg",
          clickable: true,
          step: steps
        })

      assert result =~ ~s(id="signup")
      assert result =~ "max-w-lg"
      assert result =~ "stepper-vertical"
      assert result =~ "stepper-secondary"
      assert result =~ "stepper-lg"
      assert result =~ "stepper-clickable"
      assert result =~ "stepper-step-completed"
      assert result =~ "stepper-step-active"
      assert result =~ "Account"
      assert result =~ "Create account"
      assert result =~ "Details"
      assert result =~ "Review"
    end
  end

  test "passes through global attributes" do
    result = render_component(&dm_stepper/1, %{step: basic_steps(), "data-testid": "my-stepper"})
    assert result =~ ~s[data-testid="my-stepper"]
  end
end
