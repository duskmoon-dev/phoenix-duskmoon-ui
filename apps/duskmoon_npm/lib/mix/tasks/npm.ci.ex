defmodule Mix.Tasks.Npm.Ci do
  @shortdoc "Install from lockfile (CI mode)"

  @moduledoc """
  Install npm packages in CI mode.

      mix npm.ci

  Equivalent to `mix npm.install --frozen`. Fails if `npm.lock` doesn't
  match `package.json`, ensuring reproducible builds.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.install(frozen: true) do
      :ok -> :ok
      {:error, reason} -> Mix.raise("npm.ci failed: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.ci")
  end
end
