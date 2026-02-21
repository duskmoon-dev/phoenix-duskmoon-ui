defmodule PhoenixDuskmoon.Component.DataEntry.TreeSelectTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataEntry.TreeSelect

  @tree_options [
    %{
      value: "fruits",
      label: "Fruits",
      children: [
        %{value: "apple", label: "Apple"},
        %{value: "banana", label: "Banana"}
      ]
    },
    %{
      value: "vegs",
      label: "Vegetables",
      children: [
        %{value: "carrot", label: "Carrot"}
      ]
    }
  ]

  @flat_options [
    %{value: "a", label: "Alpha"},
    %{value: "b", label: "Beta"}
  ]

  describe "dm_tree_select/1" do
    test "renders base tree-select structure" do
      result = render_component(&dm_tree_select/1, %{})
      assert result =~ "tree-select"
      assert result =~ "tree-select-trigger"
      assert result =~ "tree-select-dropdown"
      assert result =~ "tree-select-options"
      assert result =~ "tree-select-arrow"
    end

    test "renders with id" do
      result = render_component(&dm_tree_select/1, %{id: "my-tree"})
      assert result =~ ~s(id="my-tree")
    end

    test "renders placeholder when nothing selected" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          placeholder: "Select item..."
        })

      assert result =~ "tree-select-placeholder"
      assert result =~ "Select item..."
    end

    test "renders selected value label" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          selected: ["apple"]
        })

      assert result =~ "tree-select-value-selected"
      assert result =~ "Apple"
    end

    test "renders selected from nested children" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          selected: ["carrot"]
        })

      assert result =~ "Carrot"
    end

    test "renders tree nodes" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          expanded: ["fruits"]
        })

      assert result =~ "tree-select-node"
      assert result =~ "Fruits"
    end

    test "renders expand toggle for parent nodes" do
      result = render_component(&dm_tree_select/1, %{options: @tree_options})
      assert result =~ "tree-select-node-toggle"
      assert result =~ "tree-select-node-icon"
    end

    test "leaf nodes have leaf class" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          expanded: ["fruits"]
        })

      assert result =~ "tree-select-node-leaf"
    end

    test "expanded nodes show children" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          expanded: ["fruits"]
        })

      assert result =~ "tree-select-children"
      assert result =~ "Apple"
      assert result =~ "Banana"
      assert result =~ "tree-select-node-expanded"
    end

    test "collapsed nodes hide children" do
      result = render_component(&dm_tree_select/1, %{options: @tree_options})
      # "Fruits" and "Vegetables" are visible as top-level nodes
      assert result =~ "Fruits"
      # But children should not be rendered when not expanded
      refute result =~ "tree-select-children"
    end

    test "marks selected nodes" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          selected: ["a"]
        })

      assert result =~ "tree-select-node-selected"
      assert result =~ ~s(aria-selected="true")
    end

    test "renders size variants" do
      for size <- ["sm", "lg"] do
        result = render_component(&dm_tree_select/1, %{size: size})
        assert result =~ "tree-select-#{size}"
      end
    end

    test "renders variant styles" do
      for variant <- ["outlined", "filled"] do
        result = render_component(&dm_tree_select/1, %{variant: variant})
        assert result =~ "tree-select-#{variant}"
      end
    end

    test "renders open state" do
      result = render_component(&dm_tree_select/1, %{open: true})
      assert result =~ "tree-select-open"
    end

    test "renders error state" do
      result = render_component(&dm_tree_select/1, %{error: true})
      assert result =~ "tree-select-error"
    end

    test "renders disabled state" do
      result = render_component(&dm_tree_select/1, %{disabled: true})
      assert result =~ "tree-select-disabled"
    end

    test "renders loading state" do
      result = render_component(&dm_tree_select/1, %{loading: true})
      assert result =~ "tree-select-loading"
    end

    test "renders multiple mode with checkboxes" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          multiple: true
        })

      assert result =~ "tree-select-multiple"
      assert result =~ "tree-select-checkbox"
      assert result =~ "tree-select-checkbox-box"
    end

    test "multiple mode shows tags" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          selected: ["a", "b"],
          multiple: true
        })

      assert result =~ "tree-select-tags"
      assert result =~ "tree-select-tag"
      assert result =~ "Alpha"
      assert result =~ "Beta"
    end

    test "renders searchable input" do
      result = render_component(&dm_tree_select/1, %{searchable: true})
      assert result =~ "tree-select-search"
      assert result =~ "tree-select-search-input"
    end

    test "renders clearable button" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          selected: ["a"],
          clearable: true
        })

      assert result =~ "tree-select-clear"
    end

    test "no clear button when nothing selected" do
      result = render_component(&dm_tree_select/1, %{clearable: true})
      refute result =~ "tree-select-clear"
    end

    test "renders path display" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          selected: ["apple"],
          show_path: true
        })

      assert result =~ "tree-select-path"
      assert result =~ "Fruits / Apple"
    end

    test "renders empty state" do
      result = render_component(&dm_tree_select/1, %{options: []})
      assert result =~ "tree-select-empty"
      assert result =~ "No options available"
    end

    test "custom empty text" do
      result =
        render_component(&dm_tree_select/1, %{
          options: [],
          empty_text: "No items"
        })

      assert result =~ "No items"
    end

    test "renders hidden inputs for single select" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          selected: ["a"],
          name: "category"
        })

      assert result =~ ~s(name="category")
      assert result =~ ~s(value="a")
    end

    test "renders hidden inputs for multiple select" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @flat_options,
          selected: ["a", "b"],
          name: "categories",
          multiple: true
        })

      assert result =~ ~s(name="categories[]")
    end

    test "data-value on nodes" do
      result = render_component(&dm_tree_select/1, %{options: @flat_options})
      assert result =~ ~s(data-value="a")
      assert result =~ ~s(data-value="b")
    end

    test "renders additional CSS classes" do
      result = render_component(&dm_tree_select/1, %{class: "my-tree"})
      assert result =~ "my-tree"
    end

    test "combines multiple modifiers" do
      result =
        render_component(&dm_tree_select/1, %{
          size: "lg",
          variant: "filled",
          open: true,
          error: true,
          multiple: true
        })

      assert result =~ "tree-select-lg"
      assert result =~ "tree-select-filled"
      assert result =~ "tree-select-open"
      assert result =~ "tree-select-error"
      assert result =~ "tree-select-multiple"
    end

    test "deeply nested tree" do
      deep_options = [
        %{
          value: "l1",
          label: "Level 1",
          children: [
            %{
              value: "l2",
              label: "Level 2",
              children: [
                %{value: "l3", label: "Level 3"}
              ]
            }
          ]
        }
      ]

      result =
        render_component(&dm_tree_select/1, %{
          options: deep_options,
          expanded: ["l1", "l2"],
          selected: ["l3"],
          show_path: true
        })

      assert result =~ "Level 1 / Level 2 / Level 3"
    end
  end

  describe "accessibility" do
    test "trigger has aria-expanded false when closed" do
      result = render_component(&dm_tree_select/1, %{})
      assert result =~ ~s(aria-expanded="false")
      assert result =~ ~s(aria-haspopup="tree")
    end

    test "trigger has aria-expanded true when open" do
      result = render_component(&dm_tree_select/1, %{open: true})
      assert result =~ ~s(aria-expanded="true")
    end

    test "options container has role tree" do
      result = render_component(&dm_tree_select/1, %{options: @tree_options})
      assert result =~ ~s(role="tree")
    end

    test "nodes have role treeitem" do
      result = render_component(&dm_tree_select/1, %{options: @flat_options})
      assert result =~ ~s(role="treeitem")
    end

    test "toggle button has aria-label" do
      result = render_component(&dm_tree_select/1, %{options: @tree_options})
      assert result =~ ~s(aria-label="Toggle Fruits")
    end
  end

  describe "FormField integration" do
    test "renders tree select with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"category" => ["a"]}, as: "product")[:category]

      result =
        render_component(&dm_tree_select/1, %{
          field: field,
          options: [%{value: "a", label: "Alpha"}]
        })

      assert result =~ ~s(id="product_category")
      assert result =~ ~s(name="product[category])
    end

    test "renders tree select with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"category" => []}, as: "product")[:category]

      result =
        render_component(&dm_tree_select/1, %{
          field: field,
          id: "custom-tree",
          options: []
        })

      assert result =~ ~s(id="custom-tree")
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "tree-select-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_tree_select/1, %{
          options: @tree_options,
          errors: []
        })

      refute result =~ "helper-text text-error"
    end
  end
end
