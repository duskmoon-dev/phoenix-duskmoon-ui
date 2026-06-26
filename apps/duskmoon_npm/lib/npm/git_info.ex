defmodule NPM.GitInfo do
  @moduledoc """
  Extracts git metadata for npm packages.

  Reads repository, bugs, and homepage URLs from package.json
  and generates common URLs (issues, PRs, compare, etc.).
  """

  @doc """
  Extracts git repository URL from package data.
  """
  @spec repo_url(map()) :: String.t() | nil
  def repo_url(%{"repository" => %{"url" => url}}), do: clean_url(url)
  def repo_url(%{"repository" => url}) when is_binary(url), do: resolve_shorthand(url)
  def repo_url(_), do: nil

  @doc """
  Returns the issues URL for a package.
  """
  @spec issues_url(map()) :: String.t() | nil
  def issues_url(%{"bugs" => %{"url" => url}}), do: url
  def issues_url(%{"bugs" => url}) when is_binary(url), do: url

  def issues_url(data) do
    case github_base(data) do
      nil -> nil
      base -> "#{base}/issues"
    end
  end

  @doc """
  Returns the homepage URL.
  """
  @spec homepage(map()) :: String.t() | nil
  def homepage(%{"homepage" => url}) when is_binary(url), do: url
  def homepage(data), do: github_base(data)

  @doc """
  Generates a compare URL for two versions.
  """
  @spec compare_url(map(), String.t(), String.t()) :: String.t() | nil
  def compare_url(data, from_version, to_version) do
    case github_base(data) do
      nil -> nil
      base -> "#{base}/compare/v#{from_version}...v#{to_version}"
    end
  end

  @doc """
  Extracts the GitHub user/repo from package data.
  """
  @spec github_repo(map()) :: String.t() | nil
  def github_repo(data) do
    case repo_url(data) do
      nil -> nil
      url -> extract_github_path(url)
    end
  end

  @doc """
  Checks if the package is hosted on GitHub.
  """
  @spec github?(map()) :: boolean()
  def github?(data) do
    case repo_url(data) do
      nil -> false
      url -> String.contains?(url, "github.com")
    end
  end

  defp github_base(data) do
    case github_repo(data) do
      nil -> nil
      path -> "https://github.com/#{path}"
    end
  end

  defp clean_url(url) do
    url
    |> String.replace(~r/^git\+/, "")
    |> String.replace(~r/\.git$/, "")
    |> String.replace("git://", "https://")
    |> String.replace("ssh://git@", "https://")
  end

  defp resolve_shorthand(str) do
    cond do
      String.starts_with?(str, "github:") ->
        "https://github.com/#{String.trim_leading(str, "github:")}"

      String.contains?(str, "://") ->
        clean_url(str)

      String.contains?(str, "/") ->
        "https://github.com/#{str}"

      true ->
        str
    end
  end

  defp extract_github_path(url) do
    case Regex.run(~r{github\.com[/:]([^/]+/[^/.\s]+)}, url) do
      [_, path] -> path
      _ -> nil
    end
  end
end
