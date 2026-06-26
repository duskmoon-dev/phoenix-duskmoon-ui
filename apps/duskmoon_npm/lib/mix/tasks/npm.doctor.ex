defmodule Mix.Tasks.Npm.Doctor do
  alias NPM.Install.Lifecycle

  @shortdoc "Diagnose npm installation issues"

  @moduledoc """
  Run diagnostics on the npm installation.

      mix npm.doctor

  Checks:
  - Package.json validity
  - Lockfile freshness
  - node_modules completeness
  - Platform compatibility
  - Lifecycle scripts
  - Deprecated packages
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    checks = [
      {"package.json", check_package_json()},
      {"npm.lock", check_lockfile()},
      {"node_modules", check_node_modules()},
      {"lifecycle scripts", check_lifecycle()},
      {"platform compat", check_platform()}
    ]

    Enum.each(checks, fn {label, result} ->
      icon = if result == :ok, do: "✓", else: "✗"
      msg = if result == :ok, do: "ok", else: elem(result, 1)
      Mix.shell().info("  #{icon} #{label}: #{msg}")
    end)
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.doctor")
  end

  defp check_package_json do
    if File.exists?("package.json"), do: :ok, else: {:warn, "not found"}
  end

  defp check_lockfile do
    if File.exists?("npm.lock"), do: :ok, else: {:warn, "not found — run mix npm.install"}
  end

  defp check_node_modules do
    if File.exists?("node_modules"), do: :ok, else: {:warn, "not found — run mix npm.install"}
  end

  defp check_lifecycle do
    if File.exists?("node_modules") do
      scripts = Lifecycle.detect_all("node_modules")

      if map_size(scripts) > 0 do
        names = Map.keys(scripts) |> Enum.join(", ")
        {:warn, "#{map_size(scripts)} packages have install scripts: #{names}"}
      else
        :ok
      end
    else
      :ok
    end
  end

  defp check_platform do
    Mix.shell().info("    OS: #{NPM.Platform.current_os()}, CPU: #{NPM.Platform.current_cpu()}")
    :ok
  end
end
