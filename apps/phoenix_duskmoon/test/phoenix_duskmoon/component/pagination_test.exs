defmodule PhoenixDuskmoon.Component.PaginationTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Pagination

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
      assert result =~ ~s[phx-click="update-page"]
      assert result =~ ~s[class="join"]
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
      # Current page should be highlighted
      assert result =~ ~s[btn-primary]
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
      assert result =~ ">10<"
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
      # Should show current page with primary styling
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[btn-primary]
      # Check for prev/next SVG icons
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

      assert result =~ "<code>100</code>"
      # Check for view-dashboard icon SVG path
      assert result =~ "M13,3V9H21V3M13,21H21V11H13M3,21H11V15H3M3,13H11V3H3V13Z"
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
      assert result =~ ">10<"
    end

    test "calculates correct max_page for remainder" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 95
        })

      # Should have 10 pages (ceiling of 95/10)
      assert result =~ ">10<"
    end

    test "handles zero total gracefully" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 0
        })

      # Should show page 1 even with 0 total
      assert result =~ ">1<"
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

      assert result =~ ~s[href="/items?page=1"]
      assert result =~ ~s[href="/items?page=2"]
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

      assert result =~ ~s[href="/items?p=1"]
      assert result =~ ~s[href="/items?p=2"]
    end

    test "shows limited pages when total pages < 7" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50
        })

      # Should show all 5 pages
      assert result =~ ">1<"
      assert result =~ ">2<"
      assert result =~ ">3<"
      assert result =~ ">4<"
      assert result =~ ">5<"
      # No ellipsis needed
      refute result =~ "..."
    end

    test "shows ellipsis when on page 3" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 10,
          total: 100
        })

      # Should show pages 1-4 and last 3 pages with ellipsis
      assert result =~ ">1<"
      assert result =~ ">2<"
      assert result =~ ">3<"
      assert result =~ ">4<"
      assert result =~ "..."
      assert result =~ ">10<"
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
      assert result =~ ~s[class="join"]
      # Check for chevron icons via SVG paths
      assert result =~ "M15.41,16.58L10.83,12L15.41,7.41L14,6L8,12L14,18L15.41,16.58Z"  # chevron-left
      assert result =~ "M8.59,16.58L13.17,12L8.59,7.41L10,6L16,12L10,18L8.59,16.58Z"  # chevron-right
    end

    test "renders current page with primary styling" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100
        })

      assert result =~ "bg-primary text-primary-content"
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
      # Previous button should not have phx-click event
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

      assert result =~ "loading loading-spinner"
      assert result =~ "cursor-wait"
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

      # When loading, should have cursor-wait styling
      assert result =~ "cursor-wait"
      assert result =~ "loading loading-spinner"
    end

    test "renders with show_total enabled" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 250,
          show_total: true
        })

      assert result =~ "<code class=\"font-medium\">250</code>"
      # Check for view-dashboard icon SVG path
      assert result =~ "M13,3V9H21V3M13,21H21V11H13M3,21H11V15H3M3,13H11V3H3V13Z"
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
      # Check for arrow-right-top icon SVG path
      assert result =~ "M20 8L14.5 13.5"
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
      assert result =~ "Math.round"
      assert result =~ "if(this.value&lt;1){this.value=1}"
      assert result =~ "if(this.value&gt;10){this.value=10}"
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

    test "handles edge case with 1 total page" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 5
        })

      # Both prev and next should be disabled
      assert result =~ ~s[disabled]
      # Should show page 1 with primary styling
      assert result =~ ~s[aria-current="page"]
      assert result =~ ~s[bg-primary text-primary-content]
    end
  end
end
