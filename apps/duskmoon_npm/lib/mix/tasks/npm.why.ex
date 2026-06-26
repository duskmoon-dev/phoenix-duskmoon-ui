defmodule Mix.Tasks.Npm.Why do
  alias NPM.Package.JSON

  @shortdoc "Explain why a package is installed"

  @moduledoc """
  Show why an npm package is in the dependency tree.

      mix npm.why accepts

  Displays which packages depend on the given package.
  """

  use Mix.Task

  @impl true
  def run([name]) do
    Application.ensure_all_started(:req)

    with {:ok, lockfile} <- NPM.Lockfile.read(),
         {:ok, deps} <- JSON.read() do
      explain(name, lockfile, deps)
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.why <package>")
  end

  defp explain(name, lockfile, root_deps) do
    unless Map.has_key?(lockfile, name) do
      Mix.shell().error("Package #{name} is not installed.")
      return({:error, :not_found})
    end

    reasons = find_dependents(name, lockfile, root_deps)

    if reasons == [] do
      Mix.shell().info("#{name} — no dependents found (orphan?)")
    else
      Mix.shell().info("#{name}@#{lockfile[name].version} is required by:")

      Enum.each(reasons, fn reason ->
        Mix.shell().info("  #{reason}")
      end)
    end
  end

  defp find_dependents(name, lockfile, root_deps) do
    root_reasons =
      if Map.has_key?(root_deps, name) do
        ["package.json (#{root_deps[name]})"]
      else
        []
      end

    transitive_reasons =
      lockfile
      |> Enum.filter(fn {pkg_name, entry} ->
        pkg_name != name and Map.has_key?(entry.dependencies, name)
      end)
      |> Enum.map(fn {pkg_name, entry} ->
        range = entry.dependencies[name]
        "#{pkg_name}@#{entry.version} (#{range})"
      end)
      |> Enum.sort()

    root_reasons ++ transitive_reasons
  end

  defp return(value), do: value
end
