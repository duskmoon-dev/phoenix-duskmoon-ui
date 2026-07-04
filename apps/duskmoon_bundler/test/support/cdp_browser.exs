defmodule DuskmoonBundler.Integration.CDPBrowser do
  @moduledoc false

  use GenServer

  @startup_timeout 10_000
  @default_timeout 5_000

  defmodule Page do
    @moduledoc false

    defstruct [:browser, :context_id, :target_id, :session_id]
  end

  defmodule Client do
    @moduledoc false

    defstruct [:conn, :ws, :ref, next_id: 1, events: []]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts)
  end

  def stop(browser) do
    GenServer.call(browser, :stop, @default_timeout)
  end

  def new_page(browser, opts \\ []) do
    GenServer.call(browser, {:new_page, opts}, call_timeout(opts))
  end

  def close_page(%Page{browser: browser} = page) do
    GenServer.call(browser, {:close_page, page}, @default_timeout)
  end

  def goto(%Page{browser: browser} = page, url, opts \\ []) do
    GenServer.call(browser, {:goto, page, url, opts}, call_timeout(opts))
  end

  def evaluate(%Page{browser: browser} = page, expression, opts \\ []) do
    GenServer.call(browser, {:evaluate, page, expression, opts}, call_timeout(opts))
  end

  @impl true
  def init(opts) do
    with {:ok, executable} <- chromium_executable(opts),
         {:ok, profile_dir} <- profile_dir() do
      case launch_and_connect(executable, profile_dir) do
        {:ok, port, client} ->
          {:ok, %{port: port, profile_dir: profile_dir, client: client}}

        {:error, reason, port} ->
          close_port(port)
          File.rm_rf(profile_dir)
          {:stop, reason}

        {:error, reason} ->
          File.rm_rf(profile_dir)
          {:stop, reason}
      end
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_call({:new_page, opts}, _from, state) do
    timeout = timeout(opts)

    with {:ok, %{"browserContextId" => context_id}, state} <-
           cdp_call(state, "Target.createBrowserContext", %{}, nil, timeout),
         {:ok, %{"targetId" => target_id}, state} <-
           cdp_call(
             state,
             "Target.createTarget",
             %{"url" => "about:blank", "browserContextId" => context_id},
             nil,
             timeout
           ),
         {:ok, %{"sessionId" => session_id}, state} <-
           cdp_call(
             state,
             "Target.attachToTarget",
             %{"targetId" => target_id, "flatten" => true},
             nil,
             timeout
           ),
         {:ok, _result, state} <- cdp_call(state, "Page.enable", %{}, session_id, timeout),
         {:ok, _result, state} <- cdp_call(state, "Runtime.enable", %{}, session_id, timeout) do
      page = %Page{
        browser: self(),
        context_id: context_id,
        target_id: target_id,
        session_id: session_id
      }

      {:reply, {:ok, page}, state}
    else
      {:error, reason, state} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:close_page, %Page{} = page}, _from, state) do
    state = cdp_call_ignore(state, "Target.closeTarget", %{"targetId" => page.target_id})

    state =
      cdp_call_ignore(state, "Target.disposeBrowserContext", %{
        "browserContextId" => page.context_id
      })

    {:reply, :ok, state}
  end

  def handle_call({:goto, %Page{} = page, url, opts}, _from, state) do
    timeout = timeout(opts)

    case cdp_call(state, "Page.navigate", %{"url" => url}, page.session_id, timeout) do
      {:ok, _result, state} ->
        case wait_event(state, page.session_id, "Page.loadEventFired", timeout) do
          {:ok, _event, state} -> {:reply, :ok, state}
          {:error, reason, state} -> {:reply, {:error, reason}, state}
        end

      {:error, reason, state} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:evaluate, %Page{} = page, expression, opts}, _from, state) do
    timeout = timeout(opts)

    params = %{
      "expression" => expression,
      "returnByValue" => true,
      "awaitPromise" => true,
      "timeout" => timeout
    }

    case cdp_call(state, "Runtime.evaluate", params, page.session_id, timeout) do
      {:ok, %{"exceptionDetails" => details}, state} ->
        {:reply, {:error, details}, state}

      {:ok, %{"result" => remote_object}, state} ->
        {:reply, {:ok, remote_value(remote_object)}, state}

      {:error, reason, state} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:stop, _from, state) do
    _state = cdp_call_ignore(state, "Browser.close", %{})
    close_port(state.port)
    wait_for_port_exit(state.port, 1_000)

    {:stop, :normal, :ok, state}
  end

  @impl true
  def handle_info({_port, {:data, _data}}, state), do: {:noreply, state}

  def handle_info({_port, {:exit_status, status}}, state),
    do: {:stop, {:chromium_exit, status}, state}

  @impl true
  def terminate(_reason, state) do
    close_port(state.port)
  rescue
    _ -> :ok
  after
    rm_rf_retry(state.profile_dir)
  end

  defp launch_and_connect(executable, profile_dir) do
    case launch_chromium(executable, profile_dir) do
      {:ok, port} ->
        with {:ok, ws_url} <- wait_for_browser_ws_url(profile_dir, @startup_timeout),
             {:ok, client} <- connect(ws_url, @startup_timeout) do
          {:ok, port, client}
        else
          {:error, reason} -> {:error, reason, port}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp close_port(port) when is_port(port) do
    Port.close(port)
  rescue
    _ -> :ok
  end

  defp close_port(_port), do: :ok

  defp wait_for_port_exit(port, timeout) when is_port(port) do
    receive do
      {^port, {:exit_status, _status}} -> :ok
    after
      timeout -> :ok
    end
  end

  defp wait_for_port_exit(_port, _timeout), do: :ok

  defp rm_rf_retry(path, attempts \\ 20)

  defp rm_rf_retry(_path, 0), do: :ok

  defp rm_rf_retry(path, attempts) do
    case File.rm_rf(path) do
      {:ok, _files} ->
        :ok

      {:error, _reason, _file} ->
        Process.sleep(50)
        rm_rf_retry(path, attempts - 1)
    end
  end

  defp cdp_call_ignore(state, method, params) do
    case cdp_call(state, method, params, nil, @default_timeout) do
      {:ok, _result, state} -> state
      {:error, _reason, state} -> state
    end
  end

  defp cdp_call(%{client: client} = state, method, params, session_id, timeout) do
    case send_command(client, method, params, session_id) do
      {:ok, id, client} ->
        %{state | client: client}
        |> recv_response(id, timeout)

      {:error, reason, client} ->
        {:error, reason, %{state | client: client}}
    end
  end

  defp send_command(%Client{} = client, method, params, session_id) do
    id = client.next_id

    payload =
      %{"id" => id, "method" => method, "params" => params}
      |> maybe_put_session_id(session_id)
      |> Jason.encode!()

    with {:ok, ws, data} <- Mint.WebSocket.encode(client.ws, {:text, payload}),
         {:ok, conn} <- Mint.WebSocket.stream_request_body(client.conn, client.ref, data) do
      {:ok, id, %{client | conn: conn, ws: ws, next_id: id + 1}}
    else
      {:error, conn, reason} -> {:error, reason, %{client | conn: conn}}
      {:error, reason} -> {:error, reason, client}
    end
  end

  defp maybe_put_session_id(payload, nil), do: payload
  defp maybe_put_session_id(payload, session_id), do: Map.put(payload, "sessionId", session_id)

  defp recv_response(state, id, timeout) do
    deadline = System.monotonic_time(:millisecond) + timeout
    recv_response_loop(state, id, deadline)
  end

  defp recv_response_loop(state, id, deadline) do
    case recv_messages(state, deadline) do
      {:ok, messages, state} ->
        case find_response(messages, id, state) do
          {:ok, result, state} -> {:ok, result, state}
          {:error, reason, state} -> {:error, reason, state}
          {:cont, state} -> recv_response_loop(state, id, deadline)
        end

      {:error, reason, state} ->
        {:error, reason, state}
    end
  end

  defp find_response(messages, id, state) do
    Enum.reduce_while(messages, {:cont, state}, fn
      %{"id" => ^id, "error" => error}, {:cont, state} ->
        {:halt, {:error, error, state}}

      %{"id" => ^id, "result" => result}, {:cont, state} ->
        {:halt, {:ok, result, state}}

      message, {:cont, state} ->
        {:cont, {:cont, queue_event(state, message)}}
    end)
  end

  defp wait_event(state, session_id, method, timeout) do
    deadline = System.monotonic_time(:millisecond) + timeout
    wait_event_loop(state, session_id, method, deadline)
  end

  defp wait_event_loop(state, session_id, method, deadline) do
    case pop_event(state, session_id, method) do
      {:ok, event, state} ->
        {:ok, event, state}

      :error ->
        case recv_messages(state, deadline) do
          {:ok, messages, state} ->
            messages
            |> Enum.reduce(state, &queue_event(&2, &1))
            |> wait_event_loop(session_id, method, deadline)

          {:error, reason, state} ->
            {:error, reason, state}
        end
    end
  end

  defp recv_messages(state, deadline) do
    remaining = max(deadline - System.monotonic_time(:millisecond), 0)

    if remaining == 0 do
      {:error, :timeout, state}
    else
      do_recv_messages(state, remaining)
    end
  end

  defp do_recv_messages(%{client: %Client{} = client} = state, timeout) do
    case Mint.WebSocket.recv(client.conn, 0, timeout) do
      {:ok, conn, responses} ->
        decode_responses(%{state | client: %{client | conn: conn}}, responses)

      {:error, conn, %Mint.TransportError{reason: :timeout}, _responses} ->
        {:error, :timeout, %{state | client: %{client | conn: conn}}}

      {:error, conn, reason, _responses} ->
        {:error, reason, %{state | client: %{client | conn: conn}}}
    end
  end

  defp decode_responses(state, responses) do
    Enum.reduce_while(responses, {:ok, [], state}, fn
      {:data, ref, data}, {:ok, messages, %{client: %Client{ref: ref} = client} = state} ->
        case Mint.WebSocket.decode(client.ws, data) do
          {:ok, ws, frames} ->
            messages = messages ++ Enum.flat_map(frames, &frame_messages/1)
            {:cont, {:ok, messages, %{state | client: %{client | ws: ws}}}}

          {:error, ws, reason} ->
            {:halt, {:error, reason, %{state | client: %{client | ws: ws}}}}
        end

      _response, acc ->
        {:cont, acc}
    end)
  end

  defp frame_messages({:text, text}), do: [Jason.decode!(text)]
  defp frame_messages({:binary, data}), do: [Jason.decode!(data)]
  defp frame_messages({:close, _code, _reason}), do: [%{"method" => "CDP.close"}]
  defp frame_messages(_frame), do: []

  defp queue_event(%{client: %Client{} = client} = state, message) do
    %{state | client: %{client | events: client.events ++ [message]}}
  end

  defp pop_event(%{client: %Client{} = client} = state, session_id, method) do
    case Enum.split_while(client.events, &(not matching_event?(&1, session_id, method))) do
      {_before, []} ->
        :error

      {before, [event | after_events]} ->
        {:ok, event, %{state | client: %{client | events: before ++ after_events}}}
    end
  end

  defp matching_event?(%{"method" => method, "sessionId" => session_id}, session_id, method),
    do: true

  defp matching_event?(_event, _session_id, _method), do: false

  defp remote_value(%{"unserializableValue" => value}), do: value
  defp remote_value(%{"value" => value}), do: value
  defp remote_value(%{"type" => "undefined"}), do: nil
  defp remote_value(_remote_object), do: nil

  defp connect(ws_url, timeout) do
    uri = URI.parse(ws_url)

    with {:ok, conn} <- Mint.HTTP.connect(:http, uri.host, uri.port, mode: :passive),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(:ws, conn, uri.path, []),
         {:ok, conn, responses} <- Mint.WebSocket.recv(conn, 0, timeout),
         {:ok, headers} <- websocket_headers(responses, ref),
         {:ok, conn, ws} <- Mint.WebSocket.new(conn, ref, 101, headers, mode: :passive) do
      {:ok, %Client{conn: conn, ws: ws, ref: ref}}
    end
  end

  defp websocket_headers(responses, ref) do
    case Enum.find(responses, &match?({:status, ^ref, 101}, &1)) do
      nil ->
        {:error, :websocket_upgrade_failed}

      _status ->
        {:ok, Enum.find_value(responses, [], &headers_for(&1, ref))}
    end
  end

  defp headers_for({:headers, ref, headers}, ref), do: headers
  defp headers_for(_response, _ref), do: nil

  defp launch_chromium(executable, profile_dir) do
    args = [
      "--headless",
      "--disable-background-networking",
      "--disable-dev-shm-usage",
      "--disable-gpu",
      "--no-sandbox",
      "--no-default-browser-check",
      "--no-first-run",
      "--remote-allow-origins=*",
      "--remote-debugging-port=0",
      "--user-data-dir=#{profile_dir}",
      "about:blank"
    ]

    try do
      port =
        Port.open({:spawn_executable, executable}, [
          :binary,
          :exit_status,
          :stderr_to_stdout,
          :use_stdio,
          {:args, args}
        ])

      {:ok, port}
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  defp wait_for_browser_ws_url(profile_dir, timeout) do
    path = Path.join(profile_dir, "DevToolsActivePort")
    deadline = System.monotonic_time(:millisecond) + timeout
    wait_for_browser_ws_url_loop(path, deadline)
  end

  defp wait_for_browser_ws_url_loop(path, deadline) do
    case read_browser_ws_url(path) do
      {:ok, ws_url} ->
        {:ok, ws_url}

      :error ->
        if System.monotonic_time(:millisecond) >= deadline do
          {:error, :devtools_endpoint_timeout}
        else
          Process.sleep(50)
          wait_for_browser_ws_url_loop(path, deadline)
        end
    end
  end

  defp read_browser_ws_url(path) do
    with {:ok, contents} <- File.read(path),
         [port, ws_path | _rest] <- String.split(contents, "\n", trim: true) do
      {:ok, "ws://127.0.0.1:#{port}#{ws_path}"}
    else
      _ -> :error
    end
  end

  defp chromium_executable(opts) do
    [
      opts[:executable],
      System.get_env("CHROME_EXECUTABLE"),
      System.get_env("CHROME_BIN"),
      System.get_env("CHROMIUM_EXECUTABLE"),
      System.find_executable("chrome"),
      System.find_executable("chromium"),
      System.find_executable("chromium-browser"),
      System.find_executable("google-chrome"),
      System.find_executable("google-chrome-stable")
    ]
    |> Enum.find(&executable?/1)
    |> case do
      nil -> {:error, :chromium_not_found}
      path -> {:ok, path}
    end
  end

  defp executable?(nil), do: false
  defp executable?(path), do: File.exists?(path)

  defp profile_dir do
    path = Path.join(System.tmp_dir!(), "duskmoon-cdp-#{System.unique_integer([:positive])}")

    case File.mkdir_p(path) do
      :ok -> {:ok, path}
      {:error, reason} -> {:error, reason}
    end
  end

  defp call_timeout(opts), do: timeout(opts) + 1_000
  defp timeout(opts), do: Keyword.get(opts, :timeout, @default_timeout)
end
