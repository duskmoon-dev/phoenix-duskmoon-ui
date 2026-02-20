defmodule PhoenixDuskmoon.Component.Layout.DividerTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.Divider

  test "renders basic divider with divider class" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "divider"
  end

  test "renders divider with role separator" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ ~s[role="separator"]
  end

  test "renders divider with default horizontal orientation" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-vertical"
    assert result =~ ~s[aria-orientation="horizontal"]
  end

  test "renders vertical divider" do
    result = render_component(&dm_divider/1, %{orientation: "vertical"})

    assert result =~ "divider-vertical"
    assert result =~ ~s[aria-orientation="vertical"]
  end

  test "renders divider with default variant base (no variant class)" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-base"
    refute result =~ "divider-primary"
  end

  test "renders divider with primary variant" do
    result = render_component(&dm_divider/1, %{variant: "primary"})

    assert result =~ "divider-primary"
  end

  test "renders divider with secondary variant" do
    result = render_component(&dm_divider/1, %{variant: "secondary"})

    assert result =~ "divider-secondary"
  end

  test "renders divider with unsupported variants without CSS class" do
    for variant <- ~w(base tertiary accent info success warning error) do
      result = render_component(&dm_divider/1, %{variant: variant})
      # Base variants without upstream CSS just render the base divider
      assert result =~ "divider"
      refute result =~ "divider-#{variant}"
    end
  end

  test "renders divider with default style solid (no style class)" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-solid"
  end

  test "renders divider with dashed style" do
    result = render_component(&dm_divider/1, %{style: "dashed"})

    assert result =~ "divider-dashed"
  end

  test "renders divider with dotted style" do
    result = render_component(&dm_divider/1, %{style: "dotted"})

    assert result =~ "divider-dotted"
  end

  test "renders divider with default size md (no size class)" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-md"
  end

  test "renders divider with xs size" do
    result = render_component(&dm_divider/1, %{size: "xs"})

    assert result =~ "divider-xs"
  end

  test "renders divider with sm size" do
    result = render_component(&dm_divider/1, %{size: "sm"})

    assert result =~ "divider-sm"
  end

  test "renders divider with lg size" do
    result = render_component(&dm_divider/1, %{size: "lg"})

    assert result =~ "divider-lg"
  end

  test "renders divider with text content" do
    result =
      render_component(&dm_divider/1, %{
        inner_block: [%{inner_block: fn _, _ -> "OR" end}]
      })

    assert result =~ "OR"
    assert result =~ "divider-text-content"
    assert result =~ "divider-text"
  end

  test "renders divider without content span when no inner_block" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-text-content"
    refute result =~ "divider-text"
  end

  test "renders divider with custom class" do
    result = render_component(&dm_divider/1, %{class: "my-divider"})

    assert result =~ "my-divider"
  end

  test "renders divider with combined options" do
    result =
      render_component(&dm_divider/1, %{
        orientation: "vertical",
        variant: "primary",
        style: "dashed",
        size: "lg"
      })

    assert result =~ "divider-vertical"
    assert result =~ "divider-primary"
    assert result =~ "divider-dashed"
    assert result =~ "divider-lg"
  end

  test "renders divider with rest attributes" do
    result =
      render_component(&dm_divider/1, %{
        "data-testid": "section-divider"
      })

    assert result =~ "data-testid=\"section-divider\""
  end

  test "renders divider with empty inner_block list does not show content span" do
    result = render_component(&dm_divider/1, %{inner_block: []})

    refute result =~ "divider-text-content"
  end

  test "renders divider content span wraps text correctly" do
    result =
      render_component(&dm_divider/1, %{
        inner_block: [%{inner_block: fn _, _ -> "Section Break" end}]
      })

    assert result =~ "divider-text-content"
    assert result =~ "Section Break"
  end

  test "renders divider as div element" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "<div"
    assert result =~ "</div>"
  end

  test "renders divider with all defaults in class list" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "divider"
    refute result =~ "divider-vertical"
    refute result =~ "divider-md"
    refute result =~ "divider-solid"
    refute result =~ "divider-base"
  end

  test "renders divider with multiple rest attributes" do
    result =
      render_component(&dm_divider/1, %{
        "data-testid": "div-1",
        "aria-hidden": "true"
      })

    assert result =~ "data-testid=\"div-1\""
    assert result =~ "aria-hidden=\"true\""
  end

  test "renders divider with all attributes and content combined" do
    result =
      render_component(&dm_divider/1, %{
        orientation: "vertical",
        variant: "primary",
        style: "dotted",
        size: "lg",
        class: "my-custom-divider",
        "data-testid": "full-divider",
        inner_block: [%{inner_block: fn _, _ -> "OR" end}]
      })

    assert result =~ "divider-vertical"
    assert result =~ "divider-primary"
    assert result =~ "divider-dotted"
    assert result =~ "divider-lg"
    assert result =~ "my-custom-divider"
    assert result =~ "data-testid=\"full-divider\""
    assert result =~ "divider-text-content"
    assert result =~ "OR"
    assert result =~ ~s[role="separator"]
    assert result =~ ~s[aria-orientation="vertical"]
  end

  test "renders divider with default horizontal aria-orientation" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ ~s[aria-orientation="horizontal"]
  end

  test "does not render content span when no inner_block" do
    result = render_component(&dm_divider/1, %{})

    refute result =~ "divider-text-content"
  end

  test "renders divider with content span when inner_block is provided" do
    result =
      render_component(&dm_divider/1, %{
        inner_block: [%{inner_block: fn _, _ -> "OR" end}]
      })

    assert result =~ "divider-text-content"
    assert result =~ "OR"
  end

  test "renders divider vertical with content" do
    result =
      render_component(&dm_divider/1, %{
        orientation: "vertical",
        inner_block: [%{inner_block: fn _, _ -> "VS" end}]
      })

    assert result =~ "divider-vertical"
    assert result =~ "divider-text-content"
    assert result =~ "VS"
  end

  test "renders divider with primary variant and dashed style" do
    result =
      render_component(&dm_divider/1, %{
        variant: "primary",
        style: "dashed"
      })

    assert result =~ "divider-primary"
    assert result =~ "divider-dashed"
  end

  test "renders divider as div element with separator role" do
    result = render_component(&dm_divider/1, %{})

    assert result =~ "<div"
    assert result =~ ~s[role="separator"]
  end
end
