defmodule NPM.NodeVersion do
  @moduledoc """
  Parses Node.js version pinning files (.nvmrc, .node-version, .tool-versions).
  """

  @version_files ~w(.nvmrc .node-version)

  @doc """
  Detects and reads the Node.js version from project files.
  """
  @spec detect(String.t()) :: {:ok, String.t(), String.t()} | :not_found
  def detect(project_dir \\ ".") do
    case Enum.find_value(@version_files, fn file ->
           path = Path.join(project_dir, file)
           read_version_file(path, file)
         end) do
      nil -> read_tool_versions(project_dir) || :not_found
      result -> result
    end
  end

  @doc """
  Parses a .nvmrc file content.
  """
  @spec parse_nvmrc(String.t()) :: String.t()
  def parse_nvmrc(content) do
    content |> String.trim() |> strip_v_prefix()
  end

  @doc """
  Parses a .tool-versions file to extract the node version.
  """
  @spec parse_tool_versions(String.t()) :: String.t() | nil
  def parse_tool_versions(content) do
    content
    |> String.split("\n")
    |> Enum.find_value(fn line ->
      case String.split(String.trim(line), ~r/\s+/, parts: 2) do
        ["nodejs", version] -> strip_v_prefix(version)
        _ -> nil
      end
    end)
  end

  @doc """
  Checks if a version string looks like a major-only version.
  """
  @spec major_only?(String.t()) :: boolean()
  def major_only?(version) do
    String.match?(version, ~r/^\d+$/)
  end

  @doc """
  Checks if a version string includes an alias (lts/*, etc).
  """
  @spec alias?(String.t()) :: boolean()
  def alias?(version) do
    version = String.trim(version)
    String.starts_with?(version, "lts") or version in ~w(stable node current)
  end

  @doc """
  Normalizes version to include all three parts.
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(version) do
    version = strip_v_prefix(version)

    case String.split(version, ".") do
      [_major] -> "#{version}.0.0"
      [_major, _minor] -> "#{version}.0"
      _ -> version
    end
  end

  defp strip_v_prefix("v" <> rest), do: rest
  defp strip_v_prefix(version), do: version

  defp read_version_file(path, file) do
    case File.read(path) do
      {:ok, content} ->
        version = parse_nvmrc(content)
        if version != "", do: {:ok, version, file}

      _ ->
        nil
    end
  end

  defp read_tool_versions(project_dir) do
    path = Path.join(project_dir, ".tool-versions")

    case File.read(path) do
      {:ok, content} ->
        case parse_tool_versions(content) do
          nil -> nil
          version -> {:ok, version, ".tool-versions"}
        end

      _ ->
        nil
    end
  end
end
