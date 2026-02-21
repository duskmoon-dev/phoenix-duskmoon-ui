defmodule PhoenixDuskmoon.Component.DataEntry.OtpInputTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.OtpInput

  describe "dm_otp_input basic rendering" do
    test "renders otp-group container" do
      result = render_component(&dm_otp_input/1, %{})
      assert result =~ "otp-group"
      assert result =~ "otp-input"
    end

    test "renders with custom id" do
      result = render_component(&dm_otp_input/1, %{id: "verify-code"})
      assert result =~ ~s(id="verify-code")
    end

    test "renders with custom class" do
      result = render_component(&dm_otp_input/1, %{class: "mt-4"})
      assert result =~ "mt-4"
    end

    test "renders 6 input fields by default" do
      result = render_component(&dm_otp_input/1, %{})
      fields = String.split(result, "otp-input-field")
      # 6 fields + 1 for the initial split
      assert length(fields) == 7
    end

    test "renders custom length" do
      result = render_component(&dm_otp_input/1, %{length: 4})
      fields = String.split(result, "otp-input-field")
      assert length(fields) == 5
    end

    test "renders input with maxlength 1" do
      result = render_component(&dm_otp_input/1, %{})
      assert result =~ ~s(maxlength="1")
    end

    test "renders input with numeric inputmode" do
      result = render_component(&dm_otp_input/1, %{})
      assert result =~ ~s(inputmode="numeric")
    end

    test "renders aria labels" do
      result = render_component(&dm_otp_input/1, %{length: 4})
      assert result =~ ~s(aria-label="Digit 1 of 4")
      assert result =~ ~s(aria-label="Digit 4 of 4")
    end
  end

  describe "dm_otp_input size" do
    test "no size class by default" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "otp-input-sm"
      refute result =~ "otp-input-lg"
    end

    test "renders sm size" do
      result = render_component(&dm_otp_input/1, %{size: "sm"})
      assert result =~ "otp-input-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_otp_input/1, %{size: "lg"})
      assert result =~ "otp-input-lg"
    end
  end

  describe "dm_otp_input color" do
    test "no color class by default" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "otp-input-primary"
    end

    test "renders primary color" do
      result = render_component(&dm_otp_input/1, %{color: "primary"})
      assert result =~ "otp-input-primary"
    end

    test "renders secondary color" do
      result = render_component(&dm_otp_input/1, %{color: "secondary"})
      assert result =~ "otp-input-secondary"
    end

    test "renders tertiary color" do
      result = render_component(&dm_otp_input/1, %{color: "tertiary"})
      assert result =~ "otp-input-tertiary"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_otp_input/1, %{color: "accent"})
      assert result =~ "otp-input-tertiary"
      refute result =~ "otp-input-accent"
    end

    test "renders info, success, warning, error colors" do
      for color <- ~w(info success warning error) do
        result = render_component(&dm_otp_input/1, %{color: color})
        assert result =~ "otp-input-#{color}"
      end
    end
  end

  describe "dm_otp_input role=group" do
    test "has role group with aria-label" do
      result = render_component(&dm_otp_input/1, %{})
      assert result =~ ~s[role="group"]
      assert result =~ "Verification code, 6 digits"
    end

    test "aria-label reflects custom length" do
      result = render_component(&dm_otp_input/1, %{length: 4})
      assert result =~ "Verification code, 4 digits"
    end
  end

  describe "dm_otp_input variant" do
    test "no variant class by default (outlined)" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "otp-input-filled"
      refute result =~ "otp-input-underline"
    end

    test "renders filled variant" do
      result = render_component(&dm_otp_input/1, %{variant: "filled"})
      assert result =~ "otp-input-filled"
    end

    test "renders underline variant" do
      result = render_component(&dm_otp_input/1, %{variant: "underline"})
      assert result =~ "otp-input-underline"
    end
  end

  describe "dm_otp_input gap" do
    test "no gap class by default" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "otp-input-compact"
      refute result =~ "otp-input-wide"
    end

    test "renders compact gap" do
      result = render_component(&dm_otp_input/1, %{gap: "compact"})
      assert result =~ "otp-input-compact"
    end

    test "renders wide gap" do
      result = render_component(&dm_otp_input/1, %{gap: "wide"})
      assert result =~ "otp-input-wide"
    end
  end

  describe "dm_otp_input masked" do
    test "renders text type by default" do
      result = render_component(&dm_otp_input/1, %{})
      assert result =~ ~s(type="text")
    end

    test "renders password type when masked" do
      result = render_component(&dm_otp_input/1, %{masked: true})
      assert result =~ ~s(type="password")
      assert result =~ "otp-input-masked"
    end
  end

  describe "dm_otp_input states" do
    test "renders error state" do
      result = render_component(&dm_otp_input/1, %{error: true})
      assert result =~ "otp-input-error"
    end

    test "renders success state" do
      result = render_component(&dm_otp_input/1, %{success: true})
      assert result =~ "otp-input-success"
    end

    test "renders disabled state" do
      result = render_component(&dm_otp_input/1, %{disabled: true})
      assert result =~ "disabled"
      assert result =~ "opacity-50"
      assert result =~ "cursor-not-allowed"
    end

    test "renders enabled state without disabled styling" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "opacity-50"
      refute result =~ "cursor-not-allowed"
    end
  end

  describe "dm_otp_input label and helper" do
    test "renders label" do
      result = render_component(&dm_otp_input/1, %{label: "Enter code"})
      assert result =~ "otp-label"
      assert result =~ "Enter code"
    end

    test "no label by default" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ "otp-label"
    end

    test "renders helper text" do
      result = render_component(&dm_otp_input/1, %{helper: "Check your email"})
      assert result =~ "helper-text"
      assert result =~ "Check your email"
    end

    test "renders error message" do
      result = render_component(&dm_otp_input/1, %{error_message: "Invalid code"})
      assert result =~ "otp-error-message"
      assert result =~ "Invalid code"
    end

    test "error message takes precedence over helper" do
      result =
        render_component(&dm_otp_input/1, %{
          helper: "Check email",
          error_message: "Invalid code"
        })

      assert result =~ "Invalid code"
      refute result =~ "Check email"
    end
  end

  describe "dm_otp_input form integration" do
    test "renders name attributes for form submission" do
      result = render_component(&dm_otp_input/1, %{name: "code", length: 4})
      assert result =~ ~s(name="code[1]")
      assert result =~ ~s(name="code[2]")
      assert result =~ ~s(name="code[3]")
      assert result =~ ~s(name="code[4]")
    end

    test "no name by default" do
      result = render_component(&dm_otp_input/1, %{})
      refute result =~ ~s(name=")
    end
  end

  describe "dm_otp_input combined" do
    test "renders with all attrs" do
      result =
        render_component(&dm_otp_input/1, %{
          id: "verify",
          class: "mx-auto",
          length: 4,
          size: "lg",
          color: "primary",
          variant: "filled",
          label: "Verification Code",
          helper: "Sent to your phone"
        })

      assert result =~ ~s(id="verify")
      assert result =~ "mx-auto"
      assert result =~ "otp-input-lg"
      assert result =~ "otp-input-primary"
      assert result =~ "otp-input-filled"
      assert result =~ "Verification Code"
      assert result =~ "Sent to your phone"
    end
  end

  describe "FormField integration" do
    test "renders otp input with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"code" => ""}, as: "verify")[:code]

      result = render_component(&dm_otp_input/1, %{field: field})

      assert result =~ ~s(id="verify_code")
      assert result =~ ~s(name="verify[code])
    end

    test "renders otp input with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"code" => ""}, as: "verify")[:code]

      result = render_component(&dm_otp_input/1, %{field: field, id: "custom-otp"})

      assert result =~ ~s(id="custom-otp")
    end
  end

  describe "label_class" do
    test "renders label with custom label_class" do
      result =
        render_component(&dm_otp_input/1, %{
          label: "Verification Code",
          label_class: "text-lg font-bold"
        })

      assert result =~ "text-lg font-bold"
      assert result =~ "Verification Code"
    end

    test "renders label with otp-label base class and label_class" do
      result =
        render_component(&dm_otp_input/1, %{
          label: "Code",
          label_class: "text-sm"
        })

      assert result =~ "otp-label"
      assert result =~ "text-sm"
    end
  end

  describe "errors list" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_otp_input/1, %{
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "otp-input-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_otp_input/1, %{
          errors: []
        })

      refute result =~ "helper-text text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_otp_input/1, %{
          errors: ["invalid code"]
        })

      assert result =~ "otp-input-error"
    end

    test "errors list takes precedence over error_message" do
      result =
        render_component(&dm_otp_input/1, %{
          error_message: "Old error",
          errors: ["New error"]
        })

      assert result =~ "New error"
      refute result =~ "Old error"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_otp_input/1, %{
        name: "user[code]"
      })

    assert result =~ ~s(phx-feedback-for="user[code]")
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_otp_input/1, %{
          id: "otp",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="otp-errors"]
      assert result =~ ~s[aria-invalid="true"]
    end

    test "references helper when no errors and no error_message" do
      result =
        render_component(&dm_otp_input/1, %{
          id: "otp",
          helper: "Check your email"
        })

      assert result =~ ~s[aria-describedby="otp-helper"]
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_otp_input/1, %{
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "renders otp input with rest attributes" do
    result =
      render_component(&dm_otp_input/1, %{
        name: "otp",
        "data-testid": "my-otp"
      })

    assert result =~ ~s[data-testid="my-otp"]
  end
end
