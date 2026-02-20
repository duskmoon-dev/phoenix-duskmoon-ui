defmodule PhoenixDuskmoon.Component.DataDisplay.CollapseTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataDisplay.Collapse

  defp basic_trigger do
    [%{__slot__: :trigger, inner_block: fn _, _ -> "Toggle" end}]
  end

  defp basic_content do
    [%{__slot__: :content, inner_block: fn _, _ -> "Hidden content" end}]
  end

  describe "dm_collapse basic rendering" do
    test "renders collapse container" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ "collapse"
      assert result =~ "collapse-trigger"
      assert result =~ "collapse-content"
      assert result =~ "collapse-inner"
    end

    test "renders trigger text" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ "Toggle"
    end

    test "renders content text" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ "Hidden content"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_collapse/1, %{
          id: "faq-1",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ ~s(id="faq-1")
    end

    test "renders with custom class" do
      result =
        render_component(&dm_collapse/1, %{
          class: "mt-4",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "mt-4"
    end

    test "renders collapse-icon span" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ "collapse-icon"
    end

    test "trigger is a button" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ "<button"
      assert result =~ ~s(type="button")
    end
  end

  describe "dm_collapse open state" do
    test "not open by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-open"
    end

    test "renders open state" do
      result =
        render_component(&dm_collapse/1, %{
          open: true,
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-open"
    end
  end

  describe "dm_collapse disabled" do
    test "not disabled by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-disabled"
    end

    test "renders disabled state" do
      result =
        render_component(&dm_collapse/1, %{
          disabled: true,
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-disabled"
      assert result =~ "disabled"
    end
  end

  describe "dm_collapse variants" do
    test "no variant class by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-card"
      refute result =~ "collapse-bordered"
      refute result =~ "collapse-ghost"
      refute result =~ "collapse-divider"
    end

    test "renders card variant" do
      result =
        render_component(&dm_collapse/1, %{
          variant: "card",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-card"
    end

    test "renders bordered variant" do
      result =
        render_component(&dm_collapse/1, %{
          variant: "bordered",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-bordered"
    end

    test "renders ghost variant" do
      result =
        render_component(&dm_collapse/1, %{
          variant: "ghost",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-ghost"
    end

    test "renders divider variant" do
      result =
        render_component(&dm_collapse/1, %{
          variant: "divider",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-divider"
    end
  end

  describe "dm_collapse colors" do
    test "no color class by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-primary"
    end

    test "renders primary color" do
      result =
        render_component(&dm_collapse/1, %{
          color: "primary",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-primary"
    end

    test "renders secondary color" do
      result =
        render_component(&dm_collapse/1, %{
          color: "secondary",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-secondary"
    end

    test "renders tertiary color" do
      result =
        render_component(&dm_collapse/1, %{
          color: "tertiary",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-tertiary"
    end
  end

  describe "dm_collapse sizes" do
    test "no size class by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-sm"
      refute result =~ "collapse-lg"
    end

    test "renders sm size" do
      result =
        render_component(&dm_collapse/1, %{
          size: "sm",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-sm"
    end

    test "renders lg size" do
      result =
        render_component(&dm_collapse/1, %{
          size: "lg",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-lg"
    end
  end

  describe "dm_collapse animation" do
    test "no animation by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-fade"
      refute result =~ "collapse-slide"
    end

    test "renders fade animation" do
      result =
        render_component(&dm_collapse/1, %{
          animation: "fade",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-fade"
    end

    test "renders slide animation" do
      result =
        render_component(&dm_collapse/1, %{
          animation: "slide",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-slide"
    end
  end

  describe "dm_collapse speed" do
    test "no speed by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-fast"
      refute result =~ "collapse-slow"
    end

    test "renders fast speed" do
      result =
        render_component(&dm_collapse/1, %{
          speed: "fast",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-fast"
    end

    test "renders slow speed" do
      result =
        render_component(&dm_collapse/1, %{
          speed: "slow",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-slow"
    end
  end

  describe "dm_collapse nested" do
    test "not nested by default" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      refute result =~ "collapse-nested"
    end

    test "renders nested style" do
      result =
        render_component(&dm_collapse/1, %{
          nested: true,
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ "collapse-nested"
    end
  end

  describe "dm_collapse combined" do
    test "renders with all options" do
      result =
        render_component(&dm_collapse/1, %{
          id: "details",
          class: "w-96",
          open: true,
          variant: "card",
          color: "primary",
          size: "lg",
          animation: "slide",
          speed: "fast",
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ ~s(id="details")
      assert result =~ "w-96"
      assert result =~ "collapse-open"
      assert result =~ "collapse-card"
      assert result =~ "collapse-primary"
      assert result =~ "collapse-lg"
      assert result =~ "collapse-slide"
      assert result =~ "collapse-fast"
      assert result =~ "Toggle"
      assert result =~ "Hidden content"
    end
  end

  describe "dm_collapse accessibility" do
    test "trigger has aria-expanded false when closed" do
      result =
        render_component(&dm_collapse/1, %{trigger: basic_trigger(), content: basic_content()})

      assert result =~ ~s(aria-expanded="false")
    end

    test "trigger has aria-expanded true when open" do
      result =
        render_component(&dm_collapse/1, %{
          open: true,
          trigger: basic_trigger(),
          content: basic_content()
        })

      assert result =~ ~s(aria-expanded="true")
    end
  end

  describe "dm_collapse_group" do
    test "renders group container" do
      result =
        render_component(&dm_collapse_group/1, %{
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "children" end}]
        })

      assert result =~ "collapse-group"
      assert result =~ "children"
    end

    test "renders with custom id" do
      result =
        render_component(&dm_collapse_group/1, %{
          id: "faq-group",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ ~s(id="faq-group")
    end

    test "renders with custom class" do
      result =
        render_component(&dm_collapse_group/1, %{
          class: "space-y-2",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "" end}]
        })

      assert result =~ "space-y-2"
    end
  end
end
