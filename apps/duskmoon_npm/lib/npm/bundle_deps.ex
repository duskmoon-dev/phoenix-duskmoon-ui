defmodule NPM.BundleDeps do
  @moduledoc """
  Handles bundledDependencies in package.json.

  bundledDependencies are packages that are included in the tarball
  when publishing, rather than being fetched from the registry.
  """

  @doc """
  Extracts bundledDependencies from package.json data.

  Handles both `bundledDependencies` and `bundleDependencies` fields.
  """
  @spec extract(map()) :: [String.t()]
  def extract(%{"bundledDependencies" => deps}) when is_list(deps), do: deps
  def extract(%{"bundleDependencies" => deps}) when is_list(deps), do: deps
  def extract(%{"bundledDependencies" => true} = data), do: all_dep_names(data)
  def extract(%{"bundleDependencies" => true} = data), do: all_dep_names(data)
  def extract(_), do: []

  @doc """
  Checks if a package is bundled.
  """
  @spec bundled?(String.t(), map()) :: boolean()
  def bundled?(name, pkg_data) do
    name in extract(pkg_data)
  end

  @doc """
  Validates that all bundled deps are also declared as dependencies.
  """
  @spec validate(map()) :: {:ok, [String.t()]} | {:error, [String.t()]}
  def validate(pkg_data) do
    bundled = extract(pkg_data)
    declared = Map.keys(pkg_data["dependencies"] || %{})
    missing = Enum.reject(bundled, &(&1 in declared))

    if missing == [] do
      {:ok, bundled}
    else
      {:error, Enum.map(missing, &"#{&1} is bundled but not in dependencies")}
    end
  end

  @doc """
  Returns the count of bundled dependencies.
  """
  @spec count(map()) :: non_neg_integer()
  def count(pkg_data), do: pkg_data |> extract() |> length()

  defp all_dep_names(data) do
    data
    |> Map.get("dependencies", %{})
    |> Map.keys()
    |> Enum.sort()
  end
end
