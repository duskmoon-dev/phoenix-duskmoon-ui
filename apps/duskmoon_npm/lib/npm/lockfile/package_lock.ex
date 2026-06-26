defmodule NPM.Lockfile.PackageLock do
  @moduledoc """
  Reads and analyzes npm's package-lock.json format.

  Supports lockfileVersion 1, 2, and 3 for compatibility
  with projects migrating from npm.
  """

  @doc """
  Reads a package-lock.json file.
  """
  @spec read(String.t()) :: {:ok, map()} | {:error, term()}
  def read(path) do
    case File.read(path) do
      {:ok, content} -> {:ok, NPM.JSON.decode!(content)}
      error -> error
    end
  rescue
    e -> {:error, e}
  end

  @doc """
  Detects the lockfile version.
  """
  @spec version(map()) :: 1 | 2 | 3 | nil
  def version(%{"lockfileVersion" => v}) when v in [1, 2, 3], do: v
  def version(_), do: nil

  @doc """
  Counts the total number of packages in the lockfile.
  """
  @spec package_count(map()) :: non_neg_integer()
  def package_count(%{"packages" => packages}) when is_map(packages) do
    packages
    |> Map.keys()
    |> Enum.reject(&(&1 == ""))
    |> length()
  end

  def package_count(%{"dependencies" => deps}) when is_map(deps), do: map_size(deps)
  def package_count(_), do: 0

  @doc """
  Extracts package names and versions.
  """
  @spec packages(map()) :: %{String.t() => String.t()}
  def packages(%{"packages" => pkgs}) when is_map(pkgs) do
    pkgs
    |> Enum.reject(fn {key, _} -> key == "" end)
    |> Map.new(fn {path, info} ->
      name = path |> String.replace("node_modules/", "")
      {name, info["version"] || ""}
    end)
  end

  def packages(%{"dependencies" => deps}) when is_map(deps) do
    Map.new(deps, fn {name, info} -> {name, info["version"] || ""} end)
  end

  def packages(_), do: %{}

  @doc """
  Checks if the lockfile requires npm 7+ (v2/v3 format).
  """
  @spec requires_npm7?(map()) :: boolean()
  def requires_npm7?(data), do: version(data) in [2, 3]

  @doc """
  Returns metadata about the lockfile.
  """
  @spec metadata(map()) :: map()
  def metadata(data) do
    %{
      version: version(data),
      package_count: package_count(data),
      name: data["name"],
      lock_version: data["lockfileVersion"],
      requires_npm7: requires_npm7?(data)
    }
  end
end
