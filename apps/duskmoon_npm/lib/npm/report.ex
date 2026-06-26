defmodule NPM.Report do
  @moduledoc """
  Generates comprehensive project dependency reports.

  Combines data from multiple modules to produce an overview
  of dependencies, licenses, security, and project health.
  """

  @doc """
  Generates a dependency summary from the lockfile.
  """
  @spec dependency_summary(map()) :: map()
  def dependency_summary(lockfile) do
    total = map_size(lockfile)
    scoped = Enum.count(lockfile, fn {name, _} -> NPM.Scope.scoped?(name) end)

    %{
      total: total,
      scoped: scoped,
      unscoped: total - scoped,
      scoped_pct: if(total > 0, do: Float.round(scoped / total * 100, 1), else: 0.0)
    }
  end

  @doc """
  Generates a version summary from the lockfile.
  """
  @spec version_summary(map()) :: map()
  def version_summary(lockfile) do
    versions =
      lockfile
      |> Enum.map(fn {_, entry} -> extract_version(entry) end)
      |> Enum.reject(&is_nil/1)

    majors =
      versions
      |> Enum.map(&major_version/1)
      |> Enum.frequencies()
      |> Enum.sort_by(&elem(&1, 1), :desc)

    %{
      total: length(versions),
      major_distribution: majors
    }
  end

  @doc """
  Formats a dependency summary for display.
  """
  @spec format_summary(map()) :: String.t()
  def format_summary(summary) do
    """
    Dependencies: #{summary.total}
      Scoped: #{summary.scoped} (#{summary.scoped_pct}%)
      Unscoped: #{summary.unscoped}\
    """
  end

  @doc """
  Returns a combined project report.
  """
  @spec full_report(map(), map()) :: map()
  def full_report(lockfile, pkg_data) do
    %{
      name: pkg_data["name"],
      version: pkg_data["version"],
      dependencies: dependency_summary(lockfile),
      versions: version_summary(lockfile),
      has_license: Map.has_key?(pkg_data, "license"),
      has_repository: Map.has_key?(pkg_data, "repository")
    }
  end

  defp extract_version(%{version: v}), do: v
  defp extract_version(%{"version" => v}), do: v
  defp extract_version(_), do: nil

  defp major_version(version) do
    case String.split(version, ".", parts: 2) do
      [major | _] -> major
      _ -> "0"
    end
  end
end
