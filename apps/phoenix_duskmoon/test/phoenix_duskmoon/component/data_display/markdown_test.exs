defmodule PhoenixDuskmoon.Component.DataDisplay.MarkdownTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Markdown

  test "remark empty" do
    assert render_component(&dm_markdown/1, content: "value") ==
             ~s[<remark-element class="">value</remark-element>]
  end
end
