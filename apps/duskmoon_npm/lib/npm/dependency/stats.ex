defmodule NPM.Dependency.Stats do
  @moduledoc """
  Computes aggregate statistics across all dependencies.
  """

  @doc """
  Computes comprehensive stats from a lockfile.
  """
  @spec compute(map()) :: map()
  def compute(lockfile) do
    versions = Enum.map(lockfile, fn {_, e} -> extract_version(e) end) |> Enum.reject(&is_nil/1)

    %{
      total: map_size(lockfile),
      scoped: Enum.count(lockfile, fn {name, _} -> NPM.Scope.scoped?(name) end),
      version_stats: version_stats(versions),
      top_scopes: top_scopes(lockfile, 5)
    }
  end

  @doc """
  Returns the top N scopes by package count.
  """
  @spec top_scopes(map(), non_neg_integer()) :: [{String.t(), non_neg_integer()}]
  def top_scopes(lockfile, n \\ 5) do
    lockfile
    |> Enum.flat_map(fn {name, _} ->
      case NPM.Scope.extract(name) do
        nil -> []
        scope -> [scope]
      end
    end)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.take(n)
  end

  @doc """
  Returns the average number of transitive dependencies.
  """
  @spec avg_deps(map()) :: float()
  def avg_deps(lockfile) when map_size(lockfile) == 0, do: 0.0

  def avg_deps(lockfile) do
    total_deps =
      lockfile
      |> Enum.map(fn {_, e} -> dep_count(e) end)
      |> Enum.sum()

    Float.round(total_deps / map_size(lockfile), 2)
  end

  @doc """
  Formats stats for display.
  """
  @spec format(map()) :: String.t()
  def format(stats) do
    """
    Total packages: #{stats.total}
    Scoped: #{stats.scoped}
    Major versions: #{format_version_stats(stats.version_stats)}
    Top scopes: #{format_scopes(stats.top_scopes)}\
    """
  end

  defp version_stats(versions) do
    versions
    |> Enum.map(fn v -> v |> String.split(".", parts: 2) |> hd() end)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.take(5)
  end

  defp extract_version(%{version: v}), do: v
  defp extract_version(%{"version" => v}), do: v
  defp extract_version(_), do: nil

  defp dep_count(%{dependencies: deps}) when is_map(deps), do: map_size(deps)
  defp dep_count(%{"dependencies" => deps}) when is_map(deps), do: map_size(deps)
  defp dep_count(_), do: 0

  defp format_version_stats(stats) do
    Enum.map_join(stats, ", ", fn {v, count} -> "v#{v}(#{count})" end)
  end

  defp format_scopes([]), do: "none"
  defp format_scopes(scopes), do: Enum.map_join(scopes, ", ", fn {s, c} -> "@#{s}(#{c})" end)
end
