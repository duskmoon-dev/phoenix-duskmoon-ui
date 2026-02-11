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
end
