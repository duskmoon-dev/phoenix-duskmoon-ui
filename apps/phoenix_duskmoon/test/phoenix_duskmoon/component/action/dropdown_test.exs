defmodule PhoenixDuskmoon.Component.Action.DropdownTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Dropdown

  defp trigger, do: [%{inner_block: fn _, _ -> "Menu" end}]
  defp content, do: [%{inner_block: fn _, _ -> "Item content" end}]

  test "renders wrapper as div element" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert String.starts_with?(String.trim(result), "<div")
  end

  test "renders trigger and content slot text" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: [%{inner_block: fn _, _ -> "Open Menu" end}],
        content: [%{inner_block: fn _, _ -> "Profile" end}]
      })

    assert result =~ "Open Menu"
    assert result =~ "Profile"
  end

  test "renders trigger as button with popovertarget" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "<button"
    assert result =~ "popovertarget="
  end

  test "renders trigger with aria-haspopup" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[aria-haspopup="menu"]
  end

  test "renders trigger with anchor-name in style" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "anchor-name:"
  end

  test "renders trigger with reset button styles" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "appearance: none"
    assert result =~ "border: none"
    assert result =~ "cursor: pointer"
  end

  test "renders content with popover-menu class" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "popover-menu"
  end

  test "renders content with popover class and popover attribute" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    # Native popover: the content div has both the .popover class and [popover] attribute
    assert result =~ ~s[class="popover popover-menu]
  end

  test "renders content with role menu" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[role="menu"]
  end

  test "renders content with position-anchor in style" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "position-anchor:"
  end

  test "renders content with generated id" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[id="dropdown-]
  end

  test "renders content with popover attribute" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    # The native popover attribute should be present
    assert result =~ "popover"
  end

  test "renders default position bottom" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ "popover-bottom"
  end

  test "renders all position variants" do
    for pos <- ~w(left right top bottom) do
      result =
        render_component(&dm_dropdown/1, %{
          position: pos,
          trigger: trigger(),
          content: content()
        })

      assert result =~ "popover-#{pos}"
    end
  end

  test "renders color primary" do
    result =
      render_component(&dm_dropdown/1, %{
        color: "primary",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "popover-primary"
  end

  test "renders color secondary" do
    result =
      render_component(&dm_dropdown/1, %{
        color: "secondary",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "popover-secondary"
  end

  test "renders color tertiary" do
    result =
      render_component(&dm_dropdown/1, %{
        color: "tertiary",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "popover-tertiary"
  end

  test "renders with nil color (no color class)" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    refute result =~ "popover-primary"
    refute result =~ "popover-secondary"
    refute result =~ "popover-tertiary"
  end

  test "renders with custom class on wrapper" do
    result =
      render_component(&dm_dropdown/1, %{
        class: "my-custom-dropdown",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "my-custom-dropdown"
  end

  test "renders with dropdown_class on content" do
    result =
      render_component(&dm_dropdown/1, %{
        dropdown_class: "w-96",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "w-96"
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
        content: [%{class: "content-custom", inner_block: fn _, _ -> "Item" end}]
      })

    assert result =~ "content-custom"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_dropdown/1, %{
        "data-testid": "my-dropdown",
        "aria-label": "Navigation menu",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[data-testid="my-dropdown"]
    assert result =~ ~s[aria-label="Navigation menu"]
  end

  test "renders with custom id in popover target" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "my-dropdown",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[id="my-dropdown-popover"]
    assert result =~ ~s[popovertarget="my-dropdown-popover"]
  end

  test "renders matching popovertarget and content id" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    # Extract the popover id from the content div
    [_, popover_id] = Regex.run(~r/id="(dropdown-\d+)"/, result)
    assert result =~ ~s[popovertarget="#{popover_id}"]
  end

  test "renders matching anchor-name and position-anchor" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    [_, anchor] = Regex.run(~r/anchor-name: (--anchor-dropdown-\d+)/, result)
    assert result =~ "position-anchor: #{anchor}"
  end

  test "renders with custom class and dropdown_class combined" do
    result =
      render_component(&dm_dropdown/1, %{
        class: "outer-custom",
        dropdown_class: "inner-custom",
        trigger: trigger(),
        content: content()
      })

    assert result =~ "outer-custom"
    assert result =~ "inner-custom"
  end

  test "renders with all options combined" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "full-dropdown",
        position: "right",
        color: "primary",
        class: "outer",
        dropdown_class: "inner",
        trigger: [%{class: "trig-cls", inner_block: fn _, _ -> "Open" end}],
        content: [%{class: "cont-cls", inner_block: fn _, _ -> "Delete" end}],
        "data-testid": "full-dropdown"
      })

    assert result =~ "popover-right"
    assert result =~ "popover-primary"
    assert result =~ "popover-menu"
    assert result =~ "outer"
    assert result =~ "inner"
    assert result =~ "trig-cls"
    assert result =~ "cont-cls"
    assert result =~ "Open"
    assert result =~ "Delete"
    assert result =~ ~s[data-testid="full-dropdown"]
    assert result =~ ~s[id="full-dropdown-popover"]
    assert result =~ ~s[popovertarget="full-dropdown-popover"]
    assert result =~ ~s[aria-haspopup="menu"]
    assert result =~ ~s[role="menu"]
  end

  test "trigger has aria-expanded false by default" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[aria-expanded="false"]
  end

  test "trigger has aria-controls pointing to popover id" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "ctrl-test",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[aria-controls="ctrl-test-popover"]
  end

  test "trigger button has type=button" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "btn-type",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[type="button"]
  end

  test "trigger has id derived from popover id" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "trig-id",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[id="trig-id-popover-trigger"]
  end

  test "menu has aria-labelledby pointing to trigger" do
    result =
      render_component(&dm_dropdown/1, %{
        id: "lbl-test",
        trigger: trigger(),
        content: content()
      })

    assert result =~ ~s[aria-labelledby="lbl-test-popover-trigger"]
  end

  test "menu has aria-labelledby with generated id" do
    result =
      render_component(&dm_dropdown/1, %{
        trigger: trigger(),
        content: content()
      })

    # Extract the trigger id
    [_, trigger_id] = Regex.run(~r/id="(dropdown-\d+-trigger)"/, result)
    assert result =~ ~s[aria-labelledby="#{trigger_id}"]
  end
end
