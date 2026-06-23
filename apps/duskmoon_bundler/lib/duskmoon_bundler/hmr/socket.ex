defmodule DuskmoonBundler.HMR.Socket do
  @moduledoc """
  WebSocket handler for HMR updates.

  Receives file change events from `DuskmoonBundler.Watcher` via the HMR registry
  and pushes JSON messages to connected browsers.
  """
  @behaviour WebSock
  require Logger

  @impl true
  def init(_args) do
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)
    {:ok, %{}}
  end

  # Heartbeat: the browser client sends a `{"type":"ping"}` JSON message
  # every few seconds to keep Bandit's websocket `read_timeout` from closing
  # an otherwise idle connection. We reply with `{"type":"pong"}` so the
  # client can also detect a dead link and reconnect. Both messages flow
  # through the `DuskmoonBundler.HMR.Message` JSONCodec.
  @impl true
  def handle_in({text, opcode: :text}, state) do
    case DuskmoonBundler.HMR.Message.decode(text) do
      {:ok, %DuskmoonBundler.HMR.Message{type: :ping}} ->
        push(%DuskmoonBundler.HMR.Message{type: :pong}, state)

      {:ok, %DuskmoonBundler.HMR.Message{type: type} = message} ->
        Logger.debug(
          "[DuskmoonBundler.HMR] Received: #{inspect(type)} #{inspect(message.payload)}"
        )

        {:ok, state}

      {:error, reason} ->
        Logger.debug("[DuskmoonBundler.HMR] Ignoring malformed frame: #{inspect(reason)}")
        {:ok, state}
    end
  end

  @impl true
  def handle_info({:duskmoon_bundler_hmr, type, payload}, state) do
    push(%DuskmoonBundler.HMR.Message{type: type, payload: payload}, state)
  end

  def handle_info(_msg, state) do
    {:ok, state}
  end

  defp push(%DuskmoonBundler.HMR.Message{} = message, state) do
    case encode(message) do
      {:ok, frame} -> {:push, frame, state}
      :error -> {:ok, state}
    end
  end

  defp encode(%DuskmoonBundler.HMR.Message{} = message) do
    {:ok, {:text, message |> DuskmoonBundler.HMR.Message.dump() |> Jason.encode!()}}
  rescue
    error ->
      Logger.warning(
        "[DuskmoonBundler.HMR] Failed to encode #{inspect(message.type)} payload: #{inspect(error)}"
      )

      :error
  end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end
end
