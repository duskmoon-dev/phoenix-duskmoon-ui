defmodule NPM.SBOM do
  @moduledoc """
  Software Bill of Materials (SBOM) generation.

  Generates CycloneDX-compatible SBOM data from the lockfile,
  listing all dependencies with versions, licenses, and integrity hashes.
  """

  @doc """
  Generates an SBOM from the lockfile and node_modules.
  """
  @spec generate(map(), String.t()) :: map()
  def generate(lockfile, node_modules_dir \\ "node_modules") do
    components =
      lockfile
      |> Enum.map(fn {name, entry} ->
        build_component(name, entry, node_modules_dir)
      end)
      |> Enum.sort_by(& &1.name)

    %{
      bom_format: "CycloneDX",
      spec_version: "1.4",
      version: 1,
      components: components,
      metadata: %{
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601(),
        tools: [%{vendor: "npm_ex", name: "npm_ex"}]
      }
    }
  end

  @doc """
  Generates a minimal SBOM from lockfile only (no filesystem access).
  """
  @spec from_lockfile(map()) :: map()
  def from_lockfile(lockfile) do
    components =
      lockfile
      |> Enum.map(fn {name, entry} ->
        %{
          type: "library",
          name: name,
          version: entry_version(entry),
          purl: purl(name, entry_version(entry)),
          hashes: integrity_hashes(entry)
        }
      end)
      |> Enum.sort_by(& &1.name)

    %{
      bom_format: "CycloneDX",
      spec_version: "1.4",
      version: 1,
      components: components
    }
  end

  @doc """
  Returns the count of components in the SBOM.
  """
  @spec component_count(map()) :: non_neg_integer()
  def component_count(%{components: components}), do: length(components)
  def component_count(_), do: 0

  @doc """
  Generates a Package URL (purl) for an npm package.
  """
  @spec purl(String.t(), String.t()) :: String.t()
  def purl(name, version) do
    "pkg:npm/#{name}@#{version}"
  end

  @doc """
  Filters SBOM components by a predicate.
  """
  @spec filter(map(), (map() -> boolean())) :: map()
  def filter(%{components: components} = sbom, fun) do
    %{sbom | components: Enum.filter(components, fun)}
  end

  defp build_component(name, entry, nm_dir) do
    version = entry_version(entry)
    license = read_license(nm_dir, name)

    component = %{
      type: "library",
      name: name,
      version: version,
      purl: purl(name, version),
      hashes: integrity_hashes(entry)
    }

    if license, do: Map.put(component, :license, license), else: component
  end

  defp entry_version(%{version: v}), do: v
  defp entry_version(%{"version" => v}), do: v
  defp entry_version(_), do: "0.0.0"

  defp integrity_hashes(%{integrity: "sha512-" <> hash}) do
    [%{alg: "SHA-512", content: hash}]
  end

  defp integrity_hashes(%{integrity: "sha256-" <> hash}) do
    [%{alg: "SHA-256", content: hash}]
  end

  defp integrity_hashes(_), do: []

  defp read_license(nm_dir, name) do
    pkg_path = Path.join([nm_dir, name, "package.json"])

    case File.read(pkg_path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        data["license"]

      _ ->
        nil
    end
  rescue
    _ -> nil
  end
end
