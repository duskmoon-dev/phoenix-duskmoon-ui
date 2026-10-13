Code.require_file("release_support.exs", __DIR__)

defmodule UIRelease do
  @moduledoc false
  def plan(version, sha) do
    ReleaseSupport.stable!(version)
    ReleaseSupport.checked_head!(sha)
    config = JSON.decode!(File.read!("apps/phoenix_duskmoon/package.json"))
    unless config["version"] == version, do: raise("npm U version differs from requested release")
    ReleaseSupport.manifests!("apps", ["phoenix_duskmoon"], version)

    Mix.Project.in_project(:ui_release_root, ".", fn _ ->
      if Mix.Project.config()[:version] != version,
        do: raise("umbrella U version differs from requested release")
    end)

    bundler = File.read!("BUNDLER_VERSION") |> String.trim() |> ReleaseSupport.stable!()

    %{
      product: "phoenix_duskmoon",
      version: version,
      source_sha: sha,
      source_dirty: ReleaseSupport.source_dirty?(),
      bundler_version: bundler,
      mix_lock_sha256: ReleaseSupport.digest("mix.lock"),
      bun_lock_sha256: ReleaseSupport.digest("bun.lock"),
      packages: ["phoenix_duskmoon"],
      native_builds: [],
      toolchain_publish: [],
      steps: [
        "verify published B",
        "compile/tests/hooks/browser",
        "JS/CSS/icons",
        "staged consumer",
        "Hex/npm U",
        "UI release",
        "Storybook image"
      ]
    }
  end

  def publish(version, sha, stage) do
    ReleaseSupport.clean_source!()
    provenance = plan(version, sha)
    stage = Path.expand(stage)
    ReleaseSupport.manifests!(Path.dirname(stage), [Path.basename(stage)], version)
    hex = Path.join(stage, "phoenix_duskmoon-#{version}.tar")
    [npm] = Path.wildcard(Path.join(stage, "*.tgz"))

    provenance =
      Map.merge(provenance, %{
        hex_tar_sha256: ReleaseSupport.digest(hex),
        npm_tar_sha256: ReleaseSupport.digest(npm)
      })

    validated = Path.join(stage, "validation-provenance.json") |> File.read!() |> JSON.decode!()
    ReleaseSupport.immutable_action(validated["hex_tar_sha256"], provenance.hex_tar_sha256)
    ReleaseSupport.immutable_action(validated["npm_tar_sha256"], provenance.npm_tar_sha256)

    file = Path.join(stage, "ui-release.json")
    File.write!(file, JSON.encode!(provenance))
    # Record immutable expected package bytes before touching either registry.
    ReleaseSupport.public_release!("duskmoon-dev/phoenix-duskmoon-ui", version, sha, [
      file,
      hex,
      npm
    ])

    ReleaseSupport.hex_publish!("phoenix_duskmoon", version, stage)
    url = "https://registry.npmjs.org/phoenix_duskmoon/#{version}"

    status =
      ReleaseSupport.cmd!("curl", [
        "--silent",
        "--show-error",
        "--output",
        "/dev/null",
        "--write-out",
        "%{http_code}",
        url
      ])

    case status do
      "404" ->
        ReleaseSupport.cmd!("npm", ["publish", npm, "--access", "public", "--provenance"])
        |> IO.write()

      "200" ->
        metadata =
          ReleaseSupport.cmd!("curl", ["--fail", "--silent", "--show-error", url])
          |> JSON.decode!()

        downloaded = npm <> ".registry"
        ReleaseSupport.http!(metadata["dist"]["tarball"], downloaded)

        ReleaseSupport.immutable_action(
          ReleaseSupport.digest(downloaded),
          ReleaseSupport.digest(npm)
        )

        File.rm!(downloaded)

      _ ->
        raise("npm lookup failed: HTTP #{status}")
    end

    ReleaseSupport.verify_hex!("phoenix_duskmoon", version, hex)

    metadata =
      ReleaseSupport.cmd!("curl", ["--fail", "--silent", "--show-error", url]) |> JSON.decode!()

    downloaded = npm <> ".verified"

    try do
      ReleaseSupport.http!(metadata["dist"]["tarball"], downloaded)

      ReleaseSupport.immutable_action(
        ReleaseSupport.digest(downloaded),
        ReleaseSupport.digest(npm)
      )
    after
      File.rm(downloaded)
    end

    IO.puts("UI Hex/npm release complete; U=#{version}, pinned B=#{provenance.bundler_version}")
  end
end

case System.argv() do
  ["plan", version, sha] -> IO.puts(JSON.encode!(UIRelease.plan(version, sha)))
  ["publish", version, sha, stage] -> UIRelease.publish(version, sha, stage)
  _ -> raise("usage: elixir ui_release.exs plan U SHA | publish U SHA STAGE")
end
