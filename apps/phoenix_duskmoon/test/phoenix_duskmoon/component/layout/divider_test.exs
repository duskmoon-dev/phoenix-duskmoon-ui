defmodule PhoenixDuskmoon.Component.Layout.DividerTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.Divider

  test "renders basic divider with dm-divider class" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider"
  end

  test "renders divider with role separator" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ ~s[role="separator"]
  end

  test "renders divider with default horizontal orientation" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider--horizontal"
    assert result =~ ~s[aria-orientation="horizontal"]
  end

  test "renders vertical divider" do
    result = render_component(&dm_divider/1, %{orientation: "vertical"})

    assert result =~ "dm-divider--vertical"
    assert result =~ ~s[aria-orientation="vertical"]
  end

  test "renders divider with default variant base" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider--base"
  end

  test "renders divider with all variant options" do
    for variant <- ~w(base primary secondary accent info success warning error) do
      result = render_component(&dm_divider/1, %{variant: variant})
      assert result =~ "dm-divider--#{variant}"
    end
  end

  test "renders divider with default style solid" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider--solid"
  end

  test "renders divider with all style options" do
    for style <- ~w(solid dashed dotted) do
      result = render_component(&dm_divider/1, %{style: style})
      assert result =~ "dm-divider--#{style}"
    end
  end

  test "renders divider with default size md" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "dm-divider--md"
  end

  test "renders divider with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_divider/1, %{size: size})
      assert result =~ "dm-divider--#{size}"
    end
  end

  test "renders divider with text content" do
    result =
      render_component(&dm_divider/1, %{
        inner_block: [%{inner_block: fn _, _ -> "OR" end}]
      })

    assert result =~ "OR"
    assert result =~ "dm-divider__content"
  end

  test "renders divider without content span when no inner_block" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "dm-divider__content"
  end

  test "renders divider with custom class" do
    result = render_component(&dm_divider/1, %{class: "my-divider"})

    assert result =~ "my-divider"
  end

  test "renders divider with combined options" do
    result =
      render_component(&dm_divider/1, %{
        orientation: "vertical",
        variant: "accent",
        style: "dashed",
        size: "lg"
      })

    assert result =~ "dm-divider--vertical"
    assert result =~ "dm-divider--accent"
    assert result =~ "dm-divider--dashed"
    assert result =~ "dm-divider--lg"
  end

  test "renders divider with rest attributes" do
    result =
      render_component(&dm_divider/1, %{
        "data-testid": "section-divider"
      })

    assert result =~ "data-testid=\"section-divider\""
  end
end
