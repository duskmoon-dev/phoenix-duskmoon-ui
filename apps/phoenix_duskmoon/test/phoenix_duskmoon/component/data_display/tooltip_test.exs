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

      assert result =~ "tooltip-#{color}"
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
end
