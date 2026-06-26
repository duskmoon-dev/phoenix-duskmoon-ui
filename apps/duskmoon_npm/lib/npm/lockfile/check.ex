defmodule NPM.Lockfile.Check do
  @moduledoc """
  Validates lockfile consistency against package.json dependencies.
  """

  @doc """
  Checks if all package.json dependencies are in the lockfile.
  """
  @spec missing(map(), map()) :: [String.t()]
  def missing(pkg_data, lockfile) do
    all_deps(pkg_data)
    |> Enum.reject(fn {name, _} -> Map.has_key?(lockfile, name) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  @doc """
  Checks if the lockfile has packages not in package.json dependencies.
  """
  @spec extraneous(map(), map()) :: [String.t()]
  def extraneous(pkg_data, lockfile) do
    dep_names = all_deps(pkg_data) |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    lockfile
    |> Map.keys()
    |> Enum.reject(&MapSet.member?(dep_names, &1))
    |> Enum.sort()
  end

  @doc """
  Checks if locked versions satisfy the declared ranges.
  """
  @spec mismatched(map(), map()) :: [{String.t(), String.t(), String.t()}]
  def mismatched(pkg_data, lockfile) do
    all_deps(pkg_data)
    |> Enum.flat_map(&check_version_match(&1, lockfile))
    |> Enum.sort_by(&elem(&1, 0))
  end

  defp check_version_match({name, range}, lockfile) do
    case Map.get(lockfile, name) do
      %{version: version} ->
        if NPMSemver.matches?(version, range), do: [], else: [{name, range, version}]

      _ ->
        []
    end
  end

  @doc """
  Runs all consistency checks.
  """
  @spec check(map(), map()) :: map()
  def check(pkg_data, lockfile) do
    missing_deps = missing(pkg_data, lockfile)
    extra = extraneous(pkg_data, lockfile)
    mismatches = mismatched(pkg_data, lockfile)

    %{
      valid: missing_deps == [] and mismatches == [],
      missing: missing_deps,
      extraneous: extra,
      mismatched: mismatches
    }
  end

  @doc """
  Formats check results for display.
  """
  @spec format_results(map()) :: String.t()
  def format_results(%{valid: true, extraneous: []}), do: "Lockfile is consistent."

  def format_results(%{valid: true, extraneous: extra}),
    do: "#{length(extra)} extraneous packages in lockfile."

  def format_results(result) do
    parts = []

    parts =
      if result.missing != [],
        do: ["Missing: #{Enum.join(result.missing, ", ")}" | parts],
        else: parts

    parts =
      if result.extraneous != [],
        do: ["Extraneous: #{Enum.join(result.extraneous, ", ")}" | parts],
        else: parts

    parts =
      if result.mismatched != [] do
        mismatches =
          Enum.map_join(result.mismatched, ", ", fn {name, range, ver} ->
            "#{name} (want #{range}, have #{ver})"
          end)

        ["Mismatched: #{mismatches}" | parts]
      else
        parts
      end

    Enum.reverse(parts) |> Enum.join("\n")
  end

  defp all_deps(pkg_data) do
    dep_fields = ~w(dependencies devDependencies optionalDependencies)

    Enum.flat_map(dep_fields, fn field ->
      case Map.get(pkg_data, field) do
        deps when is_map(deps) -> Map.to_list(deps)
        _ -> []
      end
    end)
    |> Enum.uniq_by(&elem(&1, 0))
  end
end
