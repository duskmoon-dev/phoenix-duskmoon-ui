defmodule Mix.Tasks.Npm.Set do
  @shortdoc "Set npm config values"

  @moduledoc """
  Set a configuration value in `.npmrc`.

      mix npm.set registry https://registry.example.com
      mix npm.set save-exact true
      mix npm.set always-auth true

  Values are written to the project-level `.npmrc` file.
  """

  use Mix.Task

  @impl true
  def run([key, value]) do
    path = ".npmrc"

    existing =
      case File.read(path) do
        {:ok, content} -> NPM.Config.parse_npmrc(content)
        {:error, :enoent} -> %{}
      end

    updated = Map.put(existing, key, value)

    content =
      updated
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join("\n", fn {k, v} -> "#{k}=#{v}" end)

    File.write!(path, content <> "\n")
    Mix.shell().info("Set #{key}=#{value} in .npmrc")
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.set <key> <value>")
  end
end
