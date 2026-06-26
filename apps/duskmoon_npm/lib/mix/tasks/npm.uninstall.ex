defmodule Mix.Tasks.Npm.Uninstall do
  @shortdoc "Remove an npm package (alias for npm.remove)"

  @moduledoc """
  Remove an npm package from `package.json` and re-install.

      mix npm.uninstall lodash
      mix npm.uninstall @types/node

  Alias for `mix npm.remove`.
  """

  use Mix.Task

  alias Mix.Tasks.Npm.Remove

  @impl true
  def run(args), do: Remove.run(args)
end
