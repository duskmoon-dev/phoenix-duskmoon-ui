defmodule Mix.Tasks.Npm.List do
  alias NPM.Package.JSON

  @shortdoc "List installed npm packages"

  @moduledoc """
  List installed npm packages from `npm.lock`.

      mix npm.list

  Shows direct dependencies (from `package.json`) and their locked versions.
  Transitive dependencies are shown indented.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, _, _} = OptionParser.parse(args, strict: [depth: :integer])

    with {:ok, %{dependencies: deps, dev_dependencies: dev_deps}} <-
           JSON.read_all(),
         {:ok, packages} <- NPM.list() do
      if packages == [] do
        Mix.shell().info("No npm packages installed.")
      else
        print_tree(packages, deps, dev_deps, opts)
      end
    end
  end

  defp print_tree(packages, deps, dev_deps, opts) do
    direct = Map.keys(deps) |> MapSet.new()
    dev = Map.keys(dev_deps) |> MapSet.new()
    max_depth = Keyword.get(opts, :depth, :infinity)

    {direct_pkgs, rest} =
      Enum.split_with(packages, fn {name, _} -> MapSet.member?(direct, name) end)

    {dev_pkgs, transitive_pkgs} =
      Enum.split_with(rest, fn {name, _} -> MapSet.member?(dev, name) end)

    if direct_pkgs != [] do
      print_dep_section("dependencies:", direct_pkgs, deps)
    end

    if dev_pkgs != [] do
      print_dep_section("devDependencies:", dev_pkgs, dev_deps)
    end

    if transitive_pkgs != [] and max_depth != 0 do
      Mix.shell().info("transitive (#{length(transitive_pkgs)}):")

      Enum.each(transitive_pkgs, fn {name, version} ->
        Mix.shell().info("  └── #{name}@#{version}")
      end)
    end

    Mix.shell().info("#{length(packages)} packages total")
  end

  defp print_dep_section(header, pkgs, ranges) do
    Mix.shell().info(header)

    Enum.each(pkgs, fn {name, version} ->
      range = Map.get(ranges, name, "")
      Mix.shell().info("  ├── #{name}@#{version} (#{range})")
    end)
  end
end
