defmodule Mix.Tasks.Npm.Search do
  @shortdoc "Search npm registry"

  @moduledoc """
  Search for packages on the npm registry.

      mix npm.search lodash
      mix npm.search react --limit 5

  Returns matching packages with descriptions.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, terms, _} = OptionParser.parse(args, strict: [limit: :integer])

    case terms do
      [] ->
        Mix.shell().error("Usage: mix npm.search <query> [--limit N]")

      _ ->
        query = Enum.join(terms, " ")
        limit = Keyword.get(opts, :limit, 10)
        search(query, limit)
    end
  end

  defp search(query, limit) do
    url = "#{NPM.Registry.registry_url()}/-/v1/search?text=#{URI.encode(query)}&size=#{limit}"

    case Req.get(url) do
      {:ok, %{status: 200, body: body}} ->
        print_results(body)

      {:ok, %{status: status}} ->
        Mix.shell().error("Search failed with status #{status}")

      {:error, reason} ->
        Mix.shell().error("Search failed: #{inspect(reason)}")
    end
  end

  defp print_results(%{"objects" => []}) do
    Mix.shell().info("No packages found.")
  end

  defp print_results(%{"objects" => objects}) do
    Enum.each(objects, fn %{"package" => pkg} ->
      name = Map.get(pkg, "name", "?")
      version = Map.get(pkg, "version", "?")
      description = Map.get(pkg, "description", "")

      Mix.shell().info(
        String.pad_trailing("#{name}@#{version}", 40) <>
          String.slice(description, 0, 60)
      )
    end)
  end

  defp print_results(_), do: Mix.shell().info("No results.")
end
