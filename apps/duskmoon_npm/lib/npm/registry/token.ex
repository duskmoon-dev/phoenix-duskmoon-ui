defmodule NPM.Registry.Token do
  @moduledoc """
  Manages npm authentication tokens.

  Handles reading, validating, and masking auth tokens used
  for private registry access.
  """

  @doc """
  Reads the auth token from environment or .npmrc.
  """
  @spec read :: String.t() | nil
  def read do
    NPM.Config.auth_token() || read_from_npmrc()
  end

  @doc """
  Checks if a valid auth token is configured.
  """
  @spec configured? :: boolean()
  def configured?, do: read() != nil

  @doc """
  Masks a token for safe display.

  Shows only the first and last 4 characters.
  """
  @spec mask(String.t()) :: String.t()
  def mask(token) when byte_size(token) <= 8, do: "****"

  def mask(token) do
    first = String.slice(token, 0, 4)
    last = String.slice(token, -4, 4)
    "#{first}...#{last}"
  end

  @doc """
  Validates token format.

  npm tokens are typically UUIDs or base64-encoded strings.
  """
  @spec valid_format?(String.t()) :: boolean()
  def valid_format?(token) do
    byte_size(token) >= 8 and
      not String.contains?(token, " ") and
      not String.contains?(token, "\n")
  end

  @doc """
  Returns the auth header value for the given token.
  """
  @spec auth_header(String.t()) :: String.t()
  def auth_header(token), do: "Bearer #{token}"

  @doc """
  Reads token from an .npmrc file content.
  """
  @spec parse_npmrc(String.t()) :: String.t() | nil
  def parse_npmrc(content) do
    content
    |> String.split("\n")
    |> Enum.find_value(fn line ->
      case Regex.run(~r/_authToken=(.+)$/, String.trim(line)) do
        [_, token] -> String.trim(token)
        _ -> nil
      end
    end)
  end

  defp read_from_npmrc do
    npmrc_path = Path.join(System.user_home!(), ".npmrc")

    case File.read(npmrc_path) do
      {:ok, content} -> parse_npmrc(content)
      _ -> nil
    end
  end
end
