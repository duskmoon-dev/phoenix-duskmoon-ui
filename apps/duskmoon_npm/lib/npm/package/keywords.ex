defmodule NPM.Package.Keywords do
  @moduledoc """
  Analyzes package keywords for search and categorization.

  Extracts, normalizes, and analyzes keywords from package.json
  across installed packages.
  """

  @doc """
  Extracts keywords from package.json data.
  """
  @spec extract(map()) :: [String.t()]
  def extract(%{"keywords" => keywords}) when is_list(keywords), do: keywords
  def extract(_), do: []

  @doc """
  Returns the most common keywords across a set of packages.
  """
  @spec most_common([map()], non_neg_integer()) :: [{String.t(), non_neg_integer()}]
  def most_common(packages, n \\ 10) do
    packages
    |> Enum.flat_map(&extract/1)
    |> Enum.frequencies()
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.take(n)
  end

  @doc """
  Finds packages matching a keyword.
  """
  @spec search([{String.t(), map()}], String.t()) :: [String.t()]
  def search(packages, keyword) do
    keyword_lower = String.downcase(keyword)

    packages
    |> Enum.filter(fn {_name, data} ->
      data
      |> extract()
      |> Enum.any?(&(String.downcase(&1) == keyword_lower))
    end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  @doc """
  Groups packages by keyword.
  """
  @spec group_by_keyword([{String.t(), map()}]) :: %{String.t() => [String.t()]}
  def group_by_keyword(packages) do
    Enum.reduce(packages, %{}, fn {name, data}, acc ->
      Enum.reduce(extract(data), acc, fn kw, inner_acc ->
        Map.update(inner_acc, kw, [name], &[name | &1])
      end)
    end)
    |> Map.new(fn {k, v} -> {k, Enum.sort(v)} end)
  end

  @doc """
  Returns unique keywords count.
  """
  @spec unique_count([map()]) :: non_neg_integer()
  def unique_count(packages) do
    packages
    |> Enum.flat_map(&extract/1)
    |> Enum.uniq()
    |> length()
  end
end
