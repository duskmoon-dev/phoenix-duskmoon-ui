defmodule NPM.Security.CVE do
  @moduledoc """
  CVE (Common Vulnerabilities and Exposures) cross-referencing.

  Maps npm advisory data to CVE identifiers and provides
  vulnerability severity analysis.
  """

  @severity_order %{"critical" => 4, "high" => 3, "moderate" => 2, "low" => 1, "info" => 0}

  @doc """
  Extracts CVE identifiers from advisory data.
  """
  @spec extract_cves(map()) :: [String.t()]
  def extract_cves(%{"cves" => cves}) when is_list(cves), do: cves
  def extract_cves(%{"cve" => cve}) when is_binary(cve), do: [cve]

  def extract_cves(%{"references" => refs}) when is_binary(refs) do
    Regex.scan(~r/CVE-\d{4}-\d+/, refs)
    |> List.flatten()
    |> Enum.uniq()
  end

  def extract_cves(_), do: []

  @doc """
  Compares two severity levels. Returns :gt, :lt, or :eq.
  """
  @spec compare_severity(String.t(), String.t()) :: :gt | :lt | :eq
  def compare_severity(a, b) do
    va = Map.get(@severity_order, a, 0)
    vb = Map.get(@severity_order, b, 0)

    cond do
      va > vb -> :gt
      va < vb -> :lt
      true -> :eq
    end
  end

  @doc """
  Returns the highest severity from a list of advisories.
  """
  @spec max_severity([map()]) :: String.t()
  def max_severity([]), do: "none"

  def max_severity(advisories) do
    advisories
    |> Enum.map(&(&1["severity"] || "info"))
    |> Enum.max_by(&Map.get(@severity_order, &1, 0))
  end

  @doc """
  Groups advisories by affected package.
  """
  @spec group_by_package([map()]) :: %{String.t() => [map()]}
  def group_by_package(advisories) do
    Enum.group_by(advisories, &(&1["module_name"] || &1["name"] || "unknown"))
  end

  @doc """
  Counts advisories by severity.
  """
  @spec severity_counts([map()]) :: %{String.t() => non_neg_integer()}
  def severity_counts(advisories) do
    advisories
    |> Enum.group_by(&(&1["severity"] || "info"))
    |> Map.new(fn {severity, items} -> {severity, length(items)} end)
  end

  @doc """
  Checks if any advisory is above a given threshold.
  """
  @spec above_threshold?([map()], String.t()) :: boolean()
  def above_threshold?(advisories, threshold) do
    Enum.any?(advisories, fn adv ->
      compare_severity(adv["severity"] || "info", threshold) in [:gt, :eq]
    end)
  end

  @doc """
  Formats a vulnerability summary.
  """
  @spec format_summary([map()]) :: String.t()
  def format_summary([]), do: "No known vulnerabilities."

  def format_summary(advisories) do
    counts = severity_counts(advisories)

    parts =
      ~w(critical high moderate low info)
      |> Enum.flat_map(fn sev ->
        case Map.get(counts, sev) do
          nil -> []
          0 -> []
          n -> ["#{n} #{sev}"]
        end
      end)

    "#{length(advisories)} vulnerabilities: #{Enum.join(parts, ", ")}"
  end
end
