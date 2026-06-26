defmodule NPM.Format do
  @moduledoc """
  Formatting utilities for npm CLI output.

  Shared formatting functions used across Mix tasks for
  consistent output.
  """

  @doc """
  Format a byte size into human-readable string.
  """
  @spec bytes(non_neg_integer()) :: String.t()
  def bytes(b) when b < 1024, do: "#{b} B"
  def bytes(b) when b < 1_048_576, do: "#{Float.round(b / 1024, 1)} KB"
  def bytes(b) when b < 1_073_741_824, do: "#{Float.round(b / 1_048_576, 1)} MB"
  def bytes(b), do: "#{Float.round(b / 1_073_741_824, 1)} GB"

  @doc """
  Format a duration in microseconds.
  """
  @spec duration(non_neg_integer()) :: String.t()
  def duration(us) when us < 1_000, do: "#{us}µs"
  def duration(us) when us < 1_000_000, do: "#{div(us, 1_000)}ms"
  def duration(us), do: "#{Float.round(us / 1_000_000, 1)}s"

  @doc """
  Format a package name and version.
  """
  @spec package(String.t(), String.t()) :: String.t()
  def package(name, version), do: "#{name}@#{version}"

  @doc """
  Pluralize a word based on count.
  """
  @spec pluralize(non_neg_integer(), String.t(), String.t()) :: String.t()
  def pluralize(1, singular, _plural), do: "1 #{singular}"
  def pluralize(count, _singular, plural), do: "#{count} #{plural}"

  @doc """
  Truncate a string to a maximum length.
  """
  @spec truncate(String.t(), non_neg_integer()) :: String.t()
  def truncate(str, max) when byte_size(str) <= max, do: str
  def truncate(str, max), do: String.slice(str, 0, max - 3) <> "..."
end
