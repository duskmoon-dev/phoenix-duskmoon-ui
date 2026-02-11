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

  test "renders signature with medium size and correct pixel value" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-m"})
    assert result =~ "--size: 80px"
  end

  test "renders signature with correct size pixel values for each preset" do
    for {size, expected_px} <- [{"small", "48"}, {"medium", "80"}, {"large", "128"}] do
      result = render_component(&dm_fun_signature/1, %{id: "sig-px", size: size})
      assert result =~ "--size: #{expected_px}px"
    end
  end

  test "renders signature with default rotation -30deg" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-rot"})
    assert result =~ "--rotate: -30deg"
  end

  test "renders signature with default opacity 0.618" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-opa"})
    assert result =~ "--opacity: 0.618"
  end

  test "renders signature with default position absolute" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-pos"})
    assert result =~ "position: absolute"
  end

  test "renders signature with default right and top 2rem" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-rt"})
    assert result =~ "--right: 2rem"
    assert result =~ "--top: 2rem"
  end

  test "renders signature with various position values" do
    for position <- ~w(fixed relative sticky static) do
      result = render_component(&dm_fun_signature/1, %{id: "sig-p", position: position})
      assert result =~ "position: #{position}"
    end
  end

  test "renders signature with all attributes combined" do
    result =
      render_component(&dm_fun_signature/1, %{
        id: "sig-all",
        content: "OK",
        size: "large",
        color: "#0066cc",
        rotation: 45,
        opacity: 0.5,
        right: "10px",
        top: "10px",
        position: "fixed",
        class: "watermark"
      })

    assert result =~ ~s[data-content="OK"]
    assert result =~ "--size: 128px"
    assert result =~ "--sign-color: #0066cc"
    assert result =~ "--rotate: 45deg"
    assert result =~ "--opacity: 0.5"
    assert result =~ "--right: 10px"
    assert result =~ "--top: 10px"
    assert result =~ "position: fixed"
    assert result =~ "watermark"
  end

  test "renders signature with zero rotation" do
    result = render_component(&dm_fun_signature/1, %{id: "sig-z", rotation: 0})
    assert result =~ "--rotate: 0deg"
  end

  test "renders signature with opacity edge cases" do
    for opacity <- [0.0, 1.0, 0.001] do
      result = render_component(&dm_fun_signature/1, %{id: "sig-o", opacity: opacity})
      assert result =~ "--opacity: #{opacity}"
    end
  end
end
