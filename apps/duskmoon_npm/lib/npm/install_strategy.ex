defmodule NPM.InstallStrategy do
  @moduledoc """
  Determines and configures package installation strategy.

  npm supports hoisted (default), nested, and isolated install strategies
  configured via `.npmrc` or `--install-strategy` flag.
  """

  @strategies ~w(hoisted nested shallow linked)a

  @doc """
  Detects the install strategy from config.
  """
  @spec detect(map()) :: atom()
  def detect(config) when is_map(config) do
    case config["install-strategy"] || config["install_strategy"] do
      "nested" -> :nested
      "shallow" -> :shallow
      "linked" -> :linked
      _ -> :hoisted
    end
  end

  @doc """
  Returns all supported strategies.
  """
  @spec strategies :: [atom()]
  def strategies, do: @strategies

  @doc """
  Checks if a strategy is valid.
  """
  @spec valid?(atom()) :: boolean()
  def valid?(strategy), do: strategy in @strategies

  @doc """
  Describes a strategy.
  """
  @spec describe(atom()) :: String.t()
  def describe(:hoisted), do: "Hoist all dependencies to top-level node_modules (default)"
  def describe(:nested), do: "Install dependencies nested in package folders"
  def describe(:shallow), do: "Only install direct dependencies at top level"
  def describe(:linked), do: "Symlink packages instead of copying"
  def describe(_), do: "Unknown strategy"

  @doc """
  Returns recommended strategy for a project configuration.
  """
  @spec recommend(map()) :: atom()
  def recommend(pkg_data) do
    cond do
      has_many_workspaces?(pkg_data) -> :hoisted
      has_conflicting_versions?(pkg_data) -> :nested
      true -> :hoisted
    end
  end

  @doc """
  Returns the node_modules structure depth for a strategy.
  """
  @spec max_depth(atom()) :: non_neg_integer() | :infinity
  def max_depth(:hoisted), do: 1
  def max_depth(:nested), do: :infinity
  def max_depth(:shallow), do: 1
  def max_depth(:linked), do: 1
  def max_depth(_), do: 1

  defp has_many_workspaces?(%{"workspaces" => ws}) when is_list(ws), do: length(ws) > 3
  defp has_many_workspaces?(_), do: false

  defp has_conflicting_versions?(%{"dependencies" => deps, "devDependencies" => dev_deps})
       when is_map(deps) and is_map(dev_deps) do
    common = MapSet.intersection(MapSet.new(Map.keys(deps)), MapSet.new(Map.keys(dev_deps)))
    MapSet.size(common) > 0
  end

  defp has_conflicting_versions?(_), do: false
end
