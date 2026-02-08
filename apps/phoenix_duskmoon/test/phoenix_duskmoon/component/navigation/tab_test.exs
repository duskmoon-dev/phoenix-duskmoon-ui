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
    result =
      render_component(&dm_tab/1, %{
        variant: "bordered",
        tab: [%{id: "t1", name: "tab1", inner_block: fn _, _ -> "Tab 1" end}],
        tab_content: [%{id: "c1", name: "tab1", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "<el-dm-tabs"
  end
end
