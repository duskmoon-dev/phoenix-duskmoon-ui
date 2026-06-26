defmodule NPM.Dependency.Range do
  @moduledoc """
  Analyzes dependency version ranges for pinning strategy insights.
  """

  @doc """
  Classifies a version range string.
  """
  @spec classify(String.t()) :: atom()
  def classify("*"), do: :star
  def classify("latest"), do: :latest
  def classify("git" <> _ = range), do: classify_url_or(range)
  def classify("file:" <> _), do: :file
  def classify("workspace:" <> _), do: :workspace
  def classify("npm:" <> _), do: :alias
  def classify("~" <> _), do: :tilde
  def classify("^" <> _range = full), do: classify_compound(full)

  def classify(range) when is_binary(range) do
    cond do
      String.contains?(range, "://") -> :url
      String.contains?(range, "||") -> :or_range
      String.contains?(range, " - ") -> :hyphen
      NPM.VersionRange.exact?(range) -> :exact
      true -> :other
    end
  end

  defp classify_url_or(range) do
    if String.contains?(range, "://"), do: :url, else: :other
  end

  defp classify_compound(range) do
    if String.contains?(range, "||"), do: :or_range, else: :caret
  end

  @doc """
  Analyzes all dependencies and returns a breakdown by range type.
  """
  @spec analyze(map()) :: map()
  def analyze(deps) when is_map(deps) do
    deps
    |> Enum.map(fn {name, range} -> {name, classify(range)} end)
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Map.new(fn {type, names} -> {type, Enum.sort(names)} end)
  end

  @doc """
  Returns a summary of range types.
  """
  @spec summary(map()) :: map()
  def summary(deps) when is_map(deps) do
    breakdown = Enum.map(deps, fn {_, range} -> classify(range) end) |> Enum.frequencies()
    total = map_size(deps)
    pinned = Map.get(breakdown, :exact, 0)

    %{
      total: total,
      breakdown: breakdown,
      pinned_count: pinned,
      pinned_pct: if(total > 0, do: Float.round(pinned / total * 100, 1), else: 0.0),
      has_urls: Map.has_key?(breakdown, :url),
      has_files: Map.has_key?(breakdown, :file)
    }
  end

  @doc """
  Returns packages using non-registry sources (git, file, url).
  """
  @spec non_registry(map()) :: [{String.t(), atom()}]
  def non_registry(deps) when is_map(deps) do
    deps
    |> Enum.filter(fn {_, range} -> classify(range) in [:url, :file] end)
    |> Enum.map(fn {name, range} -> {name, classify(range)} end)
    |> Enum.sort_by(&elem(&1, 0))
  end
end
