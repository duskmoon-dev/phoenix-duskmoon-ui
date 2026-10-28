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

defmodule BundlerLockTest do
  use ExUnit.Case, async: true
  @moduletag :tmp_dir

  test "derives the concrete synchronized version while allowing later 10.x releases", ctx do
    for version <- ["10.0.1", "10.1.0", "10.42.7"] do
      lock = cohort(version)
      path = write_lock(ctx.tmp_dir, lock)
      assert ReleaseSupport.bundler_version!(path) == version
      assert ReleaseSupport.bundler_lock!(path) == lock
    end
  end

  test "consumer subsets retain the exact registry entries and checksums", ctx do
    lock = cohort("10.0.1")
    path = write_lock(ctx.tmp_dir, lock)

    assert ReleaseSupport.bundler_lock!(path, ["duskmoon_bundler_runtime"]) ==
             Map.take(lock, [:duskmoon_bundler_runtime])
  end

  test "rejects incompatible major versions and prereleases", ctx do
    for version <- ["9.16.16", "11.0.0", "10.1.0-rc.1"] do
      path = write_lock(ctx.tmp_dir, cohort(version))
      assert_raise RuntimeError, fn -> ReleaseSupport.bundler_version!(path) end
    end
  end

  test "rejects missing or mixed cohort versions", ctx do
    lock = cohort("10.0.1")

    for package <- [:duskmoon_oxc] do
      path = write_lock(ctx.tmp_dir, Map.delete(lock, package))

      assert_raise RuntimeError, ~r/#{package} requires/, fn ->
        ReleaseSupport.bundler_version!(path)
      end

      path = write_lock(ctx.tmp_dir, Map.put(lock, package, entry(package, "10.1.0")))

      assert_raise RuntimeError, ~r/cohort versions differ/, fn ->
        ReleaseSupport.bundler_version!(path)
      end
    end
  end

  test "rejects non-Hex entries, package aliases, other repositories and missing checksums",
       ctx do
    lock = cohort("10.0.1")
    original = lock.duskmoon_oxc

    invalid = [
      {:git, "https://example.test/oxc.git", String.duplicate("a", 40), []},
      put_elem(original, 1, :another_package),
      put_elem(original, 6, "private"),
      put_elem(original, 3, nil),
      put_elem(original, 7, "invalid")
    ]

    for replacement <- invalid do
      path = write_lock(ctx.tmp_dir, Map.put(lock, :duskmoon_oxc, replacement))
      assert_raise RuntimeError, fn -> ReleaseSupport.bundler_version!(path) end
    end
  end

  defp cohort(version) do
    Map.new(ReleaseSupport.cohort(), fn name ->
      package = String.to_atom(name)
      {package, entry(package, version)}
    end)
  end

  defp entry(package, version) do
    {:hex, package, version, String.duplicate("a", 64), [:mix], [], "hexpm",
     String.duplicate("b", 64)}
  end

  defp write_lock(root, lock) do
    path = Path.join(root, "mix.lock")
    File.write!(path, inspect(lock, limit: :infinity))
    path
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
    test "$url" = "$DOC_TEST_URL" || exit 91
    if [ -f "$DOC_TEST_QUERY" ]; then
      status="$DOC_TEST_FINAL"
    else
      : > "$DOC_TEST_QUERY"
      status="$DOC_TEST_INITIAL"
    fi
    case "$*" in
      *--retry*)
        if [ -n "$DOC_TEST_RETRY_STDERR" ]; then printf '%s\n' "$DOC_TEST_RETRY_STDERR" >&2; fi ;;
    esac
    case "$*" in *--fail*) test "$status" = 200 || exit 22 ;; esac
    printf '%s' "${DOC_TEST_BODY:-$status}"
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

    File.write!(Path.join(bin, "npm"), """
    #!/bin/sh
    printf '%s\n' "$*" >> "$DOC_TEST_NPM_LOG"
    exit 93
    """)

    for tool <- ~w(curl mix npm), do: File.chmod!(Path.join(bin, tool), 0o755)

    %{
      root: root,
      tarball: tarball,
      mix_log: Path.join(root, "mix.log"),
      npm_log: Path.join(root, "npm.log"),
      curl_log: Path.join(root, "curl.log"),
      env: [
        {"DOC_TEST_PATH", bin <> ":" <> System.fetch_env!("PATH")},
        {"DOC_TEST_SUPPORT", Path.join(__DIR__, "release_support.exs")},
        {"DOC_TEST_STAGE", root},
        {"DOC_TEST_TARBALL", tarball},
        {"DOC_TEST_QUERY", Path.join(root, "queried")},
        {"DOC_TEST_MIX_LOG", Path.join(root, "mix.log")},
        {"DOC_TEST_NPM_LOG", Path.join(root, "npm.log")},
        {"DOC_TEST_CURL_LOG", Path.join(root, "curl.log")},
        {"DOC_TEST_INITIAL", "404"},
        {"DOC_TEST_FINAL", "200"},
        {"DOC_TEST_URL", "https://hexdocs.pm/phoenix_duskmoon/10.0.0/index.html"},
        {"DOC_TEST_RETRY_STDERR", ""},
        {"DOC_TEST_BODY", ""},
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

  test "transient retry stderr does not contaminate the successful HexDocs status", ctx do
    warning = "curl: (22) The requested URL returned error: 404"
    {output, status} = run(ctx, [{"DOC_TEST_RETRY_STDERR", warning}])
    assert status == 0, output
    assert output =~ warning
    assert output =~ "Published and verified HexDocs phoenix_duskmoon 10.0.0"
    assert File.read!(ctx.tarball) == "verified immutable UI package"
  end

  test "npm readiness retries only metadata and ignores transient stderr", ctx do
    metadata = %{"version" => "10.0.0", "dist" => %{"tarball" => "https://example.test/ui.tgz"}}

    {output, status} =
      run(
        ctx,
        [
          {"DOC_TEST_URL", "https://registry.npmjs.org/phoenix_duskmoon/10.0.0"},
          {"DOC_TEST_INITIAL", "200"},
          {"DOC_TEST_BODY", JSON.encode!(metadata)},
          {"DOC_TEST_RETRY_STDERR", "curl: (22) The requested URL returned error: 404"}
        ],
        "IO.puts(JSON.encode!(ReleaseSupport.npm_metadata!(\"phoenix_duskmoon\", \"10.0.0\")))"
      )

    assert status == 0, output
    assert output =~ JSON.encode!(metadata)
    assert [request] = String.split(File.read!(ctx.curl_log), "\n", trim: true)
    assert request =~ "--retry 240 --retry-delay 5 --retry-all-errors"
    assert request =~ "--max-time 30 --retry-max-time 1200"
    refute File.exists?(ctx.npm_log)
    refute File.exists?(ctx.mix_log)
    assert File.read!(ctx.tarball) == "verified immutable UI package"
  end

  test "npm readiness exhaustion fails without publishing or changing package bytes", ctx do
    {output, status} =
      run(
        ctx,
        [
          {"DOC_TEST_URL", "https://registry.npmjs.org/phoenix_duskmoon/10.0.0"},
          {"DOC_TEST_INITIAL", "404"}
        ],
        "ReleaseSupport.npm_metadata!(\"phoenix_duskmoon\", \"10.0.0\")"
      )

    assert status != 0
    assert output =~ "failed (22)"
    refute File.exists?(ctx.npm_log)
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

  defp run(
         ctx,
         overrides \\ [],
         expression \\ "ReleaseSupport.hex_docs_publish!(\"phoenix_duskmoon\", \"10.0.0\", System.fetch_env!(\"DOC_TEST_STAGE\"))"
       ) do
    env = Map.new(ctx.env ++ overrides) |> Map.to_list()

    System.cmd(
      System.find_executable("elixir"),
      [
        "-e",
        """
        System.put_env("PATH", System.fetch_env!("DOC_TEST_PATH"))
        Code.require_file(System.fetch_env!("DOC_TEST_SUPPORT"))
        #{expression}
        """
      ],
      env: env,
      stderr_to_stdout: true
    )
  end
end
