defmodule Mix.Tasks.Npm.Pack do
  @shortdoc "Create a tarball"

  @moduledoc """
  Create a tarball of the current package.

      mix npm.pack

  Creates a `.tgz` file from the project's `package.json`,
  including all files that would be published.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case File.read("package.json") do
      {:ok, content} ->
        data = NPM.JSON.decode!(content)
        pack(data)

      {:error, :enoent} ->
        Mix.shell().error("No package.json found.")

      {:error, reason} ->
        Mix.shell().error("Failed to read package.json: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.pack")
  end

  defp pack(data) do
    name = Map.get(data, "name", "package") |> String.replace("/", "-")
    version = Map.get(data, "version", "0.0.0")
    files = collect_files(data)
    tarball_name = "#{name}-#{version}.tgz"

    entries =
      Enum.map(files, fn file ->
        {~c"package/#{file}", ~c"#{file}"}
      end)

    case :erl_tar.create(~c"#{tarball_name}", entries, [:compressed]) do
      :ok ->
        stat = File.stat!(tarball_name)
        Mix.shell().info("Created #{tarball_name} (#{format_size(stat.size)})")

      {:error, reason} ->
        Mix.shell().error("Failed to create tarball: #{inspect(reason)}")
    end
  end

  defp collect_files(data) do
    case Map.get(data, "files") do
      patterns when is_list(patterns) ->
        Enum.flat_map(patterns, &Path.wildcard/1)
        |> Enum.concat(["package.json"])
        |> Enum.uniq()
        |> Enum.filter(&File.regular?/1)

      _ ->
        default_files()
    end
  end

  defp default_files do
    ["package.json", "README.md", "LICENSE", "CHANGELOG.md"]
    |> Enum.filter(&File.exists?/1)
  end

  defp format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_size(bytes), do: "#{Float.round(bytes / 1024, 1)} KB"
end
