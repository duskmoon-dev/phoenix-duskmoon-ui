defmodule Mix.Tasks.Npm.Explain do
  @shortdoc "Explain why a package is installed (alias for npm.why)"

  @moduledoc """
  Explain why a package is installed.

      mix npm.explain lodash

  This is an alias for `mix npm.why`.
  """

  use Mix.Task

  alias Mix.Tasks.Npm.Why

  @impl true
  def run(args) do
    Why.run(args)
  end
end
