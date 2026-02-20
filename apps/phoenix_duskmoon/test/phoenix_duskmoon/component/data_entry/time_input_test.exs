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
end
