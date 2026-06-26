defmodule NPM.Corepack do
  @moduledoc """
  Parses corepack/packageManager field from package.json.

  The `packageManager` field specifies which package manager and version
  to use (e.g., `"npm@10.2.0"`, `"pnpm@8.10.0"`).
  """

  @doc """
  Extracts the packageManager field.
  """
  @spec get(map()) :: String.t() | nil
  def get(%{"packageManager" => pm}) when is_binary(pm), do: pm
  def get(_), do: nil

  @doc """
  Parses the package manager name from the field.
  """
  @spec manager_name(map()) :: String.t() | nil
  def manager_name(data) do
    case get(data) do
      nil -> nil
      pm -> pm |> String.split("@", parts: 2) |> hd()
    end
  end

  @doc """
  Parses the package manager version.
  """
  @spec manager_version(map()) :: String.t() | nil
  def manager_version(data) do
    case get(data) do
      nil ->
        nil

      pm ->
        case String.split(pm, "@", parts: 2) do
          [_, version] -> strip_hash(version)
          _ -> nil
        end
    end
  end

  @doc """
  Checks if the project uses npm.
  """
  @spec npm?(map()) :: boolean()
  def npm?(data), do: manager_name(data) == "npm"

  @doc """
  Checks if the project uses pnpm.
  """
  @spec pnpm?(map()) :: boolean()
  def pnpm?(data), do: manager_name(data) == "pnpm"

  @doc """
  Checks if the project uses yarn.
  """
  @spec yarn?(map()) :: boolean()
  def yarn?(data), do: manager_name(data) == "yarn"

  @doc """
  Checks if corepack is configured.
  """
  @spec configured?(map()) :: boolean()
  def configured?(data), do: get(data) != nil

  @doc """
  Formats for display.
  """
  @spec format(map()) :: String.t()
  def format(data) do
    case get(data) do
      nil -> "No package manager configured"
      pm -> "Package manager: #{pm}"
    end
  end

  defp strip_hash(version) do
    case String.split(version, "+", parts: 2) do
      [ver | _] -> ver
      _ -> version
    end
  end
end
