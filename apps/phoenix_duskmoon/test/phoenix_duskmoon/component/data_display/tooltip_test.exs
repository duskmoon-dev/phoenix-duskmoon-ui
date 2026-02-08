defmodule PhoenixDuskmoon.Component.DataDisplay.TooltipTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip

  test "renders basic tooltip" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Help text",
        inner_block: %{inner_block: fn _, _ -> "Hover me" end}
      })

    assert result =~ "tooltip"
    assert result =~ ~s[data-tip="Help text"]
  end

  test "renders tooltip with position" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Bottom tip",
        position: "bottom",
        inner_block: %{inner_block: fn _, _ -> "Target" end}
      })

    assert result =~ "tooltip"
    assert result =~ "tooltip-bottom"
  end

  test "renders tooltip with color" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Success tip",
        color: "success",
        inner_block: %{inner_block: fn _, _ -> "Target" end}
      })

    assert result =~ "tooltip"
    assert result =~ "tooltip-success"
  end

  test "renders tooltip with custom class" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Custom",
        class: "my-tip",
        inner_block: %{inner_block: fn _, _ -> "Target" end}
      })

    assert result =~ "my-tip"
  end
end
