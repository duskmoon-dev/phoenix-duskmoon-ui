defmodule PhoenixDuskmoon.Component.DataDisplay.ListTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataDisplay.List

  defp basic_items do
    [
      %{__slot__: :item, title: "Item 1", inner_block: fn _, _ -> "" end},
      %{__slot__: :item, title: "Item 2", inner_block: fn _, _ -> "" end},
      %{__slot__: :item, title: "Item 3", inner_block: fn _, _ -> "" end}
    ]
  end

  describe "dm_list basic rendering" do
    test "renders list container" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      assert result =~ "<ul"
      assert result =~ "list"
    end

    test "renders with custom id" do
      result = render_component(&dm_list/1, %{id: "my-list", item: basic_items()})
      assert result =~ ~s(id="my-list")
    end

    test "renders with custom class" do
      result = render_component(&dm_list/1, %{class: "mx-4", item: basic_items()})
      assert result =~ "mx-4"
    end

    test "renders all items" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      assert result =~ "Item 1"
      assert result =~ "Item 2"
      assert result =~ "Item 3"
    end

    test "renders item titles" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      assert result =~ "list-item-title"
    end
  end

  describe "dm_list variants" do
    test "renders bordered" do
      result = render_component(&dm_list/1, %{bordered: true, item: basic_items()})
      assert result =~ "list-bordered"
    end

    test "renders compact" do
      result = render_component(&dm_list/1, %{compact: true, item: basic_items()})
      assert result =~ "list-compact"
    end

    test "renders dense" do
      result = render_component(&dm_list/1, %{dense: true, item: basic_items()})
      assert result =~ "list-dense"
    end

    test "renders hoverable" do
      result = render_component(&dm_list/1, %{hoverable: true, item: basic_items()})
      assert result =~ "list-hoverable"
    end

    test "renders two_line" do
      result = render_component(&dm_list/1, %{two_line: true, item: basic_items()})
      assert result =~ "list-two-line"
    end

    test "renders three_line" do
      result = render_component(&dm_list/1, %{three_line: true, item: basic_items()})
      assert result =~ "list-three-line"
    end
  end

  describe "dm_list item features" do
    test "renders item with subtitle" do
      items = [
        %{
          __slot__: :item,
          title: "Inbox",
          subtitle: "3 new messages",
          inner_block: fn _, _ -> "" end
        }
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "list-item-subtitle"
      assert result =~ "3 new messages"
    end

    test "renders item with icon" do
      items = [
        %{__slot__: :item, title: "Home", icon: "home", inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "list-item-icon"
      assert result =~ "<svg"
    end

    test "renders active item" do
      items = [
        %{__slot__: :item, title: "Active", active: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "list-item-active"
    end

    test "renders disabled item" do
      items = [
        %{__slot__: :item, title: "Disabled", disabled: true, inner_block: fn _, _ -> "" end}
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "list-item-disabled"
    end

    test "renders item with custom class" do
      items = [
        %{
          __slot__: :item,
          title: "Custom",
          class: "text-error",
          inner_block: fn _, _ -> "" end
        }
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "text-error"
    end

    test "renders item inner content" do
      items = [
        %{__slot__: :item, title: "Title", inner_block: fn _, _ -> "Extra content" end}
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "Extra content"
    end
  end

  describe "dm_list subheader" do
    test "renders subheader slot" do
      result =
        render_component(&dm_list/1, %{
          subheader: [
            %{__slot__: :subheader, inner_block: fn _, _ -> "SECTION" end}
          ],
          item: basic_items()
        })

      assert result =~ "list-subheader"
      assert result =~ "SECTION"
    end

    test "no subheader by default" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      refute result =~ "list-subheader"
    end
  end

  describe "dm_list defaults" do
    test "no variant classes by default" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      refute result =~ "list-bordered"
      refute result =~ "list-compact"
      refute result =~ "list-dense"
      refute result =~ "list-hoverable"
      refute result =~ "list-two-line"
      refute result =~ "list-three-line"
    end

    test "no icon element when item has no icon" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      refute result =~ "list-item-icon"
    end

    test "no subtitle element when item has no subtitle" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      refute result =~ "list-item-subtitle"
    end

    test "no active or disabled classes by default" do
      result = render_component(&dm_list/1, %{item: basic_items()})
      refute result =~ "list-item-active"
      refute result =~ "list-item-disabled"
    end
  end

  describe "dm_list edge cases" do
    test "item without title renders no title element" do
      items = [
        %{__slot__: :item, inner_block: fn _, _ -> "Content only" end}
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "Content only"
      refute result =~ "list-item-title"
    end

    test "multiple subheaders" do
      result =
        render_component(&dm_list/1, %{
          subheader: [
            %{__slot__: :subheader, inner_block: fn _, _ -> "Section A" end},
            %{__slot__: :subheader, inner_block: fn _, _ -> "Section B" end}
          ],
          item: basic_items()
        })

      assert result =~ "Section A"
      assert result =~ "Section B"
    end

    test "rest attributes pass through" do
      result =
        render_component(&dm_list/1, %{
          item: basic_items(),
          "data-testid": "my-list"
        })

      assert result =~ ~s[data-testid="my-list"]
    end

    test "combining multiple layout variants" do
      result =
        render_component(&dm_list/1, %{
          bordered: true,
          compact: true,
          hoverable: true,
          item: basic_items()
        })

      assert result =~ "list-bordered"
      assert result =~ "list-compact"
      assert result =~ "list-hoverable"
    end

    test "item with all slot attributes" do
      items = [
        %{
          __slot__: :item,
          title: "Full Item",
          subtitle: "With everything",
          icon: "star",
          active: true,
          class: "special-item",
          inner_block: fn _, _ -> "Extra" end
        }
      ]

      result = render_component(&dm_list/1, %{item: items})
      assert result =~ "Full Item"
      assert result =~ "With everything"
      assert result =~ "list-item-icon"
      assert result =~ "list-item-active"
      assert result =~ "special-item"
      assert result =~ "Extra"
    end
  end

  describe "dm_list combined" do
    test "renders with all options" do
      items = [
        %{
          __slot__: :item,
          title: "Profile",
          subtitle: "View your profile",
          icon: "account",
          active: true,
          inner_block: fn _, _ -> "" end
        },
        %{
          __slot__: :item,
          title: "Settings",
          subtitle: "App preferences",
          icon: "cog",
          inner_block: fn _, _ -> "" end
        }
      ]

      result =
        render_component(&dm_list/1, %{
          id: "nav-list",
          class: "w-64",
          bordered: true,
          hoverable: true,
          two_line: true,
          subheader: [
            %{__slot__: :subheader, inner_block: fn _, _ -> "ACCOUNT" end}
          ],
          item: items
        })

      assert result =~ ~s(id="nav-list")
      assert result =~ "w-64"
      assert result =~ "list-bordered"
      assert result =~ "list-hoverable"
      assert result =~ "list-two-line"
      assert result =~ "ACCOUNT"
      assert result =~ "list-item-active"
      assert result =~ "Profile"
      assert result =~ "View your profile"
      assert result =~ "Settings"
    end
  end
end
