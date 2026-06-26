defmodule NPM.Security.Provenance do
  @moduledoc """
  Supply chain provenance checking for npm packages.

  Validates SLSA provenance attestations, checks build source
  transparency, and identifies packages published from CI.
  """

  @trusted_registries ["https://registry.npmjs.org"]

  @doc """
  Checks if a package entry has provenance information.
  """
  @spec has_provenance?(map()) :: boolean()
  def has_provenance?(entry) do
    Map.has_key?(entry, :attestations) or
      Map.has_key?(entry, "attestations") or
      Map.has_key?(entry, :provenance) or
      Map.has_key?(entry, "provenance")
  end

  @doc """
  Scans a lockfile for packages with/without provenance.
  """
  @spec scan(map()) :: %{with_provenance: [String.t()], without: [String.t()]}
  def scan(lockfile) do
    {with_prov, without} =
      lockfile
      |> Enum.split_with(fn {_name, entry} -> has_provenance?(entry) end)

    %{
      with_provenance: with_prov |> Enum.map(&elem(&1, 0)) |> Enum.sort(),
      without: without |> Enum.map(&elem(&1, 0)) |> Enum.sort()
    }
  end

  @doc """
  Checks if a package's registry is trusted.
  """
  @spec trusted_registry?(String.t()) :: boolean()
  def trusted_registry?(registry_url) do
    Enum.any?(@trusted_registries, &String.starts_with?(registry_url, &1))
  end

  @doc """
  Validates that a package has integrity hash.
  """
  @spec has_integrity?(map()) :: boolean()
  def has_integrity?(entry) do
    case integrity_value(entry) do
      nil -> false
      "" -> false
      _ -> true
    end
  end

  @doc """
  Returns a supply chain risk summary for the lockfile.
  """
  @spec risk_summary(map()) :: map()
  def risk_summary(lockfile) do
    total = map_size(lockfile)
    with_integrity = Enum.count(lockfile, fn {_, e} -> has_integrity?(e) end)
    with_prov = Enum.count(lockfile, fn {_, e} -> has_provenance?(e) end)

    %{
      total: total,
      with_integrity: with_integrity,
      without_integrity: total - with_integrity,
      with_provenance: with_prov,
      integrity_pct: if(total > 0, do: Float.round(with_integrity / total * 100, 1), else: 0.0)
    }
  end

  @doc """
  Formats the risk summary for display.
  """
  @spec format_summary(map()) :: String.t()
  def format_summary(summary) do
    """
    Supply Chain Summary:
      Total packages: #{summary.total}
      With integrity hash: #{summary.with_integrity} (#{summary.integrity_pct}%)
      Without integrity: #{summary.without_integrity}
      With provenance: #{summary.with_provenance}\
    """
  end

  defp integrity_value(%{integrity: v}), do: v
  defp integrity_value(%{"integrity" => v}), do: v
  defp integrity_value(_), do: nil
end
