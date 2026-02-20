defmodule PhoenixDuskmoon.Component.Layout.DrawerTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Layout.Drawer

  defp inner_block(text), do: %{inner_block: fn _, _ -> text end}

  test "renders el-dm-drawer element" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Drawer content")
      })

    assert result =~ "<el-dm-drawer"
    assert result =~ "Drawer content"
  end

  test "renders with open attribute" do
    result =
      render_component(&dm_drawer/1, %{
        open: true,
        inner_block: inner_block("Open drawer")
      })

    assert result =~ "open"
  end

  test "renders with position right" do
    result =
      render_component(&dm_drawer/1, %{
        position: "right",
        inner_block: inner_block("Right drawer")
      })

    assert result =~ ~s(position="right")
  end

  test "renders default position left" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(position="left")
  end

  test "renders with modal attribute" do
    result =
      render_component(&dm_drawer/1, %{
        modal: true,
        inner_block: inner_block("Modal drawer")
      })

    assert result =~ "modal"
  end

  test "renders with custom width" do
    result =
      render_component(&dm_drawer/1, %{
        width: "400px",
        inner_block: inner_block("Wide drawer")
      })

    assert result =~ ~s(width="400px")
  end

  test "renders header slot" do
    result =
      render_component(&dm_drawer/1, %{
        header: [inner_block("My Title")],
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(slot="header")
    assert result =~ "My Title"
  end

  test "renders footer slot" do
    result =
      render_component(&dm_drawer/1, %{
        footer: [inner_block("Footer actions")],
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(slot="footer")
    assert result =~ "Footer actions"
  end

  test "renders with id attribute" do
    result =
      render_component(&dm_drawer/1, %{
        id: "nav-drawer",
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(id="nav-drawer")
  end

  test "omits header slot wrapper when no header provided" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Just content")
      })

    refute result =~ ~s(slot="header")
  end

  test "omits footer slot wrapper when no footer provided" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Just content")
      })

    refute result =~ ~s(slot="footer")
  end
end
