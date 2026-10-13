Code.require_file("native-policy.exs", __DIR__)
DuskmoonUI.NativePolicy.validate!()
root = Path.expand("..", __DIR__)
version = root |> Path.join("BUNDLER_VERSION") |> File.read!() |> String.trim()

case Version.parse(version) do
  {:ok, %Version{pre: [], build: nil}} -> :ok
  _ -> raise "BUNDLER_VERSION must be a stable version"
end

{lock, _} =
  root
  |> Path.join("mix.lock")
  |> File.read!()
  |> Code.string_to_quoted!(emit_warnings: false)
  |> Code.eval_quoted()

apps =
  ~w(duskmoon_bundler duskmoon_bundler_runtime duskmoon_oxc duskmoon_oxide duskmoon_vize duskmoon_quickbeam duskmoon_npm duskmoon_hex_solver)a

for app <- apps do
  case Map.fetch!(lock, app) do
    {:hex, ^app, ^version, checksum, _, _, "hexpm", outer}
    when is_binary(checksum) and is_binary(outer) ->
      :ok

    other ->
      raise "#{app} must be locked to Hex #{version}, got #{inspect(other)}"
  end

  if File.exists?(Path.join([root, "apps", Atom.to_string(app), "mix.exs"])),
    do: raise("Toolchain source remains in UI umbrella: #{app}")
end

IO.puts("UI toolchain: all eight packages locked to Hex #{version}; strict precompiled policy")
