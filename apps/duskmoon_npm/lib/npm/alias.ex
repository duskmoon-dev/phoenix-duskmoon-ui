defmodule NPM.Alias do
  @moduledoc """
  Handle npm package aliases.

  npm supports aliasing packages with the `npm:` prefix syntax:

      "my-react": "npm:react@^18.0.0"

  This allows installing a package under a different name, useful for
  running multiple versions of the same package side by side.
  """

  @doc """
  Parse an alias specifier.

  Returns `{:alias, package, range}` if the specifier uses `npm:` prefix,
  or `{:normal, range}` otherwise.

  ## Examples

      iex> NPM.Alias.parse("npm:react@^18.0.0")
      {:alias, "react", "^18.0.0"}

      iex> NPM.Alias.parse("npm:@scope/pkg@1.0.0")
      {:alias, "@scope/pkg", "1.0.0"}

      iex> NPM.Alias.parse("^1.0.0")
      {:normal, "^1.0.0"}
  """
  @spec parse(String.t()) :: {:alias, String.t(), String.t()} | {:normal, String.t()}
  def parse("npm:" <> rest) do
    case parse_aliased(rest) do
      {pkg, range} -> {:alias, pkg, range}
      :error -> {:normal, "npm:" <> rest}
    end
  end

  def parse(range), do: {:normal, range}

  @doc """
  Check if a dependency specifier is an alias.
  """
  @spec alias?(String.t()) :: boolean()
  def alias?("npm:" <> _), do: true
  def alias?(_), do: false

  @doc """
  Extract the real package name from an alias specifier.

  Returns the original name if not an alias.
  """
  @spec real_name(String.t(), String.t()) :: String.t()
  def real_name(alias_name, "npm:" <> rest) do
    case parse_aliased(rest) do
      {pkg, _range} -> pkg
      :error -> alias_name
    end
  end

  def real_name(name, _range), do: name

  defp parse_aliased("@" <> rest) do
    case String.split(rest, "@", parts: 2) do
      [scope_and_name, range] -> {"@" <> scope_and_name, range}
      _ -> :error
    end
  end

  defp parse_aliased(rest) do
    case String.split(rest, "@", parts: 2) do
      [name, range] when name != "" -> {name, range}
      _ -> :error
    end
  end
end
