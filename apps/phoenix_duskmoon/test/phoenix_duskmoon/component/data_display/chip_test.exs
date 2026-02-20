defmodule PhoenixDuskmoon.Component.DataDisplay.ChipTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Chip

  defp inner_block(text \\ "Tag"),
    do: %{inner_block: fn _, _ -> text end}

  test "renders el-dm-chip custom element" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    assert result =~ "<el-dm-chip"
    assert result =~ "</el-dm-chip>"
  end

  test "renders default variant filled" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    assert result =~ ~s[variant="filled"]
  end

  test "renders all variant types" do
    for variant <- ~w(filled outlined soft) do
      result =
        render_component(&dm_chip/1, %{
          variant: variant,
          inner_block: inner_block()
        })

      assert result =~ ~s[variant="#{variant}"]
    end
  end

  test "renders with color" do
    result =
      render_component(&dm_chip/1, %{
        color: "primary",
        inner_block: inner_block()
      })

    assert result =~ ~s[color="primary"]
  end

  test "renders all color options" do
    for color <- ~w(primary secondary tertiary success warning error info) do
      result =
        render_component(&dm_chip/1, %{
          color: color,
          inner_block: inner_block()
        })

      assert result =~ ~s[color="#{color}"]
    end
  end

  test "renders without color by default" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    [_, chip_tag] = String.split(result, "<el-dm-chip", parts: 2)
    [chip_attrs, _] = String.split(chip_tag, ">", parts: 2)
    refute chip_attrs =~ ~s[color="]
  end

  test "renders default size md" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    assert result =~ ~s[size="md"]
  end

  test "renders all size options" do
    for size <- ~w(sm md lg) do
      result =
        render_component(&dm_chip/1, %{
          size: size,
          inner_block: inner_block()
        })

      assert result =~ ~s[size="#{size}"]
    end
  end

  test "renders deletable attribute" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        inner_block: inner_block()
      })

    assert result =~ "deletable"
  end

  test "renders without deletable by default" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    [_, chip_tag] = String.split(result, "<el-dm-chip", parts: 2)
    [chip_attrs, _] = String.split(chip_tag, ">", parts: 2)
    refute chip_attrs =~ "deletable"
  end

  test "renders selected attribute" do
    result =
      render_component(&dm_chip/1, %{
        selected: true,
        inner_block: inner_block()
      })

    assert result =~ "selected"
  end

  test "renders disabled attribute" do
    result =
      render_component(&dm_chip/1, %{
        disabled: true,
        inner_block: inner_block()
      })

    assert result =~ "disabled"
  end

  test "renders inner block content" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block("Elixir")
      })

    assert result =~ "Elixir"
  end

  test "renders with id" do
    result =
      render_component(&dm_chip/1, %{
        id: "chip-1",
        inner_block: inner_block()
      })

    assert result =~ ~s[id="chip-1"]
  end

  test "renders with custom class" do
    result =
      render_component(&dm_chip/1, %{
        class: "mr-2",
        inner_block: inner_block()
      })

    assert result =~ ~s[class="mr-2"]
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_chip/1, %{
        "data-testid": "chip-x",
        inner_block: inner_block()
      })

    assert result =~ ~s[data-testid="chip-x"]
  end

  test "renders icon slot when provided" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block(),
        icon: %{inner_block: fn _, _ -> "star" end}
      })

    assert result =~ ~s[slot="icon"]
    assert result =~ "star"
  end

  test "does not render icon slot wrapper when empty" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    refute result =~ ~s[slot="icon"]
  end

  test "renders all options combined" do
    result =
      render_component(&dm_chip/1, %{
        id: "full-chip",
        variant: "outlined",
        color: "error",
        size: "lg",
        deletable: true,
        selected: true,
        disabled: true,
        class: "my-chip",
        inner_block: inner_block("Full")
      })

    assert result =~ ~s[variant="outlined"]
    assert result =~ ~s[color="error"]
    assert result =~ ~s[size="lg"]
    assert result =~ "deletable"
    assert result =~ "selected"
    assert result =~ "disabled"
    assert result =~ "my-chip"
    assert result =~ "Full"
  end
end
