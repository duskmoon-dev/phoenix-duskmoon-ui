defmodule PhoenixDuskmoon.Component.Feedback.SnackbarTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Feedback.Snackbar

  defp basic_message do
    [%{__slot__: :message, inner_block: fn _, _ -> "File saved" end}]
  end

  describe "dm_snackbar basic rendering" do
    test "renders snackbar container" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      assert result =~ "snackbar"
      assert result =~ "snackbar-message"
    end

    test "renders message content" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      assert result =~ "File saved"
    end

    test "renders with custom id" do
      result = render_component(&dm_snackbar/1, %{id: "save-msg", message: basic_message()})
      assert result =~ ~s(id="save-msg")
    end

    test "renders with custom class" do
      result = render_component(&dm_snackbar/1, %{class: "mt-4", message: basic_message()})
      assert result =~ "mt-4"
    end

    test "renders role=alert" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      assert result =~ ~s(role="alert")
    end
  end

  describe "dm_snackbar types" do
    test "no type class by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-info"
      refute result =~ "snackbar-success"
    end

    for type <- ~w(info success warning error primary secondary tertiary dark) do
      test "renders #{type} type" do
        result =
          render_component(&dm_snackbar/1, %{type: unquote(type), message: basic_message()})

        assert result =~ "snackbar-#{unquote(type)}"
      end
    end
  end

  describe "dm_snackbar open state" do
    test "not open by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-show"
    end

    test "renders open state" do
      result = render_component(&dm_snackbar/1, %{open: true, message: basic_message()})
      assert result =~ "snackbar-show"
    end
  end

  describe "dm_snackbar multiline" do
    test "not multiline by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-multiline"
    end

    test "renders multiline layout" do
      result = render_component(&dm_snackbar/1, %{multiline: true, message: basic_message()})
      assert result =~ "snackbar-multiline"
    end
  end

  describe "dm_snackbar position" do
    test "no position by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-bottom"
      refute result =~ "snackbar-top"
    end

    for pos <- ~w(bottom bottom-left bottom-right top top-left top-right) do
      test "renders #{pos} position" do
        result =
          render_component(&dm_snackbar/1, %{position: unquote(pos), message: basic_message()})

        assert result =~ "snackbar-#{unquote(pos)}"
      end
    end
  end

  describe "dm_snackbar action slot" do
    test "renders action button" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          action: [%{__slot__: :action, inner_block: fn _, _ -> "Undo" end}]
        })

      assert result =~ "snackbar-action"
      assert result =~ "Undo"
    end

    test "action button has type=button" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          action: [%{__slot__: :action, inner_block: fn _, _ -> "Undo" end}]
        })

      assert result =~ ~s(type="button")
    end

    test "renders multiple action buttons" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          action: [
            %{__slot__: :action, inner_block: fn _, _ -> "Retry" end},
            %{__slot__: :action, inner_block: fn _, _ -> "Dismiss" end}
          ]
        })

      assert result =~ "Retry"
      assert result =~ "Dismiss"
    end

    test "no action by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-action"
    end
  end

  describe "dm_snackbar close slot" do
    test "renders close button" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          close: [%{__slot__: :close, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ "snackbar-close"
    end

    test "close button has aria-label" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          close: [%{__slot__: :close, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ ~s(aria-label="Close")
    end

    test "close button renders times character" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          close: [%{__slot__: :close, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ "&times;"
    end

    test "no close by default" do
      result = render_component(&dm_snackbar/1, %{message: basic_message()})
      refute result =~ "snackbar-close"
    end
  end

  describe "dm_snackbar combined" do
    test "renders with all options" do
      result =
        render_component(&dm_snackbar/1, %{
          id: "upload-msg",
          class: "mx-4",
          type: "success",
          open: true,
          multiline: true,
          message: basic_message(),
          action: [%{__slot__: :action, inner_block: fn _, _ -> "View" end}],
          close: [%{__slot__: :close, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ ~s(id="upload-msg")
      assert result =~ "mx-4"
      assert result =~ "snackbar-success"
      assert result =~ "snackbar-show"
      assert result =~ "snackbar-multiline"
      assert result =~ "File saved"
      assert result =~ "View"
      assert result =~ "snackbar-close"
    end
  end

  describe "dm_snackbar rest attrs" do
    test "passes rest attributes through" do
      result =
        render_component(&dm_snackbar/1, %{
          message: basic_message(),
          "data-testid": "my-snack"
        })

      assert result =~ ~s(data-testid="my-snack")
    end
  end

  describe "dm_snackbar position + type combined" do
    test "renders type and position together" do
      result =
        render_component(&dm_snackbar/1, %{
          type: "error",
          position: "top-right",
          open: true,
          multiline: true,
          message: basic_message()
        })

      assert result =~ "snackbar-error"
      assert result =~ "snackbar-top-right"
      assert result =~ "snackbar-show"
      assert result =~ "snackbar-multiline"
    end
  end

  describe "dm_snackbar_container" do
    test "renders container" do
      result =
        render_component(&dm_snackbar_container/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "children" end}]
        })

      assert result =~ "snackbar-container"
      assert result =~ "snackbar-container-bottom"
      assert result =~ "children"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_snackbar_container/1, %{
          id: "notifs",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ ~s(id="notifs")
    end

    for pos <- ~w(bottom bottom-left bottom-right top top-left top-right) do
      test "renders #{pos} position" do
        result =
          render_component(&dm_snackbar_container/1, %{
            position: unquote(pos),
            inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
          })

        assert result =~ "snackbar-container-#{unquote(pos)}"
      end
    end

    test "renders with custom class" do
      result =
        render_component(&dm_snackbar_container/1, %{
          class: "my-container",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ "my-container"
    end

    test "passes rest attributes through" do
      result =
        render_component(&dm_snackbar_container/1, %{
          "data-testid": "notif-container",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ ~s(data-testid="notif-container")
    end
  end
end
