Code.require_file("release_support.exs", __DIR__)
[version | paths] = System.argv()
ReleaseSupport.stable!(version)

dep =
  case paths do
    [] ->
      "{:duskmoon_bundler_runtime, \"~> 10.0\"}"

    [stage] ->
      "{:duskmoon_bundler_runtime, path: #{inspect(Path.join(Path.expand(stage), "duskmoon_bundler_runtime"))}}"
  end

locked_runtime =
  if paths == [] do
    unless ReleaseSupport.bundler_version!() == version,
      do: raise("requested runtime version differs from the repository lockfile")

    ReleaseSupport.bundler_lock!() |> Map.take([:duskmoon_bundler_runtime])
  end

root = Path.join(System.tmp_dir!(), "runtime-consumer-#{System.unique_integer([:positive])}")
File.mkdir_p!(Path.join(root, "test"))

try do
  File.write!(Path.join(root, "mix.exs"), """
  defmodule RuntimeConsumer.MixProject do
    use Mix.Project
    def project, do: [app: :runtime_consumer, version: "0.0.0", deps: [#{dep}]]
  end
  """)

  if locked_runtime,
    do: File.write!(Path.join(root, "mix.lock"), inspect(locked_runtime, limit: :infinity))

  File.write!(Path.join(root, "test/test_helper.exs"), "ExUnit.start()\n")

  File.cp!(
    Path.join(__DIR__, "runtime_consumer_test.exs"),
    Path.join(root, "test/runtime_consumer_test.exs")
  )

  IO.write(ReleaseSupport.cmd!("mix", ["deps.get"], cd: root))

  if locked_runtime do
    ReleaseSupport.immutable_action(
      ReleaseSupport.bundler_lock!(Path.join(root, "mix.lock"), ["duskmoon_bundler_runtime"]),
      locked_runtime
    )
  end

  IO.write(ReleaseSupport.cmd!("mix", ["compile", "--warnings-as-errors"], cd: root))
  IO.write(ReleaseSupport.cmd!("mix", ["test"], cd: root))
after
  File.rm_rf!(root)
end
