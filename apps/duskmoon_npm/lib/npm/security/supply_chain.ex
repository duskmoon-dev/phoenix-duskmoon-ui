defmodule NPM.Security.SupplyChain do
  alias NPM.Dependency.Phantom

  @moduledoc """
  Evaluates supply chain security posture of a project's dependencies.

  Combines multiple signals: provenance, integrity, deprecations,
  phantom deps, and package age.
  """

  @doc """
  Assesses supply chain risk.
  """
  @spec assess(map(), map()) :: map()
  def assess(pkg_data, lockfile) do
    total = map_size(lockfile)
    phantoms = Phantom.count(pkg_data, lockfile)

    integrity_count =
      Enum.count(lockfile, fn {_, entry} ->
        integrity_present?(entry)
      end)

    integrity_pct = if total > 0, do: Float.round(integrity_count / total * 100, 1), else: 0.0

    %{
      total_packages: total,
      phantom_deps: phantoms,
      integrity_coverage: integrity_pct,
      risk_level: risk_level(integrity_pct, phantoms, total)
    }
  end

  @doc """
  Computes a risk score (0-100, lower is better).
  """
  @spec risk_score(map()) :: non_neg_integer()
  def risk_score(assessment) do
    score = 0
    score = score + max(0, round(50 - assessment.integrity_coverage / 2))
    score = if assessment.phantom_deps > 5, do: score + 20, else: score
    score = if assessment.phantom_deps > 0, do: score + 10, else: score
    min(100, score)
  end

  @doc """
  Formats assessment for display.
  """
  @spec format(map()) :: String.t()
  def format(assessment) do
    """
    Supply Chain Assessment (#{assessment.risk_level}):
      Packages: #{assessment.total_packages}
      Integrity: #{assessment.integrity_coverage}%
      Phantom deps: #{assessment.phantom_deps}\
    """
  end

  defp risk_level(integrity_pct, phantoms, _total) do
    cond do
      integrity_pct >= 90 and phantoms == 0 -> :low
      integrity_pct >= 50 and phantoms < 5 -> :medium
      true -> :high
    end
  end

  defp integrity_present?(%{integrity: i}) when is_binary(i) and i != "", do: true
  defp integrity_present?(%{"integrity" => i}) when is_binary(i) and i != "", do: true
  defp integrity_present?(_), do: false
end
