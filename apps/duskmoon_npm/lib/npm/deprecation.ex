defmodule NPM.Deprecation do
  @moduledoc """
  Detects and reports deprecated packages in the dependency tree.

  Checks the `deprecated` field from package metadata to warn
  users about packages that should be replaced.
  """

  @type deprecation_entry :: %{
          package: String.t(),
          version: String.t(),
          message: String.t()
        }

  @doc """
  Checks a lockfile against registry metadata for deprecation notices.

  Takes a map of `%{package_name => %{deprecated: message | nil, ...}}`.
  """
  @spec check(map(), map()) :: [deprecation_entry()]
  def check(lockfile, metadata) do
    lockfile
    |> Enum.flat_map(fn {name, entry} ->
      case get_deprecation(name, metadata) do
        nil -> []
        msg -> [%{package: name, version: entry.version, message: msg}]
      end
    end)
    |> Enum.sort_by(& &1.package)
  end

  @doc """
  Extracts the deprecation message from a package.json data map.
  """
  @spec extract(map()) :: String.t() | nil
  def extract(%{"deprecated" => msg}) when is_binary(msg) and msg != "", do: msg
  def extract(_), do: nil

  @doc """
  Checks if a package is deprecated.
  """
  @spec deprecated?(map()) :: boolean()
  def deprecated?(%{"deprecated" => msg}) when is_binary(msg) and msg != "", do: true
  def deprecated?(_), do: false

  @doc """
  Formats a deprecation entry as a warning string.
  """
  @spec format_warning(deprecation_entry()) :: String.t()
  def format_warning(entry) do
    "DEPRECATED #{entry.package}@#{entry.version}: #{entry.message}"
  end

  @doc """
  Scans node_modules for deprecated packages.
  """
  @spec scan(String.t()) :: [deprecation_entry()]
  def scan(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&scan_package(node_modules_dir, &1))
        |> Enum.sort_by(& &1.package)

      _ ->
        []
    end
  end

  defp get_deprecation(name, metadata) do
    case Map.get(metadata, name) do
      %{deprecated: msg} when is_binary(msg) and msg != "" -> msg
      _ -> nil
    end
  end

  defp scan_package(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      scan_scope(nm_dir, entry)
    else
      read_deprecation(nm_dir, entry)
    end
  end

  defp scan_scope(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} ->
        Enum.flat_map(subs, fn sub ->
          read_deprecation(scope_dir, sub, "#{scope}/#{sub}")
        end)

      _ ->
        []
    end
  end

  defp read_deprecation(parent, name, full_name \\ nil) do
    pkg_json = Path.join([parent, name, "package.json"])
    full_name = full_name || name

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        case extract(data) do
          nil -> []
          msg -> [%{package: full_name, version: data["version"] || "0.0.0", message: msg}]
        end

      _ ->
        []
    end
  rescue
    _ -> []
  end
end
