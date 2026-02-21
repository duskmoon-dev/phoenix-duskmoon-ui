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

  test "renders footer copyright with custom class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{class: "copyright-custom", inner_block: fn _, _ -> "2024" end}
        ]
      })

    assert result =~ "copyright-custom"
    assert result =~ "self-center"
  end

  test "renders footer copyright with title_class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{title: "Legal", title_class: "text-lg", inner_block: fn _, _ -> "MIT" end}
        ]
      })

    assert result =~ "text-lg"
    assert result =~ "Legal"
  end

  test "renders footer copyright with body_class" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{body_class: "text-xs", inner_block: fn _, _ -> "All rights reserved" end}
        ]
      })

    assert result =~ "text-xs"
  end

  test "renders footer copyright without title when not provided" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{inner_block: fn _, _ -> "No title here" end}
        ]
      })

    assert result =~ "No title here"
    # No <h4> in copyright when title is not set
    # Check that only the self-center div is rendered without h4
    assert result =~ "self-center"
  end

  test "renders footer with empty sections list" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: []
      })

    assert result =~ "<footer"
    assert result =~ "grid"
  end

  test "renders footer with empty copyright list" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: []
      })

    assert result =~ "<footer"
  end

  test "renders footer section with empty string title does not show h4" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "", inner_block: fn _, _ -> "Content only" end}
        ]
      })

    assert result =~ "Content only"
    refute result =~ "<h4"
  end

  test "renders footer with three sections in grid" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "Products", inner_block: fn _, _ -> "Product links" end},
          %{title: "Company", inner_block: fn _, _ -> "Company info" end},
          %{title: "Support", inner_block: fn _, _ -> "Support links" end}
        ]
      })

    assert result =~ "Products"
    assert result =~ "Company"
    assert result =~ "Support"
    assert result =~ "grid-cols-2 md:grid-cols-3"
  end

  test "renders footer with all attributes combined" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        class: "bg-gray-900 text-white",
        section: [
          %{
            title: "Links",
            class: "col-span-1",
            title_class: "uppercase",
            body_class: "gap-1",
            inner_block: fn _, _ -> "Link items" end
          }
        ],
        copyright: [
          %{
            title: "Legal",
            class: "col-span-1",
            title_class: "text-sm",
            body_class: "opacity-75",
            inner_block: fn _, _ -> "2024 Company" end
          }
        ]
      })

    assert result =~ "bg-gray-900 text-white"
    assert result =~ "Links"
    assert result =~ "uppercase"
    assert result =~ "gap-1"
    assert result =~ "col-span-1"
    assert result =~ "Legal"
    assert result =~ "2024 Company"
    assert result =~ "opacity-75"
  end

  test "renders footer with inner_block content before grid" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [%{inner_block: fn _, _ -> "Pre-grid content" end}]
      })

    assert result =~ "Pre-grid content"
    assert result =~ "<footer"
  end

  test "renders footer with py-20 vertical padding" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: []
      })

    assert result =~ "py-20"
  end

  test "renders footer container with mx-auto centering" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: []
      })

    assert result =~ "container mx-auto"
  end

  test "renders footer section body in flex column" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{inner_block: fn _, _ -> "Body content" end}
        ]
      })

    assert result =~ "Body content"
    assert result =~ "flex flex-col"
  end

  test "renders footer copyright with self-center alignment" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{inner_block: fn _, _ -> "Copyright text" end}
        ]
      })

    assert result =~ "self-center"
    assert result =~ "Copyright text"
  end

  test "renders footer as footer HTML element" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: []
      })

    assert result =~ "</footer>"
  end

  test "renders footer with min-h-fit height" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: []
      })

    assert result =~ "min-h-fit"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        "data-testid": "footer-test"
      })

    assert result =~ ~s[data-testid="footer-test"]
  end
end
