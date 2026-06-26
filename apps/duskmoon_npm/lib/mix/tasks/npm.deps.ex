defmodule Mix.Tasks.Npm.Deps do
  @shortdoc "List installed npm packages (like mix deps)"

  @moduledoc """
  Lists installed npm packages in a format similar to `mix deps`.

      mix npm.deps

  Shows each package with its locked version and integrity hash.
  """

  use Mix.Task

  @impl true
  def run(_args) do
    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No npm dependencies installed.")

      {:ok, lockfile} ->
        NPM.DepsOutput.print(lockfile)

      {:error, _} ->
        Mix.shell().info("No npm.lock found. Run `mix npm.install` first.")
    end
  end
end
