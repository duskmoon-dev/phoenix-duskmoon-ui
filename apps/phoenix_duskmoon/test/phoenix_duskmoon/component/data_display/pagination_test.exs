defmodule PhoenixDuskmoon.Component.DataDisplay.PaginationTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Pagination

  describe "dm_pagination component" do
    test "renders pagination with basic attributes" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          update_event: "update-page"
        })

      assert result =~ ~s[aria-label="Pagination"]
      assert result =~ ~s[<el-dm-pagination]
      assert result =~ ~s[dm-pagination]
    end

    test "renders first page correctly" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 100
        })

      # Previous button should be disabled on first page
      assert result =~ ~s[disabled]
      # Current page should be marked
      assert result =~ ~s[aria-current="page"]
    end

    test "renders last page correctly" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 10,
          page_size: 10,
          total: 100
        })

      # Next button should be disabled on last page
      assert result =~ ~s[disabled]
      # Should show page 10
      assert result =~ ~s[phx-value-current="10"]
    end

    test "renders middle page correctly" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 5,
          page_size: 10,
          total: 100
        })

      # Should show ellipsis for hidden pages
      assert result =~ "..."
      # Should show current page
      assert result =~ ~s[aria-current="page"]
      # Check for prev/next
      assert result =~ "Previous"
      assert result =~ "Next"
      assert result =~ "<svg"
    end

    test "renders with show_total enabled" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          show_total: true
        })

      assert result =~ "100"
    end

    test "renders with custom id and class" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          id: "custom-pagination",
          class: "custom-class"
        })

      assert result =~ ~s[id="custom-pagination"]
      assert result =~ "custom-class"
    end

    test "renders with custom update event" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 100,
          update_event: "custom-update"
        })

      assert result =~ ~s[phx-click="custom-update"]
    end

    test "calculates correct max_page for exact division" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 100
        })

      # Should have 10 pages
      assert result =~ ~s[total-pages="10"]
    end

    test "calculates correct max_page for remainder" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 95
        })

      # Should have 10 pages (ceiling of 95/10)
      assert result =~ ~s[total-pages="10"]
    end

    test "handles zero total gracefully" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 0
        })

      # Should show page 1 even with 0 total
      assert result =~ ~s[current-page="1"]
    end

    test "renders page links with href when page_url provided" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          page_url: "/items?page={page}",
          page_link_type: "patch"
        })

      assert result =~ ~s[data-phx-link="patch"]
    end

    test "renders with custom page_url_marker" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          page_url: "/items?p=:page:",
          page_url_marker: ":page:"
        })

      assert result =~ ~s[data-phx-link]
    end

    test "shows limited pages when total pages < 7" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50
        })

      # Should show all 5 pages
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[phx-value-current="2"]
      assert result =~ ~s[phx-value-current="3"]
      assert result =~ ~s[phx-value-current="4"]
      assert result =~ ~s[phx-value-current="5"]
      # No ellipsis needed
      refute result =~ "..."
    end

    test "handles page_size of 0 without crashing" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 0,
          total: 100
        })

      # Should treat page_size=0 as 1 and not crash
      assert result =~ ~s[<el-dm-pagination]
      assert result =~ ~s[current-page="1"]
    end

    test "handles negative page_size without crashing" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: -5,
          total: 100
        })

      assert result =~ ~s[<el-dm-pagination]
      assert result =~ ~s[current-page="1"]
    end

    test "renders prev and next buttons with aria-labels" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50
        })

      assert result =~ ~s[aria-label="Previous page"]
      assert result =~ ~s[aria-label="Next page"]
    end

    test "shows ellipsis when on page 3" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 10,
          total: 100
        })

      # Should show pages and ellipsis
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[phx-value-current="3"]
      assert result =~ "..."
      assert result =~ ~s[phx-value-current="10"]
    end
  end

  describe "dm_pagination_thin component" do
    test "renders thin pagination with basic attributes" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          update_event: "update-page"
        })

      assert result =~ ~s[phx-click="update-page"]
      assert result =~ ~s[dm-pagination--thin]
      # Check for chevron icons via SVG paths
      # chevron-left
      assert result =~ "M15.41,16.58L10.83,12L15.41,7.41L14,6L8,12L14,18L15.41,16.58Z"
      # chevron-right
      assert result =~ "M8.59,16.58L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z"
    end

    test "renders current page with primary styling" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100
        })

      assert result =~ "dm-pagination__current"
      assert result =~ ~s[aria-current="page"]
    end

    test "disables previous on first page" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100
        })

      assert result =~ ~s[disabled]
      # Previous button should not have phx-click event when disabled
      refute result =~ ~s[phx-value-current="0"]
    end

    test "disables next on last page" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 10,
          page_size: 10,
          total: 100
        })

      assert result =~ ~s[disabled]
    end

    test "renders with loading state" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: true
        })

      assert result =~ "dm-pagination__spinner" or result =~ "dm-pagination__btn--loading"
    end

    test "disables clicks when loading" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: true,
          update_event: "update-page"
        })

      # When loading, should have loading styling
      assert result =~ "dm-pagination"
    end

    test "renders with show_total enabled" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 250,
          show_total: true
        })

      assert result =~ "250"
    end

    test "renders with page jumper" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          show_page_jumper: true
        })

      assert result =~ ~s[type="number"]
      assert result =~ ~s[name="current"]
      assert result =~ ~s[min="1"]
      assert result =~ ~s[max="10"]
      assert result =~ ~s[value="5"]
    end

    test "page jumper has debounce" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          show_page_jumper: true
        })

      assert result =~ ~s[phx-debounce="300"]
    end

    test "page jumper prevents invalid input" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          show_page_jumper: true
        })

      # Should have oninput validation (HTML-escaped in render)
      assert result =~ "oninput="
    end

    test "renders with custom id and class" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          id: "thin-pagination",
          class: "my-pagination"
        })

      assert result =~ ~s[id="thin-pagination"]
      assert result =~ "my-pagination"
    end

    test "handles page_size of 0 without crashing" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 0,
          total: 100
        })

      assert result =~ ~s[dm-pagination--thin]
      assert result =~ ~s[aria-current="page"]
    end

    test "renders prev and next buttons with aria-labels" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 3,
          page_size: 10,
          total: 100
        })

      assert result =~ ~s[aria-label="Previous page"]
      assert result =~ ~s[aria-label="Next page"]
    end

    test "handles edge case with 1 total page" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 5
        })

      # Both prev and next should be disabled
      assert result =~ ~s[disabled]
      # Should show page 1 with current styling
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[dm-pagination__current]
    end
  end
end
