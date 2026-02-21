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
  end
end
