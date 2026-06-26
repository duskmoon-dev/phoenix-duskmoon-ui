defmodule NPM.Config.Npmrc.Merge do
  alias NPM.Config.Npmrc

  @moduledoc """
  Multi-layer .npmrc resolution (project → user → global).

  Merges configuration from multiple .npmrc files with proper precedence.
  """

  @doc """
  Resolves merged configuration from all .npmrc layers.

  Project-level overrides user-level, which overrides global.
  """
  @spec resolve(String.t()) :: map()
  def resolve(project_dir) do
    layers(project_dir)
    |> Enum.map(&read_layer/1)
    |> Enum.reduce(%{}, &Map.merge(&2, &1))
  end

  @doc """
  Returns the ordered list of .npmrc file paths (global → user → project).
  """
  @spec layers(String.t()) :: [String.t()]
  def layers(project_dir) do
    [
      global_path(),
      user_path(),
      Path.join(project_dir, ".npmrc")
    ]
  end

  @doc """
  Reads and parses a single .npmrc file.
  """
  @spec read_layer(String.t()) :: map()
  def read_layer(path) do
    case File.read(path) do
      {:ok, content} -> Npmrc.parse(content)
      _ -> %{}
    end
  end

  @doc """
  Returns which layers exist and contribute config.
  """
  @spec active_layers(String.t()) :: [%{path: String.t(), keys: [String.t()]}]
  def active_layers(project_dir) do
    layers(project_dir)
    |> Enum.flat_map(fn path ->
      config = read_layer(path)

      if map_size(config) > 0 do
        [%{path: path, keys: Map.keys(config) |> Enum.sort()}]
      else
        []
      end
    end)
  end

  @doc """
  Traces where a specific config key comes from.
  """
  @spec trace(String.t(), String.t()) :: {:ok, String.t(), String.t()} | :not_found
  def trace(project_dir, key) do
    layers(project_dir)
    |> Enum.reverse()
    |> Enum.find_value(fn path ->
      config = read_layer(path)
      if Map.has_key?(config, key), do: {:ok, path, config[key]}
    end) || :not_found
  end

  defp global_path, do: "/etc/npmrc"

  defp user_path do
    Path.join(System.user_home() || "/tmp", ".npmrc")
  end
end
