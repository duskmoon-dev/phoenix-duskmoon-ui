defmodule PhoenixDuskmoon.Component.Navigation.TabTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Tab

  test "renders basic tabs" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", name: "tab1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", name: "tab2", inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{id: "c1", name: "tab1", inner_block: fn _, _ -> "Content 1" end},
          %{id: "c2", name: "tab2", inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    assert result =~ "<el-dm-tabs"
    assert result =~ "Tab 1"
    assert result =~ "Tab 2"
    # Only active tab content renders
    assert result =~ "Content 1"
  end

  test "renders tabs with custom class" do
    result =
      render_component(&dm_tab/1, %{
        class: "my-tabs",
        tab: [%{id: "t1", name: "tab1", inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{id: "c1", name: "tab1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "my-tabs"
  end

  test "renders tabs with variant" do
    for variant <- ["lifted", "bordered", "boxed"] do
      result =
        render_component(&dm_tab/1, %{
          variant: variant,
          tab: [%{id: "t1", name: "tab1", inner_block: fn _, _ -> "Tab" end}],
          tab_content: [%{id: "c1", name: "tab1", inner_block: fn _, _ -> "Content" end}]
        })

      assert result =~ ~s[variant="#{variant}"]
    end
  end

  test "renders tabs with active tab by index" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_index: 1,
        tab: [
          %{id: "t1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{id: "c1", inner_block: fn _, _ -> "Content 1" end},
          %{id: "c2", inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    # Content 2 should be rendered (index 1 is active)
    assert result =~ "Content 2"
    # Content 1 should not be rendered
    refute result =~ "Content 1"
  end

  test "renders tabs with active tab by name" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_name: "settings",
        tab: [
          %{id: "t1", name: "profile", inner_block: fn _, _ -> "Profile" end},
          %{id: "t2", name: "settings", inner_block: fn _, _ -> "Settings" end}
        ],
        tab_content: [
          %{id: "c1", name: "profile", inner_block: fn _, _ -> "Profile Content" end},
          %{id: "c2", name: "settings", inner_block: fn _, _ -> "Settings Content" end}
        ]
      })

    assert result =~ "Settings Content"
    refute result =~ "Profile Content"
    assert result =~ ~s[active-name="settings"]
  end

  test "renders tabs with size" do
    for size <- ["xs", "sm", "md", "lg"] do
      result =
        render_component(&dm_tab/1, %{
          size: size,
          tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
          tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
        })

      assert result =~ ~s[size="#{size}"]
    end
  end

  test "renders tabs with vertical orientation" do
    result =
      render_component(&dm_tab/1, %{
        orientation: "vertical",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[orientation="vertical"]
  end

  test "renders tabs with header_class" do
    result =
      render_component(&dm_tab/1, %{
        header_class: "tab-header-custom",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "tab-header-custom"
  end

  test "renders tabs with content_class" do
    result =
      render_component(&dm_tab/1, %{
        content_class: "content-padding",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "content-padding"
  end

  test "renders tab buttons with slot and data attributes" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", name: "first", inner_block: fn _, _ -> "Tab 1" end}
        ],
        tab_content: [
          %{id: "c1", name: "first", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ ~s[slot="tab"]
    assert result =~ ~s[data-tab-name="first"]
    assert result =~ ~s[data-tab-index="0"]
  end

  test "renders tab content with slot and data attributes" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", name: "panel1", inner_block: fn _, _ -> "Tab" end}
        ],
        tab_content: [
          %{id: "c1", name: "panel1", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ ~s[slot="panel"]
    assert result =~ ~s[data-panel-name="panel1"]
    assert result =~ ~s[data-panel-index="0"]
  end

  test "marks active tab with aria-selected" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_index: 0,
        tab: [
          %{id: "t1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{id: "c1", inner_block: fn _, _ -> "Content 1" end},
          %{id: "c2", inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    assert result =~ "aria-selected"
  end

  test "renders tabs with custom id" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[id="my-tabs"]
  end

  test "renders tabs with rest attributes" do
    result =
      render_component(&dm_tab/1, %{
        "data-testid": "tab-component",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[data-testid="tab-component"]
  end
end
