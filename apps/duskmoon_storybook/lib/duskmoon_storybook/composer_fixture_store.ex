defmodule DuskmoonStorybook.ComposerFixtureStore do
  @moduledoc """
  Bounded, memory-only composer fixtures retained across LiveView reconnects.

  Entries expire after 30 idle minutes or when displaced by 128 newer sessions.
  A new LiveView root or application restart starts a fresh fixture. This store
  does not establish durable admission or crash recovery.
  """

  use Agent

  @max_sessions 128
  @idle_ms :timer.minutes(30)

  @doc "Starts the supervised fixture cache."
  def start_link(_opts), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @doc "Restores a fixture for the same LiveView root, if it has not expired."
  def get(id) when is_binary(id) do
    Agent.get_and_update(__MODULE__, fn entries ->
      now = System.monotonic_time(:millisecond)
      entries = prune(entries, now)

      case entries[id] do
        {_, fixture} -> {fixture, Map.put(entries, id, {now, fixture})}
        nil -> {nil, entries}
      end
    end)
  end

  def get(_id), do: nil

  @doc "Retains the fixture without persisting browser files or transport state."
  def put(id, fixture) when is_binary(id) do
    Agent.update(__MODULE__, fn entries ->
      now = System.monotonic_time(:millisecond)

      entries
      |> prune(now)
      |> Map.put(id, {now, fixture})
      |> Enum.sort_by(fn {_id, {seen_at, _fixture}} -> seen_at end, :desc)
      |> Enum.take(@max_sessions)
      |> Map.new()
    end)
  end

  def put(_id, _fixture), do: :ok

  defp prune(entries, now) do
    Map.reject(entries, fn {_id, {seen_at, _fixture}} -> now - seen_at >= @idle_ms end)
  end
end
