defmodule NPM.Package.Fund do
  @moduledoc """
  Discovers and aggregates funding information from installed packages.

  Reads the `funding` field from package manifests to help users
  support open source maintainers.
  """

  @type funding_info :: %{
          package: String.t(),
          version: String.t(),
          type: String.t() | nil,
          url: String.t()
        }

  @doc """
  Extracts funding info from a package.json data map.

  The `funding` field can be a string (URL), a map with `type` and `url`,
  or a list of such entries.
  """
  @spec extract(map()) :: [funding_info()]
  def extract(%{"name" => name, "version" => version} = data) do
    case data["funding"] do
      nil -> []
      url when is_binary(url) -> [%{package: name, version: version, type: nil, url: url}]
      %{"url" => url} = f -> [%{package: name, version: version, type: f["type"], url: url}]
      list when is_list(list) -> Enum.flat_map(list, &parse_funding_entry(name, version, &1))
      _ -> []
    end
  end

  def extract(_), do: []

  @doc """
  Collects funding info from all packages in a node_modules directory.
  """
  @spec collect(String.t()) :: [funding_info()]
  def collect(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&read_package_funding(node_modules_dir, &1))
        |> Enum.sort_by(& &1.package)

      _ ->
        []
    end
  end

  @doc """
  Groups funding entries by funding URL.
  """
  @spec group_by_url([funding_info()]) :: %{String.t() => [funding_info()]}
  def group_by_url(entries) do
    Enum.group_by(entries, & &1.url)
  end

  @doc """
  Returns a summary of funding information.
  """
  @spec summary([funding_info()]) :: %{
          packages_with_funding: non_neg_integer(),
          unique_urls: non_neg_integer(),
          types: [String.t()]
        }
  def summary(entries) do
    %{
      packages_with_funding: entries |> Enum.map(& &1.package) |> Enum.uniq() |> length(),
      unique_urls: entries |> Enum.map(& &1.url) |> Enum.uniq() |> length(),
      types:
        entries |> Enum.map(& &1.type) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort()
    }
  end

  defp parse_funding_entry(name, version, url) when is_binary(url) do
    [%{package: name, version: version, type: nil, url: url}]
  end

  defp parse_funding_entry(name, version, %{"url" => url} = f) do
    [%{package: name, version: version, type: f["type"], url: url}]
  end

  defp parse_funding_entry(_, _, _), do: []

  defp read_package_funding(nm_dir, entry) do
    pkg_json = Path.join([nm_dir, entry, "package.json"])

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        extract(data)

      _ ->
        []
    end
  rescue
    _ -> []
  end
end
