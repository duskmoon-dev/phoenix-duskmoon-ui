defmodule PhoenixDuskmoon.Component.Feedback.DialogTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Feedback.Dialog

  defp body(text \\ "Content") do
    [%{inner_block: fn _, _ -> text end}]
  end

  test "renders basic modal with native dialog element" do
    result = render_component(&dm_modal/1, %{body: body("Modal content")})

    assert result =~ "<dialog"
    assert result =~ "dialog-box"
    assert result =~ "Modal content"
    assert result =~ "</dialog>"
    refute result =~ "el-dm-dialog"
  end

  test "renders dialog with dialog class" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[class="dialog]
  end

  test "renders modal with custom id" do
    result = render_component(&dm_modal/1, %{id: "my-dialog", body: body()})

    assert result =~ ~s[id="my-dialog"]
  end

  test "renders modal with auto-generated id when not provided" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[id="modal-]
  end

  test "renders modal with title in dialog-header" do
    result =
      render_component(&dm_modal/1, %{
        title: [%{inner_block: fn _, _ -> "Dialog Title" end}],
        body: body()
      })

    assert result =~ "Dialog Title"
    assert result =~ "dialog-header"
    assert result =~ "dialog-title"
  end

  test "renders modal with title class" do
    result =
      render_component(&dm_modal/1, %{
        title: [%{class: "title-custom", inner_block: fn _, _ -> "Title" end}],
        body: body()
      })

    assert result =~ "title-custom"
  end

  test "renders modal with body content" do
    result = render_component(&dm_modal/1, %{body: body("Body text here")})

    assert result =~ "Body text here"
    assert result =~ "dialog-body"
  end

  test "renders modal with body class" do
    result =
      render_component(&dm_modal/1, %{
        body: [%{class: "body-custom", inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "body-custom"
  end

  test "renders modal with footer slot" do
    result =
      render_component(&dm_modal/1, %{
        body: body(),
        footer: [%{inner_block: fn _, _ -> "Footer actions" end}]
      })

    assert result =~ "Footer actions"
    assert result =~ "dialog-footer"
  end

  test "renders modal with footer class" do
    result =
      render_component(&dm_modal/1, %{
        body: body(),
        footer: [%{class: "footer-custom", inner_block: fn _, _ -> "Actions" end}]
      })

    assert result =~ "footer-custom"
  end

  test "renders modal with close button by default" do
    result = render_component(&dm_modal/1, %{id: "close-test", body: body()})

    assert result =~ "dialog-close"
    assert result =~ ~s[command="close"]
    assert result =~ ~s[commandfor="close-test"]
  end

  test "renders modal with hidden close button" do
    result = render_component(&dm_modal/1, %{hide_close: true, body: body()})

    refute result =~ "dialog-close"
    refute result =~ ~s[command="close"]
  end

  test "renders modal with position classes" do
    assert render_component(&dm_modal/1, %{position: "top", body: body()}) =~ "dialog-top"
    assert render_component(&dm_modal/1, %{position: "bottom", body: body()}) =~ "dialog-bottom"

    middle = render_component(&dm_modal/1, %{position: "middle", body: body()})
    refute middle =~ "dialog-top"
    refute middle =~ "dialog-bottom"
  end

  test "renders modal with size classes" do
    assert render_component(&dm_modal/1, %{size: "sm", body: body()}) =~ "dialog-sm"
    assert render_component(&dm_modal/1, %{size: "lg", body: body()}) =~ "dialog-lg"
    assert render_component(&dm_modal/1, %{size: "xl", body: body()}) =~ "dialog-xl"

    for size <- ~w(xs md) do
      result = render_component(&dm_modal/1, %{size: size, body: body()})
      refute result =~ "dialog-xs"
      refute result =~ "dialog-md"
      refute result =~ "dialog-sm"
      refute result =~ "dialog-lg"
      refute result =~ "dialog-xl"
    end
  end

  test "renders modal with custom class" do
    result = render_component(&dm_modal/1, %{class: "my-modal", body: body()})

    assert result =~ "my-modal"
  end

  test "renders modal with rest attributes" do
    result =
      render_component(&dm_modal/1, %{
        body: body(),
        "data-testid": "confirm-dialog"
      })

    assert result =~ "data-testid=\"confirm-dialog\""
  end

  test "renders modal with trigger slot" do
    result =
      render_component(&dm_modal/1, %{
        id: "test-modal",
        trigger: [%{inner_block: fn _, id -> "Open #{id}" end}],
        body: body()
      })

    assert result =~ "Open test-modal"
  end

  test "renders modal without title header when no title and hide_close" do
    result = render_component(&dm_modal/1, %{hide_close: true, body: body()})

    refute result =~ "dialog-header"
    refute result =~ "dialog-title"
  end

  test "renders modal without footer when no footer slot" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ "dialog-footer"
  end

  test "renders modal with title, body, and footer combined" do
    result =
      render_component(&dm_modal/1, %{
        title: [%{inner_block: fn _, _ -> "Confirm" end}],
        body: body("Are you sure?"),
        footer: [%{inner_block: fn _, _ -> "OK Cancel" end}]
      })

    assert result =~ "Confirm"
    assert result =~ "Are you sure?"
    assert result =~ "OK Cancel"
  end

  test "renders modal with size and position combined" do
    result =
      render_component(&dm_modal/1, %{
        position: "bottom",
        size: "lg",
        body: body()
      })

    assert result =~ "dialog-bottom"
    assert result =~ "dialog-lg"
  end

  test "renders modal without position class by default" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ "dialog-top"
    refute result =~ "dialog-bottom"
  end

  test "renders close button with aria-label Close" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[aria-label="Close"]
  end

  test "renders modal without trigger when trigger slot omitted" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ "<dialog"
  end

  test "renders modal with multiple body slots" do
    result =
      render_component(&dm_modal/1, %{
        body: [
          %{inner_block: fn _, _ -> "Body part 1" end},
          %{inner_block: fn _, _ -> "Body part 2" end}
        ]
      })

    assert result =~ "Body part 1"
    assert result =~ "Body part 2"
  end

  test "renders modal with all options combined" do
    result =
      render_component(&dm_modal/1, %{
        id: "full-modal",
        class: "custom-modal",
        position: "top",
        size: "lg",
        title: [%{class: "title-cls", inner_block: fn _, _ -> "Title" end}],
        body: [%{class: "body-cls", inner_block: fn _, _ -> "Body" end}],
        footer: [%{class: "footer-cls", inner_block: fn _, _ -> "Footer" end}],
        "data-testid": "full-modal"
      })

    assert result =~ ~s[id="full-modal"]
    assert result =~ "custom-modal"
    assert result =~ "dialog-top"
    assert result =~ "dialog-lg"
    assert result =~ "Title"
    assert result =~ "title-cls"
    assert result =~ "Body"
    assert result =~ "body-cls"
    assert result =~ "Footer"
    assert result =~ "footer-cls"
    assert result =~ "data-testid=\"full-modal\""
  end

  test "renders modal with multiple title slots" do
    result =
      render_component(&dm_modal/1, %{
        title: [
          %{inner_block: fn _, _ -> "Title One" end},
          %{inner_block: fn _, _ -> "Title Two" end}
        ],
        body: body()
      })

    assert result =~ "Title One"
    assert result =~ "Title Two"
  end

  test "renders modal with multiple footer slots" do
    result =
      render_component(&dm_modal/1, %{
        body: body(),
        footer: [
          %{inner_block: fn _, _ -> "Action A" end},
          %{inner_block: fn _, _ -> "Action B" end}
        ]
      })

    assert result =~ "Action A"
    assert result =~ "Action B"
  end

  test "renders modal with aria-labelledby pointing to title" do
    result =
      render_component(&dm_modal/1, %{
        id: "titled-dialog",
        title: [%{inner_block: fn _, _ -> "My Title" end}],
        body: body()
      })

    assert result =~ ~s[aria-labelledby="titled-dialog-title"]
    assert result =~ ~s[id="titled-dialog-title"]
  end

  test "renders modal without aria-labelledby when no title" do
    result =
      render_component(&dm_modal/1, %{
        id: "untitled-dialog",
        body: body()
      })

    refute result =~ "aria-labelledby"
  end

  test "renders modal with default close_label Close" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[aria-label="Close"]
  end

  test "renders modal with custom close_label" do
    result =
      render_component(&dm_modal/1, %{
        body: body(),
        close_label: "Dismiss"
      })

    assert result =~ ~s[aria-label="Dismiss"]
  end

  test "renders aria-label fallback when no title slot provided" do
    result =
      render_component(&dm_modal/1, %{
        id: "no-title-dialog",
        body: body()
      })

    assert result =~ ~s[aria-label="Dialog"]
    refute result =~ "aria-labelledby"
  end

  test "does not render aria-label when title slot is present" do
    result =
      render_component(&dm_modal/1, %{
        id: "titled-dialog",
        title: [%{inner_block: fn _, _ -> "My Title" end}],
        body: body()
      })

    assert result =~ ~s[aria-labelledby="titled-dialog-title"]
    refute result =~ ~s[aria-label="Dialog"]
  end

  test "only first title slot gets the id for aria-labelledby" do
    result =
      render_component(&dm_modal/1, %{
        id: "multi-title",
        title: [
          %{inner_block: fn _, _ -> "Primary Title" end},
          %{inner_block: fn _, _ -> "Subtitle" end}
        ],
        body: body()
      })

    assert result =~ ~s[aria-labelledby="multi-title-title"]
    id_count = length(String.split(result, ~s[id="multi-title-title"])) - 1
    assert id_count == 1
    assert result =~ "Primary Title"
    assert result =~ "Subtitle"
  end

  describe "dialog_label i18n" do
    test "custom dialog_label when no title" do
      result =
        render_component(&dm_modal/1, %{
          id: "dl",
          body: body(),
          dialog_label: "Dialogue"
        })

      assert result =~ ~s[aria-label="Dialogue"]
      refute result =~ ~s[aria-label="Dialog"]
    end
  end
end
