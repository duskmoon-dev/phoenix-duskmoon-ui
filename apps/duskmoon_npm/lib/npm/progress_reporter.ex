defmodule NPM.ProgressReporter do
  @moduledoc """
  Reports progress during npm operations (resolution, fetching, linking).
  """

  @doc """
  Formats a resolution progress message.
  """
  @spec resolving(non_neg_integer(), non_neg_integer()) :: String.t()
  def resolving(resolved, total) do
    pct = if total > 0, do: round(resolved / total * 100), else: 0
    "Resolving packages... #{resolved}/#{total} (#{pct}%)"
  end

  @doc """
  Formats a fetch progress message.
  """
  @spec fetching(String.t(), non_neg_integer(), non_neg_integer()) :: String.t()
  def fetching(name, fetched, total) do
    "Fetching #{name}... (#{fetched}/#{total})"
  end

  @doc """
  Formats a linking progress message.
  """
  @spec linking(non_neg_integer(), non_neg_integer()) :: String.t()
  def linking(linked, total) do
    "Linking packages... #{linked}/#{total}"
  end

  @doc """
  Formats a completion message with timing.
  """
  @spec done(atom(), non_neg_integer()) :: String.t()
  def done(:resolve, ms), do: "✓ Resolved in #{format_time(ms)}"
  def done(:fetch, ms), do: "✓ Fetched in #{format_time(ms)}"
  def done(:link, ms), do: "✓ Linked in #{format_time(ms)}"
  def done(:install, ms), do: "✓ Installed in #{format_time(ms)}"
  def done(step, ms), do: "✓ #{step} in #{format_time(ms)}"

  @doc """
  Formats a step breakdown for total timing.
  """
  @spec breakdown(keyword()) :: String.t()
  def breakdown(steps) do
    Enum.map_join(steps, "\n", fn {step, ms} ->
      "  #{step}: #{format_time(ms)}"
    end)
  end

  @doc """
  Formats time in human-readable form.
  """
  @spec format_time(non_neg_integer()) :: String.t()
  def format_time(ms) when ms < 1000, do: "#{ms}ms"
  def format_time(ms), do: "#{Float.round(ms / 1000, 1)}s"
end
