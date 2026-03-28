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
    test "renders el-dm-cascader custom element" do
      result = render_component(&dm_cascader/1, %{})
      assert result =~ "el-dm-cascader"
    end

    test "renders with id on the custom element" do
      result = render_component(&dm_cascader/1, %{id: "my-cascader"})
      assert result =~ ~s(id="my-cascader")
    end

    test "encodes options as JSON" do
      result = render_component(&dm_cascader/1, %{options: @cascader_options})
      assert result =~ "&quot;value&quot;:&quot;asia&quot;"
      assert result =~ "&quot;label&quot;:&quot;Asia&quot;"
      assert result =~ "&quot;children&quot;:"
    end

    test "encodes selected_path as JSON value" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn", "bj"]
        })

      assert result =~ ~s(value="[&quot;asia&quot;,&quot;cn&quot;,&quot;bj&quot;]")
    end

    test "empty selected_path encodes as empty JSON array" do
      result = render_component(&dm_cascader/1, %{})
      assert result =~ ~s(value="[]")
    end

    test "renders placeholder attribute" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          placeholder: "Select region..."
        })

      assert result =~ ~s(placeholder="Select region...")
    end

    test "renders separator attribute" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn"],
          separator: " > "
        })

      assert result =~ ~s(separator=" &gt; ")
    end

    test "renders size attribute defaulting to md" do
      result = render_component(&dm_cascader/1, %{})
      assert result =~ ~s(size="md")
    end

    test "renders size variants" do
      for size <- ["sm", "lg"] do
        result = render_component(&dm_cascader/1, %{size: size})
        assert result =~ ~s(size="#{size}")
      end
    end

    test "renders additional CSS classes on custom element" do
      result = render_component(&dm_cascader/1, %{class: "my-cascader"})
      assert result =~ "my-cascader"
    end

    test "renders searchable attribute when true" do
      result = render_component(&dm_cascader/1, %{searchable: true})
      assert result =~ "searchable"
    end

    test "no searchable attribute when false" do
      result = render_component(&dm_cascader/1, %{searchable: false})
      refute result =~ "searchable"
    end

    test "renders clearable attribute when true" do
      result = render_component(&dm_cascader/1, %{clearable: true})
      assert result =~ "clearable"
    end

    test "renders disabled attribute when true" do
      result = render_component(&dm_cascader/1, %{disabled: true})
      assert result =~ "disabled"
    end

    test "no disabled attribute when false" do
      result = render_component(&dm_cascader/1, %{disabled: false})
      refute result =~ "disabled"
    end

    test "renders loading attribute when true" do
      result = render_component(&dm_cascader/1, %{loading: true})
      assert result =~ "loading"
      assert result =~ ~s(aria-busy="true")
    end

    test "no aria-busy when not loading" do
      result = render_component(&dm_cascader/1, %{})
      refute result =~ "aria-busy"
    end

    test "sets validation-state invalid when error is true" do
      result = render_component(&dm_cascader/1, %{error: true})
      assert result =~ ~s(validation-state="invalid")
    end

    test "sets validation-state invalid when errors list is non-empty" do
      result = render_component(&dm_cascader/1, %{errors: ["is required"]})
      assert result =~ ~s(validation-state="invalid")
    end

    test "no validation-state when no error" do
      result = render_component(&dm_cascader/1, %{error: false, errors: []})
      refute result =~ "validation-state"
    end

    test "renders multiple attribute when true" do
      result = render_component(&dm_cascader/1, %{multiple: true})
      assert result =~ "multiple"
    end

    test "renders change-on-select attribute when true" do
      result = render_component(&dm_cascader/1, %{change_on_select: true})
      assert result =~ "change-on-select"
    end

    test "renders hidden input with last path value when name is set" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          selected_path: ["asia", "cn", "bj"],
          name: "location"
        })

      assert result =~ ~s(name="location")
      assert result =~ ~s(value="bj")
      assert result =~ ~s(type="hidden")
    end

    test "no hidden input when selected_path is empty" do
      result = render_component(&dm_cascader/1, %{name: "location"})
      refute result =~ ~s(type="hidden")
    end

    test "no hidden input when name is nil" do
      result =
        render_component(&dm_cascader/1, %{
          selected_path: ["asia"],
          options: @cascader_options
        })

      refute result =~ ~s(type="hidden")
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
    end

    test "sets aria-invalid when errors present" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          errors: ["is required"]
        })

      assert result =~ ~s(aria-invalid="true")
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_cascader/1, %{
        options: @cascader_options,
        name: "user[location]"
      })

    assert result =~ ~s(phx-feedback-for="user[location]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          id: "casc",
          helper: "Select a location"
        })

      assert result =~ "helper-text"
      assert result =~ "Select a location"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          id: "casc",
          helper: "Select a location",
          errors: ["is required"]
        })

      refute result =~ "Select a location"
      assert result =~ "is required"
    end
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          id: "casc",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="casc-errors"]
      assert result =~ ~s[aria-invalid="true"]
    end

    test "references helper when no errors" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          id: "casc",
          helper: "Select a location"
        })

      assert result =~ ~s[aria-describedby="casc-helper"]
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_cascader/1, %{
          options: @cascader_options,
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "passes through global attributes" do
    result =
      render_component(&dm_cascader/1, %{
        options: @cascader_options,
        "data-testid": "my-cascader"
      })

    assert result =~ ~s[data-testid="my-cascader"]
  end
end
