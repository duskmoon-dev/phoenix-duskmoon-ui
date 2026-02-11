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

  test "renders confirm dialog with role and aria-modal attributes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[role="dialog"]
    assert result =~ ~s[aria-modal="true"]
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

  test "renders button with all variant options" do
    for variant <- ~w(primary secondary accent info success warning error ghost link outline) do
      result =
        render_component(&dm_btn/1, %{
          variant: variant,
          inner_block: %{inner_block: fn _, _ -> "Btn" end}
        })

      assert result =~ ~s[variant="#{variant}"]
    end
  end

  test "renders button with all size options" do
    for size <- ~w(xs sm md lg) do
      result =
        render_component(&dm_btn/1, %{
          size: size,
          inner_block: %{inner_block: fn _, _ -> "Btn" end}
        })

      assert result =~ ~s[size="#{size}"]
    end
  end

  test "renders button with square shape" do
    result =
      render_component(&dm_btn/1, %{
        shape: "square",
        inner_block: %{inner_block: fn _, _ -> "S" end}
      })

    assert result =~ ~s[shape="square"]
  end

  test "renders noise button with custom class" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "SUBMIT",
        class: "mx-auto",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    assert result =~ "btn-noise"
    assert result =~ "mx-auto"
    assert result =~ ~s[data-content="SUBMIT"]
  end

  test "renders noise button with 73 i elements" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "X",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    # 0..72 = 73 elements
    i_count = length(String.split(result, "<i></i>")) - 1
    assert i_count == 73
  end

  test "renders button with confirm and custom id" do
    result =
      render_component(&dm_btn/1, %{
        id: "del-btn",
        confirm: "Really delete?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[id="del-btn"]
    assert result =~ ~s[id="confirm-dialog-del-btn"]
    assert result =~ "Really delete?"
  end

  test "renders button with confirm dialog header only when title is non-empty" do
    # With empty confirm_title, no header slot should render
    result =
      render_component(&dm_btn/1, %{
        confirm: "Sure?",
        confirm_title: "",
        inner_block: %{inner_block: fn _, _ -> "Go" end}
      })

    refute result =~ ~s[slot="header"]
  end

  test "renders button with phx-click passes through to el-dm-button" do
    result =
      render_component(&dm_btn/1, %{
        "phx-click": "handle_click",
        inner_block: %{inner_block: fn _, _ -> "Click" end}
      })

    assert result =~ ~s[phx-click="handle_click"]
  end

  test "renders button without phx-hook when no phx-click" do
    result =
      render_component(&dm_btn/1, %{
        inner_block: %{inner_block: fn _, _ -> "No hook" end}
      })

    refute result =~ "WebComponentHook"
  end

  test "renders button with all standard attributes combined" do
    result =
      render_component(&dm_btn/1, %{
        id: "combo-btn",
        variant: "error",
        size: "lg",
        shape: "circle",
        loading: true,
        disabled: true,
        class: "my-class",
        "data-testid": "combo",
        inner_block: %{inner_block: fn _, _ -> "X" end}
      })

    assert result =~ ~s[id="combo-btn"]
    assert result =~ ~s[variant="error"]
    assert result =~ ~s[size="lg"]
    assert result =~ ~s[shape="circle"]
    assert result =~ "loading"
    assert result =~ "disabled"
    assert result =~ "my-class"
    assert result =~ "data-testid=\"combo\""
  end

  test "renders noise button with aria-label matching content" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "SUBMIT",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    assert result =~ ~s[aria-label="SUBMIT"]
  end

  test "renders noise button with aria-hidden on span" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "GO",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    assert result =~ ~s[aria-hidden="true"]
  end

  test "renders noise button with rest attributes passthrough" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "SEND",
        "data-testid": "noise-btn",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    assert result =~ ~s[data-testid="noise-btn"]
  end

  test "renders confirm button with variant on outer button" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Delete?",
        variant: "error",
        size: "sm",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[variant="error"]
    assert result =~ ~s[size="sm"]
  end

  test "renders confirm dialog Yes button passes rest attributes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        "phx-click": "delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    # The phx-click should be on the Yes button inside the dialog
    assert result =~ ~s[phx-click="delete"]
  end

  test "renders button without confirm when confirm is empty string" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "",
        inner_block: %{inner_block: fn _, _ -> "Normal Button" end}
      })

    refute result =~ "el-dm-dialog"
    refute result =~ "confirm-dialog"
    assert result =~ "Normal Button"
  end

  test "renders button with form-related global attributes" do
    result =
      render_component(&dm_btn/1, %{
        type: "submit",
        name: "action",
        value: "save",
        inner_block: %{inner_block: fn _, _ -> "Save" end}
      })

    assert result =~ ~s[type="submit"]
    assert result =~ ~s[name="action"]
    assert result =~ ~s[value="save"]
  end

  test "renders confirm dialog with empty confirm_action shows default Yes button" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_action: [],
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "Are you sure?"
    assert result =~ "Yes"
    assert result =~ "Cancel"
  end
end
