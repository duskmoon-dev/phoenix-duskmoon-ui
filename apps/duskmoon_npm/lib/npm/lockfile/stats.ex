defmodule NPM.Lockfile.Stats do
  @moduledoc """
  Computes statistics about the lockfile itself.
  """

  @doc """
  Computes lockfile metadata.
  """
  @spec compute(String.t()) :: {:ok, map()} | {:error, term()}
  def compute(path) do
    case File.stat(path) do
      {:ok, stat} ->
        {:ok,
         %{
           size: stat.size,
           modified: stat.mtime,
           size_human: format_size(stat.size)
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Computes lockfile content stats.
  """
  @spec content_stats(map()) :: map()
  def content_stats(lockfile) do
    total = map_size(lockfile)
    with_integrity = Enum.count(lockfile, fn {_, e} -> has_field?(e, :integrity) end)
    with_deps = Enum.count(lockfile, fn {_, e} -> has_deps?(e) end)

    %{
      total_packages: total,
      with_integrity: with_integrity,
      with_deps: with_deps,
      leaf_packages: total - with_deps,
      integrity_pct: if(total > 0, do: Float.round(with_integrity / total * 100, 1), else: 0.0)
    }
  end

  @doc """
  Estimates disk size of node_modules from lockfile.
  """
  @spec estimated_size(map()) :: non_neg_integer()
  def estimated_size(lockfile) do
    map_size(lockfile) * 50_000
  end

  @doc """
  Formats size in human-readable form.
  """
  @spec format_size(non_neg_integer()) :: String.t()
  defdelegate format_size(bytes), to: NPM.FormatUtil

  defp has_field?(entry, field) do
    case Map.get(entry, field) || Map.get(entry, to_string(field)) do
      nil -> false
      "" -> false
      _ -> true
    end
  end

  defp has_deps?(%{dependencies: deps}) when is_map(deps) and map_size(deps) > 0, do: true
  defp has_deps?(%{"dependencies" => deps}) when is_map(deps) and map_size(deps) > 0, do: true
  defp has_deps?(_), do: false
end
