defmodule PhoenixDuskmoon.Component.ButtonTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Button

  test "renders basic button" do
    assert render_component(&dm_btn/1, %{inner_block: %{inner_block: fn _, _ -> "Click me" end}}) ==
             ~s[<button class="btn ">Click me</button>]
  end

  test "renders button with custom class" do
    assert render_component(&dm_btn/1, %{
             class: "btn-primary",
             inner_block: %{inner_block: fn _, _ -> "Primary" end}
           }) ==
             ~s[<button class="btn btn-primary">Primary</button>]
  end

  test "renders button with id" do
    assert render_component(&dm_btn/1, %{
             id: "test-button",
             inner_block: %{inner_block: fn _, _ -> "Test" end}
           }) ==
             ~s[<button id="test-button" class="btn ">Test</button>]
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

    assert result =~ ~s[class="btn "]
    assert result =~ ~s[onclick="document.getElementById(&#39;confirm-dialog-]
    assert result =~ ~s[<dialog id="confirm-dialog-]
    assert result =~ ~s[<p class="py-4">]
    assert result =~ ~s[Are you sure?]
    assert result =~ ~s[<button class="btn ">\n            Yes\n          </button>]
    assert result =~ ~s[<button class="btn ">\n          Cancel\n        </button>]
  end

  test "renders button with confirmation dialog and custom title" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_title: "Confirm Delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<h3 class="font-bold text-lg text-primary">]
    assert result =~ ~s[Confirm Delete]
    assert result =~ ~s[<p class="py-4">]
    assert result =~ ~s[Are you sure?]
  end

  test "renders button with confirmation dialog and custom classes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_class: "btn-error",
        cancel_class: "btn-ghost",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<button class="btn btn-error">\n            Yes\n          </button>]
    assert result =~ ~s[<button class="btn btn-ghost">\n          Cancel\n        </button>]
  end

  test "renders button with confirmation dialog without cancel action" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        show_cancel_action: false,
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<button class="btn ">\n            Yes\n          </button>]
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
    assert result =~ ~s[<button class="btn ">\n          Cancel\n        </button>]
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
