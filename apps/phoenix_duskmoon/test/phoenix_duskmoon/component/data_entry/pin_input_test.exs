defmodule PhoenixDuskmoon.Component.DataEntry.PinInputTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.PinInput

  describe "dm_pin_input/1" do
    test "renders default 4-field pin input" do
      result = render_component(&dm_pin_input/1, %{})
      assert result =~ "pin-group"
      assert result =~ "pin-input"
      assert result =~ "pin-input-field"
      # Default length is 4
      assert length(String.split(result, "pin-input-field")) - 1 == 4
    end

    test "renders custom length" do
      result = render_component(&dm_pin_input/1, %{length: 6})
      assert length(String.split(result, "pin-input-field")) - 1 == 6
    end

    test "renders with id" do
      result = render_component(&dm_pin_input/1, %{id: "my-pin"})
      assert result =~ ~s(id="my-pin")
    end

    test "renders size variants" do
      for size <- ["sm", "lg"] do
        result = render_component(&dm_pin_input/1, %{size: size})
        assert result =~ "pin-input-#{size}"
      end
    end

    test "default size has no modifier class" do
      result = render_component(&dm_pin_input/1, %{})
      refute result =~ "pin-input-sm"
      refute result =~ "pin-input-lg"
    end

    test "renders color variants" do
      for color <- ["primary", "secondary", "tertiary"] do
        result = render_component(&dm_pin_input/1, %{color: color})
        assert result =~ "pin-input-#{color}"
      end
    end

    test "renders filled variant" do
      result = render_component(&dm_pin_input/1, %{variant: "filled"})
      assert result =~ "pin-input-filled"
    end

    test "renders circle shape" do
      result = render_component(&dm_pin_input/1, %{shape: "circle"})
      assert result =~ "pin-input-circle"
    end

    test "renders compact spacing" do
      result = render_component(&dm_pin_input/1, %{compact: true})
      assert result =~ "pin-input-compact"
    end

    test "renders dots display" do
      result = render_component(&dm_pin_input/1, %{dots: true})
      assert result =~ "pin-input-dots"
    end

    test "renders visible toggle" do
      result = render_component(&dm_pin_input/1, %{visible: true})
      assert result =~ "pin-input-visible"
    end

    test "no visible class when false" do
      result = render_component(&dm_pin_input/1, %{visible: false})
      refute result =~ "pin-input-visible"
    end

    test "renders error state" do
      result = render_component(&dm_pin_input/1, %{error: true})
      assert result =~ "pin-input-error"
    end

    test "renders success state" do
      result = render_component(&dm_pin_input/1, %{success: true})
      assert result =~ "pin-input-success"
    end

    test "renders disabled fields" do
      result = render_component(&dm_pin_input/1, %{disabled: true})
      assert result =~ "disabled"
    end

    test "renders label" do
      result = render_component(&dm_pin_input/1, %{label: "Enter PIN"})
      assert result =~ "pin-label"
      assert result =~ "Enter PIN"
    end

    test "renders helper text" do
      result = render_component(&dm_pin_input/1, %{helper: "4-digit code"})
      assert result =~ "pin-helper"
      assert result =~ "4-digit code"
    end

    test "renders error message" do
      result = render_component(&dm_pin_input/1, %{error_message: "Invalid PIN"})
      assert result =~ "pin-error-message"
      assert result =~ "Invalid PIN"
    end

    test "error message takes precedence over helper" do
      result =
        render_component(&dm_pin_input/1, %{
          helper: "Enter code",
          error_message: "Wrong PIN"
        })

      assert result =~ "Wrong PIN"
      refute result =~ "Enter code"
    end

    test "renders form name attributes" do
      result = render_component(&dm_pin_input/1, %{name: "pin"})
      assert result =~ ~s(name="pin[1]")
      assert result =~ ~s(name="pin[2]")
      assert result =~ ~s(name="pin[3]")
      assert result =~ ~s(name="pin[4]")
    end

    test "fields have correct input attributes" do
      result = render_component(&dm_pin_input/1, %{})
      assert result =~ ~s(maxlength="1")
      assert result =~ ~s(inputmode="numeric")
      assert result =~ ~s(autocomplete="off")
    end

    test "fields have aria labels" do
      result = render_component(&dm_pin_input/1, %{length: 4})
      assert result =~ "PIN digit 1 of 4"
      assert result =~ "PIN digit 4 of 4"
    end

    test "renders additional CSS classes" do
      result = render_component(&dm_pin_input/1, %{class: "my-custom"})
      assert result =~ "my-custom"
    end

    test "combines multiple modifiers" do
      result =
        render_component(&dm_pin_input/1, %{
          size: "lg",
          color: "primary",
          shape: "circle",
          compact: true,
          error: true
        })

      assert result =~ "pin-input-lg"
      assert result =~ "pin-input-primary"
      assert result =~ "pin-input-circle"
      assert result =~ "pin-input-compact"
      assert result =~ "pin-input-error"
    end

    test "no label renders no label element" do
      result = render_component(&dm_pin_input/1, %{})
      refute result =~ "pin-label"
    end

    test "no helper or error renders no message" do
      result = render_component(&dm_pin_input/1, %{})
      refute result =~ "pin-helper"
      refute result =~ "pin-error-message"
    end
  end
end
