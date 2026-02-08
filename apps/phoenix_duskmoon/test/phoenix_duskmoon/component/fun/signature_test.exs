defmodule PhoenixDuskmoon.Component.Fun.SignatureTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Fun.Signature

  test "renders signature component" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-1"})

    assert result =~ "dm-fun-signature"
    assert result =~ ~s[id="sig-1"]
  end

  test "renders signature with custom content" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-2", content: "Z"})

    assert result =~ "Z"
  end

  test "renders signature with size" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-3", size: "large"})

    assert result =~ "dm-fun-signature"
  end

  test "renders signature with custom color" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-4", color: "#00ff00"})

    assert result =~ "#00ff00"
  end

  test "renders signature with rotation" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-5", rotation: -45})

    assert result =~ "-45"
  end
end
