defmodule Mix.Tasks.Npm.Info do
  @shortdoc "Show info about an npm package"

  @moduledoc """
  Show information about an npm package from the registry.

      mix npm.info lodash
      mix npm.info express@4.21.2

  Displays the package name, latest version, description, and dependencies.
  """

  use Mix.Task

  @impl true
  def run([spec]) do
    Application.ensure_all_started(:req)
    {name, version} = parse_spec(spec)
    show_info(name, version)
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.info <package[@version]>")
  end

  defp parse_spec(spec) do
    case spec do
      "@" <> rest ->
        case String.split(rest, "@", parts: 2) do
          [scoped, version] -> {"@" <> scoped, version}
          [scoped] -> {"@" <> scoped, nil}
        end

      _ ->
        case String.split(spec, "@", parts: 2) do
          [name, version] -> {name, version}
          [name] -> {name, nil}
        end
    end
  end

  defp show_info(name, version) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        print_packument(packument, version)

      {:error, :not_found} ->
        Mix.shell().error("Package #{name} not found.")

      {:error, reason} ->
        Mix.shell().error("Failed to fetch package: #{inspect(reason)}")
    end
  end

  defp print_packument(packument, nil) do
    versions = Map.keys(packument.versions)
    latest = latest_stable(versions)
    version_count = length(versions)

    Mix.shell().info("#{packument.name}")
    Mix.shell().info("  latest: #{latest || "unknown"}")
    Mix.shell().info("  versions: #{version_count}")

    if latest do
      print_version_info(packument, latest)
    end
  end

  defp print_packument(packument, version) do
    if Map.has_key?(packument.versions, version) do
      Mix.shell().info("#{packument.name}@#{version}")
      print_version_info(packument, version)
    else
      Mix.shell().error("Version #{version} not found for #{packument.name}")

      Mix.shell().info(
        "Available: #{packument.versions |> Map.keys() |> Enum.take(-5) |> Enum.join(", ")}"
      )
    end
  end

  defp print_version_info(packument, version) do
    info = Map.get(packument.versions, version)
    if info, do: print_deps(info.dependencies)
  end

  defp print_deps(deps) when map_size(deps) == 0 do
    Mix.shell().info("  dependencies: none")
  end

  defp print_deps(deps) do
    Mix.shell().info("  dependencies:")

    Enum.each(Enum.sort(deps), fn {dep_name, range} ->
      Mix.shell().info("    #{dep_name}: #{range}")
    end)
  end

  defp latest_stable(versions) do
    versions
    |> Enum.flat_map(&parse_stable/1)
    |> Enum.sort_by(&elem(&1, 0), Version)
    |> last_version_string()
  end

  defp parse_stable(v) do
    case Version.parse(v) do
      {:ok, %{pre: []} = ver} -> [{ver, v}]
      _ -> []
    end
  end

  defp last_version_string([]), do: nil
  defp last_version_string(list), do: list |> List.last() |> elem(1)
end
