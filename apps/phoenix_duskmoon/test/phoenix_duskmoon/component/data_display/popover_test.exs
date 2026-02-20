defmodule PhoenixDuskmoon.Component.DataDisplay.PopoverTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataDisplay.Popover

  defp trigger_slot do
    [%{__slot__: :trigger, inner_block: fn _, _ -> "Trigger" end}]
  end

  describe "dm_popover basic rendering" do
    test "renders el-dm-popover element" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ "<el-dm-popover"
      assert result =~ "</el-dm-popover>"
    end

    test "renders with custom id" do
      result = render_component(&dm_popover/1, %{id: "my-popover", trigger: trigger_slot()})
      assert result =~ ~s(id="my-popover")
    end

    test "renders with custom class" do
      result = render_component(&dm_popover/1, %{class: "custom-pop", trigger: trigger_slot()})
      assert result =~ "custom-pop"
    end

    test "renders trigger slot" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ ~s(slot="trigger")
      assert result =~ "Trigger"
    end

    test "renders inner_block content" do
      result =
        render_component(&dm_popover/1, %{
          trigger: trigger_slot(),
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Popover content" end}
          ]
        })

      assert result =~ "Popover content"
    end
  end

  describe "dm_popover trigger modes" do
    test "defaults to click trigger" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ ~s(trigger="click")
    end

    test "renders hover trigger" do
      result =
        render_component(&dm_popover/1, %{trigger_mode: "hover", trigger: trigger_slot()})

      assert result =~ ~s(trigger="hover")
    end

    test "renders focus trigger" do
      result =
        render_component(&dm_popover/1, %{trigger_mode: "focus", trigger: trigger_slot()})

      assert result =~ ~s(trigger="focus")
    end
  end

  describe "dm_popover placement" do
    test "defaults to bottom" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ ~s(placement="bottom")
    end

    test "renders top placement" do
      result =
        render_component(&dm_popover/1, %{placement: "top", trigger: trigger_slot()})

      assert result =~ ~s(placement="top")
    end

    test "renders left placement" do
      result =
        render_component(&dm_popover/1, %{placement: "left", trigger: trigger_slot()})

      assert result =~ ~s(placement="left")
    end

    test "renders right placement" do
      result =
        render_component(&dm_popover/1, %{placement: "right", trigger: trigger_slot()})

      assert result =~ ~s(placement="right")
    end

    test "renders bottom-start placement" do
      result =
        render_component(&dm_popover/1, %{placement: "bottom-start", trigger: trigger_slot()})

      assert result =~ ~s(placement="bottom-start")
    end

    test "renders top-end placement" do
      result =
        render_component(&dm_popover/1, %{placement: "top-end", trigger: trigger_slot()})

      assert result =~ ~s(placement="top-end")
    end
  end

  describe "dm_popover offset" do
    test "defaults to 8" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ ~s(offset="8")
    end

    test "renders custom offset" do
      result =
        render_component(&dm_popover/1, %{offset: 16, trigger: trigger_slot()})

      assert result =~ ~s(offset="16")
    end
  end

  describe "dm_popover arrow" do
    test "arrow enabled by default" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      assert result =~ "arrow"
    end

    test "arrow can be disabled" do
      result =
        render_component(&dm_popover/1, %{arrow: false, trigger: trigger_slot()})

      refute result =~ ~s(arrow=")
    end
  end

  describe "dm_popover open state" do
    test "not open by default" do
      result = render_component(&dm_popover/1, %{trigger: trigger_slot()})
      refute result =~ ~s( open=")
    end

    test "renders open when true" do
      result =
        render_component(&dm_popover/1, %{open: true, trigger: trigger_slot()})

      assert result =~ "open"
    end
  end

  describe "dm_popover combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_popover/1, %{
          id: "info-pop",
          class: "z-50",
          trigger_mode: "hover",
          placement: "top-start",
          offset: 12,
          arrow: true,
          open: true,
          trigger: [
            %{__slot__: :trigger, inner_block: fn _, _ -> "Hover me" end}
          ],
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Info text" end}
          ]
        })

      assert result =~ ~s(id="info-pop")
      assert result =~ "z-50"
      assert result =~ ~s(trigger="hover")
      assert result =~ ~s(placement="top-start")
      assert result =~ ~s(offset="12")
      assert result =~ "Hover me"
      assert result =~ "Info text"
    end
  end
end
