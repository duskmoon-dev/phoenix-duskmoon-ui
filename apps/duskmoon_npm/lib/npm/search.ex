defmodule NPM.Search do
  @moduledoc """
  Local search functionality for installed packages.

  Searches package names, descriptions, and keywords
  in the installed node_modules.
  """

  @type search_result :: %{
          name: String.t(),
          version: String.t(),
          description: String.t() | nil,
          keywords: [String.t()],
          score: float()
        }

  @doc """
  Searches installed packages matching a query string.

  Matches against package name, description, and keywords.
  Results are sorted by relevance score.
  """
  @spec search(String.t(), String.t()) :: [search_result()]
  def search(node_modules_dir, query) do
    query_lower = String.downcase(query)
    query_parts = String.split(query_lower)

    case File.ls(node_modules_dir) do
      {:ok, entries} ->
        entries
        |> Enum.flat_map(&read_package_info(node_modules_dir, &1))
        |> Enum.flat_map(&score_result(&1, query_lower, query_parts))
        |> Enum.sort_by(& &1.score, :desc)

      _ ->
        []
    end
  end

  @doc """
  Scores a package against a search query.

  Returns a score from 0.0 to 1.0 based on match quality.
  """
  @spec score(map(), String.t()) :: float()
  def score(pkg_info, query) do
    query_lower = String.downcase(query)
    name = String.downcase(pkg_info.name)
    desc = String.downcase(pkg_info.description || "")
    keywords = Enum.map(pkg_info.keywords, &String.downcase/1)

    cond do
      name == query_lower -> 1.0
      String.starts_with?(name, query_lower) -> 0.8
      String.contains?(name, query_lower) -> 0.6
      query_lower in keywords -> 0.4
      String.contains?(desc, query_lower) -> 0.2
      true -> 0.0
    end
  end

  @doc """
  Filters search results by minimum score.
  """
  @spec filter_by_score([search_result()], float()) :: [search_result()]
  def filter_by_score(results, min_score) do
    Enum.filter(results, &(&1.score >= min_score))
  end

  defp read_package_info(nm_dir, entry) do
    if String.starts_with?(entry, "@") do
      read_scoped(nm_dir, entry)
    else
      read_single(nm_dir, entry)
    end
  end

  defp read_scoped(nm_dir, scope) do
    scope_dir = Path.join(nm_dir, scope)

    case File.ls(scope_dir) do
      {:ok, subs} -> Enum.flat_map(subs, &read_single(scope_dir, &1, "#{scope}/#{&1}"))
      _ -> []
    end
  end

  defp read_single(parent, name, full_name \\ nil) do
    pkg_json = Path.join([parent, name, "package.json"])
    full_name = full_name || name

    case File.read(pkg_json) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)

        [
          %{
            name: data["name"] || full_name,
            version: data["version"] || "0.0.0",
            description: data["description"],
            keywords: data["keywords"] || []
          }
        ]

      _ ->
        []
    end
  rescue
    _ -> []
  end

  defp score_result(pkg_info, query_lower, query_parts) do
    s = compute_score(pkg_info, query_lower, query_parts)
    if s > 0.0, do: [Map.put(pkg_info, :score, s)], else: []
  end

  defp compute_score(pkg_info, query_lower, query_parts) do
    name = String.downcase(pkg_info.name)
    desc = String.downcase(pkg_info.description || "")
    keywords = Enum.map(pkg_info.keywords, &String.downcase/1)

    name_score = name_match_score(name, query_lower)
    keyword_score = if Enum.any?(query_parts, &(&1 in keywords)), do: 0.4, else: 0.0
    desc_score = if String.contains?(desc, query_lower), do: 0.2, else: 0.0

    Enum.max([name_score, keyword_score, desc_score])
  end

  defp name_match_score(name, query) do
    cond do
      name == query -> 1.0
      String.starts_with?(name, query) -> 0.8
      String.contains?(name, query) -> 0.6
      true -> 0.0
    end
  end
end
