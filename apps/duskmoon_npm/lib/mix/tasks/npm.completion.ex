defmodule Mix.Tasks.Npm.Completion do
  @shortdoc "Generate shell completion data"

  @moduledoc """
  Output shell completion data for npm tasks.

      mix npm.completion
      mix npm.completion --tasks
      mix npm.completion --packages

  ## Options

    * `--tasks` — list available npm task names
    * `--packages` — list installed package names
  """

  use Mix.Task

  @npm_tasks ~w(
    audit cache check ci clean completion config
    dedupe deprecations diff doctor exec explain
    fund get info init install licenses link
    list ls outdated pack prune publish rebuild
    remove run search set shrinkwrap token tree
    uninstall update version view why
  )

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [tasks: :boolean, packages: :boolean])

    shell = Mix.shell()

    cond do
      opts[:tasks] -> Enum.each(@npm_tasks, &shell.info/1)
      opts[:packages] -> list_packages(shell)
      true -> Enum.each(@npm_tasks, &shell.info("npm.#{&1}"))
    end
  end

  defp list_packages(shell) do
    case NPM.Lockfile.read() do
      {:ok, lockfile} ->
        lockfile |> Map.keys() |> Enum.sort() |> Enum.each(&shell.info/1)

      _ ->
        :ok
    end
  end
end
