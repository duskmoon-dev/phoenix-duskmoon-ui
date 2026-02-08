defmodule PhoenixDuskmoon.Component.Feedback.DialogTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Feedback.Dialog

  test "renders basic modal dialog" do
    result =
      render_component(&dm_modal/1, %{
        body: [%{inner_block: fn _, _ -> "Modal content" end}]
      })

    assert result =~ "<el-dm-dialog"
    assert result =~ "Modal content"
    assert result =~ "</el-dm-dialog>"
  end

  test "renders modal with id" do
    result =
      render_component(&dm_modal/1, %{
        id: "my-dialog",
        body: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[id="my-dialog"]
  end

  test "renders modal with title" do
    result =
      render_component(&dm_modal/1, %{
        title: [%{inner_block: fn _, _ -> "Dialog Title" end}],
        body: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "Dialog Title"
    assert result =~ ~s[slot="header"]
  end

  test "renders modal with footer" do
    result =
      render_component(&dm_modal/1, %{
        body: [%{inner_block: fn _, _ -> "Content" end}],
        footer: [%{inner_block: fn _, _ -> "Footer actions" end}]
      })

    assert result =~ "Footer actions"
    assert result =~ ~s[slot="footer"]
  end

  test "renders modal with hidden close button" do
    result =
      render_component(&dm_modal/1, %{
        hide_close: true,
        body: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "<el-dm-dialog"
  end

  test "renders modal with backdrop" do
    result =
      render_component(&dm_modal/1, %{
        backdrop: true,
        body: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ "<el-dm-dialog"
  end

  test "renders modal with size" do
    result =
      render_component(&dm_modal/1, %{
        size: "lg",
        body: [%{inner_block: fn _, _ -> "Content" end}]
      })

    assert result =~ ~s[size="lg"]
  end
end
