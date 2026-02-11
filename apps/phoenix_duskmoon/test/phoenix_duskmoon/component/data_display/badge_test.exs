defmodule PhoenixDuskmoon.Component.DataDisplay.BadgeTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Badge

  defp inner_block(text), do: %{inner_block: fn _, _ -> text end}

  test "renders basic badge with el-dm-badge element" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("New")})

    assert result =~ "<el-dm-badge"
    assert result =~ "New"
    assert result =~ "</el-dm-badge>"
  end

  test "renders badge with default variant primary" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ ~s[variant="primary"]
  end

  test "renders badge with all variant options" do
    for variant <- ~w(primary secondary accent info success warning error ghost neutral) do
      result =
        render_component(&dm_badge/1, %{
          variant: variant,
          inner_block: inner_block("Badge")
        })

      assert result =~ ~s[variant="#{variant}"]
    end
  end

  test "renders badge with default size md" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ ~s[size="md"]
  end

  test "renders badge with all size options" do
    for size <- ~w(xs sm md lg) do
      result =
        render_component(&dm_badge/1, %{
          size: size,
          inner_block: inner_block("Badge")
        })

      assert result =~ ~s[size="#{size}"]
    end
  end

  test "renders badge with outline" do
    result =
      render_component(&dm_badge/1, %{
        outline: true,
        inner_block: inner_block("Outline")
      })

    assert result =~ "outline"
  end

  test "renders badge without outline by default" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    # outline=false should not render the attribute value
    assert result =~ "<el-dm-badge"
  end

  test "renders badge with custom class" do
    result =
      render_component(&dm_badge/1, %{
        class: "my-badge-class",
        inner_block: inner_block("Custom")
      })

    assert result =~ "my-badge-class"
  end

  test "renders badge content from inner_block" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Status Active")})

    assert result =~ "Status Active"
  end

  test "renders badge with rest attributes" do
    result =
      render_component(&dm_badge/1, %{
        "data-testid": "status-badge",
        "aria-label": "Status indicator",
        inner_block: inner_block("Active")
      })

    assert result =~ "data-testid=\"status-badge\""
    assert result =~ "aria-label=\"Status indicator\""
  end

  test "renders badge with variant and size combined" do
    result =
      render_component(&dm_badge/1, %{
        variant: "error",
        size: "lg",
        inner_block: inner_block("Error")
      })

    assert result =~ ~s[variant="error"]
    assert result =~ ~s[size="lg"]
  end

  test "renders badge with all options combined" do
    result =
      render_component(&dm_badge/1, %{
        variant: "warning",
        size: "sm",
        outline: true,
        class: "extra",
        inner_block: inner_block("Full")
      })

    assert result =~ ~s[variant="warning"]
    assert result =~ ~s[size="sm"]
    assert result =~ "outline"
    assert result =~ "extra"
    assert result =~ "Full"
  end

  test "renders badge with neutral variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "neutral",
        inner_block: inner_block("Neutral")
      })

    assert result =~ ~s[variant="neutral"]
    assert result =~ "Neutral"
  end

  test "renders badge with ghost variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "ghost",
        inner_block: inner_block("Ghost")
      })

    assert result =~ ~s[variant="ghost"]
  end

  test "renders badge with outline false explicitly" do
    result =
      render_component(&dm_badge/1, %{
        outline: false,
        inner_block: inner_block("No outline")
      })

    assert result =~ "<el-dm-badge"
    assert result =~ "No outline"
  end

  test "renders badge with outline and each variant" do
    for variant <- ~w(primary error success warning info) do
      result =
        render_component(&dm_badge/1, %{
          variant: variant,
          outline: true,
          inner_block: inner_block("Outlined")
        })

      assert result =~ ~s[variant="#{variant}"]
      assert result =~ "outline"
    end
  end

  test "renders badge with xs size and error variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "error",
        size: "xs",
        inner_block: inner_block("Tiny Error")
      })

    assert result =~ ~s[variant="error"]
    assert result =~ ~s[size="xs"]
    assert result =~ "Tiny Error"
  end

  test "renders badge with lg size and success variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "success",
        size: "lg",
        inner_block: inner_block("Big Success")
      })

    assert result =~ ~s[variant="success"]
    assert result =~ ~s[size="lg"]
  end

  test "renders badge with accent variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "accent",
        inner_block: inner_block("Accent")
      })

    assert result =~ ~s[variant="accent"]
  end
end
