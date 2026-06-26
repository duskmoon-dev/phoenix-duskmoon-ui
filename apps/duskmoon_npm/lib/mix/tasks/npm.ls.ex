defmodule Mix.Tasks.Npm.Ls do
  @shortdoc "List installed npm packages (alias for npm.list)"

  @moduledoc """
  List installed npm packages from `npm.lock`.

      mix npm.ls

  Alias for `mix npm.list`.
  """

  use Mix.Task

  alias Mix.Tasks.Npm.List, as: NpmList

  @impl true
  def run(args), do: NpmList.run(args)
end
