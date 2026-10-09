defmodule QuickBEAM.Fetch do
  @moduledoc false

  @known_methods %{
    "GET" => :get,
    "POST" => :post,
    "PUT" => :put,
    "DELETE" => :delete,
    "PATCH" => :patch,
    "HEAD" => :head,
    "OPTIONS" => :options
  }

  @table :quickbeam_fetch_requests

  @spec fetch([map()]) :: map()
  def fetch([%{"url" => url, "method" => method, "headers" => headers} = opts]) do
    :ok = ensure_table()
    fetch_id = opts["fetchId"] || System.unique_integer([:positive])
    controller = HTTP.AbortController.new()

    if not :ets.insert_new(@table, {fetch_id, controller}) do
      HTTP.AbortController.abort(controller)
    end

    try do
      if HTTP.AbortController.aborted?(controller), do: raise("fetch failed: :aborted")

      case HTTP.fetch(url,
             method: atomize_method(method),
             headers: Enum.map(headers, fn [key, value] -> {key, value} end),
             body: request_body(method, opts["body"]),
             redirect: opts["redirect"] || "follow",
             signal: controller,
             timeout: 30_000,
             connect_timeout: 10_000
           )
           |> HTTP.Promise.await() do
        %HTTP.Response{} = response ->
          %{
            "status" => response.status,
            "statusText" => response.status_text,
            "headers" =>
              Enum.map(HTTP.Headers.to_list(response.headers), fn {k, v} -> [k, v] end),
            "body" => {:bytes, HTTP.Response.read_all(response)},
            "url" => URI.to_string(response.url),
            "redirected" => response.redirected
          }

        {:error, :request_timeout} ->
          raise "fetch timed out"

        {:error, reason} ->
          raise "fetch failed: #{inspect(reason)}"
      end
    after
      :ets.delete(@table, fetch_id)
      Agent.stop(controller)
    end
  end

  @spec cancel([integer() | String.t()]) :: nil
  def cancel([fetch_id]) when is_integer(fetch_id) or is_binary(fetch_id) do
    :ok = ensure_table()
    cancel_request(fetch_id)
    nil
  end

  defp cancel_request(fetch_id) do
    case :ets.lookup(@table, fetch_id) do
      [{^fetch_id, controller}] when is_pid(controller) ->
        HTTP.AbortController.abort(controller)

      [{^fetch_id, {:cancelled, _ref}}] ->
        :ok

      [] ->
        # Cancellation may arrive before the asynchronous bridge task starts.
        cancelled = {:cancelled, make_ref()}

        if :ets.insert_new(@table, {fetch_id, cancelled}) do
          # Late cancellation after completion must not retain entries indefinitely.
          :timer.apply_after(30_000, :ets, :match_delete, [@table, {fetch_id, cancelled}])
        else
          cancel_request(fetch_id)
        end
    end
  catch
    :exit, {:noproc, _} -> :ok
    :exit, {:normal, _} -> :ok
  end

  defp request_body(method, _body) when method in ["GET", "HEAD", "OPTIONS", "DELETE"], do: nil
  defp request_body(_method, nil), do: nil
  defp request_body(_method, body) when is_binary(body), do: body
  defp request_body(_method, body) when is_list(body), do: :erlang.list_to_binary(body)
  defp request_body(_method, _body), do: <<>>

  defp atomize_method(method) do
    Map.get(@known_methods, method) ||
      raise ArgumentError, "unsupported HTTP method: #{method}"
  end

  @doc false
  def init, do: ensure_table()

  defp ensure_table do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    end

    :ok
  rescue
    ArgumentError ->
      # Another bridge task may have initialized the named table concurrently.
      if :ets.whereis(@table) == :undefined, do: reraise(ArgumentError, __STACKTRACE__), else: :ok
  end
end
