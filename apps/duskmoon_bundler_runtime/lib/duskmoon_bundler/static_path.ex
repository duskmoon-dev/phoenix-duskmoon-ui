defmodule DuskmoonBundler.StaticPath do
  @moduledoc "Resolve source asset paths to content-hashed production paths."

  alias DuskmoonBundler.Manifest
  alias DuskmoonBundler.Manifest.Entry
  alias DuskmoonBundler.Runtime.Config
  alias DuskmoonBundler.URL

  @doc """
  Resolve an asset path from production manifests.

  Returns `{:ok, resolved_path}` or `{:error, %DuskmoonBundler.Manifest.Error{}}`.
  """
  def resolve(endpoint_or_conn, path, opts \\ [])

  def resolve(endpoint_or_conn, path, %Config{} = config) do
    case fetch_entry(endpoint_or_conn, path, config) do
      {:ok, %{entry: entry, manifest_prefix: manifest_prefix}} ->
        with {:ok, file} <- Entry.file(entry) do
          {:ok, URL.join(manifest_prefix, file)}
        else
          :error -> {:error, missing_asset_error(path, [])}
        end

      {:error, _} = error ->
        error
    end
  end

  def resolve(endpoint_or_conn, path, opts) when is_list(opts) do
    profile = Keyword.get(opts, :profile)
    overrides = Keyword.delete(opts, :profile)
    resolve(endpoint_or_conn, path, Config.resolve(profile, overrides))
  end

  @doc """
  Fetch the manifest entry that matches an asset path.

  The result includes the normalized entries map and URL prefix for preload
  generation.
  """
  def fetch_entry(endpoint_or_conn, path, opts \\ [])

  def fetch_entry(endpoint_or_conn, path, %Config{} = config) do
    endpoint = Config.endpoint_from(endpoint_or_conn)
    root_outdir = resolve_outdir(endpoint, config.outdir)
    keys = manifest_keys(path, config.prefix)
    locations = manifest_locations(root_outdir, config.prefix)

    existing_locations =
      Enum.filter(locations, fn {manifest_path, _prefix} -> File.exists?(manifest_path) end)

    if existing_locations == [] do
      {:error, missing_manifest_error(Enum.map(locations, &elem(&1, 0)))}
    else
      find_entry(existing_locations, keys, path)
    end
  end

  def fetch_entry(endpoint_or_conn, path, opts) when is_list(opts) do
    profile = Keyword.get(opts, :profile)
    overrides = Keyword.delete(opts, :profile)
    fetch_entry(endpoint_or_conn, path, Config.resolve(profile, overrides))
  end

  defp find_entry(locations, keys, path) do
    Enum.reduce_while(
      keys,
      {:error, missing_asset_error(path, Enum.map(locations, &elem(&1, 0)))},
      fn key, fallback ->
        case find_entry_in_locations(locations, key) do
          {:ok, _} = result -> {:halt, result}
          {:error, %Manifest.Error{reason: {:missing_asset, _, _}}} -> {:cont, fallback}
          {:error, _} = error -> {:halt, error}
        end
      end
    )
  end

  defp find_entry_in_locations(locations, key) do
    Enum.reduce_while(
      locations,
      {:error, missing_asset_error(key, Enum.map(locations, &elem(&1, 0)))},
      fn {manifest_path, manifest_prefix}, fallback ->
        with {:ok, entries} <- Manifest.read(manifest_path),
             entry when not is_nil(entry) <- Map.get(entries, key) do
          {:halt,
           {:ok,
            %{
              key: key,
              entry: entry,
              entries: entries,
              manifest_path: manifest_path,
              manifest_prefix: manifest_prefix
            }}}
        else
          nil -> {:cont, fallback}
          {:error, _} = error -> {:halt, error}
        end
      end
    )
  end

  defp manifest_locations(root_outdir, prefix) do
    [
      {Path.join(root_outdir, "manifest.json"), prefix},
      {Path.join([root_outdir, "js", "manifest.json"]), URL.join(prefix, "js")},
      {Path.join([root_outdir, "css", "manifest.json"]), URL.join(prefix, "css")}
    ]
  end

  defp manifest_keys(path, prefix) do
    normalized_path = normalize_path(path)
    normalized_prefix = normalize_path(prefix)

    relative =
      if String.starts_with?(normalized_path, normalized_prefix <> "/") do
        String.replace_prefix(normalized_path, normalized_prefix <> "/", "")
      else
        String.trim_leading(normalized_path, "/")
      end

    [relative, Path.basename(relative)]
    |> Enum.uniq()
  end

  defp resolve_outdir(endpoint, outdir) do
    outdir = to_string(outdir)

    cond do
      Path.type(outdir) == :absolute ->
        outdir

      endpoint && Config.otp_app(endpoint) ->
        resolve_app_path(Config.otp_app(endpoint), outdir)

      true ->
        Path.expand(outdir)
    end
  end

  defp resolve_app_path(otp_app, "priv/" <> _ = outdir) do
    Application.app_dir(otp_app, outdir)
  rescue
    _ -> Path.expand(outdir)
  end

  defp resolve_app_path(_otp_app, outdir), do: Path.expand(outdir)

  defp normalize_path(path), do: "/" <> (path |> to_string() |> String.trim_leading("/"))

  defp missing_manifest_error(paths), do: %Manifest.Error{reason: {:missing_manifest, paths}}

  defp missing_asset_error(path, paths),
    do: %Manifest.Error{reason: {:missing_asset, path, paths}}
end
