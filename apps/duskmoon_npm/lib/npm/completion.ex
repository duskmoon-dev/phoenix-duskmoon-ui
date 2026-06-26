defmodule NPM.Completion do
  @moduledoc """
  Shell completion support for mix npm commands.

  Generates completion data for package names, scripts,
  and subcommands.
  """

  @commands ~w(install ci list outdated update prune clean audit diff fund
               why tree search init link pack publish verify doctor)

  @doc """
  Returns all available mix npm subcommands.
  """
  @spec commands :: [String.t()]
  def commands, do: @commands

  @doc """
  Generates completions for a partial command.
  """
  @spec complete(String.t()) :: [String.t()]
  def complete(prefix) do
    prefix_lower = String.downcase(prefix)

    @commands
    |> Enum.filter(&String.starts_with?(&1, prefix_lower))
    |> Enum.sort()
  end

  @doc """
  Generates package name completions from the lockfile.
  """
  @spec complete_packages(String.t(), map()) :: [String.t()]
  def complete_packages(prefix, lockfile) do
    prefix_lower = String.downcase(prefix)

    lockfile
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(String.downcase(&1), prefix_lower))
    |> Enum.sort()
  end

  @doc """
  Generates script name completions from package.json scripts.
  """
  @spec complete_scripts(String.t(), map()) :: [String.t()]
  def complete_scripts(prefix, scripts) do
    prefix_lower = String.downcase(prefix)

    scripts
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(String.downcase(&1), prefix_lower))
    |> Enum.sort()
  end

  @doc """
  Generates a bash completion script.
  """
  @spec bash_completions :: String.t()
  def bash_completions do
    cmds = Enum.join(@commands, " ")

    """
    _mix_npm() {
      local cur="${COMP_WORDS[COMP_CWORD]}"
      COMPREPLY=($(compgen -W "#{cmds}" -- "$cur"))
    }
    complete -F _mix_npm mix npm
    """
  end
end
