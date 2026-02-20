defmodule PhoenixDuskmoon.Component.Layout.BottomSheetTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Layout.BottomSheet

  describe "dm_bottom_sheet basic rendering" do
    test "renders el-dm-bottom-sheet element" do
      result = render_component(&dm_bottom_sheet/1, %{})
      assert result =~ "<el-dm-bottom-sheet"
      assert result =~ "</el-dm-bottom-sheet>"
    end

    test "renders with custom id" do
      result = render_component(&dm_bottom_sheet/1, %{id: "my-sheet"})
      assert result =~ ~s(id="my-sheet")
    end

    test "renders with custom class" do
      result = render_component(&dm_bottom_sheet/1, %{class: "custom-sheet"})
      assert result =~ "custom-sheet"
    end

    test "renders inner_block content" do
      result =
        render_component(&dm_bottom_sheet/1, %{
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Sheet content" end}
          ]
        })

      assert result =~ "Sheet content"
    end
  end

  describe "dm_bottom_sheet open state" do
    test "renders open attribute when true" do
      result = render_component(&dm_bottom_sheet/1, %{open: true})
      assert result =~ "open"
    end

    test "no open attribute by default" do
      result = render_component(&dm_bottom_sheet/1, %{})
      # The attribute should not be present when false
      refute result =~ ~s( open=")
      refute result =~ ~s( open )
    end
  end

  describe "dm_bottom_sheet modal" do
    test "renders modal attribute when true" do
      result = render_component(&dm_bottom_sheet/1, %{modal: true})
      assert result =~ "modal"
    end

    test "no modal attribute by default" do
      result = render_component(&dm_bottom_sheet/1, %{})
      refute result =~ "modal"
    end
  end

  describe "dm_bottom_sheet persistent" do
    test "renders persistent attribute when true" do
      result = render_component(&dm_bottom_sheet/1, %{persistent: true})
      assert result =~ "persistent"
    end

    test "no persistent attribute by default" do
      result = render_component(&dm_bottom_sheet/1, %{})
      refute result =~ "persistent"
    end
  end

  describe "dm_bottom_sheet snap_points" do
    test "renders snap-points attribute" do
      result = render_component(&dm_bottom_sheet/1, %{snap_points: "25,50,100"})
      assert result =~ ~s(snap-points="25,50,100")
    end

    test "no snap-points by default" do
      result = render_component(&dm_bottom_sheet/1, %{})
      refute result =~ "snap-points"
    end
  end

  describe "dm_bottom_sheet header slot" do
    test "renders header slot content" do
      result =
        render_component(&dm_bottom_sheet/1, %{
          header: [
            %{__slot__: :header, inner_block: fn _, _ -> "Sheet Title" end}
          ]
        })

      assert result =~ ~s(slot="header")
      assert result =~ "Sheet Title"
    end

    test "no header div when slot is empty" do
      result = render_component(&dm_bottom_sheet/1, %{})
      refute result =~ ~s(slot="header")
    end
  end

  describe "dm_bottom_sheet combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_bottom_sheet/1, %{
          id: "action-sheet",
          class: "z-50",
          open: true,
          modal: true,
          persistent: true,
          snap_points: "30,60,100",
          header: [
            %{__slot__: :header, inner_block: fn _, _ -> "Actions" end}
          ],
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Choose action" end}
          ]
        })

      assert result =~ ~s(id="action-sheet")
      assert result =~ "z-50"
      assert result =~ ~s(snap-points="30,60,100")
      assert result =~ "Actions"
      assert result =~ "Choose action"
    end
  end
end
