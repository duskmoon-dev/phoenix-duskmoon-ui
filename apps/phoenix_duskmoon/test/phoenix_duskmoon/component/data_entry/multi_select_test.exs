defmodule PhoenixDuskmoon.Component.DataEntry.MultiSelectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.MultiSelect

  @options [
    %{value: "a", label: "Alpha"},
    %{value: "b", label: "Beta"},
    %{value: "c", label: "Gamma"}
  ]

  describe "dm_multi_select/1" do
    test "renders base multi-select structure" do
      result = render_component(&dm_multi_select/1, %{})
      assert result =~ "multi-select"
      assert result =~ "multi-select-trigger"
      assert result =~ "multi-select-dropdown"
      assert result =~ "multi-select-options"
      assert result =~ "multi-select-arrow"
    end

    test "renders with id" do
      result = render_component(&dm_multi_select/1, %{id: "my-select"})
      assert result =~ ~s(id="my-select")
    end

    test "renders placeholder when nothing selected" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          placeholder: "Choose items..."
        })

      assert result =~ "multi-select-placeholder"
      assert result =~ "Choose items..."
    end

    test "renders selected tags" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a", "b"]
        })

      assert result =~ "multi-select-tags"
      assert result =~ "multi-select-tag"
      assert result =~ "Alpha"
      assert result =~ "Beta"
      assert result =~ "multi-select-tag-remove"
    end

    test "no placeholder when items are selected" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"],
          placeholder: "Choose..."
        })

      refute result =~ "multi-select-placeholder"
    end

    test "renders size variants" do
      for size <- ["sm", "lg"] do
        result = render_component(&dm_multi_select/1, %{size: size})
        assert result =~ "multi-select-#{size}"
      end
    end

    test "renders variant styles" do
      for variant <- ["outlined", "filled"] do
        result = render_component(&dm_multi_select/1, %{variant: variant})
        assert result =~ "multi-select-#{variant}"
      end
    end

    test "renders open state" do
      result = render_component(&dm_multi_select/1, %{open: true})
      assert result =~ "multi-select-open"
    end

    test "renders error state" do
      result = render_component(&dm_multi_select/1, %{error: true})
      assert result =~ "multi-select-error"
    end

    test "renders disabled state" do
      result = render_component(&dm_multi_select/1, %{disabled: true})
      assert result =~ "multi-select-disabled"
      assert result =~ "disabled"
    end

    test "renders loading state" do
      result = render_component(&dm_multi_select/1, %{loading: true})
      assert result =~ "multi-select-loading"
    end

    test "renders options with checkboxes" do
      result = render_component(&dm_multi_select/1, %{options: @options})
      assert result =~ "multi-select-option"
      assert result =~ "multi-select-option-checkbox"
      assert result =~ "multi-select-checkbox-box"
      assert result =~ "Alpha"
      assert result =~ "Beta"
      assert result =~ "Gamma"
    end

    test "marks selected options" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"]
        })

      assert result =~ "multi-select-option-selected"
      assert result =~ ~s(aria-selected="true")
    end

    test "renders disabled options" do
      opts = [%{value: "a", label: "Alpha", disabled: true}]
      result = render_component(&dm_multi_select/1, %{options: opts})
      assert result =~ "multi-select-option-disabled"
    end

    test "renders option descriptions" do
      opts = [%{value: "a", label: "Alpha", description: "First letter"}]
      result = render_component(&dm_multi_select/1, %{options: opts})
      assert result =~ "multi-select-option-description"
      assert result =~ "First letter"
    end

    test "renders grouped options" do
      opts = [
        %{value: "a", label: "Apple", group: "Fruits"},
        %{value: "b", label: "Banana", group: "Fruits"},
        %{value: "c", label: "Carrot", group: "Vegetables"}
      ]

      result = render_component(&dm_multi_select/1, %{options: opts})
      assert result =~ "multi-select-group"
      assert result =~ "multi-select-group-header"
      assert result =~ "Fruits"
      assert result =~ "Vegetables"
    end

    test "renders searchable input" do
      result = render_component(&dm_multi_select/1, %{searchable: true})
      assert result =~ "multi-select-search"
      assert result =~ "multi-select-search-input"
    end

    test "no search input by default" do
      result = render_component(&dm_multi_select/1, %{})
      refute result =~ "multi-select-search"
    end

    test "renders action buttons" do
      result = render_component(&dm_multi_select/1, %{show_actions: true})
      assert result =~ "multi-select-actions"
      assert result =~ "multi-select-action"
      assert result =~ "Select All"
      assert result =~ "Deselect All"
    end

    test "no actions by default" do
      result = render_component(&dm_multi_select/1, %{})
      refute result =~ "multi-select-actions"
    end

    test "renders counter badge" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a", "b"],
          show_counter: true
        })

      assert result =~ "multi-select-counter"
    end

    test "no counter when nothing selected" do
      result =
        render_component(&dm_multi_select/1, %{
          show_counter: true
        })

      refute result =~ "multi-select-counter"
    end

    test "renders clearable button" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"],
          clearable: true
        })

      assert result =~ "multi-select-clear-all"
    end

    test "no clear button when nothing selected" do
      result = render_component(&dm_multi_select/1, %{clearable: true})
      refute result =~ "multi-select-clear-all"
    end

    test "renders tag variant" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"],
          tag_variant: "primary"
        })

      assert result =~ "multi-select-tag-primary"
    end

    test "renders overflow indicator with max_tags" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a", "b", "c"],
          max_tags: 1
        })

      assert result =~ "multi-select-tag-overflow"
      assert result =~ "+2 more"
      # Only one tag visible
      assert result =~ "Alpha"
    end

    test "no overflow when within max_tags" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"],
          max_tags: 3
        })

      refute result =~ "multi-select-tag-overflow"
    end

    test "renders empty state" do
      result = render_component(&dm_multi_select/1, %{options: []})
      assert result =~ "multi-select-empty"
      assert result =~ "No options available"
    end

    test "custom empty text" do
      result =
        render_component(&dm_multi_select/1, %{
          options: [],
          empty_text: "Nothing here"
        })

      assert result =~ "Nothing here"
    end

    test "renders hidden inputs for form submission" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a", "b"],
          name: "tags"
        })

      assert result =~ ~s(name="tags[]")
      assert result =~ ~s(value="a")
      assert result =~ ~s(value="b")
    end

    test "renders additional CSS classes" do
      result = render_component(&dm_multi_select/1, %{class: "my-custom"})
      assert result =~ "my-custom"
    end

    test "data-value on options" do
      result = render_component(&dm_multi_select/1, %{options: @options})
      assert result =~ ~s(data-value="a")
      assert result =~ ~s(data-value="b")
      assert result =~ ~s(data-value="c")
    end

    test "combines multiple modifiers" do
      result =
        render_component(&dm_multi_select/1, %{
          size: "lg",
          variant: "filled",
          open: true,
          error: true
        })

      assert result =~ "multi-select-lg"
      assert result =~ "multi-select-filled"
      assert result =~ "multi-select-open"
      assert result =~ "multi-select-error"
    end

    test "ungrouped and grouped options together" do
      opts = [
        %{value: "x", label: "Extra"},
        %{value: "a", label: "Apple", group: "Fruits"}
      ]

      result = render_component(&dm_multi_select/1, %{options: opts})
      assert result =~ "Extra"
      assert result =~ "multi-select-group"
      assert result =~ "Apple"
    end
  end

  describe "FormField integration" do
    test "renders multi select with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"tags" => ["a"]}, as: "post")[:tags]

      result =
        render_component(&dm_multi_select/1, %{
          field: field,
          options: [%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]
        })

      assert result =~ ~s(id="post_tags")
      assert result =~ ~s(name="post[tags][]")
    end

    test "renders multi select with form field value as selected" do
      field = Phoenix.Component.to_form(%{"tags" => ["a", "b"]}, as: "post")[:tags]

      result =
        render_component(&dm_multi_select/1, %{
          field: field,
          options: [%{value: "a", label: "Alpha"}, %{value: "b", label: "Beta"}]
        })

      assert result =~ "multi-select-tag"
      assert result =~ "Alpha"
      assert result =~ "Beta"
    end

    test "renders multi select with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"tags" => []}, as: "post")[:tags]

      result =
        render_component(&dm_multi_select/1, %{
          field: field,
          id: "custom-ms",
          options: []
        })

      assert result =~ ~s(id="custom-ms")
    end
  end
end
