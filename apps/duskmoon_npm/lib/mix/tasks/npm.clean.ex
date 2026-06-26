defmodule Mix.Tasks.Npm.Clean do
  @shortdoc "Remove node_modules"

  @moduledoc """
  Remove the `node_modules` directory.

      mix npm.clean

  Use `mix npm.install` to reinstall after cleaning.
  """

  use Mix.Task

  @impl true
  def run([]) do
    if File.exists?("node_modules") do
      File.rm_rf!("node_modules")
      Mix.shell().info("Removed node_modules/")
    else
      Mix.shell().info("node_modules/ not found.")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.clean")
  end
end
