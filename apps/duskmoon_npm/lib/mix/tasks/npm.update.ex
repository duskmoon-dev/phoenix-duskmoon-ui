defmodule Mix.Tasks.Npm.Update do
  @shortdoc "Update npm packages"

  @moduledoc """
  Update npm packages to the latest versions matching their ranges.

      mix npm.update          # Update all packages
      mix npm.update lodash   # Update a specific package

  Re-resolves the dependency tree and writes an updated `npm.lock`.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)

    case args do
      [] -> NPM.update()
      [name] -> NPM.update(name)
      _ -> Mix.shell().error("Usage: mix npm.update [package]")
    end
  end
end
