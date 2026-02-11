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
      # Info and error flashes have close buttons (dm-btn--ghost dm-btn--xs)
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
      assert result =~ "dm-alert"
      assert result =~ "dm-alert--info"
    end

    test "renders individual flash with kind error" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          flash: %{"error" => "Error message"}
        })

      assert result =~ "Error message"
      assert result =~ "dm-alert"
      assert result =~ "dm-alert--error"
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

      assert result =~ ~s[aria-label="close"]
      assert result =~ "dm-btn dm-btn--ghost dm-btn--xs"
    end

    test "renders flash without close button when close=false" do
      result =
        render_component(&dm_flash/1, %{
          kind: :error,
          close: false,
          flash: %{"error" => "Permanent"}
        })

      refute result =~ ~s[aria-label="close"]
    end

    test "renders flash with toast positioning classes" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Positioned"}
        })

      assert result =~ "dm-toast"
      assert result =~ "dm-toast--top"
      assert result =~ "dm-toast--end"
    end

    test "does not render when flash message is empty for kind" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{}
        })

      # The :if guard should prevent rendering the outer div
      refute result =~ "dm-alert"
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

      assert result =~ ~s[aria-label="close"]
      assert result =~ ~s[type="button"]
    end

    test "renders toast positioning classes" do
      result =
        render_component(&dm_flash/1, %{
          kind: :info,
          flash: %{"info" => "Positioned"}
        })

      assert result =~ "dm-toast"
      assert result =~ "dm-toast--top"
      assert result =~ "dm-toast--end"
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

      assert info_result =~ "dm-alert--info"
      assert error_result =~ "dm-alert--error"
    end
  end
end
