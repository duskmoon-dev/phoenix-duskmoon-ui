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
    NPM.install(frozen: true)
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.ci")
  end
end
