defmodule Mix.Tasks.Npm.Check do
  alias NPM.Package.JSON

  @shortdoc "Verify npm installation state"

  @moduledoc """
  Verify that the npm installation is consistent.

      mix npm.check

  Checks:
  - `package.json` exists and is valid
  - `package-lock.json` exists and matches `package.json`
  - `node_modules/` is populated
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    checks = [
      check_package_json(),
      check_lockfile(),
      check_node_modules()
    ]

    errors = Enum.filter(checks, &match?({:error, _}, &1))

    if errors == [] do
      Mix.shell().info("All checks passed.")
    else
      Enum.each(errors, fn {:error, msg} ->
        Mix.shell().error("✗ #{msg}")
      end)
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.check")
  end

  defp check_package_json do
    if File.exists?("package.json") do
      case JSON.read() do
        {:ok, _} -> :ok
        {:error, reason} -> {:error, "package.json is invalid: #{inspect(reason)}"}
      end
    else
      {:error, "package.json not found"}
    end
  end

  defp check_lockfile do
    if File.exists?(NPM.Lockfile.default_path()) do
      case NPM.Lockfile.read() do
        {:ok, lockfile} when lockfile == %{} -> {:error, "package-lock.json is empty"}
        {:ok, _} -> :ok
        {:error, reason} -> {:error, "package-lock.json is invalid: #{inspect(reason)}"}
      end
    else
      if File.exists?(NPM.Lockfile.legacy_path()) do
        :ok
      else
        {:error, "package-lock.json not found — run `mix npm.install`"}
      end
    end
  end

  defp check_node_modules do
    if File.exists?("node_modules") do
      case File.ls("node_modules") do
        {:ok, []} -> {:error, "node_modules/ is empty"}
        {:ok, _} -> :ok
        {:error, reason} -> {:error, "Cannot read node_modules/: #{inspect(reason)}"}
      end
    else
      {:error, "node_modules/ not found — run `mix npm.install`"}
    end
  end
end
