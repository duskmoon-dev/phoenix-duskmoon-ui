defmodule NPM.ImportMap do
  @moduledoc """
  Generates and manages import maps for browser-native ES module loading.

  Import maps allow mapping bare module specifiers to URLs
  for use with `<script type="importmap">`.
  """

  @doc """
  Generates an import map from a lockfile.
  """
  @spec generate(map(), keyword()) :: map()
  def generate(lockfile, opts \\ []) do
    cdn = Keyword.get(opts, :cdn, "https://esm.sh")

    imports =
      lockfile
      |> Enum.map(fn {name, entry} ->
        version = extract_version(entry)
        {name, "#{cdn}/#{name}@#{version}"}
      end)
      |> Map.new()

    %{"imports" => imports}
  end

  @doc """
  Generates an import map with only specified packages.
  """
  @spec generate_for(map(), [String.t()], keyword()) :: map()
  def generate_for(lockfile, packages, opts \\ []) do
    filtered = Map.take(lockfile, packages)
    generate(filtered, opts)
  end

  @doc """
  Serializes an import map to JSON.
  """
  @spec to_json(map()) :: String.t()
  def to_json(import_map) do
    :json.encode(import_map) |> IO.iodata_to_binary()
  end

  @doc """
  Generates an HTML script tag.
  """
  @spec to_html(map()) :: String.t()
  def to_html(import_map) do
    json = to_json(import_map)
    ~s(<script type="importmap">\n#{json}\n</script>)
  end

  @doc """
  Merges two import maps (second overrides first).
  """
  @spec merge(map(), map()) :: map()
  def merge(base, override) do
    %{"imports" => Map.merge(base["imports"] || %{}, override["imports"] || %{})}
  end

  @doc """
  Counts the number of mappings.
  """
  @spec count(map()) :: non_neg_integer()
  def count(%{"imports" => imports}), do: map_size(imports)
  def count(_), do: 0

  defp extract_version(%{version: v}), do: v
  defp extract_version(%{"version" => v}), do: v
  defp extract_version(_), do: "latest"
end
