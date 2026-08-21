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

  test "renders aria-disabled=true when disabled" do
    result =
      render_component(&dm_chip/1, %{
        disabled: true,
        inner_block: inner_block()
      })

    assert result =~ ~s(aria-disabled="true")
  end

  test "no aria-disabled when not disabled" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    refute result =~ "aria-disabled"
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

  test "renders without selected by default" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    [_, chip_tag] = String.split(result, "<el-dm-chip", parts: 2)
    [chip_attrs, _] = String.split(chip_tag, ">", parts: 2)
    refute chip_attrs =~ "selected"
  end

  test "renders without disabled by default" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block()
      })

    [_, chip_tag] = String.split(result, "<el-dm-chip", parts: 2)
    [chip_attrs, _] = String.split(chip_tag, ">", parts: 2)
    refute chip_attrs =~ "disabled"
  end

  test "renders icon slot with inner content" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block("Label"),
        icon: %{inner_block: fn _, _ -> "ic" end}
      })

    assert result =~ "Label"
    assert result =~ "ic"
    assert result =~ ~s[slot="icon"]
  end

  test "icon slot is wrapped in span element" do
    result =
      render_component(&dm_chip/1, %{
        inner_block: inner_block(),
        icon: %{inner_block: fn _, _ -> "ic" end}
      })

    assert result =~ ~s(<span slot="icon">)
  end

  test "renders selected and deletable without disabled" do
    result =
      render_component(&dm_chip/1, %{
        selected: true,
        deletable: true,
        inner_block: inner_block("Active")
      })

    assert result =~ "selected"
    assert result =~ "deletable"
    [_, chip_tag] = String.split(result, "<el-dm-chip", parts: 2)
    [chip_attrs, _] = String.split(chip_tag, ">", parts: 2)
    refute chip_attrs =~ "disabled"
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

  test "renders href navigation as one semantic link" do
    result =
      render_component(&dm_chip/1, %{
        href: "/categories/elixir",
        color: "primary",
        target: "_blank",
        rel: "noopener",
        inner_block: inner_block("Elixir")
      })

    assert result =~ ~s[<a href="/categories/elixir"]
    assert result =~ ~s[target="_blank"]
    assert result =~ ~s[rel="noopener"]
    assert result =~ "chip-clickable"
    assert result =~ "chip-primary"
    refute result =~ "el-dm-chip"
    refute result =~ ~s[role="button"]
  end

  test "renders LiveView navigation with link semantics" do
    result =
      render_component(&dm_chip/1, %{
        navigate: "/categories/phoenix",
        inner_block: inner_block("Phoenix")
      })

    assert result =~ ~s[href="/categories/phoenix"]
    assert result =~ ~s[data-phx-link="redirect"]
    refute result =~ "el-dm-chip"
  end

  test "renders replaceable LiveView patch navigation with native classes" do
    result =
      render_component(&dm_chip/1, %{
        patch: "/categories?page=2",
        replace: true,
        variant: "soft",
        size: "sm",
        selected: true,
        class: "category-chip",
        inner_block: inner_block("Page 2")
      })

    assert result =~ ~s[href="/categories?page=2"]
    assert result =~ ~s[data-phx-link="patch"]
    assert result =~ ~s[data-phx-link-state="replace"]
    assert result =~ "chip-tonal"
    assert result =~ "chip-sm"
    assert result =~ "chip-selected"
    assert result =~ "category-chip"
  end

  test "renders an accessible native removal callback" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        delete_event: "remove-category",
        delete_label: "Remove Elixir category",
        color: "error",
        inner_block: inner_block("Elixir")
      })

    assert result =~ ~s[<span class="chip chip-error"]
    assert result =~ ~s[<button type="button"]
    assert result =~ ~s[class="chip-close"]
    assert result =~ ~s[phx-click="remove-category"]
    assert result =~ ~s[aria-label="Remove Elixir category"]
    refute result =~ "el-dm-chip"
    refute result =~ ~s[role="button"]
  end

  test "forwards LiveView delete target and values to the removal button" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        delete_event: "remove-category",
        "phx-target": "#categories",
        "phx-value-id": "42",
        inner_block: inner_block("Elixir")
      })

    [_, button] = String.split(result, "<button", parts: 2)
    [button_attrs, _] = String.split(button, ">", parts: 2)

    assert button_attrs =~ ~s[phx-click="remove-category"]
    assert button_attrs =~ ~s[phx-target="#categories"]
    assert button_attrs =~ ~s[phx-value-id="42"]
  end

  test "accepts a LiveView JS delete command with values" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        delete_event: Phoenix.LiveView.JS.push("remove-category", value: %{id: 42}),
        inner_block: inner_block("Elixir")
      })

    [_, button] = String.split(result, "<button", parts: 2)
    [button_attrs, _] = String.split(button, ">", parts: 2)

    assert button_attrs =~ "remove-category"
    assert button_attrs =~ "&quot;id&quot;:42"
  end

  test "disables the native removal button with the chip" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        delete_event: "remove-category",
        disabled: true,
        inner_block: inner_block("Elixir")
      })

    assert result =~ ~s[aria-disabled="true"]

    [_, button] = String.split(result, "<button", parts: 2)
    [button_attrs, _] = String.split(button, ">", parts: 2)
    assert button_attrs =~ "disabled"
  end

  test "keeps the custom element for legacy deletable chips without a callback" do
    result =
      render_component(&dm_chip/1, %{
        deletable: true,
        inner_block: inner_block("Legacy")
      })

    assert result =~ "<el-dm-chip"
    assert result =~ "deletable"
  end

  test "native removal takes precedence over navigation" do
    result =
      render_component(&dm_chip/1, %{
        href: "/categories/elixir",
        deletable: true,
        delete_event: "remove-category",
        inner_block: inner_block("Elixir")
      })

    assert result =~ ~s[phx-click="remove-category"]
    refute result =~ "<a "
    refute result =~ "el-dm-chip"
  end

  test "renders disabled navigation as a noninteractive native chip" do
    result =
      render_component(&dm_chip/1, %{
        href: "/categories/disabled",
        disabled: true,
        inner_block: inner_block("Disabled")
      })

    assert result =~ ~s[<span class="chip chip-clickable chip-disabled"]
    assert result =~ ~s[aria-disabled="true"]
    refute result =~ "<a "
    refute result =~ "el-dm-chip"
  end
end
