defmodule Mix.Tasks.Npm.Size do
  @shortdoc "Show node_modules size analysis"

  @moduledoc """
  Analyze `node_modules` disk usage.

      mix npm.size
      mix npm.size --top 10

  Shows total size, file count, and per-package breakdown.

  ## Options

    * `--top` — number of largest packages to show (default: 10)
  """

  use Mix.Task

  alias NPM.NodeModules

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [top: :integer])
    top_n = Keyword.get(opts, :top, 10)
    dir = "node_modules"

    total_size = NodeModules.disk_size(dir)
    total_files = NodeModules.file_count(dir)

    Mix.shell().info("node_modules analysis:")
    Mix.shell().info("  Total size:  #{NPM.FormatUtil.format_size(total_size)}")
    Mix.shell().info("  Total files: #{total_files}")

    packages = NodeModules.installed(dir)
    Mix.shell().info("  Packages:    #{length(packages)}")

    if packages != [] do
      Mix.shell().info("\n  Top #{top_n} by size:")
      print_top(dir, packages, top_n)
    end
  end

  defp print_top(dir, packages, top_n) do
    packages
    |> Enum.map(fn name ->
      pkg_dir = Path.join(dir, name)
      size = NodeModules.disk_size(pkg_dir)
      {name, size}
    end)
    |> Enum.sort_by(fn {_, size} -> -size end)
    |> Enum.take(top_n)
    |> Enum.each(fn {name, size} ->
      Mix.shell().info("    #{NPM.FormatUtil.format_size(size)} #{name}")
    end)
  end
end
