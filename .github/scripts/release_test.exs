Code.require_file("release_support.exs", __DIR__)
ExUnit.start()

defmodule ReleasePlanningTest do
  use ExUnit.Case, async: true

  test "stable versions and immutable refs reject arbitrary payloads" do
    assert "9.16.17" = ReleaseSupport.stable!("9.16.17")
    assert_raise RuntimeError, fn -> ReleaseSupport.stable!("9.16.17-dev") end
    assert_raise RuntimeError, fn -> ReleaseSupport.sha!("main") end
  end

  test "publication follows dependencies and detects cycles" do
    assert ["runtime", "bundler"] =
             ReleaseSupport.order!(%{"bundler" => ["runtime"], "runtime" => []})

    assert_raise RuntimeError, fn -> ReleaseSupport.order!(%{"a" => ["b"], "b" => ["a"]}) end
  end

  test "native retry requires every final immutable asset digest" do
    assets = Map.new(1..47, &{"asset-#{&1}.tar.gz", String.duplicate("a", 64)})
    assert ReleaseSupport.reusable_native?(%{"native_assets" => assets})

    refute ReleaseSupport.reusable_native?(%{
             "native_assets" => Map.delete(assets, "asset-1.tar.gz")
           })

    refute ReleaseSupport.reusable_native?(%{
             "native_assets" => Map.put(assets, "asset-1.tar.gz", "invalid")
           })
  end

  test "retry reuses matching output and refuses replacement" do
    assert :create = ReleaseSupport.immutable_action(nil, "sha256:a")
    assert :reuse = ReleaseSupport.immutable_action("sha256:a", "sha256:a")
    assert_raise RuntimeError, fn -> ReleaseSupport.immutable_action("sha256:a", "sha256:b") end
  end

  test "partial release and missing platform validation prevent UI adoption" do
    state = %{
      "public_assets_verified" => true,
      "registry_consumer_verified" => true,
      "musl_amd64_verified" => true,
      "musl_arm64_verified" => true,
      "packages" => ReleaseSupport.cohort()
    }

    assert ReleaseSupport.adoption_ready?(state)
    refute ReleaseSupport.adoption_ready?(Map.put(state, "packages", ["duskmoon_bundler"]))
    refute ReleaseSupport.adoption_ready?(Map.put(state, "musl_arm64_verified", false))
    refute ReleaseSupport.adoption_ready?(Map.put(state, "public_assets_verified", false))
  end
end

defmodule HexDocsPublicationTest do
  use ExUnit.Case, async: true
  @moduletag :tmp_dir

  setup %{tmp_dir: tmp_dir} do
    root = Path.expand(tmp_dir)
    bin = Path.join(root, "bin")
    File.mkdir_p!(bin)
    tarball = Path.join(root, "phoenix_duskmoon-10.0.0.tar")
    File.write!(tarball, "verified immutable UI package")

    File.write!(Path.join(bin, "curl"), """
    #!/bin/sh
    printf '%s\n' "$*" >> "$DOC_TEST_CURL_LOG"
    for url do :; done
    test "$url" = 'https://hexdocs.pm/phoenix_duskmoon/10.0.0/index.html' || exit 91
    if [ -f "$DOC_TEST_QUERY" ]; then
      status="$DOC_TEST_FINAL"
    else
      : > "$DOC_TEST_QUERY"
      status="$DOC_TEST_INITIAL"
    fi
    case "$*" in *--fail*) test "$status" = 200 || exit 22 ;; esac
    printf '%s' "$status"
    """)

    File.write!(Path.join(bin, "mix"), """
    #!/bin/sh
    printf '%s\n' "$*" >> "$DOC_TEST_MIX_LOG"
    case "$*" in
      'deps.get') ;;
      'hex.publish docs --yes')
        if [ "$DOC_TEST_MUTATE" = 1 ]; then printf changed > "$DOC_TEST_TARBALL"; fi ;;
      *) exit 92 ;;
    esac
    """)

    for tool <- ~w(curl mix), do: File.chmod!(Path.join(bin, tool), 0o755)

    %{
      root: root,
      tarball: tarball,
      mix_log: Path.join(root, "mix.log"),
      curl_log: Path.join(root, "curl.log"),
      env: [
        {"DOC_TEST_PATH", bin <> ":" <> System.fetch_env!("PATH")},
        {"DOC_TEST_SUPPORT", Path.join(__DIR__, "release_support.exs")},
        {"DOC_TEST_STAGE", root},
        {"DOC_TEST_TARBALL", tarball},
        {"DOC_TEST_QUERY", Path.join(root, "queried")},
        {"DOC_TEST_MIX_LOG", Path.join(root, "mix.log")},
        {"DOC_TEST_CURL_LOG", Path.join(root, "curl.log")},
        {"DOC_TEST_INITIAL", "404"},
        {"DOC_TEST_FINAL", "200"},
        {"DOC_TEST_MUTATE", "0"}
      ]
    }
  end

  test "publishes missing versioned docs without republishing or mutating the package", ctx do
    {output, 0} = run(ctx)
    assert output =~ "Published and verified HexDocs phoenix_duskmoon 10.0.0"
    assert File.read!(ctx.mix_log) == "deps.get\nhex.publish docs --yes\n"
    assert File.read!(ctx.tarball) == "verified immutable UI package"
    assert [lookup, verify] = String.split(File.read!(ctx.curl_log), "\n", trim: true)
    refute lookup =~ "--retry"
    assert verify =~ "--retry 12 --retry-delay 5 --retry-all-errors"
  end

  test "retry reuses reachable versioned docs without a Mix command", ctx do
    {output, 0} = run(ctx, [{"DOC_TEST_INITIAL", "200"}])
    assert output =~ "Reusing reachable HexDocs phoenix_duskmoon 10.0.0"
    refute File.exists?(ctx.mix_log)
    assert File.read!(ctx.tarball) == "verified immutable UI package"
  end

  test "unsuccessful live documentation verification fails completion", ctx do
    {output, status} = run(ctx, [{"DOC_TEST_FINAL", "503"}])
    assert status != 0
    assert output =~ "failed (22)"
    assert File.read!(ctx.mix_log) == "deps.get\nhex.publish docs --yes\n"
    assert File.read!(ctx.tarball) == "verified immutable UI package"
  end

  test "unexpected lookup response fails without publishing", ctx do
    {output, status} = run(ctx, [{"DOC_TEST_INITIAL", "503"}])
    assert status != 0
    assert output =~ "HexDocs lookup failed: HTTP 503"
    refute File.exists?(ctx.mix_log)
  end

  test "documentation commands cannot change the verified package archive", ctx do
    {output, status} = run(ctx, [{"DOC_TEST_MUTATE", "1"}])
    assert status != 0
    assert output =~ "immutable output conflict"
    assert [_lookup] = String.split(File.read!(ctx.curl_log), "\n", trim: true)
  end

  defp run(ctx, overrides \\ []) do
    env = Map.new(ctx.env ++ overrides) |> Map.to_list()

    System.cmd(
      System.find_executable("elixir"),
      [
        "-e",
        """
        System.put_env("PATH", System.fetch_env!("DOC_TEST_PATH"))
        Code.require_file(System.fetch_env!("DOC_TEST_SUPPORT"))
        ReleaseSupport.hex_docs_publish!("phoenix_duskmoon", "10.0.0", System.fetch_env!("DOC_TEST_STAGE"))
        """
      ],
      env: env,
      stderr_to_stdout: true
    )
  end
end
