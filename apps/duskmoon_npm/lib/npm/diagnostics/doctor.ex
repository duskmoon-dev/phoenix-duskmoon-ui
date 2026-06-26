defmodule NPM.Diagnostics.Doctor do
  @moduledoc """
  Health check for the npm installation.

  Validates the project's npm setup by checking for common issues:
  missing files, stale lockfiles, broken symlinks, etc.
  """

  @type check_result :: %{
          name: String.t(),
          status: :ok | :warn | :error,
          message: String.t()
        }

  @doc """
  Runs all health checks and returns results.
  """
  @spec diagnose(String.t()) :: [check_result()]
  def diagnose(project_dir \\ ".") do
    [
      check_package_json(project_dir),
      check_lockfile(project_dir),
      check_node_modules(project_dir),
      check_lockfile_sync(project_dir),
      check_git_ignored(project_dir)
    ]
  end

  @doc """
  Returns true if all checks pass (no errors).
  """
  @spec healthy?(String.t()) :: boolean()
  def healthy?(project_dir \\ ".") do
    project_dir |> diagnose() |> Enum.all?(&(&1.status != :error))
  end

  @doc """
  Formats check results for display.
  """
  @spec format_results([check_result()]) :: String.t()
  def format_results(results) do
    Enum.map_join(results, "\n", &format_result/1)
  end

  @doc """
  Returns a summary of check results.
  """
  @spec summary([check_result()]) :: %{
          ok: non_neg_integer(),
          warn: non_neg_integer(),
          error: non_neg_integer()
        }
  def summary(results) do
    %{
      ok: Enum.count(results, &(&1.status == :ok)),
      warn: Enum.count(results, &(&1.status == :warn)),
      error: Enum.count(results, &(&1.status == :error))
    }
  end

  defp check_package_json(dir) do
    path = Path.join(dir, "package.json")

    if File.exists?(path) do
      %{name: "package.json", status: :ok, message: "Found"}
    else
      %{name: "package.json", status: :error, message: "Missing package.json"}
    end
  end

  defp check_lockfile(dir) do
    path = Path.join(dir, "npm.lock")

    if File.exists?(path) do
      %{name: "lockfile", status: :ok, message: "npm.lock found"}
    else
      %{name: "lockfile", status: :warn, message: "No npm.lock — run mix npm.install"}
    end
  end

  defp check_node_modules(dir) do
    path = Path.join(dir, "node_modules")

    cond do
      not File.exists?(path) ->
        %{name: "node_modules", status: :warn, message: "Not installed — run mix npm.install"}

      not File.dir?(path) ->
        %{
          name: "node_modules",
          status: :error,
          message: "node_modules exists but is not a directory"
        }

      true ->
        %{name: "node_modules", status: :ok, message: "Installed"}
    end
  end

  defp check_lockfile_sync(dir) do
    pkg_path = Path.join(dir, "package.json")
    lock_path = Path.join(dir, "npm.lock")

    with {:ok, _pkg_content} <- File.read(pkg_path),
         {:ok, _lock_content} <- File.read(lock_path) do
      %{name: "lockfile_sync", status: :ok, message: "Lockfile present"}
    else
      _ ->
        %{name: "lockfile_sync", status: :warn, message: "Cannot verify lockfile sync"}
    end
  end

  defp check_git_ignored(dir) do
    gitignore = Path.join(dir, ".gitignore")

    case File.read(gitignore) do
      {:ok, content} ->
        if String.contains?(content, "node_modules") do
          %{name: "gitignore", status: :ok, message: "node_modules is git-ignored"}
        else
          %{name: "gitignore", status: :warn, message: "node_modules not in .gitignore"}
        end

      _ ->
        %{name: "gitignore", status: :warn, message: "No .gitignore found"}
    end
  end

  defp format_result(%{status: :ok} = r), do: "✓ #{r.name}: #{r.message}"
  defp format_result(%{status: :warn} = r), do: "⚠ #{r.name}: #{r.message}"
  defp format_result(%{status: :error} = r), do: "✗ #{r.name}: #{r.message}"
end
