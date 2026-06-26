defmodule Mix.Tasks.Npm.Run do
  alias NPM.Package.JSON

  @shortdoc "Run an npm script"

  @moduledoc """
  Run a script defined in `package.json`.

      mix npm.run build
      mix npm.run test
      mix npm.run              # List available scripts

  Scripts are executed with `node_modules/.bin` prepended to `PATH`.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)
    list_scripts()
  end

  def run([script_name | extra_args]) do
    Application.ensure_all_started(:req)
    run_script(script_name, extra_args)
  end

  defp list_scripts do
    case JSON.read_scripts() do
      {:ok, scripts} when scripts == %{} ->
        Mix.shell().info("No scripts found in package.json.")

      {:ok, scripts} ->
        Mix.shell().info("Available scripts:")

        Enum.each(Enum.sort(scripts), fn {name, command} ->
          Mix.shell().info("  #{name}: #{command}")
        end)

      {:error, reason} ->
        Mix.shell().error("Failed to read package.json: #{inspect(reason)}")
    end
  end

  defp run_script(name, extra_args) do
    case JSON.read_scripts() do
      {:ok, scripts} ->
        case Map.fetch(scripts, name) do
          {:ok, command} ->
            execute(command, extra_args)

          :error ->
            Mix.shell().error("Script \"#{name}\" not found in package.json.")
            Mix.shell().info("Available: #{scripts |> Map.keys() |> Enum.join(", ")}")
        end

      {:error, reason} ->
        Mix.shell().error("Failed to read package.json: #{inspect(reason)}")
    end
  end

  defp execute(command, extra_args) do
    full_command =
      case extra_args do
        [] -> command
        args -> command <> " " <> Enum.join(args, " ")
      end

    bin_path = Path.join(File.cwd!(), "node_modules/.bin")
    current_path = System.get_env("PATH", "")
    env = [{"PATH", "#{bin_path}:#{current_path}"}]

    port =
      Port.open({:spawn, full_command}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        env: Enum.map(env, fn {k, v} -> {~c"#{k}", ~c"#{v}"} end)
      ])

    stream_port(port)
  end

  defp stream_port(port) do
    receive do
      {^port, {:data, data}} ->
        IO.write(data)
        stream_port(port)

      {^port, {:exit_status, 0}} ->
        :ok

      {^port, {:exit_status, code}} ->
        Mix.shell().error("Script exited with code #{code}")
        exit({:shutdown, code})
    end
  end
end
