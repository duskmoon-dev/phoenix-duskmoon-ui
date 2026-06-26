defmodule NPM.BundleAnalysis do
  alias NPM.Package.Files

  @moduledoc """
  Analyzes package bundle-friendliness.

  Checks for ESM support, tree-shaking capability, sideEffects field,
  and other indicators of bundle efficiency.
  """

  @doc """
  Scores a package's bundle-friendliness (0-100).
  """
  @spec score(map()) :: non_neg_integer()
  def score(data) do
    points = 0
    points = if NPM.TypeField.esm?(data), do: points + 25, else: points
    points = if NPM.SideEffects.tree_shakeable?(data), do: points + 25, else: points
    points = if is_map(data["exports"]), do: points + 20, else: points
    points = if is_binary(data["module"]), do: points + 15, else: points
    if Files.has_whitelist?(data), do: points + 15, else: points
  end

  @doc """
  Categorizes bundle-friendliness.
  """
  @spec grade(non_neg_integer()) :: String.t()
  def grade(score) when score >= 80, do: "excellent"
  def grade(score) when score >= 60, do: "good"
  def grade(score) when score >= 40, do: "fair"
  def grade(score) when score >= 20, do: "poor"
  def grade(_), do: "minimal"

  @doc """
  Generates recommendations for improving bundle-friendliness.
  """
  @spec recommendations(map()) :: [String.t()]
  def recommendations(data) do
    checks = [
      {NPM.TypeField.esm?(data), ~s(Add "type": "module" for ESM support)},
      {NPM.SideEffects.tree_shakeable?(data), ~s(Add "sideEffects": false for tree-shaking)},
      {is_map(data["exports"]), ~s(Add "exports" field for subpath exports)},
      {is_binary(data["module"]), ~s(Add "module" field pointing to ESM entry)}
    ]

    Enum.flat_map(checks, fn
      {true, _} -> []
      {false, rec} -> [rec]
    end)
  end

  @doc """
  Analyzes bundle-friendliness across packages.
  """
  @spec analyze([{String.t(), map()}]) :: map()
  def analyze(packages) do
    scores = Enum.map(packages, fn {name, data} -> {name, score(data)} end)

    avg =
      if scores != [],
        do: scores |> Enum.map(&elem(&1, 1)) |> Enum.sum() |> div(length(scores)),
        else: 0

    %{
      average_score: avg,
      grade: grade(avg),
      best: scores |> Enum.sort_by(&elem(&1, 1), :desc) |> Enum.take(5),
      worst: scores |> Enum.sort_by(&elem(&1, 1)) |> Enum.take(5)
    }
  end
end
