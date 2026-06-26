defmodule Mix.Tasks.Npm.Deprecations do
  @shortdoc "List deprecated installed packages"

  @moduledoc """
  Show deprecated packages in the current lockfile.

      mix npm.deprecations

  Queries the registry for each locked package and reports
  any deprecation notices.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No packages installed.")

      {:ok, lockfile} ->
        lockfile |> find_deprecated() |> print_deprecated()

      {:error, reason} ->
        Mix.shell().error("Failed to read lockfile: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.deprecations")
  end

  defp print_deprecated([]) do
    Mix.shell().info("No deprecated packages found.")
  end

  defp print_deprecated(deprecated) do
    Mix.shell().info("Deprecated packages:\n")

    Enum.each(deprecated, fn {name, version, msg} ->
      Mix.shell().info("  #{name}@#{version}: #{msg}")
    end)
  end

  defp find_deprecated(lockfile) do
    lockfile
    |> Task.async_stream(
      fn {name, entry} -> check_deprecated(name, entry.version) end,
      max_concurrency: 8,
      timeout: 30_000
    )
    |> Enum.flat_map(fn
      {:ok, nil} -> []
      {:ok, result} -> [result]
      _ -> []
    end)
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp check_deprecated(name, version) do
    case NPM.Registry.get_packument(name) do
      {:ok, packument} ->
        case get_in(packument.versions, [version]) do
          %{deprecated: msg} when is_binary(msg) and msg != "" -> {name, version, msg}
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
