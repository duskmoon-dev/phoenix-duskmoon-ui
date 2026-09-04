defmodule PhoenixDuskmoon.Component.DataDisplay.TooltipTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Tooltip

  defp inner_block do
    %{
      inner_block: fn _, attrs ->
        escaped_attrs = attrs |> Phoenix.HTML.attributes_escape() |> Phoenix.HTML.safe_to_string()
        Phoenix.HTML.raw(~s(<button type="button" #{escaped_attrs}>Hover me</button>))
      end
    }
  end

  test "renders a native hint popover linked to an interest invoker" do
    result =
      render_component(&dm_tooltip/1, %{
        id: "save-help",
        content: "Help text",
        inner_block: inner_block()
      })

    assert result =~ ~s[interestfor="save-help-tooltip"]
    assert result =~ ~s[aria-describedby="save-help-tooltip"]
    assert result =~ ~s[id="save-help-tooltip"]
    assert result =~ ~s[popover="hint"]
    assert result =~ ~s[role="tooltip"]
    assert result =~ ~s[title="Help text"]
    refute result =~ "tooltip-content"
  end

  test "generates a target id when one is omitted" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Generated",
        inner_block: inner_block()
      })

    [_, id] = Regex.run(~r/interestfor="(tooltip-\d+)"/, result)
    assert result =~ ~s[id="#{id}"]
  end

  test "renders every position class" do
    for position <- ~w(top bottom left right) do
      result =
        render_component(&dm_tooltip/1, %{
          content: "Tip",
          position: position,
          inner_block: inner_block()
        })

      assert result =~ "tooltip-#{position}"
    end
  end

  test "renders every color class" do
    for color <- ~w(primary secondary tertiary accent info success warning error) do
      result =
        render_component(&dm_tooltip/1, %{
          content: "#{color} tip",
          color: color,
          inner_block: inner_block()
        })

      css_color = if color == "accent", do: "tertiary", else: color
      assert result =~ "tooltip-#{css_color}"
    end
  end

  test "uses matching CSS anchors" do
    result =
      render_component(&dm_tooltip/1, %{
        id: "anchored",
        content: "Tip",
        inner_block: inner_block()
      })

    assert result =~ "anchor-name: --anchor-anchored-tooltip"
    assert result =~ "position-anchor: --anchor-anchored-tooltip"
  end

  test "supports explicitly controlled open state through the LiveView hook" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Always visible",
        open: true,
        inner_block: inner_block()
      })

    assert result =~ ~s[popover="manual"]
    assert result =~ ~s[phx-hook="DuskmoonPopover"]
    assert result =~ ~s[data-open="true"]
  end

  test "escapes tooltip content" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Use < and > carefully",
        inner_block: inner_block()
      })

    assert result =~ "Use &lt; and &gt; carefully"
  end

  test "passes class and global attributes to the tooltip surface" do
    result =
      render_component(&dm_tooltip/1, %{
        content: "Tip",
        class: "custom-tooltip",
        "data-testid": "my-tooltip",
        inner_block: inner_block()
      })

    assert result =~ "custom-tooltip"
    assert result =~ ~s[data-testid="my-tooltip"]
  end
end
