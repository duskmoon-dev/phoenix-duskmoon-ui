defmodule NPM.Package.People do
  @moduledoc """
  Extracts and analyzes author/contributor information from packages.
  """

  @doc """
  Extracts the author from package.json data.
  """
  @spec author(map()) :: map() | nil
  def author(%{"author" => author}) when is_binary(author), do: NPM.Normalize.parse_person(author)
  def author(%{"author" => author}) when is_map(author), do: author
  def author(_), do: nil

  @doc """
  Extracts contributors list.
  """
  @spec contributors(map()) :: [map()]
  def contributors(%{"contributors" => list}) when is_list(list) do
    Enum.map(list, fn
      person when is_binary(person) -> NPM.Normalize.parse_person(person)
      person when is_map(person) -> person
    end)
  end

  def contributors(%{"maintainers" => list}) when is_list(list) do
    Enum.map(list, fn
      person when is_binary(person) -> NPM.Normalize.parse_person(person)
      person when is_map(person) -> person
    end)
  end

  def contributors(_), do: []

  @doc """
  Returns all people (author + contributors).
  """
  @spec all(map()) :: [map()]
  def all(data) do
    author_list =
      case author(data) do
        nil -> []
        a -> [a]
      end

    author_list ++ contributors(data)
  end

  @doc """
  Counts unique contributors across multiple packages.
  """
  @spec unique_authors([map()]) :: [String.t()]
  def unique_authors(packages) do
    packages
    |> Enum.flat_map(fn data ->
      case author(data) do
        %{"name" => name} -> [name]
        _ -> []
      end
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Checks if author info is present.
  """
  @spec has_author?(map()) :: boolean()
  def has_author?(data), do: author(data) != nil
end
