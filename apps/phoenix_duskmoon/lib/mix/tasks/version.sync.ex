defmodule Mix.Tasks.Version.Sync do
  @moduledoc """
  Syncs version numbers across all project files.

  This task reads the version from apps/phoenix_duskmoon/mix.exs and updates:
  - apps/phoenix_duskmoon/package.json
  - mix.exs (umbrella)

  ## Usage

      mix version.sync

  ## When to use

  - After pulling changes from main branch
  - When version numbers appear out of sync
  - Before creating a local build for testing

  ## Note

  Versions are automatically managed by semantic-release in CI.
  This task is primarily for local development synchronization.
  """

  use Mix.Task

  @shortdoc "Syncs version numbers across all project files"

  @impl Mix.Task
  def run(_args) do
    # Ensure we're in the umbrella root
    # Mix tasks run from the project root already, so we should be fine
    # But let's ensure we can find the files

    phoenix_duskmoon_mix_path =
      if File.exists?("apps/phoenix_duskmoon/mix.exs") do
        "apps/phoenix_duskmoon/mix.exs"
      else
        # We're in a child app, go up to umbrella
        "../../phoenix_duskmoon/mix.exs"
      end

    # Read version from phoenix_duskmoon mix.exs
    phoenix_duskmoon_mix = File.read!(phoenix_duskmoon_mix_path)

    version =
      case Regex.run(~r/@version "([0-9]+\.[0-9]+\.[0-9]+)"/, phoenix_duskmoon_mix) do
        [_, version] ->
          version

        nil ->
          Mix.raise("Could not find version in apps/phoenix_duskmoon/mix.exs")
      end

    Mix.shell().info("Found version: #{version}")

    # Update package.json
    update_package_json(version)

    # Update umbrella mix.exs
    update_umbrella_mix(version)

    Mix.shell().info([:green, "✓ All version files synchronized to #{version}"])
  end

  defp update_package_json(version) do
    package_json_path =
      if File.exists?("apps/phoenix_duskmoon/package.json") do
        "apps/phoenix_duskmoon/package.json"
      else
        "package.json"
      end

    content = File.read!(package_json_path)

    updated_content =
      Regex.replace(
        ~r/"version": "[0-9]+\.[0-9]+\.[0-9]+"/,
        content,
        "\"version\": \"#{version}\""
      )

    if content != updated_content do
      File.write!(package_json_path, updated_content)
      Mix.shell().info("  Updated #{package_json_path}")
    else
      Mix.shell().info("  #{package_json_path} already at #{version}")
    end
  end

  defp update_umbrella_mix(version) do
    umbrella_mix_path =
      if File.exists?("mix.exs") and
           not String.contains?(File.read!("mix.exs"), "PhoenixDuskmoon.Mixfile") do
        "mix.exs"
      else
        "../../mix.exs"
      end

    content = File.read!(umbrella_mix_path)

    updated_content =
      Regex.replace(
        ~r/@version "[0-9]+\.[0-9]+\.[0-9]+"/,
        content,
        "@version \"#{version}\""
      )

    if content != updated_content do
      File.write!(umbrella_mix_path, updated_content)
      Mix.shell().info("  Updated #{umbrella_mix_path}")
    else
      Mix.shell().info("  #{umbrella_mix_path} already at #{version}")
    end
  end
end
