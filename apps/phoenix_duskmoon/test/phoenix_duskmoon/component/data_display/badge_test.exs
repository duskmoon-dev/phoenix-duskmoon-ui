defmodule PhoenixDuskmoon.Component.DataDisplay.BadgeTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Badge

  test "renders basic badge" do
    result =
      render_component(&dm_badge/1, %{
        inner_block: %{inner_block: fn _, _ -> "New" end}
      })

    assert result =~ "<el-dm-badge"
    assert result =~ "New"
    assert result =~ "</el-dm-badge>"
  end

  test "renders badge with variant" do
    result =
      render_component(&dm_badge/1, %{
        variant: "success",
        inner_block: %{inner_block: fn _, _ -> "Active" end}
      })

    assert result =~ "<el-dm-badge"
    assert result =~ ~s[variant="success"]
  end

  test "renders badge with size" do
    result =
      render_component(&dm_badge/1, %{
        size: "lg",
        inner_block: %{inner_block: fn _, _ -> "Big" end}
      })

    assert result =~ ~s[size="lg"]
  end

  test "renders badge with outline" do
    result =
      render_component(&dm_badge/1, %{
        outline: true,
        inner_block: %{inner_block: fn _, _ -> "Outline" end}
      })

    assert result =~ "outline"
  end

  test "renders badge with custom class" do
    result =
      render_component(&dm_badge/1, %{
        class: "my-badge",
        inner_block: %{inner_block: fn _, _ -> "Custom" end}
      })

    assert result =~ "my-badge"
  end
end
