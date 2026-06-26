defmodule NPM.ReleaseNotes do
  @moduledoc """
  Extracts release notes from changelog content for specific version ranges.
  """

  @version_header ~r/^(#+\s*\[?v?)(\d+\.\d+\.\d+(?:-[a-zA-Z0-9.]+)?)/m

  @doc """
  Extracts all version sections from changelog content.
  """
  @spec sections(String.t()) :: [{String.t(), String.t()}]
  def sections(content) do
    matches = Regex.scan(@version_header, content, return: :index)

    versions =
      Regex.scan(@version_header, content) |> Enum.map(fn [_, _, v] -> clean_version(v) end)

    matches
    |> Enum.with_index()
    |> Enum.zip(versions)
    |> Enum.flat_map(fn {{[{start, _} | _], idx}, version} ->
      next_start = next_section_start(matches, idx, byte_size(content))
      body = binary_part(content, start, next_start - start) |> String.trim()

      case NPM.VersionUtil.parse_triple(version) do
        {:ok, _} -> [{version, body}]
        :error -> []
      end
    end)
  end

  @doc """
  Extracts notes for a specific version.
  """
  @spec for_version(String.t(), String.t()) :: String.t() | nil
  def for_version(content, version) do
    sections(content)
    |> Enum.find_value(fn {v, body} -> if v == version, do: body end)
  end

  @doc """
  Extracts notes between two versions (inclusive).
  """
  @spec between(String.t(), String.t(), String.t()) :: [String.t()]
  def between(content, from_version, to_version) do
    sections(content)
    |> Enum.filter(fn {v, _} ->
      NPM.VersionUtil.compare(v, from_version) in [:gt, :eq] and
        NPM.VersionUtil.compare(v, to_version) in [:lt, :eq]
    end)
    |> Enum.map(&elem(&1, 1))
  end

  @doc """
  Counts versions in the changelog.
  """
  @spec version_count(String.t()) :: non_neg_integer()
  def version_count(content), do: sections(content) |> length()

  @doc """
  Returns the latest version mentioned.
  """
  @spec latest_version(String.t()) :: String.t() | nil
  def latest_version(content) do
    case sections(content) do
      [{version, _} | _] -> version
      _ -> nil
    end
  end

  defp next_section_start(matches, idx, total) do
    case Enum.at(matches, idx + 1) do
      [{start, _} | _] -> start
      _ -> total
    end
  end

  defp clean_version(v), do: v |> String.trim_trailing("]") |> String.trim()
end
