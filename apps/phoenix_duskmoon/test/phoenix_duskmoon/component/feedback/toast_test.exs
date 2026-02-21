defmodule PhoenixDuskmoon.Component.Feedback.ToastTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.Feedback.Toast

  describe "dm_toast_container" do
    test "renders container with default position" do
      result =
        render_component(&dm_toast_container/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container"
      assert result =~ "toast-container-top-right"
    end

    test "renders with top-left position" do
      result =
        render_component(&dm_toast_container/1, %{
          position: "top-left",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container-top-left"
    end

    test "renders with top-center position" do
      result =
        render_component(&dm_toast_container/1, %{
          position: "top-center",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container-top-center"
    end

    test "renders with bottom-right position" do
      result =
        render_component(&dm_toast_container/1, %{
          position: "bottom-right",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container-bottom-right"
    end

    test "renders with bottom-left position" do
      result =
        render_component(&dm_toast_container/1, %{
          position: "bottom-left",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container-bottom-left"
    end

    test "renders with bottom-center position" do
      result =
        render_component(&dm_toast_container/1, %{
          position: "bottom-center",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ "toast-container-bottom-center"
    end

    test "renders with custom id and class" do
      result =
        render_component(&dm_toast_container/1, %{
          id: "my-toasts",
          class: "z-50",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "content" end}]
        })

      assert result =~ ~s(id="my-toasts")
      assert result =~ "z-50"
    end
  end

  describe "dm_toast basic rendering" do
    test "renders toast with role alert" do
      result = render_component(&dm_toast/1, %{})
      assert result =~ "toast"
      assert result =~ ~s(role="alert")
    end

    test "renders with aria-live assertive" do
      result = render_component(&dm_toast/1, %{})
      assert result =~ ~s(aria-live="assertive")
    end

    test "renders with aria-atomic true" do
      result = render_component(&dm_toast/1, %{})
      assert result =~ ~s(aria-atomic="true")
    end

    test "renders with custom id" do
      result = render_component(&dm_toast/1, %{id: "my-toast"})
      assert result =~ ~s(id="my-toast")
    end

    test "renders with custom class" do
      result = render_component(&dm_toast/1, %{class: "custom-toast"})
      assert result =~ "custom-toast"
    end

    test "renders message content via inner_block" do
      result =
        render_component(&dm_toast/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Hello world" end}]
        })

      assert result =~ "Hello world"
      assert result =~ "toast-message"
    end

    test "renders title" do
      result = render_component(&dm_toast/1, %{title: "Success!"})
      assert result =~ "Success!"
      assert result =~ "toast-title"
    end
  end

  describe "dm_toast type variants" do
    test "renders info type" do
      result = render_component(&dm_toast/1, %{type: "info"})
      assert result =~ "toast-info"
    end

    test "renders success type" do
      result = render_component(&dm_toast/1, %{type: "success"})
      assert result =~ "toast-success"
    end

    test "renders warning type" do
      result = render_component(&dm_toast/1, %{type: "warning"})
      assert result =~ "toast-warning"
    end

    test "renders error type" do
      result = render_component(&dm_toast/1, %{type: "error"})
      assert result =~ "toast-error"
    end

    test "no type class by default" do
      result = render_component(&dm_toast/1, %{})
      refute result =~ "toast-info"
      refute result =~ "toast-success"
      refute result =~ "toast-warning"
      refute result =~ "toast-error"
    end
  end

  describe "dm_toast filled variant" do
    test "renders filled style" do
      result = render_component(&dm_toast/1, %{type: "success", filled: true})
      assert result =~ "toast-filled"
      assert result =~ "toast-success"
    end

    test "not filled by default" do
      result = render_component(&dm_toast/1, %{})
      refute result =~ "toast-filled"
    end
  end

  describe "dm_toast open state" do
    test "renders toast-open when open" do
      result = render_component(&dm_toast/1, %{open: true})
      assert result =~ "toast-open"
    end

    test "no toast-open when closed" do
      result = render_component(&dm_toast/1, %{})
      refute result =~ "toast-open"
    end
  end

  describe "dm_toast icon" do
    test "renders icon when provided" do
      result = render_component(&dm_toast/1, %{icon: "check-circle"})
      assert result =~ "toast-icon"
    end

    test "no icon by default" do
      result = render_component(&dm_toast/1, %{})
      refute result =~ "toast-icon"
    end

    test "icon wrapper has aria-hidden" do
      result = render_component(&dm_toast/1, %{icon: "alert-circle"})
      assert result =~ ~s(aria-hidden="true")
    end
  end

  describe "dm_toast close button" do
    test "renders close button when show_close" do
      result = render_component(&dm_toast/1, %{show_close: true})
      assert result =~ "toast-close"
      assert result =~ ~s(aria-label="Close")
    end

    test "no close button by default" do
      result = render_component(&dm_toast/1, %{})
      refute result =~ "toast-close"
    end
  end

  describe "dm_toast combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_toast/1, %{
          id: "notif-1",
          type: "success",
          title: "Saved",
          icon: "check-circle",
          filled: true,
          open: true,
          show_close: true,
          class: "mb-2",
          inner_block: [
            %{__slot__: :inner_block, inner_block: fn _, _ -> "Changes saved." end}
          ]
        })

      assert result =~ ~s(id="notif-1")
      assert result =~ "toast-success"
      assert result =~ "toast-filled"
      assert result =~ "toast-open"
      assert result =~ "Saved"
      assert result =~ "Changes saved."
      assert result =~ "toast-icon"
      assert result =~ "toast-close"
      assert result =~ "mb-2"
    end
  end
end
