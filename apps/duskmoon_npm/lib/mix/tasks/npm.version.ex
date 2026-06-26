defmodule Mix.Tasks.Npm.Version do
  @shortdoc "Show npm_ex version"

  @moduledoc """
  Display the installed version of npm_ex.

      mix npm.version
  """

  use Mix.Task

  @impl true
  def run([]) do
    {:ok, version} = :application.get_key(:duskmoon_npm, :vsn)
    Mix.shell().info("duskmoon_npm #{version}")
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.version")
  end
end
