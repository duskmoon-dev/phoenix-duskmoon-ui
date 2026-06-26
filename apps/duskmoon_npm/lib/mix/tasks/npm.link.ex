defmodule Mix.Tasks.Npm.Link do
  @shortdoc "Link a local package"

  @moduledoc """
  Link a local package directory into `node_modules/`.

      mix npm.link ../my-lib          # Link local package
      mix npm.link ../my-lib --copy   # Copy instead of symlink

  Reads the package name from the linked directory's `package.json`
  and creates a symlink (or copy) in `node_modules/`.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, positional, _} = OptionParser.parse(args, strict: [copy: :boolean])

    case positional do
      [dir] -> link_local(dir, opts)
      _ -> Mix.shell().error("Usage: mix npm.link <directory> [--copy]")
    end
  end

  defp link_local(dir, opts) do
    abs_dir = Path.expand(dir)
    pkg_json = Path.join(abs_dir, "package.json")

    unless File.exists?(pkg_json) do
      Mix.shell().error("No package.json found in #{abs_dir}")
      return({:error, :no_package_json})
    end

    {:ok, content} = File.read(pkg_json)
    data = NPM.JSON.decode!(content)
    name = Map.get(data, "name")

    unless name do
      Mix.shell().error("No name field in #{pkg_json}")
      return({:error, :no_name})
    end

    target = Path.join("node_modules", name)
    File.mkdir_p!("node_modules")

    if opts[:copy] do
      File.rm_rf!(target)
      File.cp_r!(abs_dir, target)
      Mix.shell().info("Copied #{name} from #{abs_dir}")
    else
      File.rm_rf!(target)
      target |> Path.dirname() |> File.mkdir_p!()
      File.ln_s!(abs_dir, target)
      Mix.shell().info("Linked #{name} → #{abs_dir}")
    end
  end

  defp return(value), do: value
end
