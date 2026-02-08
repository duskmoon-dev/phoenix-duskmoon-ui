defmodule PhoenixDuskmoon.Component.Action.DropdownTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Dropdown

  test "renders basic dropdown" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: [%{inner_block: fn _, _ -> "Menu" end}],
        content: [%{inner_block: fn _, _ -> "<li><a>Item</a></li>" end}]
      })

    assert result =~ "dm-dropdown"
  end

  test "renders dropdown with position" do
    result =
      render_component(&dm_dropdown/1, %{
        position: "right",
        trigger: [%{inner_block: fn _, _ -> "Menu" end}],
        content: [%{inner_block: fn _, _ -> "<li><a>Item</a></li>" end}]
      })

    assert result =~ "dm-dropdown"
    assert result =~ "dm-dropdown--right"
  end

  test "renders dropdown with color" do
    result =
      render_component(&dm_dropdown/1, %{
        color: "success",
        trigger: [%{inner_block: fn _, _ -> "Menu" end}],
        content: [%{inner_block: fn _, _ -> "<li><a>Item</a></li>" end}]
      })

    assert result =~ "dm-dropdown"
    assert result =~ "dm-dropdown__content--success"
  end

  test "renders dropdown with custom class" do
    result =
      render_component(&dm_dropdown/1, %{
        class: "my-custom",
        trigger: [%{inner_block: fn _, _ -> "Menu" end}],
        content: [%{inner_block: fn _, _ -> "<li><a>Item</a></li>" end}]
      })

    assert result =~ "my-custom"
  end
end
