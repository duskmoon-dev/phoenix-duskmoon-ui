defmodule Mix.Tasks.Npm.View do
  @shortdoc "View detailed registry info for a package"

  @moduledoc """
  View detailed information about a package from the registry.

      mix npm.view react
      mix npm.view lodash versions
      mix npm.view express dependencies

  Shows name, version, description, dependencies, engines, and more.
  """

  use Mix.Task

  @impl true
  def run([name | fields]) do
    Application.ensure_all_started(:req)

    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        latest = latest_version(packument)

        if fields == [] do
          print_full(name, packument, latest)
        else
          print_fields(packument, latest, fields)
        end

      {:error, :not_found} ->
        Mix.shell().error("Package #{name} not found.")

      {:error, reason} ->
        Mix.shell().error("Error: #{inspect(reason)}")
    end
  end

  def run([]) do
    Mix.shell().error("Usage: mix npm.view <package> [field...]")
  end

  defp print_full(name, packument, latest) do
    info = Map.get(packument.versions, latest)
    Mix.shell().info("#{name}@#{latest}")

    if info do
      deps = info.dependencies
      if map_size(deps) > 0, do: print_map("dependencies", deps)

      peers = info.peer_dependencies
      if map_size(peers) > 0, do: print_map("peerDependencies", peers)

      engines = info.engines
      if map_size(engines) > 0, do: print_map("engines", engines)
    end

    Mix.shell().info("\nversions: #{map_size(packument.versions)}")
  end

  defp print_fields(packument, latest, fields) do
    info = Map.get(packument.versions, latest)

    Enum.each(fields, fn field ->
      value = get_field(packument, info, field)
      Mix.shell().info("#{field}: #{format_value(value)}")
    end)
  end

  defp get_field(packument, _info, "versions") do
    Map.keys(packument.versions) |> Enum.sort()
  end

  defp get_field(_packument, info, "dependencies"), do: info.dependencies
  defp get_field(_packument, info, "engines"), do: info.engines
  defp get_field(_packument, info, "peerDependencies"), do: info.peer_dependencies
  defp get_field(_packument, _info, _), do: nil

  defp format_value(nil), do: "(not available)"
  defp format_value(map) when is_map(map), do: inspect(map)
  defp format_value(list) when is_list(list), do: Enum.join(list, ", ")
  defp format_value(v), do: to_string(v)

  defp print_map(label, map) do
    Mix.shell().info("\n#{label}:")
    Enum.each(map, fn {k, v} -> Mix.shell().info("  #{k}: #{v}") end)
  end

  defp latest_version(packument) do
    packument.versions
    |> Map.keys()
    |> NPM.VersionUtil.sort()
    |> List.last()
  end
end
