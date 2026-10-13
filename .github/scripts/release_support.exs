defmodule ReleaseSupport do
  @moduledoc false
  @cohort ~w(duskmoon_bundler duskmoon_bundler_runtime duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver)
  def cohort, do: @cohort

  def stable!(value) do
    unless value =~ ~r/^\d+\.\d+\.\d+$/,
      do: raise("expected stable numeric version, got #{inspect(value)}")

    Version.parse!(value)
    value
  end

  def sha!(value) do
    unless value =~ ~r/^[a-f0-9]{40}$/,
      do: raise("an immutable 40-character source SHA is required")

    value
  end

  def cmd!(command, args, opts \\ []) do
    {output, status} = System.cmd(command, args, Keyword.merge([stderr_to_stdout: true], opts))
    if status != 0, do: raise("#{command} #{Enum.join(args, " ")} failed (#{status}): #{output}")
    output
  end

  def digest(file), do: :crypto.hash(:sha256, File.read!(file)) |> Base.encode16(case: :lower)

  def checked_head!(sha) do
    sha!(sha)
    head = cmd!("git", ["rev-parse", "HEAD"]) |> String.trim()
    if head != sha, do: raise("checkout SHA #{head} differs from requested #{sha}")
    sha
  end

  def order!(graph) do
    visit = fn visit, app, active, done ->
      cond do
        app in done ->
          done

        app in active ->
          raise("package dependency cycle: #{inspect([app | active])}")

        true ->
          Enum.reduce(Map.fetch!(graph, app), done, fn dep, acc ->
            visit.(visit, dep, [app | active], acc)
          end) ++ [app]
      end
    end

    graph
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reduce([], fn app, done -> visit.(visit, app, [], done) end)
  end

  def manifests!(root, apps, version) do
    Mix.start()

    Enum.map(apps, fn app ->
      path = Path.join(root, app)

      Mix.Project.in_project(String.to_atom(app), path, fn _ ->
        config = Mix.Project.config()

        if config[:version] != version,
          do: raise("#{app} version #{config[:version]} differs from #{version}")

        %{name: app, deps: config[:deps] || []}
      end)
    end)
  end

  def dependency_order!(manifests) do
    names = Enum.map(manifests, & &1.name)

    graph =
      Map.new(manifests, fn %{name: name, deps: deps} ->
        internal =
          deps |> Enum.map(&(elem(&1, 0) |> Atom.to_string())) |> Enum.filter(&(&1 in names))

        {name, internal}
      end)

    order!(graph)
  end

  def immutable_action(nil, _wanted), do: :create
  def immutable_action(wanted, wanted), do: :reuse

  def immutable_action(existing, wanted),
    do: raise("immutable output conflict: #{inspect(existing)} != #{inspect(wanted)}")

  def adoption_ready?(state) do
    state["public_assets_verified"] == true and state["registry_consumer_verified"] == true and
      state["musl_amd64_verified"] == true and state["musl_arm64_verified"] == true and
      Enum.sort(state["packages"] || []) == Enum.sort(@cohort)
  end

  def http!(url, output) do
    status =
      cmd!("curl", [
        "--fail-with-body",
        "--location",
        "--silent",
        "--show-error",
        "--output",
        output,
        "--write-out",
        "%{http_code}",
        url
      ])

    if status != "200", do: raise("unexpected status #{status}: #{url}")
    output
  end

  def exists_hex?(package, version) do
    status =
      cmd!("curl", [
        "--silent",
        "--show-error",
        "--output",
        "/dev/null",
        "--write-out",
        "%{http_code}",
        "https://hex.pm/api/packages/#{package}/releases/#{version}"
      ])

    case status do
      "200" -> true
      "404" -> false
      other -> raise("Hex query failed: #{package} #{version}: HTTP #{other}")
    end
  end

  def hex_publish!(package, version, dir) do
    tarball = Path.join(dir, "#{package}-#{version}.tar")

    if exists_hex?(package, version) do
      downloaded =
        Path.join(
          System.tmp_dir!(),
          "registry-#{package}-#{System.unique_integer([:positive])}.tar"
        )

      try do
        http!("https://repo.hex.pm/tarballs/#{package}-#{version}.tar", downloaded)
        immutable_action(digest(downloaded), digest(tarball))
        IO.puts("Reusing identical registry package #{package} #{version}")
      after
        File.rm(downloaded)
      end
    else
      expected = digest(tarball)
      IO.write(cmd!("mix", ["deps.get"], cd: dir))
      IO.write(cmd!("mix", ["hex.build"], cd: dir))
      immutable_action(digest(tarball), expected)
      IO.write(cmd!("mix", ["hex.publish", "package", "--yes"], cd: dir))
    end
  end

  def verify_hex!(package, version, tarball) do
    downloaded =
      Path.join(
        System.tmp_dir!(),
        "verify-registry-#{package}-#{System.unique_integer([:positive])}.tar"
      )

    try do
      http!("https://repo.hex.pm/tarballs/#{package}-#{version}.tar", downloaded)
      immutable_action(digest(downloaded), digest(tarball))
    after
      File.rm(downloaded)
    end
  end

  def public_release!(repo, version, sha, files) do
    stable!(version)
    sha!(sha)
    tag = "v#{version}"
    # Distinguish an absent release from authorization/network errors through the API status.
    {output, status} =
      System.cmd("gh", ["api", "repos/#{repo}/releases/tags/#{tag}"], stderr_to_stdout: true)

    case status do
      0 ->
        release = JSON.decode!(output)
        if release["draft"], do: raise("existing release must be public before publishing Hex")

        refs =
          cmd!("git", [
            "ls-remote",
            "--tags",
            "https://github.com/#{repo}.git",
            "refs/tags/#{tag}",
            "refs/tags/#{tag}^{}"
          ])

        actual_sha =
          refs |> String.split("\n", trim: true) |> List.last() |> String.split() |> hd()

        immutable_action(actual_sha, sha)

      _ ->
        unless output =~ "HTTP 404", do: raise("cannot inspect release: #{output}")
        # An existing tag must already resolve to this source SHA; never move it.
        refs =
          cmd!("git", [
            "ls-remote",
            "--tags",
            "https://github.com/#{repo}.git",
            "refs/tags/#{tag}",
            "refs/tags/#{tag}^{}"
          ])

        if String.trim(refs) != "" do
          actual_sha =
            refs |> String.split("\n", trim: true) |> List.last() |> String.split() |> hd()

          immutable_action(actual_sha, sha)
        end

        cmd!("gh", [
          "release",
          "create",
          tag,
          "--repo",
          repo,
          "--target",
          sha,
          "--title",
          tag,
          "--generate-notes"
        ])
    end

    release =
      cmd!("gh", ["release", "view", tag, "--repo", repo, "--json", "assets"]) |> JSON.decode!()

    existing = Map.new(release["assets"], &{&1["name"], &1["digest"]})

    for path <- files do
      name = Path.basename(path)
      wanted = "sha256:" <> digest(path)

      case immutable_action(existing[name], wanted) do
        :create -> cmd!("gh", ["release", "upload", tag, path, "--repo", repo])
        :reuse -> IO.puts("Reusing immutable release asset #{name}")
      end

      downloaded =
        Path.join(System.tmp_dir!(), "public-#{System.unique_integer([:positive])}-#{name}")

      try do
        # Deliberately no Authorization header: a draft/authenticated asset is insufficient.
        http!("https://github.com/#{repo}/releases/download/#{tag}/#{name}", downloaded)
        immutable_action(digest(downloaded), digest(path))
      after
        File.rm(downloaded)
      end
    end
  end
end
