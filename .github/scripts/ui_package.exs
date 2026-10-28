Code.require_file("release_support.exs", __DIR__)

defmodule UIPackage do
  @moduledoc false
  def stage(output) do
    output = Path.expand(output)
    if File.exists?(output), do: raise("stage output must be absent: #{output}")
    File.cp_r!("apps/phoenix_duskmoon", output)
    for path <- ~w(_build deps node_modules .git), do: File.rm_rf!(Path.join(output, path))
    File.cp!("README.md", Path.join(output, "README.md"))
    mix = Path.join(output, "mix.exs")

    text =
      File.read!(mix)
      |> String.replace(~r/^\s*(build_path|config_path|deps_path|lockfile):.*\n/m, "")

    File.write!(mix, text)

    if text =~ "in_umbrella:" or text =~ "{:duskmoon_bundler,",
      do: raise("UI package leaked toolchain dependencies")

    IO.puts("Self-contained UI package staged at #{output}")
  end

  def smoke(output) do
    root = Path.join(System.tmp_dir!(), "ui-consumer-#{System.unique_integer([:positive])}")
    File.mkdir_p!(root)

    try do
      locked_runtime =
        ReleaseSupport.bundler_lock!() |> Map.take([:duskmoon_bundler_runtime])

      output = Path.expand(output)
      cmd!("mix", ["hex.build"], output)
      [tarball] = Path.wildcard(Path.join(output, "phoenix_duskmoon-*.tar"))
      unpacked = Path.join(root, "hex-package")
      File.mkdir_p!(unpacked)
      :ok = :erl_tar.extract(String.to_charlist(tarball), [{:cwd, String.to_charlist(unpacked)}])

      :ok =
        :erl_tar.extract(String.to_charlist(Path.join(unpacked, "contents.tar.gz")), [
          :compressed,
          {:cwd, String.to_charlist(unpacked)}
        ])

      File.write!(Path.join(root, "mix.exs"), """
      defmodule UIConsumer.MixProject do
        use Mix.Project
        def project, do: [app: :ui_consumer, version: "0.0.0", deps: [
          {:phoenix_duskmoon, path: #{inspect(unpacked)}},
          {:duskmoon_bundler_runtime, "~> 10.0"}
        ]]
      end
      """)

      File.write!(Path.join(root, "mix.lock"), inspect(locked_runtime, limit: :infinity))
      cmd!("mix", ["deps.get"], root)

      ReleaseSupport.immutable_action(
        ReleaseSupport.bundler_lock!(Path.join(root, "mix.lock"), ["duskmoon_bundler_runtime"]),
        locked_runtime
      )

      cmd!("mix", ["compile", "--warnings-as-errors"], root)

      cmd!(
        "mix",
        [
          "run",
          "-e",
          "true = Code.ensure_loaded?(PhoenixDuskmoon); false = Code.ensure_loaded?(DuskmoonBundler.Builder)"
        ],
        root
      )

      cmd!("bun", ["pm", "pack", "--quiet", "--destination", output], output)
      [npm] = Path.wildcard(Path.join(output, "*.tgz"))
      npm_root = Path.join(root, "npm")
      File.mkdir_p!(npm_root)

      :ok =
        :erl_tar.extract(String.to_charlist(npm), [
          :compressed,
          {:cwd, String.to_charlist(npm_root)}
        ])

      npm_package = Path.join(npm_root, "package")
      package = JSON.decode!(File.read!(Path.join(npm_package, "package.json")))

      for {_export, path} <- package["exports"] do
        if String.contains?(path, "*"),
          do:
            File.exists?(Path.join(npm_package, Path.dirname(path))) ||
              raise("missing npm export directory #{path}"),
          else: File.regular?(Path.join(npm_package, path)) || raise("missing npm export #{path}")
      end

      hashes = %{
        hex_tar_sha256: :crypto.hash(:sha256, File.read!(tarball)) |> Base.encode16(case: :lower),
        npm_tar_sha256: :crypto.hash(:sha256, File.read!(npm)) |> Base.encode16(case: :lower)
      }

      File.write!(Path.join(output, "validation-provenance.json"), JSON.encode!(hashes))

      IO.puts(
        "Outside-checkout exact UI Hex/npm packages, runtime boundary and npm exports passed"
      )
    after
      File.rm_rf!(root)
    end
  end

  defp cmd!(cmd, args, cwd) do
    {text, status} =
      System.cmd(cmd, args,
        cd: cwd,
        stderr_to_stdout: true,
        env: [{"MIX_ENV", "prod"}, {"DUSKMOON_NATIVE_MODE", "precompiled"}]
      )

    IO.write(text)
    if status != 0, do: raise("#{cmd} #{Enum.join(args, " ")} failed (#{status})")
  end
end

case System.argv() do
  ["stage", output] -> UIPackage.stage(output)
  ["smoke", output] -> UIPackage.smoke(output)
  _ -> raise("usage: elixir ui_package.exs stage|smoke OUTPUT")
end
