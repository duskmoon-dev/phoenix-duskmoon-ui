defmodule PhoenixDuskmoon.Component.Navigation.PageFooterTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.PageFooter

  test "renders basic page footer" do
    result = render_component(&dm_page_footer/1, %{inner_block: []})

    assert result =~ "<footer"
  end

  test "renders footer with class" do
    result = render_component(&dm_page_footer/1, %{class: "my-footer", inner_block: []})

    assert result =~ "my-footer"
  end

  test "renders footer with copyright" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        copyright: [
          %{
            title: "Copyright 2024",
            inner_block: fn _, _ -> "All rights reserved" end
          }
        ]
      })

    assert result =~ "Copyright 2024"
    assert result =~ "All rights reserved"
  end

  test "renders footer with sections" do
    result =
      render_component(&dm_page_footer/1, %{
        inner_block: [],
        section: [
          %{title: "Links", inner_block: fn _, _ -> "Link items" end}
        ]
      })

    assert result =~ "Links"
    assert result =~ "Link items"
  end
end
