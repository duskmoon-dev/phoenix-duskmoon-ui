defmodule PhoenixDuskmoon.Component.Layout.DividerTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.Divider

  test "renders basic divider" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider"
  end

  test "renders divider with text content" do
    result =
      render_component(&dm_divider/1, %{
        inner_block: %{inner_block: fn _, _ -> "OR" end}
      })

    assert result =~ "dm-divider"
    assert result =~ "OR"
  end

  test "renders vertical divider" do
    result = render_component(&dm_divider/1, %{orientation: "vertical"})

    assert result =~ "dm-divider"
    assert result =~ "dm-divider--vertical"
  end

  test "renders divider with variant" do
    result = render_component(&dm_divider/1, %{variant: "primary"})

    assert result =~ "dm-divider--primary"
  end

  test "renders divider with style" do
    result = render_component(&dm_divider/1, %{style: "dashed"})

    assert result =~ "dm-divider--dashed"
  end

  test "renders divider with size" do
    result = render_component(&dm_divider/1, %{size: "lg"})

    assert result =~ "dm-divider--lg"
  end

  test "renders divider with custom class" do
    result = render_component(&dm_divider/1, %{class: "my-divider"})

    assert result =~ "my-divider"
  end
end
