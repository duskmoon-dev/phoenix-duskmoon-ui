defmodule PhoenixDuskmoon.Component.Navigation.ActionbarTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Navigation.Actionbar

  test "renders basic actionbar" do
    result = render_component(&dm_actionbar/1, %{})

    assert result =~ "dm-actionbar"
  end

  test "renders actionbar with left slot" do
    result =
      render_component(&dm_actionbar/1, %{
        left: [%{inner_block: fn _, _ -> "Left content" end}]
      })

    assert result =~ "dm-actionbar"
    assert result =~ "Left content"
  end

  test "renders actionbar with right slot" do
    result =
      render_component(&dm_actionbar/1, %{
        right: [%{inner_block: fn _, _ -> "Right content" end}]
      })

    assert result =~ "dm-actionbar"
    assert result =~ "Right content"
  end

  test "renders actionbar with custom class" do
    result = render_component(&dm_actionbar/1, %{class: "my-bar"})

    assert result =~ "my-bar"
  end

  test "renders actionbar with id" do
    result = render_component(&dm_actionbar/1, %{id: "action-1"})

    assert result =~ ~s[id="action-1"]
  end
end
