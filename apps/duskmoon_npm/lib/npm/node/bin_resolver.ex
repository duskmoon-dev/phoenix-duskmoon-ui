defmodule NPM.Node.BinResolver do
  @moduledoc """
  Resolve executable binaries from `node_modules/.bin/`.

  Provides lookup and listing of available npm binaries,
  matching the behavior of `npx` and `npm exec`.
  """

  @doc """
  List all available binaries in `node_modules/.bin/`.

  Returns a sorted list of `{command_name, target_path}` tuples.
  """
  @spec list(String.t()) :: [{String.t(), String.t()}]
  def list(node_modules_dir \\ "node_modules") do
    bin_dir = Path.join(node_modules_dir, ".bin")

    case File.ls(bin_dir) do
      {:ok, entries} ->
        entries
        |> Enum.map(fn name -> {name, resolve_target(bin_dir, name)} end)
        |> Enum.sort()

      {:error, _} ->
        []
    end
  end

  @doc """
  Find the path to a specific binary command.

  Returns `{:ok, path}` if found, `:error` if not.
  """
  @spec find(String.t(), String.t()) :: {:ok, String.t()} | :error
  def find(command, node_modules_dir \\ "node_modules") do
    path = Path.join([node_modules_dir, ".bin", command])

    if File.exists?(path) do
      {:ok, resolve_target(Path.join(node_modules_dir, ".bin"), command)}
    else
      :error
    end
  end

  @doc """
  Check if a binary command is available.
  """
  @spec available?(String.t(), String.t()) :: boolean()
  def available?(command, node_modules_dir \\ "node_modules") do
    Path.join([node_modules_dir, ".bin", command]) |> File.exists?()
  end

  defp resolve_target(bin_dir, name) do
    link = Path.join(bin_dir, name)

    case File.read_link(link) do
      {:ok, target} -> Path.expand(target, bin_dir)
      {:error, _} -> link
    end
  end
end
