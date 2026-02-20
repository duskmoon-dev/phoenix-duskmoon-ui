defmodule PhoenixDuskmoon.Component.DataDisplay.FlashTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Flash

  describe "dm_flash_group/1" do
    test "renders flash group with info message" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "Operation successful"}
        })

      assert result =~ "Operation successful"
    end

    test "renders flash group with error message" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"error" => "Something went wrong"}
        })

      assert result =~ "Something went wrong"
    end

    test "renders flash group with empty flash" do
      result = render_component(&dm_flash_group/1, %{flash: %{}})

      # Disconnected flash is always rendered (inner_block content)
      assert result =~ "disconnected"
      assert result =~ "Attempting to reconnect"
    end

    test "renders flash group with both info and error" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "Saved!", "error" => "But warning!"}
        })

      assert result =~ "Saved!"
      assert result =~ "But warning!"
    end

    test "renders info flash with Success! title" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "Done"}
        })

      assert result =~ "Success!"
    end

    test "renders error flash with Error! title" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"error" => "Failed"}
        })

      assert result =~ "Error!"
    end

    test "renders disconnected flash with close=false" do
      result = render_component(&dm_flash_group/1, %{flash: %{}})

      # The disconnected flash should NOT have a close button
      # Info and error flashes have close buttons (btn-ghost btn-xs)
      # but the disconnected one should not since close={false}
      assert result =~ "We can&#39;t find the internet"
      assert result =~ "Attempting to reconnect"
    end

    test "renders flash group with specific ids" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "Info msg", "error" => "Error msg"}
        })

      assert result =~ ~s[id="flash-info"]
      assert result =~ ~s[id="flash-error"]
      assert result =~ ~s[id="disconnected"]
    end
  end

  describe "dm_flash/1" do
    test "renders individual flash with kind info" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Info message"}
        })

      assert result =~ "Info message"
      assert result =~ "alert"
      assert result =~ "alert-info"
    end

    test "renders individual flash with kind error" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          flash: %{"error" => "Error message"}
        })

      assert result =~ "Error message"
      assert result =~ "alert"
      assert result =~ "alert-error"
    end

    test "renders flash with title" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          title: "Success!",
          flash: %{"info" => "Done"}
        })

      assert result =~ "Success!"
    end

    test "renders flash with custom id" do
      result =
        render_component(&dm_flash/1, %{
          id: "custom-flash",
          kind: :info,
          flash: %{"info" => "Custom"}
        })

      assert result =~ ~s[id="custom-flash"]
    end

    test "renders flash with role alert for accessibility" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Accessible"}
        })

      assert result =~ ~s[role="alert"]
    end

    test "renders flash with close button by default" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Closeable"}
        })

      assert result =~ ~s[aria-label="Close"]
      assert result =~ "btn btn-ghost btn-xs"
    end

    test "renders flash without close button when close=false" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          close: false,
          flash: %{"error" => "Permanent"}
        })

      refute result =~ ~s[aria-label="Close"]
    end

    test "renders flash with toast positioning classes" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Positioned"}
        })

      assert result =~ "fixed"
      assert result =~ "top-4"
      assert result =~ "right-4"
    end

    test "does not render when flash message is empty for kind" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{}
        })

      # The :if guard should prevent rendering the outer div
      refute result =~ "alert"
    end

    test "does not render when flash has different kind" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"error" => "Only error"}
        })

      refute result =~ "Only error"
    end

    test "renders icon for info kind with title" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          title: "Info Title",
          flash: %{"info" => "Message"}
        })

      # Icons render as inline SVGs, check the title section renders
      assert result =~ "Info Title"
      assert result =~ "<svg"
    end

    test "renders icon for error kind with title" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          title: "Error Title",
          flash: %{"error" => "Message"}
        })

      assert result =~ "Error Title"
      assert result =~ "<svg"
    end

    test "does not render title section when title is nil" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "No title"}
        })

      # No title div should be present
      refute result =~ "info-circle"
      refute result =~ "exclamation-circle"
    end

    test "renders flash with rest attributes" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Test"},
          "data-testid": "flash-test"
        })

      assert result =~ ~s[data-testid="flash-test"]
    end

    test "renders flash with default id when not specified" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Default ID"}
        })

      assert result =~ ~s[id="flash"]
    end

    test "does not render icon when title is nil" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "No icon expected"}
        })

      assert result =~ "No icon expected"
      refute result =~ "info-circle"
    end

    test "renders close button with aria-label" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Close me"}
        })

      assert result =~ ~s[aria-label="Close"]
      assert result =~ ~s[type="button"]
    end

    test "renders toast positioning classes" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Positioned"}
        })

      assert result =~ "fixed"
      assert result =~ "top-4"
      assert result =~ "right-4"
    end

    test "renders dm-alert class with kind-specific variant" do
      info_result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Info alert"}
        })

      error_result =
        render_component(&dm_flash/1, %{
          kind: :error,
          flash: %{"error" => "Error alert"}
        })

      assert info_result =~ "alert-info"
      assert error_result =~ "alert-error"
    end

    test "renders flash with default Close aria-label on close button" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Test"}
        })

      assert result =~ ~s[aria-label="Close"]
    end

    test "renders flash with custom close_label" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          close_label: "Fermer",
          flash: %{"info" => "Test"}
        })

      assert result =~ ~s[aria-label="Fermer"]
    end
  end

  describe "dm_flash_group customizable titles" do
    test "renders flash group with custom info_title" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "Done"},
          info_title: "All good!"
        })

      assert result =~ "All good!"
      refute result =~ "Success!"
    end

    test "renders flash group with custom error_title" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"error" => "Failed"},
          error_title: "Oops!"
        })

      assert result =~ "Oops!"
      refute result =~ ">Error!<"
    end

    test "renders flash group with both custom titles" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{"info" => "OK", "error" => "Bad"},
          info_title: "Yay!",
          error_title: "Oh no!"
        })

      assert result =~ "Yay!"
      assert result =~ "Oh no!"
    end
  end

  describe "dm_flash autoshow attribute" do
    test "dm_flash with autoshow false does not set phx-mounted" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Test"},
          autoshow: false
        })

      refute result =~ "phx-mounted"
    end

    test "dm_flash with default autoshow sets phx-mounted" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Test"}
        })

      assert result =~ "phx-mounted"
    end
  end

  describe "dm_flash_group customizable disconnected messages" do
    test "renders flash group with custom disconnected_title" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{},
          disconnected_title: "No network"
        })

      assert result =~ "No network"
    end

    test "renders flash group with custom reconnecting_text" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{},
          reconnecting_text: "Trying again"
        })

      assert result =~ "Trying again"
    end

    test "renders flash group with both custom disconnected messages" do
      result =
        render_component(&dm_flash_group/1, %{
          flash: %{},
          disconnected_title: "Connection lost",
          reconnecting_text: "Reconnecting..."
        })

      assert result =~ "Connection lost"
      assert result =~ "Reconnecting..."
    end
  end

  describe "accessibility" do
    test "info flash uses aria-live polite" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Polite message"}
        })

      assert result =~ ~s[aria-live="polite"]
    end

    test "error flash uses aria-live assertive" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          flash: %{"error" => "Urgent message"}
        })

      assert result =~ ~s[aria-live="assertive"]
    end

    test "flash includes aria-atomic true" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Atomic message"}
        })

      assert result =~ ~s[aria-atomic="true"]
    end
  end
end
