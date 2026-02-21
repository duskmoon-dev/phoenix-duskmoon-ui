defmodule PhoenixDuskmoonTest do
  use ExUnit.Case, async: true

  doctest PhoenixDuskmoon

  describe "PhoenixDuskmoon.Component.generate_id/0" do
    test "returns a string starting with random- prefix" do
      id = PhoenixDuskmoon.Component.generate_id()
      assert String.starts_with?(id, "random-")
    end

    test "returns a string with 16 hex characters after prefix" do
      id = PhoenixDuskmoon.Component.generate_id()
      hex_part = String.replace_prefix(id, "random-", "")
      assert String.length(hex_part) == 16
      assert hex_part =~ ~r/^[0-9A-F]{16}$/
    end

    test "generates unique ids on successive calls" do
      ids = for _ <- 1..10, do: PhoenixDuskmoon.Component.generate_id()
      assert length(Enum.uniq(ids)) == 10
    end
  end
end
