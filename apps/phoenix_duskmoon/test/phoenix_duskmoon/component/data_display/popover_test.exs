defmodule PhoenixDuskmoon.Component.DataDisplay.PopoverTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataDisplay.Popover

  defp trigger_slot do
    [
      %{
        __slot__: :trigger,
        inner_block: fn _, attrs ->
          escaped_attrs =
            attrs |> Phoenix.HTML.attributes_escape() |> Phoenix.HTML.safe_to_string()

          Phoenix.HTML.raw(~s(<button type="button" #{escaped_attrs}>Trigger</button>))
        end
      }
    ]
  end

  defp inner_block(content \\ "Popover content") do
    [%{__slot__: :inner_block, inner_block: fn _, _ -> content end}]
  end

  test "renders a native popover controlled by an HTML command" do
    result =
      render_component(&dm_popover/1, %{
        id: "account-popover",
        trigger: trigger_slot(),
        inner_block: inner_block()
      })

    assert result =~ ~s[command="toggle-popover"]
    assert result =~ ~s[commandfor="account-popover"]
    assert result =~ ~s[id="account-popover"]
    assert result =~ ~s[popover="auto"]
    assert result =~ ~s[aria-controls="account-popover"]
    assert result =~ "Popover content"
    refute result =~ "<el-dm-popover"
  end

  test "generates a target id when one is omitted" do
    result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
    [_, id] = Regex.run(~r/commandfor="(popover-\d+)"/, result)

    assert result =~ ~s[id="#{id}"]
  end

  test "uses interestfor for hover and focus trigger modes" do
    for trigger_mode <- ~w(hover focus) do
      result =
        render_component(&dm_popover/1, %{
          id: "#{trigger_mode}-popover",
          trigger_mode: trigger_mode,
          trigger: trigger_slot()
        })

      assert result =~ ~s[interestfor="#{trigger_mode}-popover"]
      refute result =~ ~s[command="toggle-popover"]
    end
  end

  test "maps every placement to native popover positioning classes" do
    for placement <-
          ~w(top bottom left right top-start top-end bottom-start bottom-end left-start left-end right-start right-end) do
      result =
        render_component(&dm_popover/1, %{
          placement: placement,
          trigger: trigger_slot()
        })

      [position | alignment] = String.split(placement, "-", parts: 2)
      assert result =~ "popover-#{position}"

      if alignment != [] do
        assert result =~ "popover-#{hd(alignment)}"
      end
    end
  end

  test "uses CSS anchor positioning and the configured offset" do
    result =
      render_component(&dm_popover/1, %{
        id: "positioned",
        offset: 12,
        trigger: trigger_slot()
      })

    assert result =~ "anchor-name: --anchor-positioned"
    assert result =~ "position-anchor: --anchor-positioned; margin: 12px"
  end

  test "renders the optional arrow with the Core CSS contract" do
    result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
    assert result =~ ~s[class="popover-arrow"]

    result = render_component(&dm_popover/1, %{arrow: false, trigger: trigger_slot()})
    assert result =~ "popover-no-arrow"
    refute result =~ ~s[class="popover-arrow"]
  end

  test "supports explicitly controlled open state through the LiveView hook" do
    result =
      render_component(&dm_popover/1, %{
        id: "controlled",
        open: true,
        trigger: trigger_slot()
      })

    assert result =~ ~s[popover="manual"]
    assert result =~ ~s[phx-hook="DuskmoonPopover"]
    assert result =~ ~s[data-open="true"]
  end

  test "passes class and global attributes to the popover surface" do
    result =
      render_component(&dm_popover/1, %{
        class: "custom-pop",
        "data-testid": "info-pop",
        trigger: trigger_slot()
      })

    assert result =~ "custom-pop"
    assert result =~ ~s[data-testid="info-pop"]
  end
end
