defmodule PhoenixDuskmoon.Component.Fun.SpotlightSearchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.SpotlightSearch

  defp base_attrs(overrides \\ %{}) do
    Map.merge(%{id: "spotlight", phx_target: nil}, overrides)
  end

  test "renders dialog element with id" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ ~s[<dialog id="spotlight"]
    assert result =~ "dm-fun-spotlight-search"
    assert result =~ "dm-modal"
  end

  test "renders search input with default placeholder" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ ~s[placeholder="Search..."]
    assert result =~ ~s[type="text"]
    assert result =~ ~s[autocomplete="off"]
  end

  test "renders search input with custom placeholder" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{placeholder: "Quick search..."})
      )

    assert result =~ ~s[placeholder="Quick search..."]
  end

  test "renders dialog with role and aria-label for accessibility" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ ~s[role="dialog"]
    assert result =~ ~s[aria-label="Spotlight search"]
  end

  test "renders search input with aria-label matching placeholder" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{placeholder: "Find anything..."})
      )

    assert result =~ ~s[aria-label="Find anything..."]
  end

  test "renders spotlight input container" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ "dm-fun-spotlight-input"
    assert result =~ "dm-modal__box"
  end

  test "renders search icon svg" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ "<svg"
    assert result =~ "M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
  end

  test "renders close button when not loading" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ "spotlight_close"
    assert result =~ "M6 18L18 6M6 6l12 12"
  end

  test "renders loading state" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs(%{loading: true}))

    assert result =~ "dm-fun-spotlight-loading"
  end

  test "renders open dialog" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs(%{open: true}))

    assert result =~ ~s[<dialog id="spotlight" open]
  end

  test "renders with suggestions" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{
              icon: "search",
              label: "Search users",
              description: "Find user accounts",
              action: "navigate_users"
            },
            %{
              icon: "file",
              label: "Search docs",
              description: nil,
              action: "navigate_docs"
            }
          ]
        })
      )

    assert result =~ "Search users"
    assert result =~ "navigate_users"
    assert result =~ "Find user accounts"
    assert result =~ "Search docs"
    assert result =~ "dm-fun-spotlight-suggestion-list"
    assert result =~ "dm-fun-spotlight-suggestion-list-item"
  end

  test "renders suggestion with phx-click spotlight_select" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{icon: "x", label: "Test", description: nil, action: nil}
          ]
        })
      )

    assert result =~ "spotlight_select"
    assert result =~ ~s[phx-value-index="0"]
  end

  test "renders keyboard shortcut indicator" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ "dm-kbd"
    assert result =~ "cmd+k"
  end

  test "renders custom keyboard shortcut" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{shortcut: "ctrl+k"})
      )

    assert result =~ "ctrl+k"
  end

  test "renders with custom class" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{class: "custom-spotlight"})
      )

    assert result =~ "custom-spotlight"
  end

  test "renders with rest attributes" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{"data-testid": "global-search"})
      )

    assert result =~ "data-testid=\"global-search\""
  end

  test "renders phx event attributes on input" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    assert result =~ "spotlight_keydown"
    assert result =~ "spotlight_change"
  end

  test "loading state hides close button" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs(%{loading: true}))

    assert result =~ "dm-fun-spotlight-loading"
    refute result =~ "spotlight_close"
  end

  test "loading state hides suggestion list" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          loading: true,
          suggestion: [
            %{icon: "search", label: "Hidden", description: nil, action: nil}
          ]
        })
      )

    refute result =~ "dm-fun-spotlight-suggestion-list-item"
  end

  test "closed dialog does not have open attribute" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs(%{open: false}))

    refute result =~ ~s[<dialog id="spotlight" open]
  end

  test "renders suggestion without description" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{icon: "x", label: "No desc", description: nil, action: "go"}
          ]
        })
      )

    assert result =~ "No desc"
    assert result =~ "go"
  end

  test "renders suggestion without action" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{icon: "x", label: "No action", description: "Has desc", action: nil}
          ]
        })
      )

    assert result =~ "No action"
    assert result =~ "Has desc"
  end

  test "renders multiple suggestions with correct indices" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{icon: "a", label: "First", description: nil, action: nil},
            %{icon: "b", label: "Second", description: nil, action: nil},
            %{icon: "c", label: "Third", description: nil, action: nil}
          ]
        })
      )

    assert result =~ ~s[phx-value-index="0"]
    assert result =~ ~s[phx-value-index="1"]
    assert result =~ ~s[phx-value-index="2"]
    assert result =~ "First"
    assert result =~ "Second"
    assert result =~ "Third"
  end

  test "empty suggestion list renders container but no items" do
    result = render_component(&dm_fun_spotlight_search/1, base_attrs())

    # Empty list is truthy — container renders but no items
    refute result =~ "dm-fun-spotlight-suggestion-list-item"
  end

  test "phx_target is set on dialog" do
    result =
      render_component(&dm_fun_spotlight_search/1, base_attrs(%{phx_target: "#my-component"}))

    assert result =~ ~s[phx-target="#my-component"]
  end

  test "renders suggestion with label only" do
    result =
      render_component(
        &dm_fun_spotlight_search/1,
        base_attrs(%{
          suggestion: [
            %{icon: "x", label: "Just a label", description: nil, action: nil}
          ]
        })
      )

    assert result =~ "Just a label"
    assert result =~ "dm-fun-spotlight-suggestion-list-item"
  end
end
