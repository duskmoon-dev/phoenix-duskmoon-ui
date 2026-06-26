defmodule NPM.DevDeps do
  @moduledoc """
  Manages devDependencies from package.json.

  DevDependencies are only needed during development (testing, building,
  linting) and should be excluded in production installs.
  """

  @doc """
  Extracts devDependencies from package.json data.
  """
  @spec extract(map()) :: map()
  def extract(%{"devDependencies" => deps}) when is_map(deps), do: deps
  def extract(_), do: %{}

  @doc """
  Extracts production dependencies only.
  """
  @spec production_deps(map()) :: map()
  def production_deps(pkg_data) do
    pkg_data["dependencies"] || %{}
  end

  @doc """
  Returns all dependencies (production + dev).
  """
  @spec all_deps(map()) :: map()
  def all_deps(pkg_data) do
    prod = production_deps(pkg_data)
    dev = extract(pkg_data)
    Map.merge(prod, dev)
  end

  @doc """
  Checks if a package is a dev dependency.
  """
  @spec dev_dep?(String.t(), map()) :: boolean()
  def dev_dep?(name, pkg_data) do
    Map.has_key?(extract(pkg_data), name)
  end

  @doc """
  Categorizes dependencies into production and development.
  """
  @spec categorize(map()) :: %{production: map(), development: map()}
  def categorize(pkg_data) do
    %{
      production: production_deps(pkg_data),
      development: extract(pkg_data)
    }
  end

  @doc """
  Finds dev deps that are also in production deps (potential misplacement).
  """
  @spec overlapping(map()) :: [String.t()]
  def overlapping(pkg_data) do
    prod_names = MapSet.new(Map.keys(production_deps(pkg_data)))
    dev_names = Map.keys(extract(pkg_data))
    Enum.filter(dev_names, &MapSet.member?(prod_names, &1)) |> Enum.sort()
  end

  @doc """
  Returns a summary of dependency distribution.
  """
  @spec summary(map()) :: %{
          production: non_neg_integer(),
          development: non_neg_integer(),
          total: non_neg_integer()
        }
  def summary(pkg_data) do
    prod = production_deps(pkg_data) |> map_size()
    dev = extract(pkg_data) |> map_size()
    %{production: prod, development: dev, total: prod + dev}
  end
end
