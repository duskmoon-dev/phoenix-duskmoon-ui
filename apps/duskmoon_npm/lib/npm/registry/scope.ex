defmodule NPM.Registry.Scope do
  @moduledoc """
  Resolve the registry URL for scoped packages.

  npm supports per-scope registry configuration in `.npmrc`:

      @mycompany:registry=https://npm.mycompany.com/

  This allows private packages under `@mycompany/*` to resolve
  from a custom registry while other packages use the default.
  """

  @doc """
  Get the registry URL for a package name.

  Checks `.npmrc` for scope-specific registry configuration,
  falls back to the default registry.
  """
  @spec registry_for(String.t()) :: String.t()
  def registry_for("@" <> _ = name) do
    scope = name |> String.split("/") |> hd()
    scope_config_key = "#{scope}:registry"

    case read_config(scope_config_key) do
      nil -> NPM.Registry.registry_url()
      url -> String.trim_trailing(url, "/")
    end
  end

  def registry_for(_name), do: NPM.Registry.registry_url()

  @doc """
  Get all configured scope registries from `.npmrc`.

  Returns a map of `scope => registry_url`.
  """
  @spec all_scopes :: %{String.t() => String.t()}
  def all_scopes do
    case File.read(".npmrc") do
      {:ok, content} ->
        content
        |> NPM.Config.parse_npmrc()
        |> Enum.filter(fn {key, _} -> String.match?(key, ~r/^@[^:]+:registry$/) end)
        |> Map.new(fn {key, url} ->
          scope = key |> String.split(":") |> hd()
          {scope, String.trim_trailing(url, "/")}
        end)

      {:error, _} ->
        %{}
    end
  end

  @doc """
  Check if a package name is scoped.
  """
  @spec scoped?(String.t()) :: boolean()
  def scoped?("@" <> _), do: true
  def scoped?(_), do: false

  @doc """
  Extract the scope from a scoped package name.

  Returns `nil` for unscoped packages.
  """
  @spec scope(String.t()) :: String.t() | nil
  def scope("@" <> _ = name) do
    name |> String.split("/") |> hd()
  end

  def scope(_), do: nil

  defp read_config(key) do
    case File.read(".npmrc") do
      {:ok, content} ->
        content |> NPM.Config.parse_npmrc() |> Map.get(key)

      {:error, _} ->
        nil
    end
  end
end
