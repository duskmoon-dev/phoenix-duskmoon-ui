defmodule NPM.Package.Funding do
  @moduledoc """
  Parses the `funding` field from package.json.

  Supports all npm funding formats: string URL, object with url/type,
  and array of funders.
  """

  @doc """
  Extracts funding entries from package.json data.
  """
  @spec extract(map()) :: [map()]
  def extract(%{"funding" => url}) when is_binary(url) do
    [%{"url" => url, "type" => nil}]
  end

  def extract(%{"funding" => %{"url" => _} = funding}) do
    [funding]
  end

  def extract(%{"funding" => funders}) when is_list(funders) do
    Enum.map(funders, fn
      url when is_binary(url) -> %{"url" => url, "type" => nil}
      funder when is_map(funder) -> funder
    end)
  end

  def extract(_), do: []

  @doc """
  Returns all funding URLs.
  """
  @spec urls(map()) :: [String.t()]
  def urls(data) do
    data |> extract() |> Enum.map(& &1["url"]) |> Enum.reject(&is_nil/1)
  end

  @doc """
  Returns funding types used (github, opencollective, etc.).
  """
  @spec types(map()) :: [String.t()]
  def types(data) do
    data |> extract() |> Enum.map(& &1["type"]) |> Enum.reject(&is_nil/1) |> Enum.uniq()
  end

  @doc """
  Checks if a package has funding info.
  """
  @spec has_funding?(map()) :: boolean()
  def has_funding?(data), do: extract(data) != []

  @doc """
  Counts packages with funding across a set.
  """
  @spec funding_stats([map()]) :: map()
  def funding_stats(packages) do
    with_funding = Enum.count(packages, &has_funding?/1)

    all_types =
      packages
      |> Enum.flat_map(&types/1)
      |> Enum.frequencies()
      |> Enum.sort_by(&elem(&1, 1), :desc)

    %{
      total: length(packages),
      with_funding: with_funding,
      without_funding: length(packages) - with_funding,
      types: all_types
    }
  end
end
