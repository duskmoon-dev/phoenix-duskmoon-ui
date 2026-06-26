defmodule Mix.Tasks.Npm.Fund do
  @shortdoc "Show package funding info"

  @moduledoc """
  Show funding information for installed packages.

      mix npm.fund

  Queries the registry for funding URLs of all installed packages.
  """

  use Mix.Task

  @impl true
  def run([]) do
    Application.ensure_all_started(:req)

    case NPM.Lockfile.read() do
      {:ok, lockfile} when lockfile == %{} ->
        Mix.shell().info("No packages installed.")

      {:ok, lockfile} ->
        show_funding(lockfile)

      {:error, reason} ->
        Mix.shell().error("Failed to read lockfile: #{inspect(reason)}")
    end
  end

  def run(_) do
    Mix.shell().error("Usage: mix npm.fund")
  end

  defp show_funding(lockfile) do
    Mix.shell().info("Checking funding for #{map_size(lockfile)} packages...")

    lockfile
    |> Map.keys()
    |> Enum.sort()
    |> Task.async_stream(&fetch_funding/1, max_concurrency: 8, timeout: 30_000)
    |> Enum.each(fn
      {:ok, {name, urls}} when urls != [] ->
        Mix.shell().info("  #{name}: #{Enum.join(urls, ", ")}")

      _ ->
        :ok
    end)
  end

  defp fetch_funding(name) do
    url = "#{NPM.Registry.registry_url()}/#{String.replace(name, "/", "%2f")}"

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        {name, extract_funding(body)}

      _ ->
        {name, []}
    end
  end

  defp extract_funding(%{"funding" => funding}) when is_binary(funding), do: [funding]

  defp extract_funding(%{"funding" => %{"url" => url}}), do: [url]

  defp extract_funding(%{"funding" => funding_list}) when is_list(funding_list) do
    Enum.flat_map(funding_list, fn
      %{"url" => url} -> [url]
      url when is_binary(url) -> [url]
      _ -> []
    end)
  end

  defp extract_funding(_), do: []
end
