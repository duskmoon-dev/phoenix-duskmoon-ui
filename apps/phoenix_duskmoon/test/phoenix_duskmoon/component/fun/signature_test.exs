defmodule PhoenixDuskmoon.Component.Fun.SignatureTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Signature

  test "renders signature with required id" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-1"})

    assert result =~ "dm-fun-signature"
    assert result =~ ~s[id="sig-1"]
  end

  test "renders signature with default content A" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-2"})

    assert result =~ ~s[data-content="A"]
  end

  test "renders signature with custom content" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-3", content: "Approved"})

    assert result =~ ~s[data-content="Approved"]
  end

  test "renders signature with small size" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-4", size: "small"})

    assert result =~ "dm-fun-signature"
  end

  test "renders signature with large size" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-5", size: "large"})

    assert result =~ "dm-fun-signature"
  end

  test "renders signature with custom color" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-6", color: "#00ff00"})

    assert result =~ "#00ff00"
  end

  test "renders signature with custom rotation" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-7", rotation: -45})

    assert result =~ "-45deg"
  end

  test "renders signature with custom opacity" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-8", opacity: 0.8})

    assert result =~ "0.8"
  end

  test "renders signature with custom position" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-9", position: "relative"})

    assert result =~ "position: relative"
  end

  test "renders signature with custom right and top" do
    result =
      render_component(&dm_fun_signature/1, %{id: "sig-10", right: "4rem", top: "4rem"})

    assert result =~ "4rem"
  end

  test "renders signature with custom class" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-11", class: "my-stamp"})

    assert result =~ "my-stamp"
    assert result =~ "dm-fun-signature"
  end

  test "renders signature with rest attributes" do
    result =
      render_component(&dm_fun_signature/1, %{
        id: "sig-12",
        "data-testid": "approval-stamp",
        "aria-hidden": "true"
      })

    assert result =~ "data-testid=\"approval-stamp\""
    assert result =~ "aria-hidden=\"true\""
  end
end
