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

    test "loading state sets aria-busy" do
      result = render_component(&dm_multi_select/1, %{loading: true})
      assert result =~ ~s(aria-busy="true")
    end

    test "no aria-busy when not loading" do
      result = render_component(&dm_multi_select/1, %{})
      refute result =~ "aria-busy"
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

    test "search input has aria-label" do
      result = render_component(&dm_multi_select/1, %{searchable: true})
      assert result =~ ~s(aria-label="Search options")
    end

    test "custom search_placeholder" do
      result =
        render_component(&dm_multi_select/1, %{searchable: true, search_placeholder: "Buscar..."})

      assert result =~ ~s(placeholder="Buscar...")
    end

    test "custom search_label" do
      result =
        render_component(&dm_multi_select/1, %{searchable: true, search_label: "Buscar opciones"})

      assert result =~ ~s(aria-label="Buscar opciones")
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

    test "custom action button text" do
      result =
        render_component(&dm_multi_select/1, %{
          show_actions: true,
          select_all_text: "Tout sélectionner",
          deselect_all_text: "Tout désélectionner"
        })

      assert result =~ "Tout sélectionner"
      assert result =~ "Tout désélectionner"
      refute result =~ "Select All"
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

    test "renders custom clear_label for i18n" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a"],
          clearable: true,
          clear_label: "すべてクリア"
        })

      assert result =~ ~s(aria-label="すべてクリア")
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

    test "custom overflow_text for i18n" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          selected: ["a", "b", "c"],
          max_tags: 1,
          overflow_text: "más"
        })

      assert result =~ "+2 más"
      refute result =~ "+2 more"
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

  describe "accessibility" do
    test "trigger has aria-expanded false when closed" do
      result = render_component(&dm_multi_select/1, %{})
      assert result =~ ~s(aria-expanded="false")
      assert result =~ ~s(aria-haspopup="listbox")
    end

    test "trigger has aria-expanded true when open" do
      result = render_component(&dm_multi_select/1, %{open: true})
      assert result =~ ~s(aria-expanded="true")
    end

    test "options container has role listbox" do
      result = render_component(&dm_multi_select/1, %{options: @options})
      assert result =~ ~s(role="listbox")
      assert result =~ ~s(aria-multiselectable="true")
    end

    test "individual options have role option" do
      result = render_component(&dm_multi_select/1, %{options: @options})
      assert result =~ ~s(role="option")
    end

    test "trigger has id when component has id" do
      result = render_component(&dm_multi_select/1, %{id: "ms"})
      assert result =~ ~s(id="ms-trigger")
    end

    test "listbox has aria-labelledby pointing to trigger" do
      result = render_component(&dm_multi_select/1, %{id: "ms", options: @options})
      assert result =~ ~s(aria-labelledby="ms-trigger")
    end

    test "no trigger id or aria-labelledby when no component id" do
      result = render_component(&dm_multi_select/1, %{options: @options})
      refute result =~ "aria-labelledby"
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

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          errors: ["is required", "must select at least 2"]
        })

      assert result =~ "is required"
      assert result =~ "must select at least 2"
      assert result =~ "multi-select-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          errors: []
        })

      refute result =~ "helper-text helper-text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          errors: ["something wrong"]
        })

      assert result =~ "multi-select-error"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_multi_select/1, %{
        options: @options,
        name: "user[languages]"
      })

    assert result =~ ~s(phx-feedback-for="user[languages]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          id: "ms",
          helper: "Select one or more options"
        })

      assert result =~ "helper-text"
      assert result =~ "Select one or more options"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          id: "ms",
          helper: "Select one or more options",
          errors: ["is required"]
        })

      refute result =~ "Select one or more options"
      assert result =~ "is required"
    end
  end

  describe "aria-describedby" do
    test "trigger references errors container when errors present" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          id: "ms",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="ms-errors"]
      assert result =~ ~s[aria-invalid="true"]
    end

    test "trigger references helper when no errors" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          id: "ms",
          helper: "Select options"
        })

      assert result =~ ~s[aria-describedby="ms-helper"]
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_multi_select/1, %{
          options: @options,
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end
end
