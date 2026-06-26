defmodule NPM.Engines do
  @moduledoc """
  Parses and analyzes the `engines` field from package.json.
  """

  @known_engines ~w(node npm yarn pnpm)

  @doc """
  Extracts engines from package.json data.
  """
  @spec extract(map()) :: map()
  def extract(%{"engines" => engines}) when is_map(engines), do: engines
  def extract(_), do: %{}

  @doc """
  Returns the node version constraint.
  """
  @spec node_range(map()) :: String.t() | nil
  def node_range(data), do: extract(data) |> Map.get("node")

  @doc """
  Returns the npm version constraint.
  """
  @spec npm_range(map()) :: String.t() | nil
  def npm_range(data), do: extract(data) |> Map.get("npm")

  @doc """
  Checks if a package specifies any engine constraints.
  """
  @spec has_engines?(map()) :: boolean()
  def has_engines?(data), do: extract(data) != %{}

  @doc """
  Returns the most restrictive node range across packages.
  """
  @spec strictest_node([map()]) :: String.t() | nil
  def strictest_node(packages) do
    packages
    |> Enum.map(&node_range/1)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> nil
      ranges -> Enum.join(ranges, " ")
    end
  end

  @doc """
  Lists all unique engine names used across packages.
  """
  @spec used_engines([map()]) :: [String.t()]
  def used_engines(packages) do
    packages
    |> Enum.flat_map(&(extract(&1) |> Map.keys()))
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Returns unknown (non-standard) engine constraints.
  """
  @spec unknown_engines(map()) :: [String.t()]
  def unknown_engines(data) do
    data
    |> extract()
    |> Map.keys()
    |> Enum.reject(&(&1 in @known_engines))
    |> Enum.sort()
  end

  @doc """
  Summarizes engine constraints across all packages.
  """
  @spec summary([map()]) :: map()
  def summary(packages) do
    engines = used_engines(packages)
    with_engines = Enum.count(packages, &has_engines?/1)

    %{
      total_packages: length(packages),
      with_engines: with_engines,
      without_engines: length(packages) - with_engines,
      engines_used: engines,
      node_range: strictest_node(packages)
    }
  end
end
