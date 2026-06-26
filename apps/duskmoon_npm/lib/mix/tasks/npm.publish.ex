defmodule Mix.Tasks.Npm.Publish do
  @shortdoc "Publish package to the npm registry"

  @moduledoc """
  Publish the current package to the npm registry.

      mix npm.publish
      mix npm.publish --tag beta
      mix npm.publish --access public
      mix npm.publish --dry-run

  Requires `NPM_TOKEN` environment variable or `.npmrc` auth config.

  ## Options

    * `--tag` — publish with a dist-tag (default: `latest`)
    * `--access` — package access level: `public` or `restricted`
    * `--dry-run` — show what would be published without uploading
  """

  use Mix.Task

  @impl true
  def run(args) do
    Application.ensure_all_started(:req)

    {opts, _, _} =
      OptionParser.parse(args, strict: [tag: :string, access: :string, dry_run: :boolean])

    tag = Keyword.get(opts, :tag, "latest")
    access = Keyword.get(opts, :access, "public")
    dry_run = Keyword.get(opts, :dry_run, false)

    with {:ok, content} <- File.read("package.json"),
         data <- NPM.JSON.decode!(content),
         :ok <- validate_publish(data) do
      name = data["name"]
      version = data["version"]

      if dry_run do
        print_dry_run(name, version, tag, access)
      else
        publish(name, version, tag, access)
      end
    else
      {:error, :enoent} ->
        Mix.shell().error("No package.json found.")

      {:error, reason} ->
        Mix.shell().error("Publish failed: #{inspect(reason)}")
    end
  end

  defp validate_publish(data) do
    cond do
      not Map.has_key?(data, "name") ->
        {:error, "package.json must have a name field"}

      not Map.has_key?(data, "version") ->
        {:error, "package.json must have a version field"}

      true ->
        :ok
    end
  end

  defp print_dry_run(name, version, tag, access) do
    Mix.shell().info("Dry run — would publish:")
    Mix.shell().info("  package: #{name}")
    Mix.shell().info("  version: #{version}")
    Mix.shell().info("  tag:     #{tag}")
    Mix.shell().info("  access:  #{access}")
  end

  defp publish(name, version, tag, access) do
    token = NPM.Config.auth_token()

    if is_nil(token) do
      Mix.shell().error(
        "NPM_TOKEN not set. Set it, configure :duskmoon_npm, :token, or add auth to .npmrc"
      )

      {:error, :no_token}
    else
      registry = NPM.Registry.registry_url()
      url = "#{registry}/#{NPM.Registry.encode_package(name)}"

      Mix.shell().info(
        "Publishing #{name}@#{version} to #{registry} (tag: #{tag}, access: #{access})..."
      )

      body = build_publish_body(name, version, tag, access)

      case Req.put(url, body: body, headers: auth_headers(token)) do
        {:ok, %{status: s}} when s in [200, 201] ->
          Mix.shell().info("Published #{name}@#{version}")
          :ok

        {:ok, %{status: status, body: resp_body}} ->
          Mix.shell().error("Publish failed (#{status}): #{inspect(resp_body)}")
          {:error, {:http, status}}

        {:error, reason} ->
          Mix.shell().error("Publish failed: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  defp build_publish_body(name, version, tag, access) do
    :json.encode(%{
      "name" => name,
      "version" => version,
      "dist-tags" => %{tag => version},
      "access" => access
    })
  end

  defp auth_headers(token) do
    [authorization: "Bearer #{token}", "content-type": "application/json"]
  end
end
