defmodule NPM.Import do
  @moduledoc """
  Imports lockfiles from other package managers.

  Converts yarn.lock, pnpm-lock.yaml, and legacy npm.lock metadata into npm_ex format
  for migration from other tools.
  """

  @doc """
  Detects which package manager lockfiles exist in the project.
  """
  @spec detect(String.t()) :: [atom()]
  def detect(project_dir \\ ".") do
    checks = [
      {:npm_ex, "package-lock.json"},
      {:yarn, "yarn.lock"},
      {:pnpm, "pnpm-lock.yaml"},
      {:bun, "bun.lockb"},
      {:npm_ex_legacy, "npm.lock"}
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
  Checks if migration is needed (other lockfile exists but no package-lock.json).
  """
  @spec migration_needed?(String.t()) :: boolean()
  def migration_needed?(project_dir \\ ".") do
    managers = detect(project_dir)
    :npm_ex not in managers and managers != []
  end

  @doc """
  Returns the primary package manager detected.
  """
  @spec primary_manager(String.t()) :: atom() | nil
  def primary_manager(project_dir \\ ".") do
    detect(project_dir) |> List.first()
  end

  defp extract_npm_lock_packages(%{"packages" => packages} = data) when is_map(packages) do
    extract_lockfile_packages(data)
  end

  defp extract_npm_lock_packages(%{"dependencies" => deps} = data) when is_map(deps) do
    extract_lockfile_packages(data)
  end

  defp extract_npm_lock_packages(_), do: %{}

  defp extract_lockfile_packages(data) do
    data
    |> NPM.Lockfile.parse()
    |> Map.new(fn {name, entry} ->
      {name,
       %{
         version: entry.version || "",
         integrity: entry.integrity || "",
         resolved: entry.tarball || "",
         dependencies: entry.dependencies || %{}
       }}
    end)
  end
end
