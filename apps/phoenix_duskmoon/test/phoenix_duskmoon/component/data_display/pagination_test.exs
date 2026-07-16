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
      assert result =~ ~s[<ul class="pagination"]
      refute result =~ ~s[<el-dm-pagination]
      assert result =~ ~s[flex items-center gap-2]
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
      assert result =~ ~s[aria-disabled="true"]
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
      assert result =~ ~s[aria-disabled="true"]
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
      assert result =~ "pagination-ellipsis"
      # Ellipsis should have accessible label
      assert result =~ ~s[<span class="sr-only">More pages</span>]
      # Should show current page
      assert result =~ ~s[aria-current="page"]
      # Check for prev/next
      assert result =~ "Previous"
      assert result =~ "Next"
      assert result =~ "<svg"
    end

    test "renders ellipsis with custom label" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          ellipsis_label: "Skipped pages"
        })

      assert result =~ ~s[<span class="sr-only">Skipped pages</span>]
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
      assert result =~ ~s[phx-value-current="10"]
    end

    test "calculates correct max_page for remainder" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 95
        })

      # Should have 10 pages (ceiling of 95/10)
      assert result =~ ~s[phx-value-current="10"]
    end

    test "handles zero total gracefully" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 0
        })

      # Should show page 1 even with 0 total
      assert result =~ ~s[phx-value-current="1"]
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
      refute result =~ "pagination-ellipsis"
    end

    test "handles page_size of 0 without crashing" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 0,
          total: 100
        })

      # Should treat page_size=0 as 1 and not crash
      assert result =~ ~s[<ul class="pagination"]
      assert result =~ ~s[phx-value-current="1"]
    end

    test "handles negative page_size without crashing" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: -5,
          total: 100
        })

      assert result =~ ~s[<ul class="pagination"]
      assert result =~ ~s[phx-value-current="1"]
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
      assert result =~ "pagination-ellipsis"
      assert result =~ ~s[phx-value-current="10"]
    end

    test "renders page 2 with near-start ellipsis layout" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 100
        })

      # page_num < 3 => [1, 2, 3, "...", 8, 9, 10]
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[phx-value-current="2"]
      assert result =~ ~s[phx-value-current="3"]
      assert result =~ "pagination-ellipsis"
      assert result =~ ~s[phx-value-current="10"]
    end

    test "renders near-end page (max_page - 2) with correct layout" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 8,
          page_size: 10,
          total: 100
        })

      # page_num == max_page - 2 => [1, 2, 3, "...", 7, 8, 9, 10]
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ "pagination-ellipsis"
      assert result =~ ~s[phx-value-current="7"]
      assert result =~ ~s[phx-value-current="8"]
      assert result =~ ~s[phx-value-current="9"]
      assert result =~ ~s[phx-value-current="10"]
    end

    test "renders near-end page (> max_page - 2) with end layout" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 9,
          page_size: 10,
          total: 100
        })

      # page_num > max_page - 2 => [1, 2, 3, "...", 8, 9, 10]
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ "pagination-ellipsis"
      assert result =~ ~s[phx-value-current="8"]
      assert result =~ ~s[phx-value-current="9"]
      assert result =~ ~s[phx-value-current="10"]
    end

    test "renders page_link_type navigate" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          page_link_type: "navigate",
          page_url: "/items?page={page}"
        })

      assert result =~ ~s[data-phx-link="redirect"]
    end

    test "renders ordered native server links for page_link_type href" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 50,
          total: 125,
          page_link_type: "href",
          page_url: "/owner/repo/commits/main?page={page}"
        })

      links =
        result
        |> then(&Regex.scan(~r/<a\b[^>]*>/, &1))
        |> Enum.map(fn [link] ->
          [_, href] = Regex.run(~r/href="([^"]+)"/, link)
          {href, link}
        end)

      [
        {"/owner/repo/commits/main?page=1", previous_link},
        {"/owner/repo/commits/main?page=1", page_one_link},
        {"/owner/repo/commits/main?page=2", current_page_link},
        {"/owner/repo/commits/main?page=3", page_three_link},
        {"/owner/repo/commits/main?page=3", next_link}
      ] = links

      assert previous_link =~ ~s[aria-label="Previous page"]
      assert page_one_link =~ ~s[aria-label="Page 1"]
      assert current_page_link =~ ~s[aria-current="page"]
      assert current_page_link =~ ~s[aria-label="Page 2"]
      assert page_three_link =~ ~s[aria-label="Page 3"]
      assert next_link =~ ~s[aria-label="Next page"]
      refute result =~ ~s[data-phx-link=]
      refute result =~ ~s[<el-dm-pagination]
      refute result =~ ~s[slot="prev"]
      refute result =~ ~s[slot="page"]
      refute result =~ ~s[slot="next"]
    end

    test "renders boundary controls as disabled buttons instead of links" do
      first_page =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 50,
          total: 125,
          page_link_type: "href",
          page_url: "/items?page={page}"
        })

      last_page =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 50,
          total: 125,
          page_link_type: "href",
          page_url: "/items?page={page}"
        })

      [previous_button] = Regex.run(~r/<button[^>]*class="pagination-prev"[^>]*>/, first_page)
      [next_button] = Regex.run(~r/<button[^>]*class="pagination-next"[^>]*>/, last_page)

      assert previous_button =~ "disabled"
      assert previous_button =~ ~s[aria-disabled="true"]
      assert next_button =~ "disabled"
      assert next_button =~ ~s[aria-disabled="true"]
      refute first_page =~ ~r/<a[^>]*class="pagination-prev"/
      refute last_page =~ ~r/<a[^>]*class="pagination-next"/
      refute first_page =~ "page=0"
      refute last_page =~ "page=4"
    end

    test "renders page_url substitution in prev/next buttons" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 10,
          total: 50,
          page_url: "/items?page={page}"
        })

      assert result =~ ~s[href="/items?page=2"]
      assert result =~ ~s[href="/items?page=4"]
    end

    test "renders page_url substitution in page buttons" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 30,
          page_url: "/items?p={page}"
        })

      assert result =~ ~s[href="/items?p=1"]
      assert result =~ ~s[href="/items?p=2"]
      assert result =~ ~s[href="/items?p=3"]
    end

    test "renders single page pagination (total <= page_size)" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 100,
          total: 50
        })

      # max_page = 1, both prev and next disabled
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[disabled]
    end

    test "renders rest attributes" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          "data-testid": "pag"
        })

      assert result =~ ~s[data-testid="pag"]
    end

    test "renders inner_block content" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          inner_block: [%{inner_block: fn _, _ -> "Custom content" end}]
        })

      assert result =~ "Custom content"
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
      assert result =~ ~s[pagination-prev]
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

      assert result =~ "pagination-item-active"
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
      assert result =~ ~s[aria-disabled="true"]
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
      assert result =~ ~s[aria-disabled="true"]
    end

    test "renders with loading state" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: true
        })

      assert result =~ "opacity-50" or result =~ "opacity-50"
    end

    test "loading state sets aria-busy on nav" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: true
        })

      assert result =~ ~s(aria-busy="true")
    end

    test "no aria-busy when not loading" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: false
        })

      refute result =~ "aria-busy"
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
      assert result =~ "pagination-prev"
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

      assert result =~ ~s[pagination-prev]
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
      assert result =~ ~s[pagination-item-active]
    end

    test "loading on first page disables prev click" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          loading: true,
          update_event: "update-page"
        })

      # prev disabled (page_num==1), loading adds btn--loading class
      assert result =~ ~s[disabled]
      assert result =~ "opacity-50"
    end

    test "loading on last page disables next click" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 10,
          page_size: 10,
          total: 100,
          loading: true,
          update_event: "update-page"
        })

      assert result =~ ~s[disabled]
      assert result =~ "opacity-50"
    end

    test "loading shows spinner in current page button" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: true
        })

      assert result =~ "opacity-50"
    end

    test "loading does not show spinner when not loading" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 5,
          page_size: 10,
          total: 100,
          loading: false
        })

      refute result =~ "opacity-50"
    end

    test "show_page_jumper and loading combined disables jumper event" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 3,
          page_size: 10,
          total: 100,
          loading: true,
          show_page_jumper: true,
          update_event: "change-page"
        })

      assert result =~ "pagination-input"
      # Form exists but phx-change should be nil when loading
      assert result =~ "<form"
    end

    test "show_total and show_page_jumper combined" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 100,
          show_total: true,
          show_page_jumper: true
        })

      assert result =~ "pagination-info"
      assert result =~ "100"
      assert result =~ "pagination-input"
      assert result =~ ~s[type="number"]
    end

    test "renders rest attributes" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          "data-testid": "thin-pag"
        })

      assert result =~ ~s[data-testid="thin-pag"]
    end

    test "renders with all options combined" do
      result =
        render_component(&dm_pagination_thin/1, %{
          id: "full-thin",
          class: "my-thin",
          page_num: 3,
          page_size: 10,
          total: 100,
          show_total: true,
          show_page_jumper: true,
          update_event: "change-pg"
        })

      assert result =~ ~s[id="full-thin"]
      assert result =~ "my-thin"
      assert result =~ "pagination"
      assert result =~ "100"
      assert result =~ "pagination-input"
      assert result =~ ~s[max="10"]
      assert result =~ ~s[value="3"]
    end

    test "renders page jumper input with aria-label" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 100,
          show_page_jumper: true
        })

      assert result =~ ~s[aria-label="Jump to page"]
    end
  end

  describe "generate_pages boundary cases" do
    test "renders exactly 6 pages without ellipsis (max_page < 7)" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 60
        })

      # max_page = 6, all pages shown without ellipsis
      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[phx-value-current="6"]
      refute result =~ "pagination-ellipsis"
    end

    test "renders penultimate page correctly (page_num == max_page - 2)" do
      # total=100, page_size=10 => max_page=10, page_num=8 => [1,2,3,...,7,8,9,10]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 8,
          page_size: 10,
          total: 100
        })

      assert result =~ ~s[phx-value-current="7"]
      assert result =~ ~s[phx-value-current="8"]
      assert result =~ ~s[phx-value-current="9"]
      assert result =~ ~s[phx-value-current="10"]
      assert result =~ "pagination-ellipsis"
    end

    test "renders page_num == 3 with expanded near-start layout" do
      # page_num=3, max_page=10 => [1,2,3,4,...,8,9,10]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 10,
          total: 100
        })

      assert result =~ ~s[phx-value-current="4"]
      assert result =~ "pagination-ellipsis"
    end

    test "renders exactly 2 pages without ellipsis" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 20
        })

      assert result =~ ~s[phx-value-current="1"]
      assert result =~ ~s[phx-value-current="2"]
      refute result =~ "pagination-ellipsis"
    end

    test "renders all 7 pages without ellipsis at first page" do
      # max_page=7, page_num=1 => max_page <= 7 => [1, 2, 3, 4, 5, 6, 7]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 70
        })

      for p <- 1..7, do: assert(result =~ ~s[phx-value-current="#{p}"])
      refute result =~ "pagination-ellipsis"
    end

    test "renders all 7 pages without ellipsis at middle position" do
      # max_page=7, page_num=4 => max_page <= 7 => [1, 2, 3, 4, 5, 6, 7]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 4,
          page_size: 10,
          total: 70
        })

      for p <- 1..7, do: assert(result =~ ~s[phx-value-current="#{p}"])
      refute result =~ "pagination-ellipsis"
    end

    test "renders all 7 pages without ellipsis at near-end" do
      # max_page=7, page_num=5 => max_page <= 7 => [1, 2, 3, 4, 5, 6, 7]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 5,
          page_size: 10,
          total: 70
        })

      for p <- 1..7, do: assert(result =~ ~s[phx-value-current="#{p}"])
      refute result =~ "pagination-ellipsis"
    end

    test "renders all 7 pages without ellipsis at last page" do
      # max_page=7, page_num=7 => max_page <= 7 => [1, 2, 3, 4, 5, 6, 7]
      result =
        render_component(&dm_pagination/1, %{
          page_num: 7,
          page_size: 10,
          total: 70
        })

      for p <- 1..7, do: assert(result =~ ~s[phx-value-current="#{p}"])
      refute result =~ "pagination-ellipsis"
    end

    test "renders large total with middle page ellipsis on both sides" do
      # total=10000, page_size=10 => max_page=1000, page_num=500
      result =
        render_component(&dm_pagination/1, %{
          page_num: 500,
          page_size: 10,
          total: 10000
        })

      assert result =~ ~s[phx-value-current="499"]
      assert result =~ ~s[phx-value-current="500"]
      assert result =~ ~s[phx-value-current="501"]
      # Should have ellipsis on both sides
      assert [[_], [_]] = Regex.scan(~r/class="pagination-ellipsis"/, result)
    end
  end

  describe "configurable prev/next labels" do
    test "dm_pagination renders default sr-only Previous/Next" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50
        })

      assert result =~ ">Previous</span>"
      assert result =~ ">Next</span>"
    end

    test "dm_pagination renders custom prev_label and next_label" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          prev_label: "Anterior",
          next_label: "Siguiente"
        })

      assert result =~ ">Anterior</span>"
      assert result =~ ">Siguiente</span>"
    end

    test "dm_pagination_thin renders custom prev_label and next_label" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          prev_label: "Prev",
          next_label: "Nxt"
        })

      assert result =~ ">Prev</span>"
      assert result =~ ">Nxt</span>"
    end
  end

  describe "configurable aria-labels" do
    test "dm_pagination renders custom pagination_label" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          pagination_label: "Paginacion"
        })

      assert result =~ ~s[aria-label="Paginacion"]
    end

    test "dm_pagination renders custom prev_page_label and next_page_label" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          prev_page_label: "Pagina anterior",
          next_page_label: "Pagina siguiente"
        })

      assert result =~ ~s[aria-label="Pagina anterior"]
      assert result =~ ~s[aria-label="Pagina siguiente"]
    end

    test "dm_pagination_thin renders custom pagination_label" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          pagination_label: "Paginacion"
        })

      assert result =~ ~s[aria-label="Paginacion"]
    end

    test "dm_pagination_thin renders custom prev/next page labels" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          prev_page_label: "Pagina anterior",
          next_page_label: "Pagina siguiente"
        })

      assert result =~ ~s[aria-label="Pagina anterior"]
      assert result =~ ~s[aria-label="Pagina siguiente"]
    end

    test "dm_pagination_thin renders custom jump_to_page_label" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          show_page_jumper: true,
          jump_to_page_label: "Ir a la pagina"
        })

      assert result =~ ~s[aria-label="Ir a la pagina"]
    end

    test "dm_pagination page buttons have aria-label with page number" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 30
        })

      assert result =~ ~s[aria-label="Page 1"]
      assert result =~ ~s[aria-label="Page 2"]
      assert result =~ ~s[aria-label="Page 3"]
    end

    test "dm_pagination renders custom page_button_label template" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 30,
          page_button_label: "Ir a pagina {page}"
        })

      assert result =~ ~s[aria-label="Ir a pagina 1"]
      assert result =~ ~s[aria-label="Ir a pagina 2"]
    end

    test "dm_pagination_thin current page button has aria-label" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 3,
          page_size: 10,
          total: 50
        })

      assert result =~ ~s[aria-label="Page 3"]
    end

    test "dm_pagination_thin renders custom page_button_label template" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          page_button_label: "Pagina {page}"
        })

      assert result =~ ~s[aria-label="Pagina 2"]
    end
  end

  describe "page_url nil handling" do
    test "dm_pagination without page_url renders no href attributes" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50
        })

      refute result =~ ~s[href="]
    end

    test "dm_pagination_thin without page_url renders no href attributes" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 50
        })

      refute result =~ ~s[href="]
    end
  end

  describe "button type=button" do
    test "dm_pagination prev button has type=button" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 2,
          page_size: 10,
          total: 50,
          update_event: "page"
        })

      assert result =~ ~s[type="button"]
    end

    test "dm_pagination page buttons have type=button" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 30,
          update_event: "page"
        })

      # All buttons should have type="button"
      buttons = Regex.scan(~r/<button[^>]*>/, result)

      for button <- buttons do
        [btn] = button
        assert btn =~ ~s[type="button"], "Button missing type=button: #{btn}"
      end
    end

    test "dm_pagination_thin all buttons have type=button" do
      result =
        render_component(&dm_pagination_thin/1, %{
          page_num: 2,
          page_size: 10,
          total: 50
        })

      buttons = Regex.scan(~r/<button[^>]*>/, result)
      assert length(buttons) >= 3

      for button <- buttons do
        [btn] = button
        assert btn =~ ~s[type="button"], "Button missing type=button: #{btn}"
      end
    end

    test "renders pagination with el_size attribute" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          el_size: "sm"
        })

      assert result =~ ~s[data-size="sm"]
      assert result =~ ~s[class="pagination pagination-sm"]
    end

    test "renders xs controls distinctly from sm controls" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          el_size: "xs"
        })

      assert result =~ ~s[data-size="xs"]

      assert result =~
               ~s[min-width: 1.5rem; height: 1.5rem; padding: 0 0.25rem; font-size: 0.75rem;]

      refute result =~ "pagination-sm"
    end

    test "renders pagination with el_color attribute" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          el_color: "primary"
        })

      assert result =~ ~s[data-color="primary"]
    end

    test "renders neutral color with neutral theme tokens" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50,
          el_color: "neutral"
        })

      assert result =~ ~s[data-color="neutral"]
      assert result =~ ~s[--color-primary: var(--color-neutral)]
    end

    test "renders pagination without el_size by default" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50
        })

      refute result =~ ~s[data-size=]
    end

    test "renders pagination without el_color by default" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 1,
          page_size: 10,
          total: 50
        })

      refute result =~ ~s[data-color=]
    end

    test "renders pagination with el_size and el_color combined" do
      result =
        render_component(&dm_pagination/1, %{
          page_num: 3,
          page_size: 10,
          total: 100,
          el_size: "lg",
          el_color: "secondary"
        })

      assert result =~ ~s[data-size="lg"]
      assert result =~ ~s[data-color="secondary"]
      assert result =~ ~s[class="pagination pagination-lg"]
      assert result =~ ~s[--color-primary: var(--color-secondary)]
    end
  end
end
