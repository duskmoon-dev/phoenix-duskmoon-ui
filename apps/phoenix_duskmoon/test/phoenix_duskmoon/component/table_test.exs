defmodule PhoenixDuskmoon.Component.TableTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  @test_data [
    %{name: "Alice", age: 30, city: "New York"},
    %{name: "Bob", age: 25, city: "Los Angeles"},
    %{name: "Charlie", age: 35, city: "Chicago"}
  ]

  defmodule TestComponent do
    use Phoenix.Component
    import PhoenixDuskmoon.Component.Table

    attr(:data, :list, default: [])
    attr(:border, :boolean, default: false)
    attr(:zebra, :boolean, default: false)
    attr(:pin_rows, :boolean, default: false)
    attr(:pin_cols, :boolean, default: false)
    attr(:size, :string, default: nil)
    attr(:compact, :boolean, default: false)
    attr(:stream, :boolean, default: false)
    attr(:id, :string, default: nil)
    attr(:class, :string, default: "")
    attr(:with_caption, :boolean, default: false)
    attr(:with_expand, :boolean, default: false)
    attr(:col_classes, :boolean, default: false)
    attr(:empty, :boolean, default: false)
    attr(:num_cols, :integer, default: 2)

    def render(assigns) do
      ~H"""
      <.dm_table
        id={@id}
        class={@class}
        data={if(@empty, do: [], else: @data)}
        border={@border}
        zebra={@zebra}
        pin_rows={@pin_rows}
        pin_cols={@pin_cols}
        size={@size}
        compact={@compact}
        stream={@stream}
      >
        <:caption :if={@with_caption}>Test Caption</:caption>
        <:col :let={row} label="Name" label_class={if(@col_classes, do: "text-primary")} class={if(@col_classes, do: "font-bold")}>
          <%= row.name %>
        </:col>
        <:col :if={@num_cols >= 2} :let={row} label="Age">
          <%= row.age %>
        </:col>
        <:col :if={@num_cols >= 3} :let={row} label="City">
          <%= row.city %>
        </:col>
        <:expand :if={@with_expand} :let={row}>
          Details: <%= row.city %>
        </:expand>
      </.dm_table>
      """
    end
  end

  describe "dm_table component" do
    test "renders basic table with data" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data
        })

      assert result =~ ~s[role="table"]
      assert result =~ ~s[role="row-group"]
      assert result =~ ~s[role="row"]
      assert result =~ ~s[role="cell"]
      assert result =~ "Alice"
      assert result =~ "Bob"
      assert result =~ "Charlie"
    end

    test "renders table headers" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          num_cols: 3
        })

      assert result =~ ~s[role="columnheader"]
      assert result =~ ">Name<"
      assert result =~ ">Age<"
      assert result =~ ">City<"
    end

    test "renders table with custom id and class" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          id: "custom-table",
          class: "my-table"
        })

      assert result =~ ~s[id="custom-table"]
      assert result =~ "my-table"
    end

    test "renders table with border" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          border: true
        })

      assert result =~ "border"
    end

    test "renders table with zebra striping" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          zebra: true
        })

      assert result =~ "dm-table--zebra"
    end

    test "renders table with pinned rows" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          pin_rows: true
        })

      assert result =~ "dm-table--pin-rows"
    end

    test "renders table with pinned columns" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          pin_cols: true
        })

      assert result =~ "dm-table--pin-cols"
    end

    test "renders table with size variants" do
      for size <- ["xs", "sm", "md", "lg"] do
        result =
          render_component(&TestComponent.render/1, %{
            data: @test_data,
            size: size
          })

        assert result =~ "dm-table--#{size}"
      end
    end

    test "renders compact table" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          compact: true
        })

      assert result =~ "dm-table--compact"
    end

    test "renders table with caption" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          with_caption: true
        })

      assert result =~ ~s[role="caption"]
      assert result =~ "Test Caption"
    end

    test "renders columns with custom classes" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          col_classes: true
        })

      assert result =~ "text-primary"
      assert result =~ "font-bold"
    end

    test "renders empty table with no data" do
      result =
        render_component(&TestComponent.render/1, %{
          data: [],
          empty: true
        })

      assert result =~ ~s[role="table"]
      assert result =~ "Name"
      # Should not have data rows
      refute result =~ "Alice"
    end

    test "renders table with expand slot" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          with_expand: true
        })

      assert result =~ "dm-table__row--expand"
      assert result =~ "Details: New York"
      assert result =~ "Details: Los Angeles"
    end

    test "expand row spans all columns" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          with_expand: true,
          num_cols: 3
        })

      assert result =~ ~s[colspan="3"]
    end

    test "columns have data-label attribute" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data
        })

      assert result =~ ~s[data-label="Name"]
      assert result =~ ~s[data-label="Age"]
    end

    test "renders multiple rows correctly" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data
        })

      # Should have 3 data rows
      assert String.contains?(result, "Alice")
      assert String.contains?(result, "Bob")
      assert String.contains?(result, "Charlie")
    end

    test "thead is hidden on mobile" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data
        })

      assert result =~ "hidden md:table-header-group"
    end

    test "combines multiple styling options" do
      result =
        render_component(&TestComponent.render/1, %{
          data: @test_data,
          border: true,
          zebra: true,
          compact: true,
          size: "lg",
          pin_rows: true,
          pin_cols: true
        })

      assert result =~ "border"
      assert result =~ "dm-table--zebra"
      assert result =~ "dm-table--compact"
      assert result =~ "dm-table--lg"
      assert result =~ "dm-table--pin-rows"
      assert result =~ "dm-table--pin-cols"
    end

    test "renders with stream mode enabled" do
      stream_data = [
        {"row-1", %{name: "Alice", age: 30, city: "NY"}},
        {"row-2", %{name: "Bob", age: 25, city: "LA"}}
      ]

      result =
        render_component(&TestComponent.render/1, %{
          data: stream_data,
          stream: true
        })

      assert result =~ ~s[phx-update="stream"]
      assert result =~ ~s[id="row-1"]
      assert result =~ ~s[id="row-2"]
      assert result =~ "Alice"
      assert result =~ "Bob"
    end
  end
end
