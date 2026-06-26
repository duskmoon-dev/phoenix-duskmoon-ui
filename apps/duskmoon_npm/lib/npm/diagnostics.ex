defmodule NPM.Diagnostics do
  alias NPM.Config.Npmrc

  @moduledoc """
  Runs diagnostic checks on a project for common npm issues.
  """

  @doc """
  Runs all diagnostic checks.
  """
  @spec run(String.t()) :: [map()]
  def run(project_dir) do
    []
    |> check_package_json(project_dir)
    |> check_lockfile(project_dir)
    |> check_node_modules(project_dir)
    |> check_npmrc(project_dir)
    |> Enum.reverse()
  end

  @doc """
  Formats diagnostic results.
  """
  @spec format([map()]) :: String.t()
  def format([]), do: "All checks passed."

  def format(issues) do
    issues
    |> Enum.map_join("\n", fn issue ->
      icon = if issue.level == :error, do: "✗", else: "!"
      "#{icon} [#{issue.check}] #{issue.message}"
    end)
  end

  @doc """
  Counts issues by level.
  """
  @spec counts([map()]) :: map()
  def counts(issues) do
    %{
      errors: Enum.count(issues, &(&1.level == :error)),
      warnings: Enum.count(issues, &(&1.level == :warning)),
      total: length(issues)
    }
  end

  defp check_package_json(issues, dir) do
    path = Path.join(dir, "package.json")

    if File.exists?(path) do
      issues
    else
      [%{level: :error, check: "package.json", message: "package.json not found"} | issues]
    end
  end

  defp check_lockfile(issues, dir) do
    lock_path = Path.join(dir, "npm.lock")
    pkg_lock_path = Path.join(dir, "package-lock.json")

    cond do
      File.exists?(lock_path) -> issues
      File.exists?(pkg_lock_path) -> issues
      true -> [%{level: :warning, check: "lockfile", message: "No lockfile found"} | issues]
    end
  end

  defp check_node_modules(issues, dir) do
    nm_path = Path.join(dir, "node_modules")

    if File.dir?(nm_path) do
      issues
    else
      [
        %{
          level: :warning,
          check: "node_modules",
          message: "node_modules not found — run npm install"
        }
        | issues
      ]
    end
  end

  defp check_npmrc(issues, dir) do
    npmrc_path = Path.join(dir, ".npmrc")

    case File.exists?(npmrc_path) && Npmrc.read(npmrc_path) do
      {:ok, config} -> check_npmrc_auth(issues, config)
      _ -> issues
    end
  end

  defp check_npmrc_auth(issues, config) do
    if Npmrc.has_auth?(config) do
      [
        %{
          level: :warning,
          check: "npmrc",
          message: ".npmrc contains auth tokens — ensure it's gitignored"
        }
        | issues
      ]
    else
      issues
    end
  end
end
