defmodule NPM.Import do
  @moduledoc """
  Imports lockfiles from other package managers.

  Converts yarn.lock, pnpm-lock.yaml metadata into npm_ex format
  for migration from other tools.
  """

  @doc """
  Detects which package manager lockfiles exist in the project.
  """
  @spec detect(String.t()) :: [atom()]
  def detect(project_dir \\ ".") do
    checks = [
      {:npm, "package-lock.json"},
      {:yarn, "yarn.lock"},
      {:pnpm, "pnpm-lock.yaml"},
      {:bun, "bun.lockb"},
      {:npm_ex, "npm.lock"}
    ]

    Enum.filter(checks, fn {_manager, file} ->
      File.exists?(Path.join(project_dir, file))
    end)
    |> Enum.map(fn {manager, _file} -> manager end)
  end

  @doc """
  Reads dependencies from a package-lock.json file.
  """
  @spec from_package_lock(String.t()) :: {:ok, map()} | {:error, term()}
  def from_package_lock(path) do
    case File.read(path) do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        packages = extract_npm_lock_packages(data)
        {:ok, packages}

      error ->
        error
    end
  end

  @doc """
  Checks if migration is needed (other lockfile exists but no npm.lock).
  """
  @spec migration_needed?(String.t()) :: boolean()
  def migration_needed?(project_dir \\ ".") do
    managers = detect(project_dir)
    other_exists = Enum.any?(managers, &(&1 != :npm_ex))
    no_npm_ex = :npm_ex not in managers
    other_exists and no_npm_ex
  end

  @doc """
  Returns the primary package manager detected.
  """
  @spec primary_manager(String.t()) :: atom() | nil
  def primary_manager(project_dir \\ ".") do
    detect(project_dir) |> List.first()
  end

  defp extract_npm_lock_packages(%{"packages" => packages}) when is_map(packages) do
    packages
    |> Enum.reject(fn {key, _} -> key == "" end)
    |> Enum.flat_map(fn {path, info} ->
      name = path |> String.replace("node_modules/", "")

      if String.contains?(name, "node_modules/") do
        []
      else
        [
          {name,
           %{
             version: info["version"] || "",
             integrity: info["integrity"] || "",
             resolved: info["resolved"] || "",
             dependencies: info["dependencies"] || %{}
           }}
        ]
      end
    end)
    |> Map.new()
  end

  defp extract_npm_lock_packages(%{"dependencies" => deps}) when is_map(deps) do
    Map.new(deps, fn {name, info} ->
      {name,
       %{
         version: info["version"] || "",
         integrity: info["integrity"] || "",
         resolved: info["resolved"] || "",
         dependencies: info["requires"] || %{}
       }}
    end)
  end

  defp extract_npm_lock_packages(_), do: %{}
end
