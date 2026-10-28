defmodule DuskmoonStorybook.Integration.StoryTailwindPlug do
  @moduledoc false
  @behaviour Plug

  def init(opts), do: opts

  def call(%{request_path: "/"} = conn, opts) do
    {story, _bindings} = Code.eval_file(opts[:story_file])

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(200, """
    <link rel="stylesheet" href="/assets/css/app.css">
    #{story}
    <script>
      window.browserErrors = [];
      window.pageIdentity = crypto.randomUUID();
      sessionStorage.loads = String(Number(sessionStorage.loads || 0) + 1);
      addEventListener('error', event => window.browserErrors.push(event.message || event.target.src || event.target.href), true);
      addEventListener('unhandledrejection', event => window.browserErrors.push(String(event.reason)));
    </script>
    <script type="module" src="/@duskmoon_bundler/client.js"></script>
    """)
  end

  def call(%{request_path: "/assets/css/app.css"} = conn, opts) do
    conn
    |> Plug.Conn.put_resp_content_type("text/css")
    |> Plug.Conn.put_resp_header("cache-control", "no-store")
    |> Plug.Conn.send_resp(200, File.read!(opts[:css_file]))
  end

  def call(conn, opts) do
    case DuskmoonBundler.DevServer.call(conn, opts[:dev_server]) do
      %{halted: true} = conn -> conn
      conn -> Plug.Conn.send_resp(conn, 404, "not found")
    end
  end
end

defmodule DuskmoonStorybook.Integration.StoryTailwindHMRTest do
  use ExUnit.Case, async: false

  @moduletag :integration
  @moduletag :tmp_dir
  alias DuskmoonBundler.Integration.CDPBrowser

  setup_all do
    {:ok, browser} = CDPBrowser.start_link()
    on_exit(fn -> CDPBrowser.stop(browser) end)
    %{browser: browser}
  end

  test "editing a story hot-applies a new Tailwind utility without reloading", %{
    tmp_dir: tmp_dir,
    browser: browser
  } do
    on_exit(fn -> File.rm_rf!(tmp_dir) end)
    assets_dir = Path.join(tmp_dir, "assets")
    storybook_dir = Path.join(tmp_dir, "storybook")
    outdir = Path.join(tmp_dir, "css_out")
    File.mkdir_p!(assets_dir)
    File.mkdir_p!(storybook_dir)
    story_file = Path.join(storybook_dir, "button.story.exs")
    File.write!(story_file, ~S|~s(<button id="story-button" class="flex">Story</button>)|)

    start_supervised!(
      {DuskmoonBundler.Watcher,
       root: assets_dir,
       watch_dirs: [storybook_dir],
       tailwind: true,
       tailwind_outdir: outdir,
       name: __MODULE__}
    )

    css_file = Path.join(outdir, "app.css")
    refute File.read!(css_file) =~ "padding: 39px"
    Registry.register(DuskmoonBundler.HMR.Registry, :clients, nil)
    existing_clients = Registry.lookup(DuskmoonBundler.HMR.Registry, :clients)

    server =
      start_supervised!(
        {Gaoxy.HTTP,
         plug:
           {DuskmoonStorybook.Integration.StoryTailwindPlug,
            story_file: story_file,
            css_file: css_file,
            dev_server: DuskmoonBundler.DevServer.init(root: assets_dir, vendor_prebundle: false)},
         port: 0,
         ip: {127, 0, 0, 1}}
      )

    %{local: {:ok, {_ip, port}}} = Gaoxy.info(server, :http)
    {:ok, page} = CDPBrowser.new_page(browser)
    on_exit(fn -> CDPBrowser.close_page(page) end)
    :ok = CDPBrowser.goto(page, "http://127.0.0.1:#{port}/")
    assert wait_for_client(existing_clients)

    # Emulate a template DOM patch before its newly introduced utility arrives.
    assert {:ok, %{"padding" => "0px", "identity" => identity}} =
             CDPBrowser.evaluate(page, """
             document.querySelector('#story-button').classList.add('p-[39px]');
             ({padding: getComputedStyle(document.querySelector('#story-button')).paddingTop,
               identity: window.pageIdentity})
             """)

    File.write!(
      story_file,
      ~S|~s(<button id="story-button" class="flex p-[39px]">Story</button>)|
    )

    File.touch!(story_file, {{2040, 1, 1}, {0, 0, 1}})

    assert_receive {:duskmoon_bundler_hmr, :update,
                    %{path: "assets/css/app.css", changes: [:style]}},
                   5_000

    assert File.read!(css_file) =~ "padding: 39px;"

    assert {:ok, %{"padding" => "39px", "identity" => ^identity, "loads" => "1", "errors" => []}} =
             CDPBrowser.evaluate(
               page,
               """
               (async () => {
                 const deadline = performance.now() + 5000;
                 while (getComputedStyle(document.querySelector('#story-button')).paddingTop !== '39px' && performance.now() < deadline)
                   await new Promise(resolve => setTimeout(resolve, 20));
                 return {padding: getComputedStyle(document.querySelector('#story-button')).paddingTop,
                   identity: window.pageIdentity, loads: sessionStorage.loads, errors: window.browserErrors};
               })()
               """,
               timeout: 6_000
             )
  end

  defp wait_for_client(existing_clients, attempts \\ 40)
  defp wait_for_client(_existing_clients, 0), do: false

  defp wait_for_client(existing_clients, attempts) do
    if Registry.lookup(DuskmoonBundler.HMR.Registry, :clients) -- existing_clients == [] do
      Process.sleep(50)
      wait_for_client(existing_clients, attempts - 1)
    else
      true
    end
  end
end
