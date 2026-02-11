defmodule PhoenixDuskmoon.Component.Feedback.DialogTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Feedback.Dialog

  defp body(text \\ "Content") do
    [%{inner_block: fn _, _ -> text end}]
  end

  test "renders basic modal with el-dm-dialog element" do
    result = render_component(&dm_modal/1, %{body: body("Modal content")})

    assert result =~ "<el-dm-dialog"
    assert result =~ "Modal content"
    assert result =~ "</el-dm-dialog>"
  end

  test "renders dialog with role and aria-modal attributes" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[role="dialog"]
    assert result =~ ~s[aria-modal="true"]
  end

  test "renders modal with custom id" do
    result = render_component(&dm_modal/1, %{id: "my-dialog", body: body()})

    assert result =~ ~s[id="my-dialog"]
  end

  test "renders modal with auto-generated id when not provided" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[id="modal-]
  end

  test "renders modal with title slot in header" do
    result =
      render_component(&dm_modal/1, %{
        title: [%{inner_block: fn _, _ -> "Dialog Title" end}],
        body: body()
      })

    assert result =~ "Dialog Title"
    assert result =~ ~s[slot="header"]
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
    assert result =~ ~s[slot="footer"]
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
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[method="dialog"]
    assert result =~ "el-dm-button"
  end

  test "renders modal with hidden close button" do
    result = render_component(&dm_modal/1, %{hide_close: true, body: body()})

    refute result =~ ~s[method="dialog"]
  end

  test "renders modal with backdrop blur" do
    result = render_component(&dm_modal/1, %{backdrop: true, body: body()})

    assert result =~ ~s[backdrop="blur"]
  end

  test "renders modal without backdrop by default" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[backdrop="blur"]
  end

  test "renders modal with position" do
    for position <- ~w(top middle bottom) do
      result = render_component(&dm_modal/1, %{position: position, body: body()})
      assert result =~ ~s[position="#{position}"]
    end
  end

  test "renders modal with size" do
    for size <- ~w(xs sm md lg xl) do
      result = render_component(&dm_modal/1, %{size: size, body: body()})
      assert result =~ ~s[size="#{size}"]
    end
  end

  test "renders modal with responsive" do
    result = render_component(&dm_modal/1, %{responsive: true, body: body()})

    assert result =~ "responsive"
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

  test "renders modal without title header when no title" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[slot="header"]
  end

  test "renders modal without footer when no footer slot" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[slot="footer"]
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

  test "renders modal with backdrop and position combined" do
    result =
      render_component(&dm_modal/1, %{
        backdrop: true,
        position: "bottom",
        body: body()
      })

    assert result =~ ~s[backdrop="blur"]
    assert result =~ ~s[position="bottom"]
  end

  test "renders modal without position by default" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[position="]
  end

  test "renders close button with aria-label Close" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[aria-label="Close"]
  end

  test "renders modal without trigger when trigger slot omitted" do
    result = render_component(&dm_modal/1, %{body: body()})

    # No trigger-related content outside the dialog
    assert result =~ "<el-dm-dialog"
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

  test "renders modal backdrop attribute absent when backdrop false" do
    result = render_component(&dm_modal/1, %{backdrop: false, body: body()})

    # When backdrop is false, `@backdrop && "blur"` evaluates to false,
    # and Phoenix suppresses the attribute entirely
    refute result =~ "backdrop="
  end

  test "renders modal with responsive and size combined" do
    result =
      render_component(&dm_modal/1, %{
        responsive: true,
        size: "lg",
        body: body()
      })

    assert result =~ "responsive"
    assert result =~ ~s[size="lg"]
  end

  test "renders modal with all options combined" do
    result =
      render_component(&dm_modal/1, %{
        id: "full-modal",
        class: "custom-modal",
        backdrop: true,
        position: "middle",
        size: "md",
        responsive: true,
        title: [%{class: "title-cls", inner_block: fn _, _ -> "Title" end}],
        body: [%{class: "body-cls", inner_block: fn _, _ -> "Body" end}],
        footer: [%{class: "footer-cls", inner_block: fn _, _ -> "Footer" end}],
        "data-testid": "full-modal"
      })

    assert result =~ ~s[id="full-modal"]
    assert result =~ "custom-modal"
    assert result =~ ~s[backdrop="blur"]
    assert result =~ ~s[position="middle"]
    assert result =~ ~s[size="md"]
    assert result =~ "responsive"
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
    # Each title gets its own span with slot="header"
    header_count = length(String.split(result, ~s[slot="header"])) - 1
    assert header_count == 2
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
    footer_count = length(String.split(result, ~s[slot="footer"])) - 1
    assert footer_count == 2
  end

  test "renders modal close button with aria-label" do
    result = render_component(&dm_modal/1, %{body: body()})

    assert result =~ ~s[aria-label="Close"]
    assert result =~ ~s[method="dialog"]
  end

  test "renders modal without title slot when not provided" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[slot="header"]
  end

  test "renders modal without footer slot when not provided" do
    result = render_component(&dm_modal/1, %{body: body()})

    refute result =~ ~s[slot="footer"]
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
end
