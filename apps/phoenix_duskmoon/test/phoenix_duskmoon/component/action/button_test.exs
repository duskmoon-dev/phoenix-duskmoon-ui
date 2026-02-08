defmodule PhoenixDuskmoon.Component.Action.ButtonTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Button

  test "renders basic button" do
    result =
      render_component(&dm_btn/1, %{inner_block: %{inner_block: fn _, _ -> "Click me" end}})

    assert result =~ ~s[<el-dm-button]
    assert result =~ "Click me"
    assert result =~ ~s[</el-dm-button>]
  end

  test "renders button with custom class" do
    result =
      render_component(&dm_btn/1, %{
        class: "my-custom-class",
        inner_block: %{inner_block: fn _, _ -> "Primary" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[class="my-custom-class"]
    assert result =~ "Primary"
    assert result =~ ~s[</el-dm-button>]
  end

  test "renders button with id" do
    result =
      render_component(&dm_btn/1, %{
        id: "test-button",
        inner_block: %{inner_block: fn _, _ -> "Test" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[id="test-button"]
    assert result =~ "Test"
    assert result =~ ~s[</el-dm-button>]
  end

  test "renders button with variant" do
    result =
      render_component(&dm_btn/1, %{
        variant: "primary",
        inner_block: %{inner_block: fn _, _ -> "Primary" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[variant="primary"]
  end

  test "renders button with size" do
    result =
      render_component(&dm_btn/1, %{
        size: "lg",
        inner_block: %{inner_block: fn _, _ -> "Large" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[size="lg"]
  end

  test "renders button with shape" do
    result =
      render_component(&dm_btn/1, %{
        shape: "circle",
        inner_block: %{inner_block: fn _, _ -> "O" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[shape="circle"]
  end

  test "renders button with loading state" do
    result =
      render_component(&dm_btn/1, %{
        loading: true,
        inner_block: %{inner_block: fn _, _ -> "Loading" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[loading]
  end

  test "renders button with disabled state" do
    result =
      render_component(&dm_btn/1, %{
        disabled: true,
        inner_block: %{inner_block: fn _, _ -> "Disabled" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[disabled]
  end

  test "renders button with noise effect" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "Noise",
        inner_block: %{inner_block: fn _, _ -> "Noise Button" end}
      })

    assert result =~ ~s[<button class="btn-noise]
    assert result =~ ~s[data-content="Noise"]
    assert result =~ ~s[style="--aps: running"]
    assert result =~ ~s[<i></i>]
  end

  test "renders button with confirmation dialog" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[onclick="document.getElementById(&#39;confirm-dialog-]
    assert result =~ ~s[<el-dm-dialog id="confirm-dialog-]
    assert result =~ ~s[Are you sure?]
    assert result =~ ~s[<el-dm-button variant="primary"]
    assert result =~ ~s[Yes]
    assert result =~ ~s[<el-dm-button variant="ghost"]
    assert result =~ ~s[Cancel]
  end

  test "renders button with confirmation dialog and custom title" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_title: "Confirm Delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[slot="header"]
    assert result =~ ~s[Confirm Delete]
    assert result =~ ~s[Are you sure?]
  end

  test "renders button with confirmation dialog and custom classes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_class: "my-confirm-class",
        cancel_class: "my-cancel-class",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[class="my-confirm-class"]
    assert result =~ ~s[class="my-cancel-class"]
  end

  test "renders button with confirmation dialog without cancel action" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        show_cancel_action: false,
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<el-dm-button variant="primary"]
    assert result =~ ~s[Yes]
    refute result =~ ~s[Cancel]
  end

  test "renders button with confirmation action slot" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_action: [%{inner_block: fn _, _ -> "Custom Action" end}],
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[Custom Action]
    assert result =~ ~s[Cancel]
  end

  test "renders button with global attributes" do
    result =
      render_component(&dm_btn/1, %{
        "data-testid": "test-button",
        "aria-label": "Test button",
        inner_block: %{inner_block: fn _, _ -> "Test" end}
      })

    assert result =~ ~s[data-testid="test-button"]
    assert result =~ ~s[aria-label="Test button"]
  end
end
