defmodule PhoenixDuskmoon.Component.Fun.SpotlightSearchTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.SpotlightSearch

  test "renders basic spotlight search" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      placeholder: "Search...",
      phx_target: nil
    })

    assert result =~ ~s[<dialog id="spotlight-search" class="dm-fun-spotlight-search modal ]
    assert result =~ ~s[<div class="modal-box p-0">]
    assert result =~ ~s[<div class="dm-fun-spotlight-input">]
    assert result =~ ~s[<input type="text" placeholder="Search..."]
    assert result =~ ~s[autocomplete="off"]
  end

  test "renders spotlight search with suggestions" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      phx_target: nil,
      suggestion: [
        %{
          icon: "search",
          label: "Search users",
          description: "Find and search through user accounts",
          action: "navigate_users"
        },
        %{
          icon: "file",
          label: "Search documents",
          description: "Search through document library",
          action: "navigate_docs"
        }
      ]
    })

    assert result =~ ~s[Search users]
    assert result =~ ~s[navigate_users]
    assert result =~ ~s[Search documents]
    assert result =~ ~s[navigate_docs]
    assert result =~ ~s[dm-fun-spotlight-suggestion-list]
  end

  test "renders spotlight search with loading state" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      loading: true,
      phx_target: nil
    })

    assert result =~ ~s[dm-fun-spotlight-loading]
  end

  test "renders spotlight search with custom placeholder" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      placeholder: "Quick search...",
      phx_target: nil
    })

    assert result =~ ~s[placeholder="Quick search..."]
  end

  test "renders spotlight search with custom classes" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      class: "custom-spotlight",
      phx_target: nil
    })

    assert result =~ ~s[custom-spotlight]
  end

  test "renders open spotlight search" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      open: true,
      phx_target: nil
    })

    assert result =~ ~s[<dialog id="spotlight-search" open]
  end

  test "renders spotlight search with custom keyboard shortcut" do
    result = render_component(&dm_fun_spotlight_search/1, %{
      id: "spotlight-search",
      shortcut: "ctrl+k",
      phx_target: nil
    })

    assert result =~ ~s[<kbd class="kbd kbd-xs">ctrl+k</kbd>]
  end
end