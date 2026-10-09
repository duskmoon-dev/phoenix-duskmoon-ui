defmodule QuickBEAM.EventSource do
  @moduledoc false
  use GenServer, restart: :temporary

  @spec open(list(), pid()) :: pid()
  def open([url, id], owner) do
    {:ok, pid} =
      DynamicSupervisor.start_child(
        QuickBEAM.NetworkSupervisor,
        {__MODULE__, %{url: url, id: id, owner: owner}}
      )

    pid
  end

  def start_link(options), do: GenServer.start_link(__MODULE__, options)

  @spec close([pid()]) :: nil
  def close([pid]) do
    GenServer.stop(pid, :normal)
    nil
  catch
    :exit, {:noproc, _} -> nil
    :exit, {:normal, _} -> nil
  end

  @impl true
  def init(options) do
    owner_ref = Process.monitor(options.owner)
    {:ok, Map.merge(options, %{owner_ref: owner_ref, source: nil}), {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    # Native.send_message queues events; it does not acknowledge JS consumption.
    case HTTP.EventSource.new(state.url, owner: self(), delivery: :legacy) do
      %HTTP.EventSource{} = source ->
        {:noreply, Map.put(state, :source, source)}

      {:error, reason} ->
        send(state.owner, {:eventsource_error, state.id, inspect(reason), 2})
        {:stop, :normal, state}
    end
  end

  @impl true
  def handle_info({HTTP.EventSource, _source, %HTTP.EventSource.Event.Open{}}, state) do
    send(state.owner, {:eventsource_open, state.id})
    {:noreply, state}
  end

  def handle_info({HTTP.EventSource, _source, %HTTP.EventSource.Event.Message{} = event}, state) do
    send(
      state.owner,
      {:eventsource_event, state.id,
       %{type: event.type, data: event.data, id: event.last_event_id}}
    )

    {:noreply, state}
  end

  def handle_info({HTTP.EventSource, source, %HTTP.EventSource.Event.Error{} = event}, state) do
    ready_state = HTTP.EventSource.ready_state(source)
    send(state.owner, {:eventsource_error, state.id, inspect(event.reason), ready_state})

    if ready_state == 2, do: {:stop, :normal, state}, else: {:noreply, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{owner_ref: ref} = state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_reason, %{source: %HTTP.EventSource{} = source}) do
    HTTP.EventSource.close(source)
  end

  def terminate(_reason, _state), do: :ok
end
