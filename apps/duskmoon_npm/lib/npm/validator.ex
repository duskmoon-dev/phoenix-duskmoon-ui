defmodule NPM.Validator do
  @moduledoc """
  Validate `package.json` fields.
  """

  @doc """
  Validate a package name according to npm naming rules.

  Returns `:ok` or `{:error, reason}`.
  """
  @spec validate_name(String.t()) :: :ok | {:error, String.t()}
  def validate_name(name) do
    cond do
      name == "" ->
        {:error, "name cannot be empty"}

      byte_size(name) > 214 ->
        {:error, "name cannot exceed 214 characters"}

      String.starts_with?(name, ".") ->
        {:error, "name cannot start with a period"}

      String.starts_with?(name, "_") ->
        {:error, "name cannot start with an underscore"}

      name != String.downcase(name) and not String.starts_with?(name, "@") ->
        {:error, "name must be lowercase"}

      String.contains?(name, " ") ->
        {:error, "name cannot contain spaces"}

      true ->
        :ok
    end
  end

  @doc """
  Validate a version range string.

  Returns `:ok` or `{:error, reason}`.
  """
  @spec validate_range(String.t()) :: :ok | {:error, String.t()}
  def validate_range(""), do: {:error, "version range cannot be empty"}
  def validate_range("*"), do: :ok
  def validate_range("latest"), do: :ok

  def validate_range(range) do
    case NPMSemver.to_hex_constraint(range) do
      {:ok, _} -> :ok
      :error -> {:error, "invalid version range: #{range}"}
    end
  end
end
