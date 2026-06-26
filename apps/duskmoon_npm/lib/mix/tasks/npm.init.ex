defmodule Mix.Tasks.Npm.Init do
  @shortdoc "Create a package.json"

  @moduledoc """
  Create a new `package.json` in the current directory.

      mix npm.init

  Creates a minimal `package.json` with the project name from `mix.exs`.
  Skips if `package.json` already exists.
  """

  use Mix.Task

  @impl true
  def run([]) do
    if File.exists?("package.json") do
      Mix.shell().info("package.json already exists.")
    else
      name = project_name()
      create_package_json(name)
      Mix.shell().info("Created package.json")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.init")
  end

  defp project_name do
    config = Mix.Project.config()
    to_string(config[:app])
  end

  defp create_package_json(name) do
    data = %{
      "name" => name,
      "version" => "1.0.0",
      "private" => true,
      "dependencies" => %{},
      "devDependencies" => %{}
    }

    File.write!("package.json", NPM.JSON.encode_pretty(data))
  end
end
