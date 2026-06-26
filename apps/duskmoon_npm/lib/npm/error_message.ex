defmodule NPM.ErrorMessage do
  @moduledoc """
  Structured error formatting for npm operations.

  Provides consistent, helpful error messages with suggestions for resolution.
  """

  @doc """
  Formats an error tuple into a user-friendly message.
  """
  @spec format({:error, atom()} | {:error, atom(), term()}) :: String.t()
  def format({:error, :no_package_json}) do
    "package.json not found.\nRun `mix npm.init` to create one."
  end

  def format({:error, :no_lockfile}) do
    "npm.lock not found.\nRun `mix npm.install` to generate a lockfile."
  end

  def format({:error, :frozen_lockfile}) do
    "npm.lock is out of sync with package.json.\nRun `mix npm.install` to update the lockfile."
  end

  def format({:error, :resolution_failed}) do
    "Dependency resolution failed.\nCheck for conflicting version ranges in package.json."
  end

  def format({:error, :integrity_mismatch, name}) do
    "Integrity check failed for #{name}.\nTry clearing the cache: `mix npm.cache clean`"
  end

  def format({:error, :network_error}) do
    "Network error. Check your internet connection and registry URL."
  end

  def format({:error, :package_not_found, name}) do
    "Package '#{name}' not found in the registry.\nCheck the package name for typos."
  end

  def format({:error, reason}) when is_atom(reason) do
    "Error: #{reason}"
  end

  def format({:error, reason}) do
    "Error: #{inspect(reason)}"
  end

  @doc """
  Returns a suggestion for a given error.
  """
  @spec suggestion(atom()) :: String.t() | nil
  def suggestion(:no_package_json), do: "mix npm.init"
  def suggestion(:no_lockfile), do: "mix npm.install"
  def suggestion(:frozen_lockfile), do: "mix npm.install"
  def suggestion(:resolution_failed), do: "Check package.json for conflicts"
  def suggestion(:integrity_mismatch), do: "mix npm.cache clean"
  def suggestion(:network_error), do: "Check connectivity and .npmrc registry"
  def suggestion(_), do: nil

  @doc """
  Checks if an error is retryable.
  """
  @spec retryable?(atom()) :: boolean()
  def retryable?(:network_error), do: true
  def retryable?(:timeout), do: true
  def retryable?(:registry_unavailable), do: true
  def retryable?(_), do: false
end
