defmodule DuskmoonBundler.Preload do
  @moduledoc """
  Generate `<link rel="modulepreload">` tags for production chunks.

  In production templates, pass a Phoenix endpoint or connection plus the entry
  asset path:

      DuskmoonBundler.Preload.tags(@endpoint, "/assets/js/app.js")

  Manifest maps and manifest file paths are still accepted for backwards
  compatibility:

      DuskmoonBundler.Preload.tags("priv/static/assets/js/manifest.json", prefix: "/assets/js")
  """

  alias DuskmoonBundler.Manifest
  alias DuskmoonBundler.Runtime.Config
  alias DuskmoonBundler.StaticPath
  alias DuskmoonBundler.URL

  @doc """
  Generate modulepreload link tags.

  ## Options

    * `:prefix` - URL prefix for manifest maps and file paths
    * `:entry` - only preload chunks related to this entry name
    * `:profile` - DuskmoonBundler config profile for endpoint/path calls
  """
  @spec tags(String.t() | map() | module() | struct(), String.t() | keyword()) :: String.t()
  def tags(manifest_or_endpoint, path_or_opts \\ [])

  def tags(manifest_path, opts) when is_binary(manifest_path) and is_list(opts) do
    manifest_path
    |> Manifest.read!()
    |> tags(opts)
  end

  def tags(manifest, opts) when is_map(manifest) and is_list(opts) do
    prefix = Keyword.get(opts, :prefix, DuskmoonBundler.Paths.prefix())
    entries = Manifest.entries!(manifest)

    entries
    |> preload_files(Keyword.get(opts, :entry))
    |> Enum.map(fn filename ->
      [
        ~s(<link rel="modulepreload" href="),
        escape_attr(URL.join(prefix, filename)),
        ~s(">)
      ]
    end)
    |> Enum.intersperse("\n")
    |> IO.iodata_to_binary()
  end

  def tags(endpoint_or_conn, path) when is_binary(path), do: tags(endpoint_or_conn, path, [])

  def tags(endpoint_or_conn, path, opts) when is_binary(path) and is_list(opts) do
    endpoint = Config.endpoint_from(endpoint_or_conn)

    if Config.code_reloader?(endpoint) do
      ""
    else
      profile = Keyword.get(opts, :profile)
      config = Config.resolve(profile, Keyword.delete(opts, :profile))

      case StaticPath.fetch_entry(endpoint_or_conn, path, config) do
        {:ok, %{key: key, entries: entries, manifest_prefix: manifest_prefix}} ->
          tags(entries, prefix: manifest_prefix, entry: key)

        {:error, error} ->
          raise error
      end
    end
  end

  defp preload_files(manifest, nil) do
    manifest
    |> Enum.flat_map(fn
      {_key, %{"file" => file}} -> [file]
      {_key, file} when is_binary(file) -> [file]
      _other -> []
    end)
    |> js_files()
  end

  defp preload_files(manifest, entry) do
    case Map.get(manifest, entry) do
      %{} = chunk -> imported_files(manifest, chunk)
      _ -> []
    end
  end

  defp imported_files(manifest, chunk), do: imported_files(manifest, chunk, MapSet.new())

  defp imported_files(manifest, chunk, seen) do
    chunk
    |> Map.get("imports", [])
    |> Enum.reject(&MapSet.member?(seen, &1))
    |> Enum.flat_map(fn file ->
      [file | imported_files(manifest, manifest[file] || %{}, MapSet.put(seen, file))]
    end)
    |> js_files()
  end

  defp escape_attr(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  defp js_files(files) do
    files
    |> Enum.uniq()
    |> Enum.filter(&String.ends_with?(&1, ".js"))
    |> Enum.sort()
  end
end
