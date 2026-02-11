defmodule PhoenixDuskmoon.Component.Action.DropdownTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Dropdown

  defp trigger, do: [%{inner_block: fn _, _ -> "Menu" end}]
  defp content, do: [%{inner_block: fn _, _ -> "<li><a>Item</a></li>" end}]

  test "renders basic dropdown with dm-dropdown class" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown"
    assert result =~ "dm-dropdown__toggle"
    assert result =~ "dm-dropdown__content"
  end

  test "renders trigger and content slots" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: [%{inner_block: fn _, _ -> "Open Menu" end}],
        content: [%{inner_block: fn _, _ -> "<li><a>Profile</a></li>" end}]
      })

    assert result =~ "Open Menu"
    assert result =~ "Profile"
  end

  test "renders default position left" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown--left"
  end

  test "renders dropdown with position right" do
    result =
      render_component(&dm_dropdown/1, %{
        position: "right",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown--right"
  end

  test "renders dropdown with position top" do
    result =
      render_component(&dm_dropdown/1, %{
        position: "top",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown--top"
  end

  test "renders dropdown with position bottom" do
    result =
      render_component(&dm_dropdown/1, %{
        position: "bottom",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown--bottom"
  end

  test "renders dropdown with all color variants" do
    for color <- ~w(primary secondary accent info success warning error) do
      result =
        render_component(&dm_dropdown/1, %{
          color: color,
          trigger: trigger(),
          content: content()
        })

      assert result =~ "dm-dropdown__content--#{color}"
    end
  end

  test "renders dropdown with open state" do
    result =
      render_component(&dm_dropdown/1, %{
        open: true,
        trigger: trigger(),
        content: content()
      })

    assert result =~ "dm-dropdown--open"
  end

  test "renders dropdown without open class when open is false" do
    result =
      render_component(&dm_dropdown/1, %{
        open: false,
        trigger: trigger(),
        content: content()
      })

    refute result =~ "dm-dropdown--open"
  end

  test "renders dropdown with custom class" do
    result =
      render_component(&dm_dropdown/1, %{
        class: "my-custom-dropdown",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "my-custom-dropdown"
  end

  test "renders dropdown with dropdown_class" do
    result =
      render_component(&dm_dropdown/1, %{
        dropdown_class: "w-96",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "w-96"
  end

  test "renders trigger with tabindex and role button" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[tabindex="0"]
    assert result =~ ~s[role="button"]
  end

  test "renders content as ul with menu classes" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "<ul"
    assert result =~ "dm-menu"
  end

  test "renders trigger slot with custom class" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: [%{class: "trigger-custom", inner_block: fn _, _ -> "Menu" end}],
        content: content()
      })

    assert result =~ "trigger-custom"
  end

  test "renders content slot with custom class" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: [%{class: "content-custom", inner_block: fn _, _ -> "<li>Item</li>" end}]
      })

    assert result =~ "content-custom"
  end

  test "renders dropdown with rest attributes" do
    result =
      render_component(&dm_dropdown/1, %{
        "data-testid": "my-dropdown",
        "aria-label": "Navigation menu",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "data-testid=\"my-dropdown\""
    assert result =~ "aria-label=\"Navigation menu\""
  end
end
