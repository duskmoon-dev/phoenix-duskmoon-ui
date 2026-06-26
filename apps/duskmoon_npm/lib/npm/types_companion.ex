defmodule NPM.TypesCompanion do
  @moduledoc """
  Suggests @types/* companion packages for dependencies that need TypeScript type definitions.
  """

  @bundled_types ~w(typescript @types/node)
  @has_own_types ~w(axios zod prisma date-fns)

  @doc """
  Suggests @types/* packages for dependencies that likely need them.
  """
  @spec suggest(map()) :: [%{package: String.t(), types_package: String.t()}]
  def suggest(pkg_data) do
    deps = Map.get(pkg_data, "dependencies", %{})
    dev_deps = Map.get(pkg_data, "devDependencies", %{})
    all_installed = Map.merge(deps, dev_deps) |> Map.keys() |> MapSet.new()

    own_types = MapSet.new(@has_own_types)

    deps
    |> Map.keys()
    |> Enum.reject(fn name -> scoped?(name) or MapSet.member?(own_types, name) end)
    |> Enum.map(fn name -> {name, types_package(name)} end)
    |> Enum.reject(fn {_, types} -> MapSet.member?(all_installed, types) end)
    |> Enum.map(fn {name, types} -> %{package: name, types_package: types} end)
    |> Enum.sort_by(& &1.package)
  end

  @doc """
  Returns the @types/* package name for a given package.
  """
  @spec types_package(String.t()) :: String.t()
  def types_package("@" <> _ = scoped) do
    name = scoped |> String.replace("/", "__") |> String.trim_leading("@")
    "@types/#{name}"
  end

  def types_package(name), do: "@types/#{name}"

  @doc """
  Checks if a package typically ships its own types.
  """
  @spec has_own_types?(map()) :: boolean()
  def has_own_types?(pkg_data) do
    Map.has_key?(pkg_data, "types") or
      Map.has_key?(pkg_data, "typings") or
      Map.get(pkg_data, "name", "") in @has_own_types
  end

  @doc """
  Returns packages that are @types/* but whose companion is not installed.
  """
  @spec orphaned_types(map()) :: [String.t()]
  def orphaned_types(pkg_data) do
    all_deps =
      Map.merge(
        Map.get(pkg_data, "dependencies", %{}),
        Map.get(pkg_data, "devDependencies", %{})
      )

    all_keys = Map.keys(all_deps) |> MapSet.new()

    all_keys
    |> Enum.filter(&String.starts_with?(&1, "@types/"))
    |> Enum.reject(fn types_pkg ->
      companion = types_pkg |> String.trim_leading("@types/") |> String.replace("__", "/")
      companion = if String.contains?(companion, "/"), do: "@#{companion}", else: companion
      MapSet.member?(all_keys, companion)
    end)
    |> Enum.sort()
  end

  @doc """
  Returns bundled types packages.
  """
  @spec bundled :: [String.t()]
  def bundled, do: @bundled_types

  defp scoped?("@" <> _), do: true
  defp scoped?(_), do: false
end
