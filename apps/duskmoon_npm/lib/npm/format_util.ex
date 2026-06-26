defmodule NPM.FormatUtil do
  @moduledoc """
  Shared formatting utilities.
  """

  @doc """
  Formats a byte count as a human-readable string.
  """
  @spec format_size(non_neg_integer()) :: String.t()
  def format_size(bytes) when bytes < 1024, do: "#{bytes} B"
  def format_size(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  def format_size(bytes) when bytes < 1_073_741_824, do: "#{Float.round(bytes / 1_048_576, 1)} MB"
  def format_size(bytes), do: "#{Float.round(bytes / 1_073_741_824, 1)} GB"
end
