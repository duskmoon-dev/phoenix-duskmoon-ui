defmodule PhoenixDuskmoon.Component.DataEntry.CascaderTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.Cascader

  @cascader_options [
    %{
      value: "asia",
      label: "Asia",
      children: [
        %{
          value: "cn",
          label: "China",
          children: [
            %{value: "bj", label: "Beijing"},
            %{value: "sh", label: "Shanghai"}
          ]
        },
        %{value: "jp", label: "Japan"}
      ]
    },
    %{
      value: "eu",
      label: "Europe",
      children: [
        %{value: "uk", label: "United Kingdom"},
        %{value: "de", label: "Germany"}
      ]
    }
  ]

  describe "dm_cascader/1" do
    test "renders base cascader structure" do
      result = render_component(&dm_cascader/1, %{})
      assert result =~ "cascader"
      assert result =~ "cascader-trigger"
      assert result =~ "cascader-dropdown"
      assert result =~ "cascader-panels"
      assert result =~ "cascader-arrow"
    end

    test "renders with id" do
      result = render_component(&dm_cascader/1, %{id: "my-cascader"})
      assert result =~ ~s(id="my-cascader")
    end

    test "renders placeholder when nothing selected" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          placeholder: "Select region..."
        })

      assert result =~ "cascader-placeholder"
      assert result =~ "Select region..."
    end

    test "renders selected path display" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn", "bj"]
        })

      assert result =~ "cascader-path"
      assert result =~ "Asia"
      assert result =~ "China"
      assert result =~ "Beijing"
      assert result =~ "cascader-path-separator"
    end

    test "custom separator" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn"],
          separator: " > "
        })

      assert result =~ " &gt; "
    end

    test "renders first panel with top-level options" do
      result = render_component(&dm_cascader/1, %{options: @cascader_options})
      assert result =~ "cascader-panel"
      assert result =~ "cascader-option"
      assert result =~ "Asia"
      assert result =~ "Europe"
    end

    test "parent options show arrow" do
      result = render_component(&dm_cascader/1, %{options: @cascader_options})
      assert result =~ "cascader-option-arrow"
    end

    test "renders multiple panels when path is selected" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn"]
        })

      # Should have 3 panels: root, Asia's children, China's children
      assert result =~ "China"
      assert result =~ "Japan"
      assert result =~ "Beijing"
      assert result =~ "Shanghai"
    end

    test "marks selected options in panels" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia"]
        })

      assert result =~ "cascader-option-selected"
    end

    test "renders size variants" do
      for size <- ["sm", "lg"] do
        result = render_component(&dm_cascader/1, %{size: size})
        assert result =~ "cascader-#{size}"
      end
    end

    test "renders variant styles" do
      for variant <- ["outlined", "filled"] do
        result = render_component(&dm_cascader/1, %{variant: variant})
        assert result =~ "cascader-#{variant}"
      end
    end

    test "renders open state" do
      result = render_component(&dm_cascader/1, %{open: true})
      assert result =~ "cascader-open"
    end

    test "renders error state" do
      result = render_component(&dm_cascader/1, %{error: true})
      assert result =~ "cascader-error"
    end

    test "renders disabled state" do
      result = render_component(&dm_cascader/1, %{disabled: true})
      assert result =~ "cascader-disabled"
    end

    test "renders loading state" do
      result = render_component(&dm_cascader/1, %{loading: true})
      assert result =~ "cascader-loading"
    end

    test "renders searchable input" do
      result = render_component(&dm_cascader/1, %{searchable: true})
      assert result =~ "cascader-search"
      assert result =~ "cascader-search-input"
    end

    test "renders clearable button" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia"],
          clearable: true
        })

      assert result =~ "cascader-clear"
    end

    test "no clear button when nothing selected" do
      result = render_component(&dm_cascader/1, %{clearable: true})
      refute result =~ "cascader-clear"
    end

    test "renders empty state" do
      result = render_component(&dm_cascader/1, %{options: []})
      assert result =~ "cascader-empty"
      assert result =~ "No options available"
    end

    test "custom empty text" do
      result =
        render_component(&dm_cascader/1, %{
          options: [],
          empty_text: "Nothing here"
        })

      assert result =~ "Nothing here"
    end

    test "renders hidden input with last path value" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn", "bj"],
          name: "location"
        })

      assert result =~ ~s(name="location")
      assert result =~ ~s(value="bj")
    end

    test "no hidden input when nothing selected" do
      result = render_component(&dm_cascader/1, %{name: "location"})
      refute result =~ ~s(name="location")
    end

    test "data-value on options" do
      result = render_component(&dm_cascader/1, %{options: @cascader_options})
      assert result =~ ~s(data-value="asia")
      assert result =~ ~s(data-value="eu")
    end

    test "renders additional CSS classes" do
      result = render_component(&dm_cascader/1, %{class: "my-cascader"})
      assert result =~ "my-cascader"
    end

    test "disabled options" do
      opts = [%{value: "a", label: "Alpha", disabled: true}]
      result = render_component(&dm_cascader/1, %{options: opts})
      assert result =~ "cascader-option-disabled"
    end

    test "leaf options have no arrow" do
      opts = [%{value: "a", label: "Leaf item"}]
      result = render_component(&dm_cascader/1, %{options: opts})
      refute result =~ "cascader-option-arrow"
    end

    test "combines multiple modifiers" do
      result =
        render_component(&dm_cascader/1, %{
          size: "lg",
          variant: "filled",
          open: true,
          error: true
        })

      assert result =~ "cascader-lg"
      assert result =~ "cascader-filled"
      assert result =~ "cascader-open"
      assert result =~ "cascader-error"
    end
  end

  describe "accessibility" do
    test "trigger has aria-expanded false when closed" do
      result = render_component(&dm_cascader/1, %{})
      assert result =~ ~s(aria-expanded="false")
      assert result =~ ~s(aria-haspopup="listbox")
    end

    test "trigger has aria-expanded true when open" do
      result = render_component(&dm_cascader/1, %{open: true})
      assert result =~ ~s(aria-expanded="true")
    end

    test "options have role option" do
      result = render_component(&dm_cascader/1, %{options: @cascader_options})
      assert result =~ ~s(role="option")
    end
  end

  describe "FormField integration" do
    test "renders cascader with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"region" => ["asia", "cn"]}, as: "location")[:region]

      result =
        render_component(&dm_cascader/1, %{
          field: field,
          options: [
            %{
              value: "asia",
              label: "Asia",
              children: [%{value: "cn", label: "China"}]
            }
          ]
        })

      assert result =~ ~s(id="location_region")
      assert result =~ ~s(name="location[region]")
    end

    test "renders cascader with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"region" => []}, as: "location")[:region]

      result =
        render_component(&dm_cascader/1, %{
          field: field,
          id: "custom-cascader",
          options: []
        })

      assert result =~ ~s(id="custom-cascader")
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "cascader-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          errors: []
        })

      refute result =~ "helper-text text-error"
    end
  end
end
