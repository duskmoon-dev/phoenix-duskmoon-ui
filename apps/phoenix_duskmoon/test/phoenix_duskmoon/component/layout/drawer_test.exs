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

  test "does not render open when false" do
    result =
      render_component(&dm_drawer/1, %{
        open: false,
        inner_block: inner_block("Closed drawer")
      })

    refute result =~ ~r/\sopen[\s>]/
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

  test "does not render modal when false" do
    result =
      render_component(&dm_drawer/1, %{
        modal: false,
        inner_block: inner_block("Non-modal drawer")
      })

    refute result =~ ~r/\smodal[\s>]/
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

  test "renders with class attribute" do
    result =
      render_component(&dm_drawer/1, %{
        class: "my-drawer-class",
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(class="my-drawer-class")
  end

  test "renders empty class when class is nil" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    # Phoenix renders class="" for nil string attrs
    assert result =~ ~s(class="")
  end

  test "omits width when nil" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    refute result =~ ~r/width="/
  end

  test "renders width with vw units" do
    result =
      render_component(&dm_drawer/1, %{
        width: "30vw",
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(width="30vw")
  end

  test "renders width with percentage" do
    result =
      render_component(&dm_drawer/1, %{
        width: "50%",
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(width="50%")
  end

  test "renders both header and footer together" do
    result =
      render_component(&dm_drawer/1, %{
        header: [inner_block("Header Text")],
        footer: [inner_block("Footer Text")],
        inner_block: inner_block("Body Text")
      })

    assert result =~ ~s(slot="header")
    assert result =~ "Header Text"
    assert result =~ ~s(slot="footer")
    assert result =~ "Footer Text"
    assert result =~ "Body Text"
  end

  test "renders position right with modal" do
    result =
      render_component(&dm_drawer/1, %{
        position: "right",
        modal: true,
        inner_block: inner_block("Right modal drawer")
      })

    assert result =~ ~s(position="right")
    assert result =~ "modal"
  end

  test "passes rest attributes" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content"),
        data_testid: "drawer-test"
      })

    assert result =~ ~s(data_testid="drawer-test")
  end

  test "passes phx-hook via rest" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content"),
        phx_hook: "DrawerHook"
      })

    assert result =~ ~s(phx_hook="DrawerHook")
  end

  test "header slot wrapped in span element" do
    result =
      render_component(&dm_drawer/1, %{
        header: [inner_block("Wrapped Header")],
        inner_block: inner_block("Body")
      })

    assert result =~ ~s(<span)
    assert result =~ ~s(slot="header")
    assert result =~ "Wrapped Header"
  end

  test "footer slot wrapped in span element" do
    result =
      render_component(&dm_drawer/1, %{
        footer: [inner_block("Wrapped Footer")],
        inner_block: inner_block("Body")
      })

    assert result =~ ~s(<span)
    assert result =~ ~s(slot="footer")
    assert result =~ "Wrapped Footer"
  end

  test "renders role=complementary" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(role="complementary")
  end

  test "renders role=dialog when modal is true" do
    result =
      render_component(&dm_drawer/1, %{
        modal: true,
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(role="dialog")
    refute result =~ ~s(role="complementary")
  end

  test "renders aria-modal=true when modal is true" do
    result =
      render_component(&dm_drawer/1, %{
        modal: true,
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(aria-modal="true")
  end

  test "no aria-modal when modal is false" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    refute result =~ "aria-modal"
  end

  test "renders aria-label when label is set" do
    result =
      render_component(&dm_drawer/1, %{
        label: "Navigation panel",
        inner_block: inner_block("Content")
      })

    assert result =~ ~s(aria-label="Navigation panel")
  end

  test "no aria-label when label is nil" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: inner_block("Content")
      })

    refute result =~ "aria-label"
  end

  test "renders with all options combined" do
    result =
      render_component(&dm_drawer/1, %{
        id: "full-drawer",
        class: "full-class",
        open: true,
        position: "right",
        modal: true,
        width: "500px",
        header: [inner_block("Full Header")],
        footer: [inner_block("Full Footer")],
        inner_block: inner_block("Full Body")
      })

    assert result =~ ~s(id="full-drawer")
    assert result =~ ~s(class="full-class")
    assert result =~ "open"
    assert result =~ ~s(position="right")
    assert result =~ "modal"
    assert result =~ ~s(width="500px")
    assert result =~ "Full Header"
    assert result =~ "Full Footer"
    assert result =~ "Full Body"
  end

  test "passes through global attributes" do
    result =
      render_component(&dm_drawer/1, %{
        inner_block: [inner_block("content")],
        "data-testid": "my-drawer"
      })

    assert result =~ ~s[data-testid="my-drawer"]
  end
end
