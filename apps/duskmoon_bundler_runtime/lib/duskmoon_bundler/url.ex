defmodule DuskmoonBundler.URL do
  @moduledoc "Helpers for URL path, query, and fragment handling."

  def join(prefix, path) do
    prefix = to_string(prefix)
    path = "/" <> (path |> to_string() |> String.trim_leading("/"))

    if prefix == "" do
      String.trim_leading(path, "/")
    else
      prefix
      |> URI.parse()
      |> URI.append_path(path)
      |> URI.to_string()
    end
  end

  def split_query(url) do
    uri = URI.parse(url)
    path = URI.to_string(%{uri | query: nil, fragment: nil})
    {path, uri.query || ""}
  end

  def append_query(path, ""), do: path
  def append_query(path, nil), do: path

  def append_query(path, query) do
    path
    |> URI.parse()
    |> URI.append_query(query)
    |> URI.to_string()
  end

  def decode_query(""), do: %{}
  def decode_query(query), do: URI.decode_query(query)

  def append_fragment(path, nil), do: path

  def append_fragment(path, fragment) do
    path
    |> URI.parse()
    |> Map.put(:fragment, fragment)
    |> URI.to_string()
  end
end
