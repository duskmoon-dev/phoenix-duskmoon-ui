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
    assert result =~ ~s[aria-busy="true"]
  end

  test "renders button without aria-busy when not loading" do
    result =
      render_component(&dm_btn/1, %{
        inner_block: %{inner_block: fn _, _ -> "Idle" end}
      })

    refute result =~ "aria-busy"
  end

  test "renders button with disabled state" do
    result =
      render_component(&dm_btn/1, %{
        disabled: true,
        inner_block: %{inner_block: fn _, _ -> "Disabled" end}
      })

    assert result =~ ~s[<el-dm-button]
    assert result =~ ~s[disabled]
    assert result =~ ~s[aria-disabled="true"]
  end

  test "renders button without aria-disabled when not disabled" do
    result =
      render_component(&dm_btn/1, %{
        inner_block: %{inner_block: fn _, _ -> "Enabled" end}
      })

    refute result =~ "aria-disabled"
  end

  test "renders navigate button as one link with button styling" do
    result =
      render_component(&dm_btn/1, %{
        navigate: "/dashboard",
        inner_block: %{inner_block: fn _, _ -> "Dashboard" end}
      })

    assert [_] = Regex.scan(~r/<a\b/, result)
    assert result =~ ~s[<a]
    assert result =~ ~s[href="/dashboard"]
    assert result =~ ~s[data-phx-link="redirect"]
    assert result =~ ~s[data-phx-link-state="push"]
    assert result =~ ~s[class="btn btn-primary"]
    refute result =~ ~s[<el-dm-button]
    refute result =~ ~s[<button]
    assert result =~ "Dashboard"
  end

  test "renders patch button as link with replace state" do
    result =
      render_component(&dm_btn/1, %{
        patch: "/settings?tab=profile",
        replace: true,
        variant: "outline",
        inner_block: %{inner_block: fn _, _ -> "Profile" end}
      })

    assert [_] = Regex.scan(~r/<a\b/, result)
    assert result =~ ~s[href="/settings?tab=profile"]
    assert result =~ ~s[data-phx-link="patch"]
    assert result =~ ~s[data-phx-link-state="replace"]
    assert result =~ ~s[class="btn btn-outline"]
    refute result =~ ~s[<el-dm-button]
    refute result =~ ~s[<button]
  end

  test "renders href button as link with styling attributes" do
    result =
      render_component(&dm_btn/1, %{
        id: "external-action",
        href: "https://example.com",
        variant: "error",
        size: "lg",
        class: "external-action",
        rest: %{"aria-label" => "External site", "rel" => "noopener", "target" => "_blank"},
        inner_block: %{inner_block: fn _, _ -> "External" end}
      })

    assert [_] = Regex.scan(~r/<a\b/, result)
    assert result =~ ~s[<a]
    assert result =~ ~s[id="external-action"]
    assert result =~ ~s[href="https://example.com"]
    assert result =~ ~s[class="btn btn-primary btn-lg external-action"]
    assert result =~ ~s[aria-label="External site"]
    assert result =~ ~s[rel="noopener"]
    assert result =~ ~s[target="_blank"]
    assert result =~ "--color-primary: var(--color-error)"
    refute result =~ ~s[<el-dm-button]
    refute result =~ ~s[<button]
    assert result =~ "External"
  end

  test "renders disabled link button as an inert control" do
    result =
      render_component(&dm_btn/1, %{
        navigate: "/dashboard",
        disabled: true,
        rest: %{
          "aria-label" => "Dashboard unavailable",
          "onclick" => "alert('clicked')",
          "phx-click" => "navigate",
          "tabindex" => "0"
        },
        inner_block: %{inner_block: fn _, _ -> "Dashboard" end}
      })

    assert [_] = Regex.scan(~r/<a\b/, result)
    assert result =~ ~s[role="link"]
    assert result =~ ~s[aria-disabled="true"]
    assert result =~ ~s[aria-label="Dashboard unavailable"]
    assert result =~ "opacity-50"
    assert result =~ "cursor-not-allowed"
    assert result =~ "pointer-events-none"
    refute result =~ ~s[href=]
    refute result =~ ~s[data-phx-link=]
    refute result =~ ~s[onclick=]
    refute result =~ ~s[phx-click=]
    refute result =~ ~s[tabindex=]
  end

  test "renders loading link button without an active destination" do
    result =
      render_component(&dm_btn/1, %{
        href: "https://example.com",
        loading: true,
        inner_block: %{inner_block: fn _, _ -> "Loading" end}
      })

    assert [_] = Regex.scan(~r/<a\b/, result)
    assert result =~ "btn-loading"
    assert result =~ ~s[aria-disabled="true"]
    assert result =~ ~s[aria-busy="true"]
    refute result =~ ~s[href=]
  end

  test "renders button with noise effect" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "Noise",
        inner_block: %{inner_block: fn _, _ -> "Noise Button" end}
      })

    assert result =~ "btn-noise"
    assert result =~ ~s[data-content="Noise"]
    assert result =~ ~s[<i></i>]
  end

  test "renders noise button inner_block in sr-only span" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "SUBMIT",
        inner_block: %{inner_block: fn _, _ -> "Submit form" end}
      })

    assert result =~ "sr-only"
    assert result =~ "Submit form"
  end

  test "renders button with confirmation modal" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<button]
    assert result =~ ~s[command="show-modal"]
    assert result =~ ~s[commandfor="confirm-dialog-]
    assert result =~ ~s[<dialog id="confirm-dialog-]
    assert result =~ "dialog-sm"
    refute result =~ "el-dm-dialog"
    assert result =~ ~s[Are you sure?]
    assert result =~ ~s[Yes]
    assert result =~ ~s[command="close"]
    assert result =~ ~s[Cancel]
  end

  test "renders confirmation as a native modal with safe focus management" do
    result =
      render_component(&dm_btn/1, %{
        id: "remove",
        confirm: "Remove?",
        "phx-click": "remove",
        inner_block: %{inner_block: fn _, _ -> "Remove" end}
      })

    assert result =~ ~s[command="show-modal"]
    assert result =~ ~s[<dialog id="confirm-dialog-remove"]
    assert result =~ ~s[autofocus]
    assert result =~ ~s[data-dm-confirm-dialog="true"]
    assert length(String.split(result, ~s[command="close"])) - 1 == 2
    assert length(String.split(result, ~s[phx-click="remove"])) - 1 == 1
    refute result =~ ~s[popover]
    refute result =~ ~s[role="dialog"]
  end

  test "renders confirm modal with one implicit dialog role" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[<dialog]
    refute result =~ ~s[role="dialog"]
  end

  test "confirm modal has aria-label fallback when no title" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[aria-label="Confirmation"]
  end

  test "confirm modal has aria-labelledby when title is provided" do
    result =
      render_component(&dm_btn/1, %{
        id: "del-btn",
        confirm: "Are you sure?",
        confirm_title: "Confirm Delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[aria-labelledby="confirm-dialog-del-btn-title"]
    refute result =~ ~s[aria-label="Confirmation"]
  end

  test "renders button with confirmation modal and custom title" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_title: "Confirm Delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[Confirm Delete]
    assert result =~ ~s[Are you sure?]
  end

  test "renders button with confirmation modal and custom classes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        confirm_class: "my-confirm-class",
        cancel_class: "my-cancel-class",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "my-confirm-class"
    assert result =~ "my-cancel-class"
  end

  test "renders button with confirmation modal without cancel action" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        show_cancel_action: false,
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

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
    # Variants that map directly to the custom element
    for variant <- ~w(primary secondary ghost outline) do
      result =
        render_component(&dm_btn/1, %{
          variant: variant,
          inner_block: %{inner_block: fn _, _ -> "Btn" end}
        })

      assert result =~ ~s[variant="#{variant}"]
    end

    # accent maps to tertiary
    result =
      render_component(&dm_btn/1, %{
        variant: "accent",
        inner_block: %{inner_block: fn _, _ -> "Btn" end}
      })

    assert result =~ ~s[variant="tertiary"]

    # link maps to ghost
    result =
      render_component(&dm_btn/1, %{
        variant: "link",
        inner_block: %{inner_block: fn _, _ -> "Btn" end}
      })

    assert result =~ ~s[variant="ghost"]

    # Semantic variants map to primary with color overrides
    for variant <- ~w(info success warning error) do
      result =
        render_component(&dm_btn/1, %{
          variant: variant,
          inner_block: %{inner_block: fn _, _ -> "Btn" end}
        })

      assert result =~ ~s[variant="primary"]
      assert result =~ "--color-primary: var(--color-#{variant})"
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

  test "renders noise button with 72 i elements" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "X",
        inner_block: %{inner_block: fn _, _ -> "" end}
      })

    # 1..72 = 72 elements matching CSS nth-child rules
    i_count = length(String.split(result, "<i></i>")) - 1
    assert i_count == 72
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

  test "renders button with confirm modal title only when title is non-empty" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Sure?",
        confirm_title: "",
        inner_block: %{inner_block: fn _, _ -> "Go" end}
      })

    refute result =~ ~s[-title"]
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
    assert result =~ ~s[variant="primary"]
    assert result =~ "--color-primary: var(--color-error)"
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

  test "renders confirm button with variant classes on outer button" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Delete?",
        variant: "error",
        size: "sm",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "btn-primary"
    assert result =~ "btn-sm"
    assert result =~ "--color-primary: var(--color-error)"
  end

  test "renders confirm modal Yes button passes rest attributes" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        "phx-click": "delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[phx-click="delete"]
  end

  test "confirm modal preserves a custom confirm command target" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Continue?",
        command: "show-modal",
        commandfor: "next-dialog",
        inner_block: %{inner_block: fn _, _ -> "Continue" end}
      })

    assert result =~ ~s[data-dm-confirm-action="true"]
    assert result =~ ~s[command="show-modal"]
    assert result =~ ~s[commandfor="next-dialog"]
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

  test "renders button with command as native button" do
    result =
      render_component(&dm_btn/1, %{
        command: "show-modal",
        commandfor: "my-modal",
        variant: "primary",
        inner_block: %{inner_block: fn _, _ -> "Open" end}
      })

    assert result =~ ~s[<button]
    assert result =~ ~s[command="show-modal"]
    assert result =~ ~s[commandfor="my-modal"]
    assert result =~ "btn-primary"
    refute result =~ "el-dm-button"
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

  test "renders opt-in native submit control for no-JS forms" do
    result =
      render_component(&dm_btn/1, %{
        native_submit: true,
        id: "save-settings",
        variant: "error",
        size: "lg",
        shape: "square",
        class: "settings-submit",
        form: "settings-form",
        name: "action",
        value: "save",
        "aria-label": "Save settings",
        "data-testid": "settings-submit",
        inner_block: %{inner_block: fn _, _ -> "Save" end}
      })

    assert [_] = Regex.scan(~r/<button\b/, result)
    assert result =~ ~s[type="submit"]
    assert result =~ ~s[class="btn btn-primary btn-lg btn-square settings-submit"]
    assert result =~ "--color-primary: var(--color-error)"
    assert result =~ ~s[form="settings-form"]
    assert result =~ ~s[name="action"]
    assert result =~ ~s[value="save"]
    assert result =~ ~s[aria-label="Save settings"]
    assert result =~ ~s[data-testid="settings-submit"]
    refute result =~ "<el-dm-button"
    refute result =~ "requestSubmit"
  end

  test "native submit confirmation keeps the confirmed action as the submitter" do
    result =
      render_component(&dm_btn/1, %{
        native_submit: true,
        id: "delete-settings",
        variant: "error",
        confirm: "Delete these settings?",
        form: "settings-form",
        name: "action",
        value: "delete",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ ~s[command="show-modal"]
    assert result =~ ~s[data-dm-confirm-action="true"]
    assert [_] = Regex.scan(~r/<button\b[^>]*type="submit"[^>]*>/, result)
    assert result =~ ~s[form="settings-form"]
    assert result =~ ~s[name="action"]
    assert result =~ ~s[value="delete"]
    refute result =~ "requestSubmit"
  end

  test "renders submit button with native form submit bridge" do
    result =
      render_component(&dm_btn/1, %{
        type: "submit",
        name: "action",
        value: "save",
        form: "note-form",
        inner_block: %{inner_block: fn _, _ -> "Save" end}
      })

    assert result =~ "document.createElement"
    assert result =~ "requestSubmit(submitter)"
    assert result =~ "submitter.name"
    assert result =~ "submitter.value"
    assert result =~ "getAttribute(&#39;form&#39;)"
  end

  test "does not render submit bridge for non-submit buttons" do
    result =
      render_component(&dm_btn/1, %{
        type: "button",
        inner_block: %{inner_block: fn _, _ -> "Cancel" end}
      })

    refute result =~ "requestSubmit"
  end

  test "merges custom onclick with submit bridge" do
    result =
      render_component(&dm_btn/1, %{
        type: "submit",
        onclick: "window.beforeSubmit()",
        inner_block: %{inner_block: fn _, _ -> "Save" end}
      })

    assert result =~ "window.beforeSubmit()"
    assert result =~ "requestSubmit(submitter)"
  end

  test "renders confirm modal with empty confirm_action shows default Yes button" do
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

  test "renders confirm modal with custom confirm_text" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Delete this?",
        confirm_text: "Confirm",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "Confirm"
    refute result =~ ">Yes<"
  end

  test "renders confirm modal with custom cancel_text" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Delete this?",
        cancel_text: "No",
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "No"
  end

  test "renders confirm modal with custom confirm_text and cancel_text" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Really?",
        confirm_text: "Do it",
        cancel_text: "Nope",
        inner_block: %{inner_block: fn _, _ -> "Action" end}
      })

    assert result =~ "Do it"
    assert result =~ "Nope"
    refute result =~ ">Yes<"
    refute result =~ ">Cancel<"
  end

  test "renders button with prefix slot" do
    result =
      render_component(&dm_btn/1, %{
        prefix: [%{inner_block: fn _, _ -> "ICON" end}],
        inner_block: %{inner_block: fn _, _ -> "Save" end}
      })

    assert result =~ ~s[slot="prefix"]
    assert result =~ "ICON"
    assert result =~ "Save"
  end

  test "renders button with suffix slot" do
    result =
      render_component(&dm_btn/1, %{
        suffix: [%{inner_block: fn _, _ -> "ARROW" end}],
        inner_block: %{inner_block: fn _, _ -> "Next" end}
      })

    assert result =~ ~s[slot="suffix"]
    assert result =~ "ARROW"
    assert result =~ "Next"
  end

  test "renders button with both prefix and suffix slots" do
    result =
      render_component(&dm_btn/1, %{
        prefix: [%{inner_block: fn _, _ -> "LEFT" end}],
        suffix: [%{inner_block: fn _, _ -> "RIGHT" end}],
        inner_block: %{inner_block: fn _, _ -> "Center" end}
      })

    assert result =~ ~s[slot="prefix"]
    assert result =~ ~s[slot="suffix"]
    assert result =~ "LEFT"
    assert result =~ "RIGHT"
    assert result =~ "Center"
  end

  test "renders button without prefix/suffix when not provided" do
    result =
      render_component(&dm_btn/1, %{
        inner_block: %{inner_block: fn _, _ -> "Simple" end}
      })

    refute result =~ ~s[slot="prefix"]
    refute result =~ ~s[slot="suffix"]
  end

  test "renders confirm button with prefix and suffix slots" do
    result =
      render_component(&dm_btn/1, %{
        confirm: "Are you sure?",
        prefix: [%{inner_block: fn _, _ -> "WARN" end}],
        inner_block: %{inner_block: fn _, _ -> "Delete" end}
      })

    assert result =~ "WARN"
    assert result =~ "Delete"
  end

  test "noise button has type=button to prevent form submission" do
    result =
      render_component(&dm_btn/1, %{
        noise: true,
        content: "Click me"
      })

    assert result =~ ~s[type="button"]
  end

  describe "confirm_label i18n" do
    test "custom confirm_label" do
      result =
        render_component(&dm_btn/1, %{
          confirm: "Are you sure?",
          confirm_label: "Bestätigung",
          inner_block: %{inner_block: fn _, _ -> "Delete" end}
        })

      assert result =~ ~s[aria-label="Bestätigung"]
      refute result =~ ~s[aria-label="Confirmation"]
    end
  end
end
