defmodule PhoenixDuskmoon.Component.DataEntry.TextareaTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Textarea

  test "renders basic textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil})

    assert result =~ "<textarea"
    assert result =~ "dm-textarea"
  end

  test "renders textarea with placeholder" do
    result =
      render_component(&dm_textarea/1, %{name: "bio", value: nil, placeholder: "Tell us..."})

    assert result =~ ~s[placeholder="Tell us..."]
  end

  test "renders textarea with rows" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, rows: 6})

    assert result =~ ~s[rows="6"]
  end

  test "renders textarea with label" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, label: "Biography"})

    assert result =~ "Biography"
  end

  test "renders textarea with color" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, color: "primary"})

    assert result =~ "dm-textarea--primary"
  end

  test "renders disabled textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, disabled: true})

    assert result =~ "disabled"
  end

  test "renders readonly textarea" do
    result = render_component(&dm_textarea/1, %{name: "bio", value: nil, readonly: true})

    assert result =~ "readonly"
  end
end
