defmodule PhoenixDuskmoon.Component.Layout.SplitPaneTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.SplitPane

  defp render_split(attrs) do
    render_component(
      &dm_split_pane/1,
      Map.merge(
        %{
          id: "storage",
          primary: [%{inner_block: fn _, _ -> "Folders" end}],
          inner_block: [%{inner_block: fn _, _ -> "Files" end}]
        },
        attrs
      )
    )
  end

  test "renders native LiveView-owned panes and a named separator controlling the primary pane" do
    html = render_split(%{resize_label: "Resize folders", primary_class: "p-4", title: "Browser"})
    document = LazyHTML.from_fragment(html)
    separator = LazyHTML.query(document, "[role=separator]")

    for {name, value} <- [
          {"id", "storage-separator"},
          {"aria-label", "Resize folders"},
          {"aria-controls", "storage-primary"},
          {"aria-orientation", "vertical"},
          {"aria-valuemin", "160"},
          {"aria-valuemax", "480"},
          {"aria-valuenow", "280"},
          {"aria-valuetext", "280 pixels"},
          {"tabindex", "-1"}
        ] do
      assert LazyHTML.attribute(separator, name) == [value]
    end

    assert html =~ ~s(phx-hook="DuskmoonSplitPane")
    assert html =~ ~s(title="Browser")
    assert html =~ "dm-split-pane-primary p-4"
    assert html =~ "Folders"
    assert html =~ "Files"
    assert LazyHTML.attribute(separator, "hidden") == [""]
    refute html =~ "phx-update"
    refute html =~ "phx-click"
    refute html =~ "el-dm-"
  end

  test "uses initial width only within the configured bounds" do
    assert render_split(%{initial_width: 50, min_width: 200, max_width: 350}) =~
             ~s(data-initial-width="200")

    assert render_split(%{initial_width: 800, max_width: 350}) =~
             ~s(data-initial-width="350")

    html = render_split(%{min_secondary_width: 300, stack_at: 720})
    assert html =~ ~s(data-min-secondary-width="300")
    assert html =~ ~s(data-stack-at="720")
  end

  test "rejects invalid pixel bounds instead of shipping inconsistent ARIA ranges" do
    assert_raise ArgumentError, "max_width must be at least min_width", fn ->
      render_split(%{min_width: 300, max_width: 200})
    end

    for {attr, value} <- [min_width: -1, max_width: "400", initial_width: 1.5, stack_at: nil] do
      assert_raise ArgumentError, ~r/nonnegative integer/, fn ->
        render_split(%{attr => value})
      end
    end
  end
end
