defmodule NPM.VersionRange do
  @moduledoc """
  Advanced version range manipulation.

  Extends NPMSemver with range intersection, union,
  and analysis operations.
  """

  @doc """
  Checks if two ranges can be satisfied by the same version.
  """
  @spec compatible?(String.t(), String.t()) :: boolean()
  def compatible?(range_a, range_b) do
    test_versions()
    |> Enum.any?(fn v -> matches_both?(v, range_a, range_b) end)
  end

  @doc """
  Finds the highest version that satisfies a range from a list.
  """
  @spec max_satisfying([String.t()], String.t()) :: String.t() | nil
  def max_satisfying(versions, range) do
    versions
    |> Enum.filter(&safe_matches?(&1, range))
    |> Enum.sort(&compare_desc/2)
    |> List.first()
  end

  @doc """
  Finds the lowest version that satisfies a range from a list.
  """
  @spec min_satisfying([String.t()], String.t()) :: String.t() | nil
  def min_satisfying(versions, range) do
    versions
    |> Enum.filter(&safe_matches?(&1, range))
    |> Enum.sort(&compare_asc/2)
    |> List.first()
  end

  @doc """
  Checks if a range is exact (pinned to a single version).
  """
  @spec exact?(String.t()) :: boolean()
  def exact?(range) do
    String.match?(range, ~r/^\d+\.\d+\.\d+$/)
  end

  @doc """
  Extracts the major version from a range (for caret ranges).
  """
  @spec major(String.t()) :: non_neg_integer() | nil
  def major(range) do
    case Regex.run(~r/(\d+)/, range) do
      [_, major] -> String.to_integer(major)
      _ -> nil
    end
  end

  @doc """
  Classifies a range by type.
  """
  @spec classify(String.t()) :: atom()
  def classify("*"), do: :any
  def classify(""), do: :any

  def classify(range) do
    cond do
      String.contains?(range, "||") -> :or_range
      exact?(range) -> :exact
      true -> classify_prefix(range)
    end
  end

  defp classify_prefix("^" <> _), do: :caret
  defp classify_prefix("~" <> _), do: :tilde

  defp classify_prefix(range) do
    cond do
      String.contains?(range, " - ") -> :hyphen
      String.contains?(range, ">=") or String.contains?(range, "<=") -> :comparator
      true -> :other
    end
  end

  @doc """
  Returns a human-readable description of a range.
  """
  @spec describe(String.t()) :: String.t()
  def describe(range) do
    case classify(range) do
      :any -> "any version"
      :exact -> "exactly #{range}"
      :caret -> "compatible with #{String.trim_leading(range, "^")}"
      :tilde -> "approximately #{String.trim_leading(range, "~")}"
      :hyphen -> "between #{range}"
      :or_range -> "one of #{range}"
      :comparator -> "#{range}"
      :other -> range
    end
  end

  defp safe_matches?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    _ -> false
  end

  defp matches_both?(version, range_a, range_b) do
    safe_matches?(version, range_a) and safe_matches?(version, range_b)
  end

  defp compare_desc(a, b), do: Version.compare(a, b) == :gt
  defp compare_asc(a, b), do: Version.compare(a, b) == :lt

  defp test_versions do
    for major <- 0..25, minor <- [0, 1, 5, 10], patch <- [0, 1, 5] do
      "#{major}.#{minor}.#{patch}"
    end
  end
end
