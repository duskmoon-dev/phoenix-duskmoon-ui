defmodule NPM.Compiler do
  @moduledoc """
  Mix compiler that ensures npm packages are installed.

  Add to your project's compilers list to automatically install
  npm dependencies during `mix compile`:

      def project do
        [
          compilers: [:npm | Mix.compilers()],
          ...
        ]
      end

  Checks if `npm.lock` exists and `node_modules/` is populated.
  Only runs the full install if needed.
  """

  use Mix.Task.Compiler

  @impl true
  def run(_argv) do
    if needs_install?() do
      case NPM.install() do
        :ok -> {:ok, []}
        {:error, _reason} -> {:error, []}
      end
    else
      {:noop, []}
    end
  end

  defp needs_install? do
    File.exists?("package.json") and
      (not File.exists?("npm.lock") or not File.exists?("node_modules"))
  end
end
