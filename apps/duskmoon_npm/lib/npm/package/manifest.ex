defmodule NPM.Package.Manifest do
  alias NPM.Resolution.Exports

  @moduledoc """
  Generate a complete package manifest from `package.json`.

  Aggregates data from the package.json file into a structured
  manifest used by publishing, auditing, and analysis tools.
  """

  @type t :: %{
          name: String.t() | nil,
          version: String.t() | nil,
          license: String.t() | nil,
          module_type: :esm | :cjs,
          dependencies: %{String.t() => String.t()},
          dev_dependencies: %{String.t() => String.t()},
          optional_dependencies: %{String.t() => String.t()},
          scripts: %{String.t() => String.t()},
          engines: %{String.t() => String.t()},
          exports: map() | nil,
          files: [String.t()] | nil
        }

  @doc """
  Build a manifest from a `package.json` file.
  """
  @spec from_file(String.t()) :: {:ok, t()} | {:error, term()}
  def from_file(path \\ "package.json") do
    case File.read(path) do
      {:ok, content} -> {:ok, from_json(content)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Build a manifest from a JSON string.
  """
  @spec from_json(String.t()) :: t()
  def from_json(json) do
    data = NPM.JSON.decode!(json)

    %{
      name: Map.get(data, "name"),
      version: Map.get(data, "version"),
      license: Map.get(data, "license"),
      module_type: Exports.module_type(data),
      dependencies: Map.get(data, "dependencies", %{}),
      dev_dependencies: Map.get(data, "devDependencies", %{}),
      optional_dependencies: Map.get(data, "optionalDependencies", %{}),
      scripts: Map.get(data, "scripts", %{}),
      engines: Map.get(data, "engines", %{}),
      exports: Exports.parse(data),
      files: Map.get(data, "files")
    }
  end

  @doc """
  Count total dependency count across all types.
  """
  @spec dep_count(t()) :: non_neg_integer()
  def dep_count(manifest) do
    map_size(manifest.dependencies) +
      map_size(manifest.dev_dependencies) +
      map_size(manifest.optional_dependencies)
  end

  @doc """
  Check if the manifest has any scripts defined.
  """
  @spec has_scripts?(t()) :: boolean()
  def has_scripts?(manifest), do: map_size(manifest.scripts) > 0

  @doc """
  Get all dependency names across all types.
  """
  @spec all_dep_names(t()) :: [String.t()]
  def all_dep_names(manifest) do
    [manifest.dependencies, manifest.dev_dependencies, manifest.optional_dependencies]
    |> Enum.flat_map(&Map.keys/1)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
