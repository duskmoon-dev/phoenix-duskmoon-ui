defmodule Mix.Tasks.Npm.Shrinkwrap do
  @shortdoc "Create npm-shrinkwrap.json from lockfile"

  @moduledoc """
  Create an `npm-shrinkwrap.json` from the current `npm.lock`.

      mix npm.shrinkwrap

  The shrinkwrap file locks exact versions for publishing. Unlike
  `npm.lock` (which is project-only), `npm-shrinkwrap.json` is
  included when the package is published to the registry.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().error("No npm.lock found. Run `mix npm.install` first.")

      {:ok, lockfile} ->
        shrinkwrap = build_shrinkwrap(lockfile)
        content = NPM.JSON.encode_pretty(shrinkwrap)
        File.write!("npm-shrinkwrap.json", content)
        Mix.shell().info("Created npm-shrinkwrap.json (#{map_size(lockfile)} packages)")

      {:error, reason} ->
        Mix.shell().error("Failed to read lockfile: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.shrinkwrap")
  end

  defp build_shrinkwrap(lockfile) do
    deps =
      Map.new(lockfile, fn {name, entry} ->
        {name,
         %{
           "version" => entry.version,
           "integrity" => entry.integrity,
           "resolved" => entry.tarball
         }}
      end)

    %{
      "lockfileVersion" => 1,
      "dependencies" => deps
    }
  end
end
