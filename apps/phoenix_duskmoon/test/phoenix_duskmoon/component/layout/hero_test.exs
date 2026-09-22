defmodule PhoenixDuskmoon.Component.Layout.HeroTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.Hero

  test "layers an assistive-technology-hidden overlay before the content" do
    html =
      render_component(&dm_hero/1, %{
        id: "welcome",
        align: "start",
        "aria-label": "Welcome",
        overlay: [%{inner_block: fn _, _ -> "Decoration" end}],
        inner_block: [%{inner_block: fn _, _ -> "Page heading" end}]
      })

    assert html =~ ~s(<section id="welcome" class="hero hero-start" aria-label="Welcome">)

    assert html =~
             ~r/class="hero-overlay" aria-hidden="true">\s*Decoration\s*<\/div>\s*<div class="hero-content\s*">Page heading<\/div>/
  end

  test "omits the overlay when absent and forwards content layout classes" do
    html =
      render_component(&dm_hero/1, %{
        content_class: "flex-col",
        inner_block: [%{inner_block: fn _, _ -> "Content" end}]
      })

    refute html =~ "hero-overlay"
    assert html =~ ~s(<div class="hero-content flex-col">Content</div>)
  end
end
