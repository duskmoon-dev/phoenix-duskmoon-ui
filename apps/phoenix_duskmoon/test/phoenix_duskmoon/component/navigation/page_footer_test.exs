defmodule PhoenixDuskmoon.Component.Navigation.PageFooterTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.PageFooter

  test "renders basic page footer" do
    result = render_component(&dm_page_footer/1, %{inner_block: []})

    assert result =~ "<footer"
    assert result =~ "</footer>"
  end

  test "renders footer with default layout classes" do
    result = render_component(&dm_page_footer/1, %{inner_block: []})

    assert result =~ "w-full"
    assert result =~ "flex flex-col"
    assert result =~ "py-20"
  end

  test "renders footer with custom class" do
    result =
      render_component(&dm_page_footer/1, %{class: "bg-primary text-white", inner_block: []})

    assert result =~ "bg-primary text-white"
  end

  test "renders footer with section slot" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{inner_block: fn _, _ -> "Section content" end}
        ]
      })

    assert result =~ "Section content"
  end

  test "renders footer section with title" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "Links", inner_block: fn _, _ -> "Link items" end}
        ]
      })

    assert result =~ "<h4"
    assert result =~ "Links"
    assert result =~ "font-bold"
  end

  test "renders footer section without title when empty" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{inner_block: fn _, _ -> "No title content" end}
        ]
      })

    assert result =~ "No title content"
    refute result =~ "<h4"
  end

  test "renders footer section with custom class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{class: "section-custom", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ "section-custom"
  end

  test "renders footer section with title_class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "About", title_class: "text-xl", inner_block: fn _, _ -> "Content" end}
        ]
      })

    assert result =~ "text-xl"
  end

  test "renders footer section with body_class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{body_class: "gap-2", inner_block: fn _, _ -> "Items" end}
        ]
      })

    assert result =~ "gap-2"
  end

  test "renders footer with copyright slot" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{inner_block: fn _, _ -> "2024 All rights reserved" end}
        ]
      })

    assert result =~ "2024 All rights reserved"
    assert result =~ "self-center"
  end

  test "renders footer copyright with title" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{title: "Copyright 2024", inner_block: fn _, _ -> "All rights reserved" end}
        ]
      })

    assert result =~ "Copyright 2024"
    assert result =~ "All rights reserved"
  end

  test "renders footer with multiple sections" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "Links", inner_block: fn _, _ -> "Link items" end},
          %{title: "Resources", inner_block: fn _, _ -> "Resource items" end}
        ]
      })

    assert result =~ "Links"
    assert result =~ "Resources"
    assert result =~ "Link items"
    assert result =~ "Resource items"
  end

  test "renders footer with sections and copyright together" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "Company", inner_block: fn _, _ -> "About us" end}
        ],
        copyright: [
          %{title: "Legal", inner_block: fn _, _ -> "2024" end}
        ]
      })

    assert result =~ "Company"
    assert result =~ "About us"
    assert result =~ "Legal"
    assert result =~ "2024"
  end

  test "renders footer with grid layout" do
    result = render_component(&dm_page_footer/1, %{inner_block: []})

    assert result =~ "grid"
    assert result =~ "container mx-auto"
  end
end
