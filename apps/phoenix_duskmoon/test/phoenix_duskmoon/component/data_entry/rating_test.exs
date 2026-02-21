defmodule PhoenixDuskmoon.Component.DataEntry.RatingTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  import PhoenixDuskmoon.Component.DataEntry.Rating

  describe "dm_rating basic rendering" do
    test "renders rating with default attrs" do
      result = render_component(&dm_rating/1, %{})
      assert result =~ "rating"
      assert result =~ "role=\"group\""
      assert result =~ "Rating: 0 out of 5"
      # Should render 5 star buttons by default
      assert length(String.split(result, "rating-item")) == 6
    end

    test "renders with value" do
      result = render_component(&dm_rating/1, %{value: 3, max: 5})
      assert result =~ "Rating: 3 out of 5"
      # 3 filled items
      filled_count = length(String.split(result, "filled")) - 1
      assert filled_count == 3
    end

    test "renders with custom max" do
      result = render_component(&dm_rating/1, %{value: 2, max: 10})
      assert result =~ "Rating: 2 out of 10"
      # 10 rating-item buttons
      assert length(String.split(result, "rating-item")) == 11
    end

    test "renders with custom id" do
      result = render_component(&dm_rating/1, %{id: "my-rating"})
      assert result =~ ~s(id="my-rating")
    end

    test "renders with custom class" do
      result = render_component(&dm_rating/1, %{class: "my-custom"})
      assert result =~ "my-custom"
    end

    test "value nil treated as 0" do
      result = render_component(&dm_rating/1, %{value: nil, max: 5})
      assert result =~ "Rating: 0 out of 5"
      refute result =~ "filled"
    end
  end

  describe "dm_rating form integration" do
    test "renders hidden input with name" do
      result = render_component(&dm_rating/1, %{name: "review[rating]", value: 4})
      assert result =~ ~s(name="review[rating]")
      assert result =~ ~s(value="4")
      assert result =~ "rating-input"
    end

    test "no hidden input without name" do
      result = render_component(&dm_rating/1, %{value: 3})
      refute result =~ "rating-input"
      refute result =~ ~s(type="hidden")
    end
  end

  describe "dm_rating size variants" do
    test "renders xs size" do
      result = render_component(&dm_rating/1, %{size: "xs"})
      assert result =~ "rating-xs"
    end

    test "renders sm size" do
      result = render_component(&dm_rating/1, %{size: "sm"})
      assert result =~ "rating-sm"
    end

    test "renders lg size" do
      result = render_component(&dm_rating/1, %{size: "lg"})
      assert result =~ "rating-lg"
    end

    test "renders xl size" do
      result = render_component(&dm_rating/1, %{size: "xl"})
      assert result =~ "rating-xl"
    end

    test "default size has no size class" do
      result = render_component(&dm_rating/1, %{})
      refute result =~ "rating-xs"
      refute result =~ "rating-sm"
      refute result =~ "rating-lg"
      refute result =~ "rating-xl"
    end
  end

  describe "dm_rating color variants" do
    test "renders primary color" do
      result = render_component(&dm_rating/1, %{color: "primary"})
      assert result =~ "rating-primary"
    end

    test "renders secondary color" do
      result = render_component(&dm_rating/1, %{color: "secondary"})
      assert result =~ "rating-secondary"
    end

    test "renders success color" do
      result = render_component(&dm_rating/1, %{color: "success"})
      assert result =~ "rating-success"
    end

    test "renders error color" do
      result = render_component(&dm_rating/1, %{color: "error"})
      assert result =~ "rating-error"
    end

    test "renders tertiary color" do
      result = render_component(&dm_rating/1, %{color: "tertiary"})
      assert result =~ "rating-tertiary"
    end

    test "renders info color" do
      result = render_component(&dm_rating/1, %{color: "info"})
      assert result =~ "rating-info"
    end

    test "renders warning color" do
      result = render_component(&dm_rating/1, %{color: "warning"})
      assert result =~ "rating-warning"
    end

    test "maps accent color to tertiary" do
      result = render_component(&dm_rating/1, %{color: "accent"})
      assert result =~ "rating-tertiary"
      refute result =~ "rating-accent"
    end

    test "default has no color class" do
      result = render_component(&dm_rating/1, %{})
      refute result =~ "rating-primary"
      refute result =~ "rating-secondary"
      refute result =~ "rating-success"
      refute result =~ "rating-error"
    end
  end

  describe "dm_rating states" do
    test "renders readonly" do
      result = render_component(&dm_rating/1, %{readonly: true})
      assert result =~ "rating-readonly"
      assert result =~ ~s(tabindex="-1")
    end

    test "renders disabled" do
      result = render_component(&dm_rating/1, %{disabled: true})
      assert result =~ "rating-disabled"
      assert result =~ "disabled"
      assert result =~ ~s(tabindex="-1")
    end

    test "renders disabled with visual styling" do
      result = render_component(&dm_rating/1, %{disabled: true})
      assert result =~ "opacity-50"
      assert result =~ "cursor-not-allowed"
    end

    test "interactive by default" do
      result = render_component(&dm_rating/1, %{})
      refute result =~ "rating-readonly"
      refute result =~ "rating-disabled"
      assert result =~ ~s(tabindex="0")
    end
  end

  describe "dm_rating style options" do
    test "renders animated" do
      result = render_component(&dm_rating/1, %{animated: true})
      assert result =~ "rating-animated"
    end

    test "renders compact" do
      result = render_component(&dm_rating/1, %{compact: true})
      assert result =~ "rating-compact"
    end

    test "no animated/compact by default" do
      result = render_component(&dm_rating/1, %{})
      refute result =~ "rating-animated"
      refute result =~ "rating-compact"
    end
  end

  describe "dm_rating custom icon" do
    test "renders custom icon (heart SVG path)" do
      result = render_component(&dm_rating/1, %{icon: "heart"})
      # Heart icon SVG path starts with M12,21.35
      assert result =~ "M12,21.35"
    end

    test "uses star icon by default (star SVG path)" do
      result = render_component(&dm_rating/1, %{})
      # Star icon SVG path starts with M12,17.27
      assert result =~ "M12,17.27"
    end
  end

  describe "dm_rating accessibility" do
    test "has role group" do
      result = render_component(&dm_rating/1, %{})
      assert result =~ ~s(role="group")
    end

    test "has aria-label with current value" do
      result = render_component(&dm_rating/1, %{value: 3, max: 5})
      assert result =~ "Rating: 3 out of 5"
    end

    test "buttons have aria-label" do
      result = render_component(&dm_rating/1, %{max: 5})
      assert result =~ "Rate 1 out of 5"
      assert result =~ "Rate 5 out of 5"
    end

    test "filled buttons have aria-pressed true" do
      result = render_component(&dm_rating/1, %{value: 2, max: 3})
      # Buttons 1 and 2 should be pressed, button 3 should not
      assert result =~ ~s(aria-pressed="true")
      assert result =~ ~s(aria-pressed="false")
    end
  end

  describe "dm_rating combined attrs" do
    test "renders with all attrs" do
      result =
        render_component(&dm_rating/1, %{
          id: "product-rating",
          name: "product[rating]",
          value: 4,
          max: 5,
          size: "lg",
          color: "primary",
          animated: true,
          compact: true,
          icon: "heart",
          class: "mt-2"
        })

      assert result =~ ~s(id="product-rating")
      assert result =~ ~s(name="product[rating]")
      assert result =~ "rating-lg"
      assert result =~ "rating-primary"
      assert result =~ "rating-animated"
      assert result =~ "rating-compact"
      assert result =~ "M12,21.35"
      assert result =~ "mt-2"
      assert result =~ "Rating: 4 out of 5"
    end
  end

  describe "FormField integration" do
    test "renders rating with form field extracting id and name" do
      field = Phoenix.Component.to_form(%{"score" => "3"}, as: "review")[:score]

      result = render_component(&dm_rating/1, %{field: field})

      assert result =~ ~s(id="review_score")
      assert result =~ ~s(name="review[score]")
    end

    test "renders rating with form field value" do
      field = Phoenix.Component.to_form(%{"score" => 4}, as: "review")[:score]

      result = render_component(&dm_rating/1, %{field: field})

      assert result =~ "Rating: 4 out of 5"
    end

    test "renders rating with custom id overriding field id" do
      field = Phoenix.Component.to_form(%{"score" => "3"}, as: "review")[:score]

      result = render_component(&dm_rating/1, %{field: field, id: "custom-rating"})

      assert result =~ ~s(id="custom-rating")
    end
  end

  describe "error messages" do
    test "renders error messages from errors list" do
      result =
        render_component(&dm_rating/1, %{
          errors: ["is required"]
        })

      assert result =~ "is required"
      assert result =~ "rating-error"
    end

    test "does not render errors when list is empty" do
      result =
        render_component(&dm_rating/1, %{
          errors: []
        })

      refute result =~ "helper-text text-error"
    end

    test "shows error state from errors list even without error boolean" do
      result =
        render_component(&dm_rating/1, %{
          errors: ["something wrong"]
        })

      assert result =~ "rating-error"
    end
  end

  test "renders phx-feedback-for with name" do
    result =
      render_component(&dm_rating/1, %{
        name: "review[rating]"
      })

    assert result =~ ~s(phx-feedback-for="review[rating]")
  end

  describe "helper text" do
    test "renders helper text when provided" do
      result =
        render_component(&dm_rating/1, %{
          id: "rt",
          helper: "Rate this product"
        })

      assert result =~ "helper-text"
      assert result =~ "Rate this product"
    end

    test "hides helper text when errors present" do
      result =
        render_component(&dm_rating/1, %{
          id: "rt",
          helper: "Rate this product",
          errors: ["is required"]
        })

      refute result =~ "Rate this product"
      assert result =~ "is required"
    end
  end

  describe "aria-describedby" do
    test "references errors container when errors present" do
      result =
        render_component(&dm_rating/1, %{
          id: "rate",
          errors: ["is required"]
        })

      assert result =~ ~s[aria-describedby="rate-errors"]
      assert result =~ ~s[aria-invalid="true"]
    end

    test "references helper when no errors" do
      result =
        render_component(&dm_rating/1, %{
          id: "rate",
          helper: "Rate this item"
        })

      assert result =~ ~s[aria-describedby="rate-helper"]
    end

    test "no aria-describedby when no id" do
      result =
        render_component(&dm_rating/1, %{
          errors: ["is required"]
        })

      refute result =~ "aria-describedby"
    end
  end

  test "renders rating with rest attributes" do
    result =
      render_component(&dm_rating/1, %{
        name: "rating",
        "data-testid": "my-rating"
      })

    assert result =~ ~s[data-testid="my-rating"]
  end
end
