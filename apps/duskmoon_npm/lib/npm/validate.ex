defmodule NPM.Validate do
  @moduledoc """
  Validates package.json data against npm conventions.

  Checks for required fields, correct types, valid values,
  and common mistakes.
  """

  @required_fields ~w(name version)
  @known_fields ~w(
    name version description main module browser types typings
    bin scripts dependencies devDependencies peerDependencies
    optionalDependencies bundleDependencies bundledDependencies
    engines os cpu repository bugs homepage license author
    contributors maintainers keywords files directories exports
    imports type sideEffects private publishConfig workspaces
    funding config overrides resolutions
  )

  @doc """
  Validates package.json data, returning a list of issues.
  """
  @spec validate(map()) :: [map()]
  def validate(data) when is_map(data) do
    []
    |> check_required(data)
    |> check_name(data)
    |> check_version(data)
    |> check_dependencies(data)
    |> check_types(data)
    |> Enum.reverse()
  end

  def validate(_), do: [%{level: :error, field: nil, message: "package.json must be an object"}]

  @doc """
  Returns only errors (not warnings).
  """
  @spec errors(map()) :: [map()]
  def errors(data), do: data |> validate() |> Enum.filter(&(&1.level == :error))

  @doc """
  Returns only warnings.
  """
  @spec warnings(map()) :: [map()]
  def warnings(data), do: data |> validate() |> Enum.filter(&(&1.level == :warning))

  @doc """
  Checks if the package.json is valid (no errors).
  """
  @spec valid?(map()) :: boolean()
  def valid?(data), do: errors(data) == []

  @doc """
  Returns a list of unknown fields.
  """
  @spec unknown_fields(map()) :: [String.t()]
  def unknown_fields(data) when is_map(data) do
    data
    |> Map.keys()
    |> Enum.reject(&(&1 in @known_fields or String.starts_with?(&1, "_")))
    |> Enum.sort()
  end

  def unknown_fields(_), do: []

  @doc """
  Formats validation issues for display.
  """
  @spec format_issues([map()]) :: String.t()
  def format_issues([]), do: "No issues found."

  def format_issues(issues) do
    Enum.map_join(issues, "\n", fn issue ->
      prefix = if issue.level == :error, do: "ERROR", else: "WARN"
      field = if issue.field, do: " [#{issue.field}]", else: ""
      "#{prefix}#{field}: #{issue.message}"
    end)
  end

  defp check_required(issues, data) do
    Enum.reduce(@required_fields, issues, fn field, acc ->
      if Map.has_key?(data, field) do
        acc
      else
        [%{level: :error, field: field, message: "missing required field '#{field}'"} | acc]
      end
    end)
  end

  defp check_name(issues, %{"name" => name}) when is_binary(name) do
    issues
    |> maybe_issue(String.length(name) == 0, :error, "name", "name cannot be empty")
    |> maybe_issue(String.length(name) > 214, :error, "name", "name exceeds 214 characters")
    |> maybe_issue(
      name != String.downcase(name) and not NPM.Scope.scoped?(name),
      :warning,
      "name",
      "name should be lowercase"
    )
    |> maybe_issue(String.starts_with?(name, "."), :error, "name", "name cannot start with a dot")
    |> maybe_issue(
      String.starts_with?(name, "_"),
      :error,
      "name",
      "name cannot start with an underscore"
    )
  end

  defp check_name(issues, %{"name" => _}) do
    [%{level: :error, field: "name", message: "name must be a string"} | issues]
  end

  defp check_name(issues, _), do: issues

  defp check_version(issues, %{"version" => version}) when is_binary(version) do
    case Version.parse(version) do
      {:ok, _} -> issues
      :error -> maybe_issue(issues, true, :error, "version", "invalid semver: '#{version}'")
    end
  end

  defp check_version(issues, %{"version" => _}) do
    [%{level: :error, field: "version", message: "version must be a string"} | issues]
  end

  defp check_version(issues, _), do: issues

  defp check_dependencies(issues, data) do
    dep_fields = ~w(dependencies devDependencies peerDependencies optionalDependencies)

    Enum.reduce(dep_fields, issues, fn field, acc ->
      case Map.get(data, field) do
        nil -> acc
        deps when is_map(deps) -> check_dep_values(acc, field, deps)
        _ -> [%{level: :error, field: field, message: "#{field} must be an object"} | acc]
      end
    end)
  end

  defp check_dep_values(issues, field, deps) do
    Enum.reduce(deps, issues, fn {name, range}, acc ->
      if is_binary(range) do
        acc
      else
        [
          %{level: :error, field: field, message: "'#{name}' has non-string version in #{field}"}
          | acc
        ]
      end
    end)
  end

  defp check_types(issues, data) do
    type_checks = [
      {"description", &is_binary/1},
      {"license", &is_binary/1},
      {"private", &is_boolean/1},
      {"keywords", &is_list/1},
      {"files", &is_list/1}
    ]

    Enum.reduce(type_checks, issues, fn {field, checker}, acc ->
      case Map.get(data, field) do
        nil ->
          acc

        val ->
          maybe_issue(acc, not checker.(val), :warning, field, "#{field} has unexpected type")
      end
    end)
  end

  defp maybe_issue(issues, false, _, _, _), do: issues

  defp maybe_issue(issues, true, level, field, message) do
    [%{level: level, field: field, message: message} | issues]
  end
end
