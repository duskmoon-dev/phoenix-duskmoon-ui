defmodule NPM.Security.Audit do
  @moduledoc """
  Security audit for npm packages.

  Checks installed packages against known vulnerabilities.
  This module provides the data structures and analysis logic;
  the actual advisory data would come from the npm audit API.
  """

  @type severity :: :critical | :high | :moderate | :low | :info
  @type advisory :: %{
          id: non_neg_integer(),
          title: String.t(),
          severity: severity(),
          vulnerable_versions: String.t(),
          patched_versions: String.t() | nil,
          url: String.t() | nil
        }
  @type finding :: %{
          package: String.t(),
          installed_version: String.t(),
          advisory: advisory()
        }

  @severity_order %{critical: 0, high: 1, moderate: 2, low: 3, info: 4}

  @doc """
  Checks a lockfile against a list of advisories.

  Returns findings — packages that match vulnerable version ranges.
  """
  @spec check(map(), [advisory()]) :: [finding()]
  def check(lockfile, advisories) do
    Enum.flat_map(advisories, fn advisory ->
      lockfile
      |> Enum.filter(fn {_name, entry} ->
        version_in_range?(entry.version, advisory.vulnerable_versions)
      end)
      |> Enum.map(fn {name, entry} ->
        %{package: name, installed_version: entry.version, advisory: advisory}
      end)
    end)
    |> Enum.sort_by(fn f -> {@severity_order[f.advisory.severity], f.package} end)
  end

  @doc """
  Checks if a finding has a patch available.
  """
  @spec fixable?(finding()) :: boolean()
  def fixable?(finding) do
    finding.advisory.patched_versions != nil and finding.advisory.patched_versions != ""
  end

  @doc """
  Filters findings by minimum severity level.
  """
  @spec filter_by_severity([finding()], severity()) :: [finding()]
  def filter_by_severity(findings, min_severity) do
    min_level = Map.get(@severity_order, min_severity, 4)

    Enum.filter(findings, fn f ->
      Map.get(@severity_order, f.advisory.severity, 4) <= min_level
    end)
  end

  @doc """
  Returns a summary of audit findings.
  """
  @spec summary([finding()]) :: %{
          total: non_neg_integer(),
          critical: non_neg_integer(),
          high: non_neg_integer(),
          moderate: non_neg_integer(),
          low: non_neg_integer(),
          fixable: non_neg_integer()
        }
  def summary(findings) do
    %{
      total: length(findings),
      critical: Enum.count(findings, &(&1.advisory.severity == :critical)),
      high: Enum.count(findings, &(&1.advisory.severity == :high)),
      moderate: Enum.count(findings, &(&1.advisory.severity == :moderate)),
      low: Enum.count(findings, &(&1.advisory.severity == :low)),
      fixable: Enum.count(findings, &fixable?/1)
    }
  end

  @doc """
  Formats a finding as a human-readable string.
  """
  @spec format_finding(finding()) :: String.t()
  def format_finding(finding) do
    severity = finding.advisory.severity |> Atom.to_string() |> String.upcase()
    "#{severity} #{finding.advisory.title} - #{finding.package}@#{finding.installed_version}"
  end

  @doc """
  Compares two severity levels. Returns :gt, :lt, or :eq.
  """
  @spec compare_severity(severity(), severity()) :: :gt | :lt | :eq
  def compare_severity(a, b) do
    a_level = Map.get(@severity_order, a, 4)
    b_level = Map.get(@severity_order, b, 4)

    cond do
      a_level < b_level -> :gt
      a_level > b_level -> :lt
      true -> :eq
    end
  end

  defp version_in_range?(version, range) do
    NPMSemver.matches?(version, range)
  rescue
    _ -> false
  end
end
