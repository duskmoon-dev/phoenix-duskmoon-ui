defmodule NPM.Diagnostics.Health do
  @moduledoc """
  Comprehensive project health scoring.

  Evaluates multiple dimensions of npm project health and
  produces an overall score with actionable recommendations.
  """

  @doc """
  Computes a health score (0-100) for a project.
  """
  @spec score(map()) :: %{score: non_neg_integer(), details: map()}
  def score(checks) do
    points = [
      has_lockfile: check_val(checks, :has_lockfile, 15),
      has_package_json: check_val(checks, :has_package_json, 15),
      integrity_coverage: integrity_points(checks),
      no_vulnerabilities: vuln_points(checks),
      up_to_date: freshness_points(checks),
      has_license: check_val(checks, :has_license, 10),
      no_deprecated: check_val(checks, :no_deprecated, 10)
    ]

    total = points |> Keyword.values() |> Enum.sum()
    capped = min(total, 100)

    %{score: capped, details: Map.new(points)}
  end

  @doc """
  Returns a grade based on the score.
  """
  @spec grade(non_neg_integer()) :: String.t()
  def grade(score) when score >= 90, do: "A"
  def grade(score) when score >= 80, do: "B"
  def grade(score) when score >= 70, do: "C"
  def grade(score) when score >= 60, do: "D"
  def grade(_), do: "F"

  @doc """
  Returns recommendations based on checks.
  """
  @spec recommendations(map()) :: [String.t()]
  def recommendations(checks) do
    recs = [
      {!checks[:has_lockfile], "Run `mix npm.install` to generate a lockfile"},
      {!checks[:has_package_json], "Create a package.json file"},
      {checks[:vulnerability_count] && checks[:vulnerability_count] > 0,
       "Run `mix npm.audit` to review vulnerabilities"},
      {checks[:outdated_count] && checks[:outdated_count] > 0,
       "Run `mix npm.outdated` to check for updates"},
      {!checks[:has_license], "Add a license field to package.json"},
      {!checks[:no_deprecated], "Replace deprecated dependencies"}
    ]

    recs
    |> Enum.filter(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Formats the health report.
  """
  @spec format_report(map()) :: String.t()
  def format_report(%{score: score, details: details}) do
    grade_str = grade(score)

    detail_lines =
      Enum.map_join(details, "\n", fn {key, points} -> "  #{key}: #{points} pts" end)

    "Health Score: #{score}/100 (#{grade_str})\n#{detail_lines}"
  end

  defp check_val(checks, key, points) do
    if Map.get(checks, key, false), do: points, else: 0
  end

  defp integrity_points(checks) do
    pct = Map.get(checks, :integrity_pct, 0)

    cond do
      pct >= 95 -> 15
      pct >= 80 -> 10
      pct >= 50 -> 5
      true -> 0
    end
  end

  defp vuln_points(checks) do
    count = Map.get(checks, :vulnerability_count, 0)
    if count == 0, do: 15, else: 0
  end

  defp freshness_points(checks) do
    outdated = Map.get(checks, :outdated_count, 0)

    cond do
      outdated == 0 -> 10
      outdated < 5 -> 5
      true -> 0
    end
  end
end
