defmodule DuskmoonBundler.Manifest do
  @moduledoc """
  Reads and normalizes DuskmoonBundler production manifests.

  Versioned manifests use this shape:

      %{
        "manifest_version" => 1,
        "entries" => %{}
      }

  Older flat manifests are still accepted for non-breaking upgrades.
  """

  defmodule Error do
    defexception [:reason]

    @impl Exception
    def message(%__MODULE__{reason: {:missing_manifest, paths}}) when is_list(paths) do
      "DuskmoonBundler manifest not found. Checked: #{Enum.join(paths, ", ")}"
    end

    def message(%__MODULE__{reason: {:missing_manifest, path}}) do
      "DuskmoonBundler manifest not found at #{path}"
    end

    def message(%__MODULE__{reason: {:invalid_json, path, reason}}) do
      "DuskmoonBundler manifest at #{path} is not valid JSON: #{inspect(reason)}"
    end

    def message(%__MODULE__{reason: {:invalid_manifest, path}}) do
      "DuskmoonBundler manifest at #{path} must contain an entries object"
    end

    def message(%__MODULE__{reason: {:unsupported_version, path, version}}) do
      "DuskmoonBundler manifest at #{path} has unsupported manifest_version #{inspect(version)}"
    end

    def message(%__MODULE__{reason: {:missing_asset, asset_path, paths}}) do
      "DuskmoonBundler asset #{inspect(asset_path)} was not found in manifests: #{Enum.join(paths, ", ")}"
    end
  end

  @version 1

  def version, do: @version

  @doc "Wrap a flat manifest entries map in the versioned runtime schema."
  def wrap(entries) when is_map(entries) do
    %{
      "manifest_version" => @version,
      "entries" => entries
    }
  end

  @doc "Read and normalize entries from a manifest file."
  def read(path) when is_binary(path) do
    with {:ok, content} <- File.read(path),
         {:ok, manifest} <- decode(path, content),
         {:ok, entries} <- entries(manifest, path) do
      {:ok, entries}
    else
      {:error, :enoent} -> {:error, %Error{reason: {:missing_manifest, path}}}
      {:error, :enotdir} -> {:error, %Error{reason: {:missing_manifest, path}}}
      {:error, %Error{} = error} -> {:error, error}
      {:error, reason} -> {:error, %Error{reason: {:invalid_json, path, reason}}}
    end
  end

  def read!(path) do
    case read(path) do
      {:ok, entries} -> entries
      {:error, error} -> raise error
    end
  end

  @doc "Normalize a decoded manifest map to its entries map."
  def entries(manifest, path \\ "manifest.json")

  def entries(%{"manifest_version" => @version, "entries" => entries}, _path)
      when is_map(entries) do
    {:ok, entries}
  end

  def entries(%{"manifest_version" => @version}, path) do
    {:error, %Error{reason: {:invalid_manifest, path}}}
  end

  def entries(%{"manifest_version" => version}, path) do
    {:error, %Error{reason: {:unsupported_version, path, version}}}
  end

  def entries(%{"entries" => entries}, _path) when is_map(entries) do
    {:ok, entries}
  end

  def entries(entries, _path) when is_map(entries), do: {:ok, entries}
  def entries(_manifest, path), do: {:error, %Error{reason: {:invalid_manifest, path}}}

  def entries!(manifest) do
    case entries(manifest) do
      {:ok, entries} -> entries
      {:error, error} -> raise error
    end
  end

  defp decode(path, content) do
    case JSON.decode(content) do
      {:ok, decoded} -> {:ok, decoded}
      {:error, reason} -> {:error, %Error{reason: {:invalid_json, path, reason}}}
    end
  end
end
