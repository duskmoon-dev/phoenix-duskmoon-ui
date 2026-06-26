defmodule NPM.Package.License do
  @moduledoc """
  Scans and reports licenses across the dependency tree.

  Reads `license` fields from package manifests to produce
  compliance reports and detect potential issues.
  """

  @type license_entry :: %{
          package: String.t(),
          version: String.t(),
          license: String.t() | nil
        }

  @known_permissive ~w(MIT ISC BSD-2-Clause BSD-3-Clause Apache-2.0 Unlicense 0BSD CC0-1.0 BlueOak-1.0.0)

  @doc """
  Extracts the license from a package.json data map.

  Handles both string `license` and legacy `licenses` array.
  """
  @spec extract(map()) :: String.t() | nil
  def extract(%{"license" => license}) when is_binary(license), do: license

  def extract(%{"licenses" => [%{"type" => type} | _]}) when is_binary(type), do: type

  def extract(%{"license" => %{"type" => type}}) when is_binary(type), do: type

  def extract(_), do: nil

  @doc """
  Scans a node_modules directory for license information.
  """
  @spec scan(String.t()) :: [license_entry()]
  def scan(node_modules_dir) do
    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&read_package_license(node_modules_dir, &1))
        |> Enum.sort_by(& &1.package)

      _ ->
        []
    end
  end

  @doc """
  Groups license entries by license type.
  """
  @spec group_by_license([license_entry()]) :: %{String.t() => [license_entry()]}
  def group_by_license(entries) do
    Enum.group_by(entries, fn e -> e.license || "UNKNOWN" end)
  end

  @doc """
  Checks if a license is considered permissive.
  """
  @spec permissive?(String.t() | nil) :: boolean()
  def permissive?(nil), do: false
  def permissive?(license), do: license in @known_permissive

  @doc """
  Finds packages with non-permissive or unknown licenses.
  """
  @spec non_permissive([license_entry()]) :: [license_entry()]
  def non_permissive(entries) do
    Enum.reject(entries, &permissive?(&1.license))
  end

  @doc """
  Returns a compliance summary.
  """
  @spec summary([license_entry()]) :: %{
          total: non_neg_integer(),
          permissive: non_neg_integer(),
          non_permissive: non_neg_integer(),
          unknown: non_neg_integer(),
          unique_licenses: [String.t()]
        }
  def summary(entries) do
    licenses =
      entries |> Enum.map(& &1.license) |> Enum.reject(&is_nil/1) |> Enum.uniq() |> Enum.sort()

    %{
      total: length(entries),
      permissive: Enum.count(entries, &permissive?(&1.license)),
      non_permissive:
        Enum.count(entries, &(not is_nil(&1.license) and not permissive?(&1.license))),
      unknown: Enum.count(entries, &is_nil(&1.license)),
      unique_licenses: licenses
    }
  end

  @doc """
  Checks entries against a list of allowed licenses.
  Returns packages that violate the policy.
  """
  @spec check_policy([license_entry()], [String.t()]) :: [license_entry()]
  def check_policy(entries, allowed) do
    allowed_set = MapSet.new(allowed)
    Enum.reject(entries, &MapSet.member?(allowed_set, &1.license))
  end

  defp read_package_license(nm_dir, entry) do
    pkg_json = Path.join([nm_dir, entry, "package.json"])

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        [
          %{
            package: data["name"] || entry,
            version: data["version"] || "0.0.0",
            license: extract(data)
          }
        ]

      _ ->
        []
    end
  rescue
    _ -> []
  end
end
