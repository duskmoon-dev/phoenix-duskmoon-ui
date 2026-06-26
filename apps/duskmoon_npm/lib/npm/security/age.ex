defmodule NPM.Security.Age do
  @moduledoc """
  Heuristics for recently created packages and freshly published versions.

  Very new packages and versions are not automatically malicious, but recent
  publication is a useful supply-chain risk signal. The default policy only
  warns: packages created in the last 7 days and versions published in the last
  3 days are flagged when registry metadata includes timestamps.
  """

  @type warning :: %{
          type: :new_package | :new_version,
          age_days: non_neg_integer(),
          threshold_days: non_neg_integer()
        }

  @doc "Return age warnings for package/version metadata."
  @spec warnings(map()) :: [warning()]
  def warnings(info) do
    []
    |> maybe_warn(:new_package, Map.get(info, :created_at), NPM.Config.package_age_warning_days())
    |> maybe_warn(
      :new_version,
      Map.get(info, :published_at),
      NPM.Config.version_age_warning_days()
    )
    |> Enum.reverse()
  end

  @doc "Format an age warning for display."
  @spec format(String.t(), String.t(), warning()) :: String.t()
  def format(name, version, %{type: :new_package, age_days: age, threshold_days: threshold}) do
    "#{name}@#{version} belongs to a package created #{age} day#{plural(age)} ago (< #{threshold} days)"
  end

  def format(name, version, %{type: :new_version, age_days: age, threshold_days: threshold}) do
    "#{name}@#{version} was published #{age} day#{plural(age)} ago (< #{threshold} days)"
  end

  defp maybe_warn(warnings, _type, nil, _threshold), do: warnings
  defp maybe_warn(warnings, _type, _timestamp, 0), do: warnings

  defp maybe_warn(warnings, type, timestamp, threshold) do
    with {:ok, age_days} <- age_days(timestamp),
         true <- age_days < threshold do
      [%{type: type, age_days: age_days, threshold_days: threshold} | warnings]
    else
      _ -> warnings
    end
  end

  defp age_days(timestamp) when is_binary(timestamp) do
    with {:ok, datetime, _offset} <- DateTime.from_iso8601(timestamp) do
      {:ok, max(div(DateTime.diff(DateTime.utc_now(), datetime, :second), 86_400), 0)}
    end
  end

  defp age_days(_), do: :error

  defp plural(1), do: ""
  defp plural(_), do: "s"
end
