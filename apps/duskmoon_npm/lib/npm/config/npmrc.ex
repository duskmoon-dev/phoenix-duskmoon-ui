defmodule NPM.Config.Npmrc do
  @moduledoc """
  Parses and analyzes .npmrc configuration files.

  Supports project, user, and global .npmrc locations.
  """

  @doc """
  Finds all .npmrc files for a project.
  """
  @spec locate(String.t()) :: [String.t()]
  def locate(project_dir \\ ".") do
    candidates = [
      Path.join(project_dir, ".npmrc"),
      Path.expand("~/.npmrc"),
      "/etc/npmrc"
    ]

    Enum.filter(candidates, &File.exists?/1)
  end

  @doc """
  Parses an .npmrc file into a map.
  """
  @spec parse(String.t()) :: map()
  def parse(content) when is_binary(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&blank_or_comment?/1)
    |> Enum.flat_map(&parse_line/1)
    |> Map.new()
  end

  @doc """
  Reads and parses an .npmrc file from disk.
  """
  @spec read(String.t()) :: {:ok, map()} | {:error, :not_found}
  def read(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, parse(content)}
      _ -> {:error, :not_found}
    end
  end

  @doc """
  Merges multiple .npmrc configs (later overrides earlier).
  """
  @spec merge([map()]) :: map()
  def merge(configs), do: Enum.reduce(configs, %{}, &Map.merge(&2, &1))

  @doc """
  Checks if auth token is configured.
  """
  @spec has_auth?(map()) :: boolean()
  def has_auth?(config) do
    Enum.any?(config, fn {key, _} ->
      String.contains?(key, "_authToken") or key == "_auth"
    end)
  end

  @doc """
  Extracts scoped registry configurations.
  """
  @spec scoped_registries(map()) :: [{String.t(), String.t()}]
  def scoped_registries(config) do
    config
    |> Enum.filter(fn {key, _} -> String.match?(key, ~r/^@.+:registry$/) end)
    |> Enum.map(fn {key, url} ->
      scope = key |> String.replace(":registry", "") |> String.trim_leading("@")
      {scope, url}
    end)
    |> Enum.sort_by(&elem(&1, 0))
  end

  @doc """
  Formats .npmrc config for display.
  """
  @spec format(map()) :: String.t()
  def format(config) when map_size(config) == 0, do: "Empty .npmrc"

  def format(config) do
    config
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map_join("\n", fn {k, v} ->
      if String.contains?(k, "Token") or k == "_auth",
        do: "#{k} = [REDACTED]",
        else: "#{k} = #{v}"
    end)
  end

  defp blank_or_comment?(line) do
    trimmed = String.trim(line)
    trimmed == "" or String.starts_with?(trimmed, "#") or String.starts_with?(trimmed, ";")
  end

  defp parse_line(line) do
    case String.split(String.trim(line), "=", parts: 2) do
      [key, value] -> [{String.trim(key), String.trim(value)}]
      _ -> []
    end
  end
end
