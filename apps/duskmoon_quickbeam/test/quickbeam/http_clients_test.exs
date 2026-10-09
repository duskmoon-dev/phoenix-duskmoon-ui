defmodule QuickBEAM.HTTPClientsTest do
  use ExUnit.Case, async: false

  defmodule EchoSocket do
    @behaviour WebSock
    def init(state), do: {:ok, state}

    def handle_in({"finish", [opcode: :text]}, state),
      do: {:stop, :normal, {4001, "finished"}, state}

    def handle_in({data, [opcode: opcode]}, state), do: {:push, {opcode, data}, state}
    def handle_info(_message, state), do: {:ok, state}
  end

  defmodule TestPlug do
    @behaviour Plug
    import Plug.Conn

    def init(opts), do: opts

    def call(%{request_path: "/echo"} = conn, _opts) do
      {:ok, body, conn} = read_body(conn)
      send_resp(conn, 200, body)
    end

    def call(%{request_path: "/redirect"} = conn, _opts) do
      conn |> put_resp_header("location", "/binary") |> send_resp(302, "")
    end

    def call(%{request_path: "/chunked"} = conn, _opts) do
      conn = send_chunked(conn, 200)
      {:ok, conn} = chunk(conn, <<0, 255>>)
      {:ok, conn} = chunk(conn, <<128, 1>>)
      conn
    end

    def call(%{request_path: "/gzip-binary"} = conn, _opts) do
      conn
      |> put_resp_header("content-encoding", "gzip")
      |> send_resp(200, :zlib.gzip(<<0, 255, 128, 1>>))
    end

    def call(%{request_path: "/gzip-chunked-binary"} = conn, _opts) do
      <<first::binary-size(10), last::binary>> = :zlib.gzip(<<0, 255, 128, 1>>)
      conn = conn |> put_resp_header("content-encoding", "gzip") |> send_chunked(200)
      {:ok, conn} = chunk(conn, first)
      {:ok, conn} = chunk(conn, last)
      conn
    end

    def call(%{request_path: "/ws"} = conn, _opts) do
      conn
      |> put_resp_header("sec-websocket-protocol", "echo")
      |> WebSockAdapter.upgrade(EchoSocket, [], [])
    end

    def call(%{request_path: "/sse-stop"} = conn, _opts), do: send_resp(conn, 204, "")

    def call(%{request_path: "/sse"} = conn, _opts) do
      conn
      |> put_resp_content_type("text/event-stream")
      |> send_resp(200, "id: cursor\nevent: update\ndata: hello\n\n")
    end

    def call(conn, _opts), do: send_resp(conn, 200, <<0, 255, 128, 1>>)
  end

  setup_all do
    for app <- [:duskmoon_quickbeam, :bandit, :websock_adapter] do
      {:ok, _} = Application.ensure_all_started(app)
    end

    QuickBEAM.Fetch.init()
    :ok
  end

  setup do
    unless Process.whereis(QuickBEAM.NetworkSupervisor) do
      start_supervised!(
        {DynamicSupervisor, strategy: :one_for_one, name: QuickBEAM.NetworkSupervisor}
      )
    end

    server =
      start_supervised!({Bandit, plug: TestPlug, port: 0, ip: :loopback, startup_log: false})

    {:ok, {_address, port}} = ThousandIsland.listener_info(server)
    {:ok, url: "http://127.0.0.1:#{port}"}
  end

  test "fetch preserves raw buffered, chunked and request bytes", %{url: url} do
    for path <- ["/binary", "/chunked", "/gzip-binary", "/gzip-chunked-binary"] do
      assert %{"status" => 200, "body" => {:bytes, <<0, 255, 128, 1>>}} = fetch(url <> path)
    end

    assert %{"body" => {:bytes, <<0, 255, 128, 1>>}} =
             fetch(url <> "/echo", %{"method" => "POST", "body" => <<0, 255, 128, 1>>})
  end

  test "fetch returns final redirect metadata and respects redirect modes", %{url: url} do
    assert %{"status" => 200, "url" => final_url, "redirected" => true} =
             fetch(url <> "/redirect")

    assert final_url == url <> "/binary"

    assert %{"status" => 302, "redirected" => false} =
             fetch(url <> "/redirect", %{"redirect" => "manual"})

    assert_raise RuntimeError, "fetch failed: :redirect", fn ->
      fetch(url <> "/redirect", %{"redirect" => "error"})
    end
  end

  test "fetch cancellation closes the network connection and releases its controller" do
    parent = self()

    {url, server} =
      raw_server(fn listener ->
        {:ok, socket} = :gen_tcp.accept(listener, 2_000)
        {:ok, _request} = :gen_tcp.recv(socket, 0, 2_000)
        send(parent, :request_received)
        send(parent, {:socket_result, :gen_tcp.recv(socket, 0, 2_000)})
        :gen_tcp.close(socket)
      end)

    id = "cancel-#{System.unique_integer([:positive])}"

    task =
      Task.async(fn ->
        try do
          fetch(url, %{"fetchId" => id})
        rescue
          error -> {:error, Exception.message(error)}
        end
      end)

    assert_receive :request_received, 2_000
    assert [{^id, controller}] = :ets.lookup(:quickbeam_fetch_requests, id)
    assert nil == QuickBEAM.Fetch.cancel([id])
    assert {:error, "fetch failed: :aborted"} = Task.await(task, 2_000)
    assert_receive {:socket_result, {:error, :closed}}, 2_000
    assert [] == :ets.lookup(:quickbeam_fetch_requests, id)
    refute Process.alive?(controller)
    Task.await(server, 2_000)
  end

  test "cancellation before asynchronous registration prevents the request" do
    id = "pre-cancel-#{System.unique_integer([:positive])}"
    assert nil == QuickBEAM.Fetch.cancel([id])

    assert_raise RuntimeError, "fetch failed: :aborted", fn ->
      fetch("http://127.0.0.1:1", %{"fetchId" => id})
    end

    assert [] == :ets.lookup(:quickbeam_fetch_requests, id)
  end

  test "EventSource uses upstream parsing and reconnects with Last-Event-ID" do
    parent = self()

    {url, server} =
      raw_server(fn listener ->
        for attempt <- 1..2 do
          {:ok, socket} = :gen_tcp.accept(listener, 4_000)
          {:ok, request} = :gen_tcp.recv(socket, 0, 2_000)
          send(parent, {:sse_request, attempt, request})

          body =
            "retry: 10\r\nid: cursor-#{attempt}\r\nevent: update\r\ndata: first\r\ndata:second\r\n\r\n"

          :ok =
            :gen_tcp.send(
              socket,
              "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\n\r\n" <> body
            )

          if attempt == 2 do
            send(parent, :sse_second_connected)
            assert {:error, :closed} = :gen_tcp.recv(socket, 0, 2_000)
          end

          :gen_tcp.close(socket)
        end
      end)

    source = QuickBEAM.EventSource.open([url, "sse"], self())
    assert_receive {:eventsource_open, "sse"}, 2_000

    assert_receive {:eventsource_event, "sse",
                    %{type: "update", data: "first\nsecond", id: "cursor-1"}},
                   2_000

    assert_receive {:eventsource_error, "sse", _reason, 0}, 2_000
    assert_receive {:sse_request, 2, request}, 2_000
    assert String.downcase(request) =~ "last-event-id: cursor-1"
    assert_receive {:eventsource_open, "sse"}, 2_000
    assert_receive :sse_second_connected, 2_000
    assert nil == QuickBEAM.EventSource.close([source])
    refute Process.alive?(source)
    Task.await(server, 2_000)
  end

  test "WebSocket preserves subprotocol, text, binary and clean close metadata", %{url: url} do
    id =
      QuickBEAM.WebSocket.connect(
        [String.replace(url, "http:", "ws:") <> "/ws", ["echo"]],
        self()
      )

    assert_receive {:websocket_started, ^id, pid}, 2_000
    assert_receive {:websocket_event, ["__ws_open", ^id, "echo"]}, 2_000
    GenServer.cast(pid, {:send, "text", "hello"})
    assert_receive {:websocket_event, ["__ws_message", ^id, "hello"]}, 2_000
    GenServer.cast(pid, {:send, "binary", <<0, 255, 128>>})
    assert_receive {:websocket_event, ["__ws_message", ^id, {:bytes, <<0, 255, 128>>}]}, 2_000
    GenServer.cast(pid, {:send, "text", "finish"})
    assert_receive {:websocket_event, ["__ws_close", ^id, 4001, "finished", true]}, 2_000
  end

  test "WebSocket sends a client close and forwards the peer's close response", %{url: url} do
    id =
      QuickBEAM.WebSocket.connect(
        [String.replace(url, "http:", "ws:") <> "/ws", ["echo"]],
        self()
      )

    assert_receive {:websocket_started, ^id, pid}, 2_000
    assert_receive {:websocket_event, ["__ws_open", ^id, "echo"]}, 2_000
    GenServer.cast(pid, {:close, 4001, "client finished"})
    # Bandit acknowledges client closes with its own normal close frame.
    assert_receive {:websocket_event, ["__ws_close", ^id, 1000, "", true]}, 2_000
  end

  test "the native JavaScript bridge returns fetch bytes and receives WebSocket ArrayBuffers", %{
    url: url
  } do
    {:ok, runtime} = QuickBEAM.start(apis: [:fetch, :websocket, :url])
    on_exit(fn -> if Process.alive?(runtime), do: QuickBEAM.stop(runtime) end)

    for path <- ["/chunked", "/gzip-binary", "/gzip-chunked-binary"] do
      assert {:ok, [0, 255, 128, 1]} =
               QuickBEAM.eval(
                 runtime,
                 "Array.from(new Uint8Array(await (await fetch(#{inspect(url <> path)})).arrayBuffer()))",
                 timeout: 3_000
               )
    end

    ws_url = String.replace(url, "http:", "ws:") <> "/ws"

    assert {:ok, %{"protocol" => "echo", "binary" => true, "bytes" => [0, 255, 128]}} =
             QuickBEAM.eval(
               runtime,
               """
               await new Promise((resolve, reject) => {
                 const socket = new WebSocket(#{inspect(ws_url)}, ['echo']);
                 socket.binaryType = 'arraybuffer';
                 socket.onerror = reject;
                 socket.onopen = () => socket.send(new Uint8Array([0, 255, 128]));
                 socket.onmessage = event => {
                   const result = {protocol: socket.protocol, binary: event.data instanceof ArrayBuffer, bytes: Array.from(new Uint8Array(event.data))};
                   socket.onclose = () => resolve(result);
                   socket.close();
                 };
               })
               """,
               timeout: 3_000
             )
  end

  test "closing a native JavaScript WebSocket ignores queued open events", %{url: url} do
    {:ok, runtime} = QuickBEAM.start(apis: [:websocket, :url])
    on_exit(fn -> if Process.alive?(runtime), do: QuickBEAM.stop(runtime) end)
    ws_url = String.replace(url, "http:", "ws:") <> "/ws"

    assert {:ok, %{"opens" => 0, "state" => 3}} =
             QuickBEAM.eval(
               runtime,
               """
               await new Promise(resolve => {
                 const socket = new WebSocket(#{inspect(ws_url)}, ['echo']);
                 let opens = 0;
                 socket.onopen = () => { opens++; };
                 socket.onclose = () => resolve({opens, state: socket.readyState});
                 socket.close();
                 // Simulate an open event already queued when close() was called.
                 socket._onOpen('echo');
               })
               """,
               timeout: 3_000
             )
  end

  test "pooled JavaScript contexts receive SSE messages and terminal state", %{url: url} do
    pool = start_supervised!(QuickBEAM.ContextPool)
    context = start_supervised!({QuickBEAM.Context, pool: pool, apis: [:eventsource]})

    assert {:ok, %{"data" => "hello", "id" => "cursor", "state" => 2}} =
             QuickBEAM.Context.eval(
               context,
               """
               await new Promise((resolve, reject) => {
                 const source = new EventSource(#{inspect(url <> "/sse")});
                 source.addEventListener('update', event => {
                   source.close();
                   resolve({data: event.data, id: event.lastEventId, state: source.readyState});
                 });
                 source.onerror = reject;
               })
               """,
               timeout: 3_000
             )

    assert {:ok, 2} =
             QuickBEAM.Context.eval(
               context,
               """
               await new Promise(resolve => {
                 const source = new EventSource(#{inspect(url <> "/sse-stop")});
                 source.onerror = () => resolve(source.readyState);
               })
               """,
               timeout: 3_000
             )
  end

  test "JavaScript AbortSignal cancels the native network request" do
    parent = self()

    {url, server} =
      raw_server(fn listener ->
        {:ok, socket} = :gen_tcp.accept(listener, 2_000)
        {:ok, _request} = :gen_tcp.recv(socket, 0, 2_000)
        send(parent, {:js_socket_result, :gen_tcp.recv(socket, 0, 2_000)})
        :gen_tcp.close(socket)
      end)

    {:ok, runtime} = QuickBEAM.start(apis: [:fetch])
    on_exit(fn -> if Process.alive?(runtime), do: QuickBEAM.stop(runtime) end)

    assert {:ok, "stopped"} =
             QuickBEAM.eval(
               runtime,
               """
               const controller = new AbortController();
               setTimeout(() => controller.abort('stopped'), 100);
               try { await fetch(#{inspect(url)}, {signal: controller.signal}); } catch (reason) { reason; }
               """,
               timeout: 3_000
             )

    assert_receive {:js_socket_result, {:error, :closed}}, 2_000
    Task.await(server, 2_000)
  end

  test "EventSource closes permanently when the server returns 204", %{url: url} do
    source = QuickBEAM.EventSource.open([url <> "/sse-stop", "sse-stop"], self())
    ref = Process.monitor(source)
    assert_receive {:eventsource_error, "sse-stop", _reason, 2}, 2_000
    assert_receive {:DOWN, ^ref, :process, ^source, :normal}, 2_000
  end

  test "WebSocket adapter stops when its JavaScript owner exits", %{url: url} do
    parent = self()

    owner =
      spawn(fn ->
        id =
          QuickBEAM.WebSocket.connect(
            [String.replace(url, "http:", "ws:") <> "/ws", ["echo"]],
            self()
          )

        receive do
          {:websocket_started, ^id, pid} -> send(parent, {:adapter, pid})
        end

        receive do
          {:websocket_event, ["__ws_open", ^id, "echo"]} -> send(parent, :socket_open)
        end

        receive do
          :stop -> :ok
        end
      end)

    assert_receive {:adapter, adapter}, 2_000
    assert_receive :socket_open, 2_000
    connection = :sys.get_state(adapter).socket.pid
    connection_ref = Process.monitor(connection)
    ref = Process.monitor(adapter)
    send(owner, :stop)
    assert_receive {:DOWN, ^ref, :process, ^adapter, :normal}, 2_000
    assert_receive {:DOWN, ^connection_ref, :process, ^connection, _reason}, 2_000
  end

  defp fetch(url, opts \\ %{}) do
    QuickBEAM.Fetch.fetch([Map.merge(%{"url" => url, "method" => "GET", "headers" => []}, opts)])
  end

  defp raw_server(callback) do
    {:ok, listener} = :gen_tcp.listen(0, [:binary, active: false, ip: {127, 0, 0, 1}])
    {:ok, {_address, port}} = :inet.sockname(listener)
    on_exit(fn -> :gen_tcp.close(listener) end)

    task =
      Task.async(fn ->
        try do
          callback.(listener)
        after
          :gen_tcp.close(listener)
        end
      end)

    {"http://127.0.0.1:#{port}", task}
  end
end
