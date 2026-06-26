defmodule NPM.Security.Compromised.OSV do
  @moduledoc """
  Optional OSV.dev lookup for malicious npm package advisories.

  The OpenSSF malicious-packages dataset is published in OSV format and is
  ingested by OSV.dev. Calls are opt-in so normal installs remain offline and
  deterministic unless a caller explicitly enables online checks.
  """

  @endpoint "https://api.osv.dev/v1/query"
  @batch_endpoint "https://api.osv.dev/v1/querybatch"

  @doc "Build the OSV package-version query body for an npm package."
  @spec query_body(String.t(), String.t()) :: map()
  def query_body(package, version) do
    %{"package" => %{"name" => package, "ecosystem" => "npm"}, "version" => version}
  end

  @doc "Build the OSV batch query body for npm package versions."
  @spec batch_body([{String.t(), String.t()}]) :: map()
  def batch_body(packages) do
    %{"queries" => Enum.map(packages, fn {package, version} -> query_body(package, version) end)}
  end

  @doc "Query OSV.dev for one npm package version."
  @spec query_package(String.t(), String.t(), keyword()) :: {:ok, [map()]} | {:error, term()}
  def query_package(package, version, opts \\ []) do
    endpoint = Keyword.get(opts, :endpoint, @endpoint)

    request = [
      json: query_body(package, version),
      receive_timeout: Keyword.get(opts, :timeout, 10_000)
    ]

    case Req.post(endpoint, request) do
      {:ok, %{status: status, body: %{"vulns" => vulns}}} when status in 200..299 ->
        {:ok, Enum.filter(vulns, &malicious_advisory?/1)}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Query OSV.dev for multiple npm package versions."
  @spec query_packages([{String.t(), String.t()}], keyword()) ::
          {:ok, %{String.t() => [map()]}} | {:error, term()}
  def query_packages(packages, opts \\ []) do
    endpoint = Keyword.get(opts, :batch_endpoint, @batch_endpoint)
    unique_packages = Enum.uniq(packages)

    request = [
      json: batch_body(unique_packages),
      receive_timeout: Keyword.get(opts, :timeout, 30_000)
    ]

    case Req.post(endpoint, request) do
      {:ok, %{status: status, body: %{"results" => results}}} when status in 200..299 ->
        {:ok, results_to_map(unique_packages, results)}

      {:ok, %{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Return whether an OSV advisory is a malicious-package report."
  @spec malicious_advisory?(map()) :: boolean()
  def malicious_advisory?(%{"id" => "MAL-" <> _}), do: true

  def malicious_advisory?(%{"database_specific" => %{"malicious-packages-origins" => origins}})
      when is_list(origins) do
    origins != []
  end

  def malicious_advisory?(%{"summary" => summary}) when is_binary(summary) do
    summary |> String.downcase() |> String.contains?("malicious")
  end

  def malicious_advisory?(_), do: false

  defp results_to_map(packages, results) do
    packages
    |> Enum.zip(results)
    |> Map.new(fn {{package, _version}, result} ->
      advisories = result |> Map.get("vulns", []) |> Enum.filter(&malicious_advisory?/1)
      {package, advisories}
    end)
  end
end
