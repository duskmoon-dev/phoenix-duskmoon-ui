defmodule PhoenixDuskmoon.Component.HelpersTest do
  use ExUnit.Case, async: true

  import PhoenixDuskmoon.Component.Helpers

  describe "css_color/1" do
    test "maps accent to tertiary" do
      assert css_color("accent") == "tertiary"
    end

    test "passes through primary" do
      assert css_color("primary") == "primary"
    end

    test "passes through secondary" do
      assert css_color("secondary") == "secondary"
    end

    test "passes through info" do
      assert css_color("info") == "info"
    end

    test "passes through success" do
      assert css_color("success") == "success"
    end

    test "passes through warning" do
      assert css_color("warning") == "warning"
    end

    test "passes through error" do
      assert css_color("error") == "error"
    end

    test "passes through nil" do
      assert css_color(nil) == nil
    end

    test "passes through tertiary unchanged" do
      assert css_color("tertiary") == "tertiary"
    end
  end

  describe "format_label/2" do
    test "replaces single placeholder" do
      assert format_label("Hello {name}", %{"name" => "World"}) == "Hello World"
    end

    test "replaces multiple placeholders" do
      result = format_label("Rate {index} out of {max}", %{"index" => 3, "max" => 5})
      assert result == "Rate 3 out of 5"
    end

    test "converts integer values to string" do
      assert format_label("{count} items", %{"count" => 42}) == "42 items"
    end

    test "returns template unchanged when no matching placeholders" do
      assert format_label("No placeholders here", %{"key" => "val"}) == "No placeholders here"
    end

    test "handles empty vars map" do
      assert format_label("Hello {name}", %{}) == "Hello {name}"
    end

    test "replaces all occurrences of same placeholder" do
      result = format_label("{x} and {x}", %{"x" => "A"})
      assert result == "A and A"
    end

    test "handles template with only placeholder" do
      assert format_label("{label}", %{"label" => "Test"}) == "Test"
    end
  end

  describe "split_value/2" do
    test "splits a binary into graphemes up to length" do
      assert split_value("1234", 4) == ["1", "2", "3", "4"]
    end

    test "takes at most length graphemes" do
      assert split_value("123456", 4) == ["1", "2", "3", "4"]
    end

    test "returns fewer graphemes when value is shorter than length" do
      assert split_value("12", 4) == ["1", "2"]
    end

    test "returns empty list for nil" do
      assert split_value(nil, 4) == []
    end

    test "returns empty list for non-binary values" do
      assert split_value(123, 4) == []
    end

    test "returns empty list for empty string" do
      assert split_value("", 4) == []
    end

    test "handles multibyte graphemes" do
      assert split_value("日本語テ", 3) == ["日", "本", "語"]
    end
  end
end
