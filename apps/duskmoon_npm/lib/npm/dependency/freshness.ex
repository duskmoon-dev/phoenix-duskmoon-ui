defmodule NPM.Dependency.Freshness do
  @moduledoc """
  Analyzes how up-to-date dependencies are by comparing locked vs latest versions.
  """

  @doc """
  Classifies how far behind a locked version is from latest.
  """
  @spec classify(String.t(), String.t()) :: atom()
  def classify(locked, latest) do
    case {parse_major(locked), parse_major(latest)} do
      {l, la} when l == la -> classify_minor(locked, latest)
      {l, la} when la - l >= 2 -> :very_outdated
      _ -> :major_behind
    end
  end

  @doc """
  Groups packages by freshness level.
  """
  @spec group([{String.t(), String.t(), String.t()}]) :: map()
  def group(packages) do
    packages
    |> Enum.map(fn {name, locked, latest} -> {name, classify(locked, latest)} end)
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
  end

  @doc """
  Computes a freshness score (0-100, higher is fresher).
  """
  @spec score([{String.t(), String.t(), String.t()}]) :: non_neg_integer()
  def score([]), do: 100

  def score(packages) do
    points =
      packages
      |> Enum.map(fn {_, locked, latest} -> classify_score(classify(locked, latest)) end)
      |> Enum.sum()

    max_points = length(packages) * 100
    round(points / max_points * 100)
  end

  @doc """
  Formats freshness report.
  """
  @spec format(map()) :: String.t()
  def format(groups) do
    groups
    |> Enum.sort_by(fn {level, _} -> level_order(level) end)
    |> Enum.map_join("\n", fn {level, names} ->
      "#{level}: #{length(names)} packages"
    end)
  end

  defp classify_minor(locked, latest) do
    case {parse_minor(locked), parse_minor(latest)} do
      {l, la} when l == la -> :current
      {l, la} when la - l <= 2 -> :slightly_behind
      _ -> :minor_behind
    end
  end

  defp parse_major(v), do: v |> String.split(".", parts: 2) |> hd() |> String.to_integer()
  defp parse_minor(v), do: v |> String.split(".") |> Enum.at(1, "0") |> String.to_integer()

  defp classify_score(:current), do: 100
  defp classify_score(:slightly_behind), do: 80
  defp classify_score(:minor_behind), do: 60
  defp classify_score(:major_behind), do: 30
  defp classify_score(:very_outdated), do: 10

  defp level_order(:current), do: 0
  defp level_order(:slightly_behind), do: 1
  defp level_order(:minor_behind), do: 2
  defp level_order(:major_behind), do: 3
  defp level_order(:very_outdated), do: 4
end
