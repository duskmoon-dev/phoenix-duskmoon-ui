defmodule NPM.Scope do
  @moduledoc """
  Parses and manages npm package scopes.

  Scopes are namespaces prefixed with `@` (e.g., `@babel/core`).
  They map to registries, organizations, and access controls.
  """

  @doc """
  Checks if a package name is scoped.
  """
  @spec scoped?(String.t()) :: boolean()
  def scoped?("@" <> rest), do: String.contains?(rest, "/")
  def scoped?(_), do: false

  @doc """
  Extracts the scope from a package name (without @).
  """
  @spec extract(String.t()) :: String.t() | nil
  def extract("@" <> rest) do
    case String.split(rest, "/", parts: 2) do
      [scope, _name] -> scope
      _ -> nil
    end
  end

  def extract(_), do: nil

  @doc """
  Extracts the bare package name (without scope).
  """
  @spec bare_name(String.t()) :: String.t()
  def bare_name("@" <> rest) do
    case String.split(rest, "/", parts: 2) do
      [_scope, name] -> name
      _ -> rest
    end
  end

  def bare_name(name), do: name

  @doc """
  Constructs a full scoped name from scope and package name.
  """
  @spec full_name(String.t(), String.t()) :: String.t()
  def full_name(scope, name), do: "@#{scope}/#{name}"

  @doc """
  Validates a scope name.

  Scopes must be lowercase, URL-safe, and not start with a dot or underscore.
  """
  @spec valid_scope?(String.t()) :: boolean()
  def valid_scope?(scope) do
    Regex.match?(~r/^[a-z][a-z0-9._-]*$/, scope)
  end

  @doc """
  Validates a full package name (scoped or unscoped).
  """
  @spec valid_name?(String.t()) :: boolean()
  def valid_name?(name) do
    if scoped?(name) do
      valid_scope?(extract(name)) and valid_bare_name?(bare_name(name))
    else
      valid_bare_name?(name)
    end
  end

  @doc """
  Lists all unique scopes found in a set of package names.
  """
  @spec unique_scopes([String.t()]) :: [String.t()]
  def unique_scopes(names) do
    names
    |> Enum.flat_map(fn name ->
      case extract(name) do
        nil -> []
        scope -> [scope]
      end
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc """
  Groups package names by scope (nil for unscoped).
  """
  @spec group_by_scope([String.t()]) :: %{(String.t() | nil) => [String.t()]}
  def group_by_scope(names) do
    Enum.group_by(names, &extract/1)
  end

  defp valid_bare_name?(name) do
    byte_size(name) > 0 and byte_size(name) <= 214 and
      Regex.match?(~r/^[a-z0-9][a-z0-9._-]*$/, name)
  end
end
