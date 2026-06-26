defmodule Mix.Tasks.Npm.Exec do
  alias NPM.Node.Exec
  alias NPM.Node.Runner

  @shortdoc "Execute a package binary"

  @moduledoc """
  Execute a binary from `node_modules/.bin/`.

      mix npm.exec eslint .
      mix npm.exec tsc --version

  Similar to `npx` but only runs locally installed binaries.
  """

  use Mix.Task

  @impl true
  def run([command | args]) do
    Application.ensure_all_started(:req)

    case Exec.which(command, "node_modules") do
      {:ok, bin_path} ->
        execute(bin_path, args)

      {:error, :not_found} ->
        Mix.shell().error("Binary #{command} not found in node_modules/.bin/")
        Mix.shell().info("Run `mix npm.install` to install packages.")
    end
  end

  def run([]) do
    bin_dir = "node_modules/.bin"

    if File.exists?(bin_dir) do
      case File.ls(bin_dir) do
        {:ok, entries} ->
          Mix.shell().info("Available binaries:")
          Enum.each(Enum.sort(entries), &Mix.shell().info("  #{&1}"))

        {:error, _} ->
          Mix.shell().info("No binaries found.")
      end
    else
      Mix.shell().info("No node_modules/.bin/ directory. Run `mix npm.install` first.")
    end
  end

  defp execute(bin_path, args) do
    {output, status} =
      Runner.run(Path.expand(bin_path), args,
        node_modules_dir: "node_modules",
        cd: File.cwd!()
      )

    if output != "", do: IO.write(output)

    case status do
      0 ->
        :ok

      code ->
        Mix.shell().error("Exited with code #{code}")
        exit({:shutdown, code})
    end
  end
end
