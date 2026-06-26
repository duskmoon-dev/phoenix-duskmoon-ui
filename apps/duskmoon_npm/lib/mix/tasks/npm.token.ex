defmodule Mix.Tasks.Npm.Token do
  @shortdoc "Manage npm auth tokens"

  @moduledoc """
  Display or verify npm authentication token status.

      mix npm.token           # Show token status
      mix npm.token --verify  # Verify token with registry

  The token is read from the `NPM_TOKEN` environment variable
  or from `.npmrc` auth configuration.
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)
    {opts, _, _} = OptionParser.parse(args, strict: [verify: :boolean])

    token = resolve_token()

    case token do
      nil ->
        Mix.shell().info("No npm token configured.")
        Mix.shell().info("Set NPM_TOKEN or add authToken to .npmrc")

      token ->
        masked = mask_token(token)
        Mix.shell().info("Token: #{masked}")
        Mix.shell().info("Source: #{token_source()}")

        if opts[:verify], do: verify_token(token)
    end
  end

  defp resolve_token do
    NPM.Config.auth_token() || read_npmrc_token()
  end

  defp read_npmrc_token do
    case File.read(".npmrc") do
      {:ok, content} ->
        config = NPM.Config.parse_npmrc(content)
        config["//registry.npmjs.org/:_authToken"]

      {:error, _} ->
        nil
    end
  end

  defp token_source do
    cond do
      System.get_env("NPM_TOKEN") -> "NPM_TOKEN environment variable"
      Application.get_env(:duskmoon_npm, :token) -> "application config"
      true -> ".npmrc file"
    end
  end

  defp mask_token(token) when byte_size(token) <= 8, do: "****"

  defp mask_token(token) do
    String.slice(token, 0, 4) <> "****" <> String.slice(token, -4, 4)
  end

  defp verify_token(token) do
    url = "#{NPM.Registry.registry_url()}/-/whoami"

    case Req.get(url, headers: [authorization: "Bearer #{token}"]) do
      {:ok, %{status: 200, body: %{"username" => user}}} ->
        Mix.shell().info("Authenticated as: #{user}")

      {:ok, %{status: 401}} ->
        Mix.shell().error("Token is invalid or expired.")

      {:ok, %{status: status}} ->
        Mix.shell().error("Unexpected response: #{status}")

      {:error, reason} ->
        Mix.shell().error("Verification failed: #{inspect(reason)}")
    end
  end
end
