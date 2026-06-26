defmodule NPM.Changelog do
  @moduledoc """
  Detects and reads changelog files from installed packages.

  Supports common changelog file names: CHANGELOG.md, HISTORY.md,
  CHANGES.md, and their case variations.
  """

  @changelog_names ~w(
    CHANGELOG.md changelog.md Changelog.md
    HISTORY.md history.md History.md
    CHANGES.md changes.md Changes.md
    CHANGELOG HISTORY CHANGES
    CHANGELOG.txt changelog.txt
  )

  @doc """
  Finds the changelog file for a package.
  """
  @spec find(String.t()) :: {:ok, String.t()} | :none
  def find(package_dir) do
    Enum.find_value(@changelog_names, :none, fn name ->
      path = Path.join(package_dir, name)
      if File.regular?(path), do: {:ok, path}
    end)
  end

  @doc """
  Reads the changelog content for a package.
  """
  @spec read(String.t()) :: {:ok, String.t()} | :none
  def read(package_dir) do
    case find(package_dir) do
      {:ok, path} -> {:ok, File.read!(path)}
      :none -> :none
    end
  end

  @doc """
  Extracts the entry for a specific version from markdown changelog.
  """
  @spec version_entry(String.t(), String.t()) :: String.t() | nil
  def version_entry(content, version) do
    lines = String.split(content, "\n")
    {entry_lines, _} = extract_version_section(lines, version)

    case entry_lines do
      [] -> nil
      lines -> Enum.join(lines, "\n") |> String.trim()
    end
  end

  @doc """
  Lists all versions mentioned in a changelog.
  """
  @spec versions(String.t()) :: [String.t()]
  def versions(content) do
    ~r/^##?\s+\[?v?(\d+\.\d+\.\d+(?:[^\]\s]*))\]?/m
    |> Regex.scan(content)
    |> Enum.map(fn [_, version] -> String.trim(version) end)
  end

  @doc """
  Checks if a package has a changelog.
  """
  @spec has_changelog?(String.t()) :: boolean()
  def has_changelog?(package_dir) do
    case find(package_dir) do
      {:ok, _} -> true
      :none -> false
    end
  end

  defp extract_version_section(lines, version) do
    {_, in_section, collected} =
      Enum.reduce(lines, {false, false, []}, fn line, {found, in_sec, acc} ->
        cond do
          not found and version_header?(line, version) ->
            {true, true, acc}

          in_sec and next_version_header?(line) ->
            {true, false, acc}

          in_sec ->
            {true, true, [line | acc]}

          true ->
            {found, in_sec, acc}
        end
      end)

    {Enum.reverse(collected), in_section}
  end

  defp version_header?(line, version) do
    String.contains?(line, version) and Regex.match?(~r/^##?\s/, line)
  end

  defp next_version_header?(line) do
    Regex.match?(~r/^##?\s+\[?\d/, line)
  end
end
