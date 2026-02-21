defmodule PhoenixDuskmoon.Component.DataDisplay.TooltipTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip

  defp inner_block, do: %{inner_block: fn _, _ -> "Hover me" end}

  test "renders basic tooltip with data-tip attribute" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Help text",
        inner_block: inner_block()
      })

    assert result =~ "tooltip"
    assert result =~ ~s[data-tip="Help text"]
  end

  test "renders default position top" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-top"
  end

  test "renders tooltip with position bottom" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Bottom tip",
        position: "bottom",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-bottom"
  end

  test "renders tooltip with position left" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Left tip",
        position: "left",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-left"
  end

  test "renders tooltip with position right" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Right tip",
        position: "right",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-right"
  end

  test "renders default color primary" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-primary"
  end

  test "renders tooltip with all color variants" do
    for color <- ~w(primary secondary accent info success warning error) do
      result =
        render_component(&dm_tooltip/1, %{
          content: "#{color} tip",
          color: color,
          inner_block: inner_block()
        })

      css_class = if color == "accent", do: "tertiary", else: color
      assert result =~ "tooltip-#{css_class}"
    end
  end

  test "renders tooltip with open state" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Always visible",
        open: true,
        inner_block: inner_block()
      })

    assert result =~ "tooltip-open"
  end

  test "renders tooltip without open class when open is false" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Normal tip",
        open: false,
        inner_block: inner_block()
      })

    refute result =~ "tooltip-open"
  end

  test "renders tooltip with custom class" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Custom",
        class: "my-tooltip-class",
        inner_block: inner_block()
      })

    assert result =~ "my-tooltip-class"
  end

  test "renders tooltip wrapping inner content in a div" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tooltip text",
        inner_block: inner_block()
      })

    assert result =~ "<div"
    assert result =~ "</div>"
  end

  test "renders tooltip with special characters in content" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Press Ctrl+S to save",
        inner_block: inner_block()
      })

    assert result =~ ~s[data-tip="Press Ctrl+S to save"]
  end

  test "renders tooltip with rest attributes" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        "data-testid": "my-tooltip",
        "aria-describedby": "desc",
        inner_block: inner_block()
      })

    assert result =~ "data-testid=\"my-tooltip\""
    assert result =~ "aria-describedby=\"desc\""
  end

  test "renders tooltip with position and color combined" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Combined",
        position: "bottom",
        color: "warning",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-bottom"
    assert result =~ "tooltip-warning"
    assert result =~ ~s[data-tip="Combined"]
  end

  test "renders tooltip with all options combined" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Full options",
        position: "left",
        color: "error",
        open: true,
        class: "extra-class",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-left"
    assert result =~ "tooltip-error"
    assert result =~ "tooltip-open"
    assert result =~ "extra-class"
    assert result =~ ~s[data-tip="Full options"]
  end

  test "renders tooltip with HTML entities in content" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Use < and > carefully",
        inner_block: inner_block()
      })

    # Phoenix escapes HTML entities in attributes
    assert result =~ "data-tip="
    assert result =~ "&lt;"
    assert result =~ "&gt;"
  end

  test "renders tooltip with long content" do
    long_text = String.duplicate("word ", 50) |> String.trim()

    result =
      render_component(&dm_tooltip/1, %{
        content: long_text,
        inner_block: inner_block()
      })

    assert result =~ "data-tip="
  end

  test "renders tooltip with all positions in loop" do
    for pos <- ~w(top bottom left right) do
      result =
        render_component(&dm_tooltip/1, %{
          content: "Tip",
          position: pos,
          inner_block: inner_block()
        })

      assert result =~ "tooltip-#{pos}"
    end
  end

  test "renders tooltip with inner block content" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        inner_block: inner_block()
      })

    assert result =~ "Hover me"
  end

  test "renders tooltip with rest attribute aria-describedby" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Help",
        "aria-describedby": "help-text",
        inner_block: inner_block()
      })

    assert result =~ ~s[aria-describedby="help-text"]
  end

  test "renders tooltip base class is always present" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        position: "bottom",
        color: "warning",
        open: true,
        class: "extra",
        inner_block: inner_block()
      })

    # The base "tooltip" class should always be in the class list
    assert result =~ "tooltip "
  end

  test "renders tooltip with empty string content" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "",
        inner_block: inner_block()
      })

    assert result =~ ~s[data-tip=""]
  end

  test "renders tooltip without custom class by default" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        inner_block: inner_block()
      })

    # Should have base tooltip classes but not an extra custom class
    assert result =~ "tooltip"
    refute result =~ "my-custom"
  end

  test "renders tooltip without open class by default" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        inner_block: inner_block()
      })

    refute result =~ "tooltip-open"
  end

  test "renders tooltip with secondary color variant" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Secondary tip",
        color: "secondary",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-secondary"
    assert result =~ ~s[data-tip="Secondary tip"]
  end

  test "renders tooltip with accent color variant" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Accent tip",
        color: "accent",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-tertiary"
  end

  test "renders tooltip with success color variant" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Saved!",
        color: "success",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-success"
  end

  test "renders tooltip with info color variant" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Info here",
        color: "info",
        inner_block: inner_block()
      })

    assert result =~ "tooltip-info"
  end

  test "renders tooltip with error color and open combined" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Error!",
        color: "error",
        open: true,
        inner_block: inner_block()
      })

    assert result =~ "tooltip-error"
    assert result =~ "tooltip-open"
  end

  test "renders tooltip with role=tooltip for accessibility" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Helpful text",
        inner_block: inner_block()
      })

    assert result =~ ~s[role="tooltip"]
  end

  test "renders visually hidden span with tooltip content for screen readers" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Screen reader text",
        inner_block: inner_block()
      })

    assert result =~ ~s[class="sr-only"]
    assert result =~ ~s[role="tooltip"]
    assert result =~ "Screen reader text"
  end

  test "tooltip span has id and wrapper has aria-describedby linking to it" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Linked tooltip",
        id: "my-tip",
        inner_block: inner_block()
      })

    assert result =~ ~s[aria-describedby="my-tip-tooltip"]
    assert result =~ ~s[id="my-tip-tooltip"]
  end

  test "role=tooltip is on hidden span, not on wrapper div" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tooltip text",
        inner_block: inner_block()
      })

    # The wrapper div should NOT have role="tooltip"
    # role="tooltip" should only be on the sr-only span
    [wrapper | _] = String.split(result, "class=\"sr-only\"")
    refute wrapper =~ ~s[role="tooltip"]
  end
end
