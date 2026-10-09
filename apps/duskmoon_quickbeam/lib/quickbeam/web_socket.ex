defmodule QuickBEAM.WebSocket do
  @moduledoc false
  use GenServer, restart: :temporary

  @spec connect(args :: [term()], owner :: pid()) :: String.t()
  def connect([url, protocols], owner) do
    id = Integer.to_string(System.unique_integer([:positive]))

    {:ok, pid} =
      DynamicSupervisor.start_child(
        QuickBEAM.NetworkSupervisor,
        {__MODULE__, %{id: id, owner: owner, url: url, protocols: List.wrap(protocols)}}
      )

    send(owner, {:websocket_started, id, pid})
    id
  end

  def start_link(options), do: GenServer.start_link(__MODULE__, options)

  @spec send_frame(args :: [term()], owner :: pid()) :: nil
  def send_frame([id, [kind, payload]], owner) do
    send(owner, {:ws_send, id, kind, payload})
    nil
  end

  @spec close(args :: [term()], owner :: pid()) :: nil
  def close([id, code, reason], owner) do
    send(owner, {:ws_close, id, code, reason})
    nil
  end

  @impl true
  def init(options) do
    owner_ref = Process.monitor(options.owner)
    {:ok, Map.merge(options, %{owner_ref: owner_ref, socket: nil}), {:continue, :connect}}
  end

  @impl true
  def handle_continue(:connect, state) do
    # The native bridge queues messages without an acknowledgement from JS.
    case HTTP.WebSocket.new(state.url, state.protocols,
           owner: self(),
           binary_type: :array_buffer,
           delivery: :legacy
         ) do
      %HTTP.WebSocket{} = socket ->
        {:noreply, Map.put(state, :socket, socket)}

      {:error, reason} ->
        notify(state, ["__ws_error", state.id, inspect(reason)])
        notify(state, ["__ws_close", state.id, 1006, "", false])
        {:stop, :normal, state}
    end
  end

  @impl true
  def handle_cast({:send, kind, payload}, state) do
    data = if kind == "binary", do: HTTP.WebSocket.array_buffer(payload), else: payload

    case HTTP.WebSocket.send(state.socket, data) do
      :ok -> {:noreply, state}
      {:error, reason} -> send_error(state, reason)
    end
  end

  def handle_cast({:close, code, reason}, state) do
    case HTTP.WebSocket.close(state.socket, code, reason) do
      :ok -> {:noreply, state}
      {:error, error} -> send_error(state, error)
    end
  end

  @impl true
  def handle_info({HTTP.WebSocket, socket, %HTTP.WebSocket.Event.Open{}}, state) do
    notify(state, ["__ws_open", state.id, HTTP.WebSocket.protocol(socket)])
    {:noreply, state}
  end

  def handle_info({HTTP.WebSocket, _socket, %HTTP.WebSocket.Event.Message{data: data}}, state) do
    payload =
      case data do
        %HTTP.WebSocket.ArrayBuffer{data: bytes} -> {:bytes, bytes}
        text when is_binary(text) -> text
      end

    notify(state, ["__ws_message", state.id, payload])
    {:noreply, state}
  end

  def handle_info({HTTP.WebSocket, _socket, %HTTP.WebSocket.Event.Error{reason: reason}}, state) do
    notify(state, ["__ws_error", state.id, inspect(reason)])
    {:noreply, state}
  end

  def handle_info({HTTP.WebSocket, _socket, %HTTP.WebSocket.Event.Close{} = event}, state) do
    notify(state, ["__ws_close", state.id, event.code || 1005, event.reason, event.was_clean])
    {:stop, :normal, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, %{owner_ref: ref} = state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(_reason, %{socket: %HTTP.WebSocket{} = socket}) do
    HTTP.WebSocket.close(socket)
  end

  def terminate(_reason, _state), do: :ok

  defp send_error(state, reason) do
    notify(state, ["__ws_error", state.id, inspect(reason)])
    notify(state, ["__ws_close", state.id, 1006, "", false])
    {:stop, :normal, state}
  end

  defp notify(state, message), do: send(state.owner, {:websocket_event, message})
end
