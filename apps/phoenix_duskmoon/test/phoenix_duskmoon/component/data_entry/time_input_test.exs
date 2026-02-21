defmodule PhoenixDuskmoon.Component.DataEntry.TimeInputTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.TimeInput

  describe "dm_time_input basic rendering" do
    test "renders time input container" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ "time-input"
      assert result =~ "time-input-segments"
    end

    test "renders hour and minute segments" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ "time-input-segment"
      assert result =~ ~s(placeholder="HH")
      assert result =~ ~s(placeholder="MM")
    end

    test "renders separator" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ "time-input-separator"
    end

    test "renders with custom id" do
      result = render_component(&dm_time_input/1, %{id: "start-time"})
      assert result =~ ~s(id="start-time")
    end

    test "renders with custom class" do
      result = render_component(&dm_time_input/1, %{class: "mt-4"})
      assert result =~ "mt-4"
    end

    test "renders maxlength 2" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ ~s(maxlength="2")
    end

    test "renders numeric inputmode" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ ~s(inputmode="numeric")
    end

    test "renders aria labels" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ ~s(aria-label="Hours")
      assert result =~ ~s(aria-label="Minutes")
    end
  end

  describe "dm_time_input show_seconds" do
    test "no seconds by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ ~s(placeholder="SS")
      refute result =~ ~s(aria-label="Seconds")
    end

    test "renders seconds segment" do
      result = render_component(&dm_time_input/1, %{show_seconds: true})
      assert result =~ ~s(placeholder="SS")
      assert result =~ ~s(aria-label="Seconds")
    end
  end

  describe "dm_time_input show_period" do
    test "no period by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ "time-input-period"
    end

    test "renders AM/PM period toggle" do
      result = render_component(&dm_time_input/1, %{show_period: true})
      assert result =~ "time-input-period"
      assert result =~ "time-input-period-btn"
      assert result =~ "AM"
      assert result =~ "PM"
    end
  end

  describe "dm_time_input sizes" do
    test "no size class by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ "time-input-sm"
      refute result =~ "time-input-lg"
    end

    test "renders sm size" do
      result = render_component(&dm_time_input/1, %{size: "sm"})
      assert result =~ "time-input-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_time_input/1, %{size: "lg"})
      assert result =~ "time-input-lg"
    end
  end

  describe "dm_time_input colors" do
    test "no color class by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ "time-input-primary"
    end

    test "renders primary color" do
      result = render_component(&dm_time_input/1, %{color: "primary"})
      assert result =~ "time-input-primary"
    end

    test "renders secondary color" do
      result = render_component(&dm_time_input/1, %{color: "secondary"})
      assert result =~ "time-input-secondary"
    end

    test "renders tertiary color" do
      result = render_component(&dm_time_input/1, %{color: "tertiary"})
      assert result =~ "time-input-tertiary"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_time_input/1, %{color: "accent"})
      assert result =~ "time-input-tertiary"
      refute result =~ "time-input-accent"
    end

    test "renders info, success, warning, error colors" do
      for color <- ~w(info success warning error) do
        result = render_component(&dm_time_input/1, %{color: color})
        assert result =~ "time-input-#{color}"
      end
    end
  end

  describe "dm_time_input role=group" do
    test "has role group with aria-label" do
      result = render_component(&dm_time_input/1, %{})
      assert result =~ ~s[role="group"]
      assert result =~ ~s[aria-label="Time input"]
    end
  end

  describe "dm_time_input variant" do
    test "no variant class by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ "time-input-filled"
    end

    test "renders filled variant" do
      result = render_component(&dm_time_input/1, %{variant: "filled"})
      assert result =~ "time-input-filled"
    end
  end

  describe "dm_time_input error" do
    test "no error by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ "time-input-error"
    end

    test "renders error state" do
      result = render_component(&dm_time_input/1, %{error: true})
      assert result =~ "time-input-error"
    end
  end

  describe "dm_time_input disabled" do
    test "renders disabled state" do
      result = render_component(&dm_time_input/1, %{disabled: true})
      assert result =~ "disabled"
    end

    test "renders disabled with visual styling" do
      result = render_component(&dm_time_input/1, %{disabled: true})
      assert result =~ "opacity-50"
      assert result =~ "cursor-not-allowed"
    end
  end

  describe "dm_time_input form integration" do
    test "renders name attributes" do
      result = render_component(&dm_time_input/1, %{name: "event_time"})
      assert result =~ ~s(name="event_time[hour]")
      assert result =~ ~s(name="event_time[minute]")
    end

    test "renders seconds name when show_seconds" do
      result = render_component(&dm_time_input/1, %{name: "t", show_seconds: true})
      assert result =~ ~s(name="t[hour]")
      assert result =~ ~s(name="t[minute]")
      assert result =~ ~s(name="t[second]")
    end

    test "no name by default" do
      result = render_component(&dm_time_input/1, %{})
      refute result =~ ~s(name=")
    end
  end

  describe "dm_time_input combined" do
    test "renders with all options" do
      result =
        render_component(&dm_time_input/1, %{
          id: "meeting-time",
          class: "mx-auto",
          size: "lg",
          color: "primary",
          variant: "filled",
          show_seconds: true,
          show_period: true,
          name: "start"
        })

      assert result =~ ~s(id="meeting-time")
      assert result =~ "mx-auto"
      assert result =~ "time-input-lg"
      assert result =~ "time-input-primary"
      assert result =~ "time-input-filled"
      assert result =~ ~s(placeholder="SS")
      assert result =~ "time-input-period"
      assert result =~ ~s(name="start[hour]")
    end
  end

  describe "FormField integration" do
    test "renders time input with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"start_time" => ""}, as: "event")[:start_time]

      result = render_component(&dm_time_input/1, %{field: field})

      assert result =~ ~s(id="event_start_time")
      assert result =~ ~s(name="event[start_time])
    end

    test "renders time input with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"start_time" => ""}, as: "event")[:start_time]

      result = render_component(&dm_time_input/1, %{field: field, id: "custom-time"})

      assert result =~ ~s(id="custom-time")
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_time_input/1, %{
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "time-input-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_time_input/1, %{
          errors: []
        })

      refute result =~ "helper-text text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_time_input/1, %{
          errors: ["invalid time"]
        })

      assert result =~ "time-input-error"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_time_input/1, %{
        name: "event[start_time]"
      })

    assert result =~ ~s(phx-feedback-for="event[start_time]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_time_input/1, %{
          id: "ti",
          helper: "Enter start time"
        })

      assert result =~ "helper-text"
      assert result =~ "Enter start time"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_time_input/1, %{
          id: "ti",
          helper: "Enter start time",
          errors: ["is required"]
        })

      refute result =~ "Enter start time"
      assert result =~ "is required"
    end
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_time_input/1, %{
          id: "ti",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="ti-errors"]
      assert result =~ ~s[aria-invalid="true"]
    end

    test "references helper when no errors" do
      result =
        render_component(&dm_time_input/1, %{
          id: "ti",
          helper: "Pick a time"
        })

      assert result =~ ~s[aria-describedby="ti-helper"]
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_time_input/1, %{
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "renders time input with rest attributes" do
    result =
      render_component(&dm_time_input/1, %{
        name: "time",
        "data-testid": "my-time"
      })

    assert result =~ ~s[data-testid="my-time"]
  end
end
