defmodule NPM.Package.Quality do
  @moduledoc """
  Scores individual package quality based on metadata completeness.
  """

  @doc """
  Scores a package's quality (0-100).
  """
  @spec score(map()) :: non_neg_integer()
  def score(data) do
    checks = [
      {Map.has_key?(data, "description"), 10},
      {Map.has_key?(data, "license"), 10},
      {Map.has_key?(data, "repository"), 10},
      {Map.has_key?(data, "homepage"), 5},
      {Map.has_key?(data, "bugs"), 5},
      {Map.has_key?(data, "keywords") and is_list(data["keywords"]), 10},
      {Map.has_key?(data, "engines"), 10},
      {Map.has_key?(data, "types") or Map.has_key?(data, "typings"), 10},
      {Map.has_key?(data, "exports"), 10},
      {Map.has_key?(data, "files"), 10},
      {Map.has_key?(data, "author"), 5},
      {data["private"] != true, 5}
    ]

    Enum.reduce(checks, 0, fn {passed, points}, acc ->
      if passed, do: acc + points, else: acc
    end)
  end

  @doc """
  Returns a quality grade.
  """
  @spec grade(non_neg_integer()) :: String.t()
  def grade(score) when score >= 90, do: "A"
  def grade(score) when score >= 75, do: "B"
  def grade(score) when score >= 60, do: "C"
  def grade(score) when score >= 40, do: "D"
  def grade(_), do: "F"

  @doc """
  Returns missing fields that would improve quality.
  """
  @spec missing_fields(map()) :: [String.t()]
  def missing_fields(data) do
    expected = ~w(description license repository keywords engines types exports files)

    Enum.reject(expected, fn field ->
      Map.has_key?(data, field) and data[field] != nil
    end)
  end

  @doc """
  Ranks packages by quality score.
  """
  @spec rank([{String.t(), map()}]) :: [{String.t(), non_neg_integer()}]
  def rank(packages) do
    packages
    |> Enum.map(fn {name, data} -> {name, score(data)} end)
    |> Enum.sort_by(&elem(&1, 1), :desc)
  end

  @doc """
  Average quality across packages.
  """
  @spec average([{String.t(), map()}]) :: float()
  def average([]), do: 0.0

  def average(packages) do
    total = packages |> Enum.map(fn {_, data} -> score(data) end) |> Enum.sum()
    Float.round(total / length(packages), 1)
  end
end
