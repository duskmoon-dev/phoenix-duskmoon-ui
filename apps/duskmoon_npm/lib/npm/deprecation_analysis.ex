defmodule NPM.DeprecationAnalysis do
  @moduledoc """
  Analyzes deprecation messages to extract replacement suggestions
  and categorize deprecation reasons.
  """

  @doc """
  Extracts suggested replacement package from deprecation message.
  """
  @spec replacement(String.t()) :: String.t() | nil
  def replacement(message) do
    patterns = [
      ~r/use\s+`?([a-z@][a-z0-9\-\/_\.]*)`?\s+instead/i,
      ~r/replaced\s+by\s+`?([a-z@][a-z0-9\-\/_\.]*)`?/i,
      ~r/moved\s+to\s+`?([a-z@][a-z0-9\-\/_\.]*)`?/i,
      ~r/see\s+`?([a-z@][a-z0-9\-\/_\.]*)`?/i
    ]

    Enum.find_value(patterns, fn pattern ->
      case Regex.run(pattern, message) do
        [_, name] -> name
        _ -> nil
      end
    end)
  end

  @categories [
    {~w(security vulnerab), :security},
    {~w(renamed moved), :renamed},
    {["replaced", "use "], :replaced},
    {["no longer maintained", "unmaintained"], :unmaintained},
    {["broken", "do not use"], :broken}
  ]

  @doc """
  Categorizes the deprecation reason.
  """
  @spec categorize(String.t()) :: atom()
  def categorize(message) do
    msg = String.downcase(message)

    Enum.find_value(@categories, :other, fn {keywords, category} ->
      if Enum.any?(keywords, &String.contains?(msg, &1)), do: category
    end)
  end

  @doc """
  Analyzes a list of deprecated packages.
  """
  @spec analyze([{String.t(), String.t()}]) :: map()
  def analyze(deprecations) do
    by_category =
      deprecations
      |> Enum.map(fn {name, msg} -> {name, msg, categorize(msg)} end)
      |> Enum.group_by(&elem(&1, 2))

    replacements =
      deprecations
      |> Enum.flat_map(fn {name, msg} ->
        case replacement(msg) do
          nil -> []
          rep -> [{name, rep}]
        end
      end)

    %{
      total: length(deprecations),
      by_category: Map.new(by_category, fn {k, v} -> {k, length(v)} end),
      with_replacement: length(replacements),
      replacements: replacements
    }
  end

  @doc """
  Formats an analysis report.
  """
  @spec format_report(map()) :: String.t()
  def format_report(%{total: 0}), do: "No deprecated packages."

  def format_report(analysis) do
    lines = ["#{analysis.total} deprecated packages:"]

    category_lines =
      analysis.by_category
      |> Enum.sort_by(&elem(&1, 1), :desc)
      |> Enum.map(fn {cat, count} -> "  #{cat}: #{count}" end)

    replacement_lines =
      if analysis.replacements != [] do
        [
          "Suggested replacements:"
          | Enum.map(analysis.replacements, fn {from, to} -> "  #{from} → #{to}" end)
        ]
      else
        []
      end

    Enum.join(lines ++ category_lines ++ replacement_lines, "\n")
  end
end
