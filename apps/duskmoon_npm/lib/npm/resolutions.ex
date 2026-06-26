defmodule NPM.Resolutions do
  @moduledoc """
  Handles yarn-style resolutions in package.json.

  Resolutions allow pinning specific versions of nested dependencies,
  similar to npm overrides but following the Yarn convention.
  """

  @type resolution :: %{
          pattern: String.t(),
          version: String.t()
        }

  @doc """
  Parses resolutions from package.json data.
  """
  @spec parse(map()) :: [resolution()]
  def parse(%{"resolutions" => resolutions}) when is_map(resolutions) do
    Enum.map(resolutions, fn {pattern, version} ->
      %{pattern: pattern, version: version}
    end)
  end

  def parse(_), do: []

  @doc """
  Checks if a package name matches a resolution pattern.

  Supports exact match and glob-style `**\/package` patterns.
  """
  @spec matches?(String.t(), String.t()) :: boolean()
  def matches?(name, pattern) do
    cond do
      pattern == name ->
        true

      String.starts_with?(pattern, "**/") ->
        suffix = String.trim_leading(pattern, "**/")
        name == suffix or String.ends_with?(name, "/#{suffix}")

      String.contains?(pattern, "/") ->
        name == extract_package_name(pattern)

      true ->
        name == pattern
    end
  end

  @doc """
  Finds the resolution version for a package, if any.
  """
  @spec resolve(String.t(), [resolution()]) :: String.t() | nil
  def resolve(name, resolutions) do
    case Enum.find(resolutions, &matches?(name, &1.pattern)) do
      nil -> nil
      res -> res.version
    end
  end

  @doc """
  Applies resolutions to a lockfile.
  """
  @spec apply_resolutions(map(), [resolution()]) :: {map(), non_neg_integer()}
  def apply_resolutions(lockfile, resolutions) do
    {new_lockfile, count} =
      Enum.reduce(lockfile, {%{}, 0}, fn {name, entry}, {acc, c} ->
        case resolve(name, resolutions) do
          nil ->
            {Map.put(acc, name, entry), c}

          version ->
            {Map.put(acc, name, %{entry | version: version}), c + 1}
        end
      end)

    {new_lockfile, count}
  end

  defp extract_package_name(pattern) do
    pattern |> String.split("/") |> List.last()
  end
end
