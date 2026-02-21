defmodule PhoenixDuskmoon.Component.DataEntry.AutocompleteTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.Autocomplete

  @sample_options [
    %{value: "us", label: "United States"},
    %{value: "ca", label: "Canada"},
    %{value: "uk", label: "United Kingdom"}
  ]

  describe "dm_autocomplete basic rendering" do
    test "renders el-dm-autocomplete element" do
      result = render_component(&dm_autocomplete/1, %{})
      assert result =~ "<el-dm-autocomplete"
      assert result =~ "</el-dm-autocomplete>"
    end

    test "renders with custom id" do
      result = render_component(&dm_autocomplete/1, %{id: "my-ac"})
      assert result =~ ~s(id="my-ac")
    end

    test "renders with custom class" do
      result = render_component(&dm_autocomplete/1, %{class: "w-full"})
      assert result =~ "w-full"
    end
  end

  describe "dm_autocomplete options" do
    test "renders empty options by default" do
      result = render_component(&dm_autocomplete/1, %{})
      assert result =~ ~s(options="[]")
    end

    test "renders options as JSON" do
      result = render_component(&dm_autocomplete/1, %{options: @sample_options})
      assert result =~ "United States"
      assert result =~ "Canada"
      assert result =~ "United Kingdom"
    end

    test "renders options with groups" do
      options = [
        %{value: "us", label: "United States", group: "Americas"},
        %{value: "uk", label: "United Kingdom", group: "Europe"}
      ]

      result = render_component(&dm_autocomplete/1, %{options: options})
      assert result =~ "Americas"
      assert result =~ "Europe"
    end

    test "renders options with descriptions" do
      options = [
        %{value: "ex", label: "Elixir", description: "Functional language"}
      ]

      result = render_component(&dm_autocomplete/1, %{options: options})
      assert result =~ "Functional language"
    end

    test "renders options with disabled flag" do
      options = [
        %{value: "a", label: "Alpha", disabled: true}
      ]

      result = render_component(&dm_autocomplete/1, %{options: options})
      # JSON in HTML attribute is entity-escaped: " becomes &quot;
      assert result =~ "&quot;disabled&quot;:true"
    end
  end

  describe "dm_autocomplete value" do
    test "no value by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ ~s(value=")
    end

    test "renders value when provided" do
      result = render_component(&dm_autocomplete/1, %{value: "us"})
      assert result =~ ~s(value="us")
    end
  end

  describe "dm_autocomplete placeholder" do
    test "no placeholder by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ ~s(placeholder=")
    end

    test "renders placeholder" do
      result = render_component(&dm_autocomplete/1, %{placeholder: "Search..."})
      assert result =~ ~s(placeholder="Search...")
    end
  end

  describe "dm_autocomplete multiple" do
    test "not multiple by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ ~s( multiple)
    end

    test "renders multiple when true" do
      result = render_component(&dm_autocomplete/1, %{multiple: true})
      assert result =~ "multiple"
    end
  end

  describe "dm_autocomplete disabled" do
    test "not disabled by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ ~s( disabled)
    end

    test "renders disabled when true" do
      result = render_component(&dm_autocomplete/1, %{disabled: true})
      assert result =~ "disabled"
    end
  end

  describe "dm_autocomplete clearable" do
    test "not clearable by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ "clearable"
    end

    test "renders clearable when true" do
      result = render_component(&dm_autocomplete/1, %{clearable: true})
      assert result =~ "clearable"
    end
  end

  describe "dm_autocomplete loading" do
    test "not loading by default" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ ~s( loading)
    end

    test "renders loading when true" do
      result = render_component(&dm_autocomplete/1, %{loading: true})
      assert result =~ "loading"
    end

    test "sets aria-busy when loading" do
      result = render_component(&dm_autocomplete/1, %{loading: true})
      assert result =~ ~s(aria-busy="true")
    end

    test "no aria-busy when not loading" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ "aria-busy"
    end
  end

  describe "dm_autocomplete size" do
    test "defaults to md" do
      result = render_component(&dm_autocomplete/1, %{})
      assert result =~ ~s(size="md")
    end

    test "renders sm size" do
      result = render_component(&dm_autocomplete/1, %{size: "sm"})
      assert result =~ ~s(size="sm")
    end

    test "renders lg size" do
      result = render_component(&dm_autocomplete/1, %{size: "lg"})
      assert result =~ ~s(size="lg")
    end
  end

  describe "dm_autocomplete no_results_text" do
    test "defaults to No results found" do
      result = render_component(&dm_autocomplete/1, %{})
      assert result =~ "No results found"
    end

    test "renders custom no results text" do
      result = render_component(&dm_autocomplete/1, %{no_results_text: "Nothing here"})
      assert result =~ "Nothing here"
    end
  end

  describe "dm_autocomplete combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_autocomplete/1, %{
          id: "country-select",
          class: "w-80",
          value: "us",
          options: @sample_options,
          multiple: false,
          clearable: true,
          placeholder: "Pick a country",
          size: "lg",
          no_results_text: "No countries found"
        })

      assert result =~ ~s(id="country-select")
      assert result =~ "w-80"
      assert result =~ ~s(value="us")
      assert result =~ "United States"
      assert result =~ "clearable"
      assert result =~ ~s(placeholder="Pick a country")
      assert result =~ ~s(size="lg")
      assert result =~ "No countries found"
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_autocomplete/1, %{
          options: @sample_options,
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "autocomplete-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_autocomplete/1, %{
          options: @sample_options,
          errors: []
        })

      refute result =~ "helper-text text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_autocomplete/1, %{
          errors: ["something wrong"]
        })

      assert result =~ "autocomplete-error"
    end

    test "renders aria-invalid when errors present" do
      result =
        render_component(&dm_autocomplete/1, %{
          errors: ["is required"]
        })

      assert result =~ ~s(aria-invalid="true")
    end

    test "no aria-invalid when no errors" do
      result = render_component(&dm_autocomplete/1, %{})
      refute result =~ "aria-invalid"
    end
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_autocomplete/1, %{
          id: "ac",
          errors: ["is required"]
        })

      assert result =~ ~s(aria-describedby="ac-errors")
    end

    test "references helper when no errors" do
      result =
        render_component(&dm_autocomplete/1, %{
          id: "ac",
          helper: "Search for a country"
        })

      assert result =~ ~s(aria-describedby="ac-helper")
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_autocomplete/1, %{
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_autocomplete/1, %{
        name: "user[country]"
      })

    assert result =~ ~s(phx-feedback-for="user[country]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_autocomplete/1, %{
          id: "ac",
          helper: "Start typing to search"
        })

      assert result =~ "helper-text"
      assert result =~ "Start typing to search"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_autocomplete/1, %{
          id: "ac",
          helper: "Start typing to search",
          errors: ["is required"]
        })

      refute result =~ "Start typing to search"
      assert result =~ "is required"
    end
  end

  describe "FormField integration" do
    test "renders autocomplete with form field extracting id, name, and value" do
      field = Phoenix.Component.to_form(%{"country" => "us"}, as: "user")[:country]

      result =
        render_component(&dm_autocomplete/1, %{
          field: field,
          options: [%{value: "us", label: "USA"}]
        })

      assert result =~ ~s(id="user_country")
      assert result =~ ~s(name="user[country]")
      assert result =~ ~s(value="us")
    end

    test "renders autocomplete with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"country" => ""}, as: "user")[:country]

      result =
        render_component(&dm_autocomplete/1, %{
          field: field,
          id: "custom-auto",
          options: []
        })

      assert result =~ ~s(id="custom-auto")
    end
  end
end
