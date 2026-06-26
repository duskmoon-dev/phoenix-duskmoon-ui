defmodule NPM.Overrides do
  @moduledoc """
  Handles npm overrides for forcing specific package versions.

  npm overrides allow replacing versions of transitive dependencies,
  useful for security patches and compatibility fixes.
  """

  @type override :: %{
          package: String.t(),
          version: String.t(),
          parent: String.t() | nil
        }

  @doc """
  Parses overrides from package.json data.

  Supports both flat overrides `{"pkg": "version"}` and
  nested overrides `{"parent": {"pkg": "version"}}`.
  """
  @spec parse(map()) :: [override()]
  def parse(%{"overrides" => overrides}) when is_map(overrides) do
    Enum.flat_map(overrides, &parse_entry/1)
  end

  def parse(_), do: []

  @doc """
  Applies overrides to a lockfile, replacing matched versions.

  Returns the modified lockfile and a list of applied overrides.
  """
  @spec apply_overrides(map(), [override()]) :: {map(), [map()]}
  def apply_overrides(lockfile, overrides) do
    Enum.reduce(overrides, {lockfile, []}, fn override, {lf, applied} ->
      case apply_single(lf, override) do
        {:applied, new_lf, info} -> {new_lf, [info | applied]}
        :noop -> {lf, applied}
      end
    end)
  end

  @doc """
  Finds which overrides would affect the current lockfile.
  """
  @spec matching(map(), [override()]) :: [override()]
  def matching(lockfile, overrides) do
    Enum.filter(overrides, fn override ->
      Map.has_key?(lockfile, override.package)
    end)
  end

  @doc """
  Validates overrides — checks if specified versions are valid semver.
  """
  @spec validate([override()]) :: {:ok, [override()]} | {:error, [String.t()]}
  def validate(overrides) do
    errors =
      overrides
      |> Enum.reject(fn o -> valid_version_spec?(o.version) end)
      |> Enum.map(fn o -> "Invalid version for #{o.package}: #{o.version}" end)

    if errors == [], do: {:ok, overrides}, else: {:error, errors}
  end

  @doc """
  Formats an override for display.
  """
  @spec format_override(override()) :: String.t()
  def format_override(%{parent: nil} = o), do: "#{o.package} → #{o.version}"
  def format_override(o), do: "#{o.parent} > #{o.package} → #{o.version}"

  defp parse_entry({package, version}) when is_binary(version) do
    [%{package: package, version: version, parent: nil}]
  end

  defp parse_entry({parent, nested}) when is_map(nested) do
    Enum.map(nested, fn {package, version} ->
      %{package: package, version: version, parent: parent}
    end)
  end

  defp parse_entry(_), do: []

  defp apply_single(lockfile, %{package: name, version: version, parent: nil}) do
    case Map.get(lockfile, name) do
      nil ->
        :noop

      entry ->
        new_entry = %{entry | version: version}
        info = %{package: name, from: entry.version, to: version}
        {:applied, Map.put(lockfile, name, new_entry), info}
    end
  end

  defp apply_single(_lockfile, _scoped_override), do: :noop

  defp valid_version_spec?(spec) do
    String.match?(spec, ~r/^\d+\.\d+\.\d+/) or
      String.starts_with?(spec, "^") or
      String.starts_with?(spec, "~") or
      String.starts_with?(spec, ">=") or
      spec == "*"
  end
end
