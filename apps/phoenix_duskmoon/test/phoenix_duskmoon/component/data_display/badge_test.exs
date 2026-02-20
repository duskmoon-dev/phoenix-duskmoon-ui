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

  test "renders badge with default color primary" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ ~s[color="primary"]
  end

  test "renders badge with all variant color options" do
    for variant <- ~w(primary secondary tertiary info success warning error ghost neutral) do
      result =
        render_component(&dm_badge/1, %{
          variant: variant,
          inner_block: inner_block("Badge")
        })

      assert result =~ ~s[color="#{variant}"]
    end
  end

  test "renders badge mapping accent to tertiary" do
    result =
      render_component(&dm_badge/1, %{
        variant: "accent",
        inner_block: inner_block("Accent")
      })

    assert result =~ ~s[color="tertiary"]
    refute result =~ ~s[color="accent"]
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

  test "renders badge with outline setting variant to outlined" do
    result =
      render_component(&dm_badge/1, %{
        outline: true,
        inner_block: inner_block("Outline")
      })

    assert result =~ ~s[variant="outlined"]
  end

  test "renders badge without variant attribute by default" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    refute result =~ ~s[variant=]
  end

  test "renders badge with soft setting variant to soft" do
    result =
      render_component(&dm_badge/1, %{
        soft: true,
        inner_block: inner_block("Soft")
      })

    assert result =~ ~s[variant="soft"]
  end

  test "renders badge soft takes precedence over outline" do
    result =
      render_component(&dm_badge/1, %{
        soft: true,
        outline: true,
        inner_block: inner_block("Both")
      })

    assert result =~ ~s[variant="soft"]
    refute result =~ ~s[variant="outlined"]
  end

  test "renders badge without soft by default" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    refute result =~ ~s[variant="soft"]
  end

  test "renders badge with soft and each color" do
    for variant <- ~w(primary success error warning info) do
      result =
        render_component(&dm_badge/1, %{
          variant: variant,
          soft: true,
          inner_block: inner_block("Soft")
        })

      assert result =~ ~s[color="#{variant}"]
      assert result =~ ~s[variant="soft"]
    end
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

  test "renders badge with color and size combined" do
    result =
      render_component(&dm_badge/1, %{
        variant: "error",
        size: "lg",
        inner_block: inner_block("Error")
      })

    assert result =~ ~s[color="error"]
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

    assert result =~ ~s[color="warning"]
    assert result =~ ~s[size="sm"]
    assert result =~ ~s[variant="outlined"]
    assert result =~ "extra"
    assert result =~ "Full"
  end

  test "renders badge with neutral variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "neutral",
        inner_block: inner_block("Neutral")
      })

    assert result =~ ~s[color="neutral"]
    assert result =~ "Neutral"
  end

  test "renders badge with ghost variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "ghost",
        inner_block: inner_block("Ghost")
      })

    assert result =~ ~s[color="ghost"]
  end

  test "renders badge with outline false explicitly" do
    result =
      render_component(&dm_badge/1, %{
        outline: false,
        inner_block: inner_block("No outline")
      })

    assert result =~ "<el-dm-badge"
    refute result =~ ~s[variant=]
    assert result =~ "No outline"
  end

  test "renders badge with outline and each color" do
    for variant <- ~w(primary error success warning info) do
      result =
        render_component(&dm_badge/1, %{
          variant: variant,
          outline: true,
          inner_block: inner_block("Outlined")
        })

      assert result =~ ~s[color="#{variant}"]
      assert result =~ ~s[variant="outlined"]
    end
  end

  test "renders badge with xs size and error color" do
    result =
      render_component(&dm_badge/1, %{
        variant: "error",
        size: "xs",
        inner_block: inner_block("Tiny Error")
      })

    assert result =~ ~s[color="error"]
    assert result =~ ~s[size="xs"]
    assert result =~ "Tiny Error"
  end

  test "renders badge with lg size and success color" do
    result =
      render_component(&dm_badge/1, %{
        variant: "success",
        size: "lg",
        inner_block: inner_block("Big Success")
      })

    assert result =~ ~s[color="success"]
    assert result =~ ~s[size="lg"]
  end

  test "renders badge with accent variant mapping to tertiary" do
    result =
      render_component(&dm_badge/1, %{
        variant: "accent",
        inner_block: inner_block("Accent")
      })

    assert result =~ ~s[color="tertiary"]
  end

  test "renders badge with secondary variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "secondary",
        inner_block: inner_block("Secondary")
      })

    assert result =~ ~s[color="secondary"]
    assert result =~ "Secondary"
  end

  test "renders badge with sm size" do
    result =
      render_component(&dm_badge/1, %{
        size: "sm",
        inner_block: inner_block("Small")
      })

    assert result =~ ~s[size="sm"]
  end

  test "renders badge as el-dm-badge custom element" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ "<el-dm-badge"
    assert result =~ "</el-dm-badge>"
  end

  test "renders badge with class on el-dm-badge element" do
    result =
      render_component(&dm_badge/1, %{
        class: "badge-extra",
        inner_block: inner_block("Styled")
      })

    assert result =~ "badge-extra"
    assert result =~ "<el-dm-badge"
  end

  test "renders badge with ghost variant and content" do
    result =
      render_component(&dm_badge/1, %{
        variant: "ghost",
        inner_block: inner_block("Ghost Badge")
      })

    assert result =~ ~s[color="ghost"]
    assert result =~ "Ghost Badge"
  end

  test "renders badge with multiple space-separated classes" do
    result =
      render_component(&dm_badge/1, %{
        class: "custom-badge highlight rounded-lg",
        inner_block: inner_block("Multi")
      })

    assert result =~ "custom-badge highlight rounded-lg"
  end

  test "renders badge with xs size" do
    result =
      render_component(&dm_badge/1, %{
        size: "xs",
        inner_block: inner_block("Tiny")
      })

    assert result =~ ~s[size="xs"]
  end

  test "renders badge with outline and color combined" do
    result =
      render_component(&dm_badge/1, %{
        variant: "error",
        outline: true,
        size: "lg",
        inner_block: inner_block("Alert")
      })

    assert result =~ ~s[color="error"]
    assert result =~ ~s[variant="outlined"]
    assert result =~ ~s[size="lg"]
    assert result =~ "Alert"
  end

  test "renders badge with pill shape" do
    result =
      render_component(&dm_badge/1, %{
        pill: true,
        inner_block: inner_block("Pill")
      })

    assert result =~ "pill"
    assert result =~ "Pill"
  end

  test "renders badge without pill by default" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ "<el-dm-badge"
  end

  test "renders badge with dot indicator" do
    result =
      render_component(&dm_badge/1, %{
        dot: true,
        inner_block: inner_block("Dot")
      })

    assert result =~ "dot"
  end

  test "renders badge without dot by default" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Tag")})

    assert result =~ "<el-dm-badge"
  end

  test "renders badge with pill and dot combined" do
    result =
      render_component(&dm_badge/1, %{
        pill: true,
        dot: true,
        variant: "error",
        inner_block: inner_block("Alert")
      })

    assert result =~ "pill"
    assert result =~ "dot"
    assert result =~ ~s[color="error"]
  end

  test "renders badge closing tag" do
    result = render_component(&dm_badge/1, %{inner_block: inner_block("Close")})

    assert result =~ "</el-dm-badge>"
  end

  test "renders badge with soft and accent mapping" do
    result =
      render_component(&dm_badge/1, %{
        variant: "accent",
        soft: true,
        inner_block: inner_block("Soft Accent")
      })

    assert result =~ ~s[color="tertiary"]
    assert result =~ ~s[variant="soft"]
    assert result =~ "Soft Accent"
  end

  test "renders badge with soft false explicitly" do
    result =
      render_component(&dm_badge/1, %{
        soft: false,
        inner_block: inner_block("Not soft")
      })

    refute result =~ ~s[variant="soft"]
  end

  test "renders badge with soft and all options combined" do
    result =
      render_component(&dm_badge/1, %{
        variant: "success",
        size: "lg",
        soft: true,
        pill: true,
        class: "custom",
        inner_block: inner_block("Full Soft")
      })

    assert result =~ ~s[color="success"]
    assert result =~ ~s[variant="soft"]
    assert result =~ ~s[size="lg"]
    assert result =~ "pill"
    assert result =~ "custom"
    assert result =~ "Full Soft"
  end
end
