defmodule Mix.Tasks.Npm.Outdated do
  @shortdoc "Show outdated npm packages"

  @moduledoc """
  Show npm packages with newer versions available.

      mix npm.outdated

  Compares locked versions against the latest available on the registry.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    with {:ok, lockfile} <- NPM.Lockfile.read(),
         {:ok, project} <- NPM.Workspace.read_all(),
         {:ok, deps} <- NPM.Workspace.install_dependencies(project) do
      if lockfile == %{} do
        Mix.shell().info("No npm.lock found, run `mix npm.install` first.")
      else
        check_outdated(lockfile, deps)
      end
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.outdated")
  end

  defp check_outdated(lockfile, deps) do
    results =
      deps
      |> Task.async_stream(
        fn {name, range} ->
          case NPM.Registry.get_packument(name) do
            {:ok, packument} ->
              locked = get_in(lockfile, [name, Access.key(:version)])
              latest = latest_version(packument)
              wanted = wanted_version(packument, range)
              {name, %{current: locked, wanted: wanted, latest: latest, range: range}}

            {:error, _} ->
              {name, :error}
          end
        end,
        max_concurrency: 8,
        timeout: 30_000
      )
      |> Enum.flat_map(fn
        {:ok, {name, %{} = info}} -> [{name, info}]
        _ -> []
      end)
      |> Enum.filter(fn {_name, info} ->
        info.current != nil and info.latest != nil and info.current != info.latest
      end)
      |> Enum.sort_by(&elem(&1, 0))

    if results == [] do
      Mix.shell().info("All packages are up to date.")
    else
      Mix.shell().info(format_table(results))
    end
  end

  defp latest_version(packument) do
    packument.versions
    |> Map.keys()
    |> parse_stable_versions()
    |> Enum.sort_by(&elem(&1, 0), Version)
    |> last_version_string()
  end

  defp wanted_version(packument, range) do
    case NPMSemver.to_hex_constraint(range) do
      {:ok, constraint} ->
        packument.versions
        |> Map.keys()
        |> parse_stable_versions()
        |> Enum.filter(fn {ver, _} -> HexSolver.Constraint.allows?(constraint, ver) end)
        |> Enum.sort_by(&elem(&1, 0), Version)
        |> last_version_string()

      :error ->
        nil
    end
  end

  defp parse_stable_versions(version_strings) do
    Enum.flat_map(version_strings, &parse_stable_version/1)
  end

  defp parse_stable_version(v) do
    case Version.parse(v) do
      {:ok, %{pre: []} = ver} -> [{ver, v}]
      _ -> []
    end
  end

  defp last_version_string([]), do: nil
  defp last_version_string(list), do: list |> List.last() |> elem(1)

  defp format_table(results) do
    header =
      String.pad_trailing("Package", 30) <>
        String.pad_trailing("Current", 15) <>
        String.pad_trailing("Wanted", 15) <>
        "Latest"

    rows =
      Enum.map_join(results, "\n", fn {name, info} ->
        String.pad_trailing(name, 30) <>
          String.pad_trailing(info.current || "?", 15) <>
          String.pad_trailing(info.wanted || "?", 15) <>
          (info.latest || "?")
      end)

    header <> "\n" <> rows
  end
end
