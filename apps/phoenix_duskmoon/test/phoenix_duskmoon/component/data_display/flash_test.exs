defmodule PhoenixDuskmoon.Component.DataDisplay.FlashTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Flash

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

    assert result =~ "dm-toast"
  end

  test "renders individual flash with kind info" do
    result =
      render_component(&dm_flash/1, %{
        kind: :info,
        flash: %{"info" => "Info message"}
      })

    assert result =~ "Info message"
    assert result =~ "dm-alert"
  end

  test "renders individual flash with kind error" do
    result =
      render_component(&dm_flash/1, %{
        kind: :error,
        flash: %{"error" => "Error message"}
      })

    assert result =~ "Error message"
    assert result =~ "dm-alert"
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
end
