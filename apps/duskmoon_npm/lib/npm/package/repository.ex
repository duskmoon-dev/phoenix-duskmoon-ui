defmodule NPM.Package.Repository do
  @moduledoc """
  Repository field parsing and URL generation from package.json.
  """

  @doc """
  Extracts repository info from package.json data.
  """
  @spec extract(map()) :: map() | nil
  def extract(%{"repository" => %{"type" => type, "url" => url} = repo}) do
    %{
      type: type,
      url: clean_url(url),
      directory: repo["directory"]
    }
  end

  def extract(%{"repository" => url}) when is_binary(url) do
    %{type: "git", url: resolve_shorthand(url), directory: nil}
  end

  def extract(_), do: nil

  @doc """
  Returns the browse URL (human-readable web URL).
  """
  @spec browse_url(map()) :: String.t() | nil
  def browse_url(data) do
    case extract(data) do
      nil -> nil
      %{url: url, directory: nil} -> url
      %{url: url, directory: dir} -> "#{url}/tree/HEAD/#{dir}"
    end
  end

  @doc """
  Returns the HTTPS clone URL.
  """
  @spec clone_url(map()) :: String.t() | nil
  def clone_url(data) do
    case extract(data) do
      nil -> nil
      %{url: url} -> ensure_git_suffix(url)
    end
  end

  @doc """
  Detects the hosting provider.
  """
  @spec provider(map()) :: atom() | nil
  def provider(data) do
    case extract(data) do
      nil ->
        nil

      %{url: url} ->
        cond do
          String.contains?(url, "github.com") -> :github
          String.contains?(url, "gitlab.com") -> :gitlab
          String.contains?(url, "bitbucket.org") -> :bitbucket
          true -> :other
        end
    end
  end

  @doc """
  Checks if repository info is present.
  """
  @spec has_repository?(map()) :: boolean()
  def has_repository?(data), do: extract(data) != nil

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

      String.contains?(str, "/") and not String.starts_with?(str, ".") ->
        "https://github.com/#{str}"

      true ->
        str
    end
  end

  defp ensure_git_suffix(url) do
    if String.ends_with?(url, ".git"), do: url, else: "#{url}.git"
  end
end
