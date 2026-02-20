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

  test "renders tab button with phx_click attribute" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", phx_click: "select_tab", inner_block: fn _, _ -> "Tab" end}
        ],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[phx-click="select_tab"]
  end

  test "renders tab button with custom class" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", class: "tab-custom-class", inner_block: fn _, _ -> "Styled Tab" end}
        ],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "tab-custom-class"
  end

  test "renders tab content with custom class" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [
          %{id: "c1", class: "panel-custom", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ "panel-custom"
  end

  test "renders active-index attribute on el-dm-tabs when using index" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_index: 2,
        tab: [
          %{id: "t1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", inner_block: fn _, _ -> "Tab 2" end},
          %{id: "t3", inner_block: fn _, _ -> "Tab 3" end}
        ],
        tab_content: [
          %{id: "c1", inner_block: fn _, _ -> "C1" end},
          %{id: "c2", inner_block: fn _, _ -> "C2" end},
          %{id: "c3", inner_block: fn _, _ -> "C3" end}
        ]
      })

    assert result =~ ~s[active-index="2"]
    assert result =~ "C3"
    refute result =~ "C1"
    refute result =~ "C2"
  end

  test "renders empty tabs and content gracefully" do
    result =
      render_component(&dm_tab/1, %{
        tab: [],
        tab_content: []
      })

    assert result =~ "<el-dm-tabs"
    assert result =~ "</el-dm-tabs>"
  end

  test "renders tab with default horizontal orientation" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[orientation="horizontal"]
  end

  test "renders named tab matching correctly with three tabs" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_name: "middle",
        tab: [
          %{id: "t1", name: "first", inner_block: fn _, _ -> "First" end},
          %{id: "t2", name: "middle", inner_block: fn _, _ -> "Middle" end},
          %{id: "t3", name: "last", inner_block: fn _, _ -> "Last" end}
        ],
        tab_content: [
          %{id: "c1", name: "first", inner_block: fn _, _ -> "First Content" end},
          %{id: "c2", name: "middle", inner_block: fn _, _ -> "Middle Content" end},
          %{id: "c3", name: "last", inner_block: fn _, _ -> "Last Content" end}
        ]
      })

    assert result =~ "Middle Content"
    refute result =~ "First Content"
    refute result =~ "Last Content"
  end

  test "renders tab content with combined content_class and panel class" do
    result =
      render_component(&dm_tab/1, %{
        content_class: "p-4",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [
          %{id: "c1", class: "bg-base-200", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ "p-4"
    assert result =~ "bg-base-200"
  end

  test "renders tabs with all attributes combined" do
    result =
      render_component(&dm_tab/1, %{
        id: "full-tabs",
        class: "my-tab-container",
        header_class: "tab-header",
        content_class: "tab-content",
        orientation: "vertical",
        variant: "boxed",
        size: "lg",
        active_tab_name: "second",
        tab: [
          %{id: "t1", name: "first", class: "tab-a", inner_block: fn _, _ -> "Tab A" end},
          %{id: "t2", name: "second", class: "tab-b", inner_block: fn _, _ -> "Tab B" end}
        ],
        tab_content: [
          %{id: "c1", name: "first", inner_block: fn _, _ -> "Content A" end},
          %{id: "c2", name: "second", inner_block: fn _, _ -> "Content B" end}
        ],
        "data-testid": "full-tab"
      })

    assert result =~ ~s[id="full-tabs"]
    assert result =~ "my-tab-container"
    assert result =~ "tab-header"
    assert result =~ ~s[orientation="vertical"]
    assert result =~ ~s[variant="boxed"]
    assert result =~ ~s[size="lg"]
    assert result =~ ~s[active-name="second"]
    assert result =~ "Content B"
    refute result =~ "Content A"
    assert result =~ "data-testid=\"full-tab\""
  end

  test "renders tab buttons with role tab" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[role="tab"]
  end

  test "renders tab content panel with role tabpanel" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[role="tabpanel"]
  end

  test "renders tablist role on tabs container" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [%{inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[role="tablist"]
  end

  test "renders aria-controls on tab buttons linking to panels" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [
          %{inner_block: fn _, _ -> "Tab 1" end},
          %{inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{inner_block: fn _, _ -> "Content 1" end},
          %{inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    assert result =~ ~s[aria-controls="my-tabs-panel-0"]
    assert result =~ ~s[aria-controls="my-tabs-panel-1"]
  end

  test "renders aria-labelledby on panel linking back to tab" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [%{inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{inner_block: fn _, _ -> "Content 1" end}]
      })

    assert result =~ ~s[aria-labelledby="my-tabs-tab-0"]
    assert result =~ ~s[id="my-tabs-panel-0"]
  end

  test "generates tab button ids from component id" do
    result =
      render_component(&dm_tab/1, %{
        id: "nav-tabs",
        tab: [
          %{inner_block: fn _, _ -> "First" end},
          %{inner_block: fn _, _ -> "Second" end}
        ],
        tab_content: [
          %{inner_block: fn _, _ -> "Content 1" end},
          %{inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    assert result =~ ~s[id="nav-tabs-tab-0"]
    assert result =~ ~s[id="nav-tabs-tab-1"]
  end

  test "user-provided tab id overrides generated id" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [%{id: "custom-tab-id", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[id="custom-tab-id"]
    refute result =~ ~s[id="my-tabs-tab-0"]
  end

  test "user-provided panel id overrides generated id" do
    result =
      render_component(&dm_tab/1, %{
        id: "my-tabs",
        tab: [%{inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "custom-panel-id", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[id="custom-panel-id"]
    refute result =~ ~s[id="my-tabs-panel-0"]
  end

  test "active_tab_name takes precedence over active_tab_index" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_index: 0,
        active_tab_name: "second",
        tab: [
          %{id: "t1", name: "first", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", name: "second", inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{id: "c1", name: "first", inner_block: fn _, _ -> "First Content" end},
          %{id: "c2", name: "second", inner_block: fn _, _ -> "Second Content" end}
        ]
      })

    # active_tab_name should win over active_tab_index
    assert result =~ "Second Content"
    refute result =~ "First Content"
    assert result =~ ~s[active-name="second"]
    refute result =~ ~s[active-index=]
  end

  test "renders tabs without variant or size when nil" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    refute result =~ ~s[variant="]
    refute result =~ ~s[size="]
  end

  test "renders multiple tabs with correct aria-selected states" do
    result =
      render_component(&dm_tab/1, %{
        active_tab_index: 1,
        tab: [
          %{id: "t1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", inner_block: fn _, _ -> "Tab 2" end},
          %{id: "t3", inner_block: fn _, _ -> "Tab 3" end}
        ],
        tab_content: [
          %{id: "c1", inner_block: fn _, _ -> "C1" end},
          %{id: "c2", inner_block: fn _, _ -> "C2" end},
          %{id: "c3", inner_block: fn _, _ -> "C3" end}
        ]
      })

    # Tab 2 (index 1) should be aria-selected, others should be false
    assert result =~ ~s[id="t2"]
    assert result =~ "C2"
  end

  test "renders tab without id does not generate panel/tab ids" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{inner_block: fn _, _ -> "Content" end}]
      })

    # Without a component id, no aria-controls or aria-labelledby
    refute result =~ ~s[aria-controls="]
    refute result =~ ~s[aria-labelledby="]
  end

  test "tab buttons have type=button to prevent form submission" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{id: "t1", inner_block: fn _, _ -> "Tab 1" end},
          %{id: "t2", inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{id: "c1", inner_block: fn _, _ -> "C1" end},
          %{id: "c2", inner_block: fn _, _ -> "C2" end}
        ]
      })

    # All tab buttons should have type="button"
    buttons = Regex.scan(~r/<button[^>]*>/, result)
    assert length(buttons) >= 2

    for button <- buttons do
      [btn] = button
      assert btn =~ ~s[type="button"], "Tab button missing type=button: #{btn}"
    end
  end

  test "renders aria-orientation on tablist div" do
    result =
      render_component(&dm_tab/1, %{
        orientation: "vertical",
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[aria-orientation="vertical"]
  end

  test "renders default horizontal aria-orientation on tablist" do
    result =
      render_component(&dm_tab/1, %{
        tab: [%{id: "t1", inner_block: fn _, _ -> "Tab" end}],
        tab_content: [%{id: "c1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[aria-orientation="horizontal"]
  end

  test "tabs without id omit aria-controls and aria-labelledby" do
    result =
      render_component(&dm_tab/1, %{
        tab: [
          %{inner_block: fn _, _ -> "Tab 1" end},
          %{inner_block: fn _, _ -> "Tab 2" end}
        ],
        tab_content: [
          %{inner_block: fn _, _ -> "Content 1" end},
          %{inner_block: fn _, _ -> "Content 2" end}
        ]
      })

    refute result =~ ~s[aria-controls="]
    refute result =~ ~s[aria-labelledby="]
  end
end
