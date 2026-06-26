defmodule NPM.Normalize do
  @moduledoc """
  Normalizes package.json data.

  Applies npm's normalization rules: defaulting main, normalizing
  repository URLs, handling people fields, etc.
  """

  @doc """
  Normalizes a package.json data map.
  """
  @spec normalize(map()) :: map()
  def normalize(data) do
    data
    |> normalize_main()
    |> normalize_repository()
    |> normalize_bugs()
    |> normalize_homepage()
    |> normalize_people()
  end

  @doc """
  Normalizes the `main` field. Defaults to `index.js` if missing.
  """
  @spec normalize_main(map()) :: map()
  def normalize_main(%{"main" => _} = data), do: data
  def normalize_main(data), do: Map.put(data, "main", "index.js")

  @doc """
  Normalizes the `repository` field.

  Converts shorthand strings like `"github:user/repo"` to full objects.
  """
  @spec normalize_repository(map()) :: map()
  def normalize_repository(%{"repository" => repo} = data) when is_binary(repo) do
    Map.put(data, "repository", parse_repo_shorthand(repo))
  end

  def normalize_repository(data), do: data

  @doc """
  Normalizes the `bugs` field from a string URL.
  """
  @spec normalize_bugs(map()) :: map()
  def normalize_bugs(%{"bugs" => url} = data) when is_binary(url) do
    Map.put(data, "bugs", %{"url" => url})
  end

  def normalize_bugs(data), do: data

  @doc """
  Normalizes the `homepage` field — removes trailing slash.
  """
  @spec normalize_homepage(map()) :: map()
  def normalize_homepage(%{"homepage" => url} = data) when is_binary(url) do
    Map.put(data, "homepage", String.trim_trailing(url, "/"))
  end

  def normalize_homepage(data), do: data

  @doc """
  Normalizes people fields (author, maintainers, contributors).

  Converts shorthand `"Name <email>"` strings to objects.
  """
  @spec normalize_people(map()) :: map()
  def normalize_people(data) do
    data
    |> normalize_person("author")
    |> normalize_person_list("contributors")
    |> normalize_person_list("maintainers")
  end

  @doc """
  Parses a person string like `"Name <email> (url)"` into a map.
  """
  @spec parse_person(String.t()) :: map()
  def parse_person(str) when is_binary(str) do
    {name, rest} = extract_name(str)
    {email, rest2} = extract_angle_bracket(rest)
    {url, _} = extract_paren(rest2)

    result = %{"name" => String.trim(name)}
    result = if email, do: Map.put(result, "email", email), else: result
    if url, do: Map.put(result, "url", url), else: result
  end

  def parse_person(data) when is_map(data), do: data

  defp normalize_person(data, field) do
    case data[field] do
      str when is_binary(str) -> Map.put(data, field, parse_person(str))
      _ -> data
    end
  end

  defp normalize_person_list(data, field) do
    case data[field] do
      list when is_list(list) -> Map.put(data, field, Enum.map(list, &parse_person/1))
      _ -> data
    end
  end

  defp parse_repo_shorthand(str) do
    cond do
      String.starts_with?(str, "github:") ->
        %{"type" => "git", "url" => "https://github.com/#{String.trim_leading(str, "github:")}"}

      String.starts_with?(str, "gitlab:") ->
        %{"type" => "git", "url" => "https://gitlab.com/#{String.trim_leading(str, "gitlab:")}"}

      String.starts_with?(str, "bitbucket:") ->
        %{
          "type" => "git",
          "url" => "https://bitbucket.org/#{String.trim_leading(str, "bitbucket:")}"
        }

      String.contains?(str, "/") and not String.contains?(str, "://") ->
        %{"type" => "git", "url" => "https://github.com/#{str}"}

      true ->
        %{"type" => "git", "url" => str}
    end
  end

  defp extract_name(str) do
    case Regex.run(~r/^([^<(]+)/, str) do
      [_, name] -> {name, String.trim_leading(str, name)}
      _ -> {str, ""}
    end
  end

  defp extract_angle_bracket(str) do
    case Regex.run(~r/<([^>]+)>/, str) do
      [full, val] -> {val, String.trim_leading(str, full)}
      _ -> {nil, str}
    end
  end

  defp extract_paren(str) do
    case Regex.run(~r/\(([^)]+)\)/, str) do
      [full, val] -> {val, String.trim_leading(str, full)}
      _ -> {nil, str}
    end
  end
end
