defmodule GenerateNativeChecksums do
  @moduledoc false

  @groups [
    {:rust, "oxc_ex_nif", "apps/duskmoon_oxc/checksum-Elixir.OXC.Native.exs", :map},
    {:rust, "oxc_fmt_nif", "apps/duskmoon_oxc/checksum-Elixir.OXC.Format.Native.exs", :map},
    {:rust, "oxc_lint_nif", "apps/duskmoon_oxc/checksum-Elixir.OXC.Lint.Native.exs", :map},
    {:rust, "oxide_ex_nif", "apps/duskmoon_oxide/checksum-Elixir.Oxide.Native.exs", :map},
    {:rust, "vize_ex_nif", "apps/duskmoon_vize/checksum-Elixir.Vize.Native.exs", :map},
    {:quickbeam, "Elixir.QuickBEAM.Native",
     "apps/duskmoon_quickbeam/checksum-QuickBEAM.Native.exs", :list}
  ]

  @rust_targets ~w(
    aarch64-apple-darwin
    aarch64-unknown-linux-gnu
    x86_64-apple-darwin
    x86_64-pc-windows-gnu
    x86_64-unknown-freebsd
    x86_64-unknown-linux-gnu
  )

  @quickbeam_targets ~w(
    aarch64-linux-gnu
    aarch64-macos-none
    x86_64-freebsd-none
    x86_64-linux-gnu
    x86_64-macos-none
  )

  def main([version, assets_dir]) do
    Version.parse!(version)

    asset_paths = load_asset_paths!(assets_dir)
    expected_groups = Enum.map(@groups, &{&1, expected_names(&1, version)})
    validate_asset_set!(asset_paths, expected_groups)

    checksum_groups =
      Enum.map(expected_groups, fn {{_type, _name, output_path, format}, names} ->
        checksums = Enum.map(names, &{&1, asset_paths |> Map.fetch!(&1) |> digest()})
        {output_path, format, checksums}
      end)

    Enum.each(checksum_groups, fn {output_path, format, checksums} ->
      File.mkdir_p!(Path.dirname(output_path))
      File.write!(output_path, encode(checksums, format))
      IO.puts("Generated #{output_path} with #{length(checksums)} checksums")
    end)
  end

  def main(_args) do
    IO.puts(
      :stderr,
      "usage: elixir generate_native_checksums.exs <version> <assets-directory>"
    )

    System.halt(2)
  end

  defp load_asset_paths!(assets_dir) do
    paths =
      assets_dir
      |> File.ls!()
      |> Enum.map(&Path.join(assets_dir, &1))

    Enum.each(paths, fn path ->
      unless File.regular?(path), do: raise("native asset is not a regular file: #{path}")
    end)

    asset_paths = Map.new(paths, &{Path.basename(&1), &1})

    if map_size(asset_paths) != length(paths) do
      raise "native asset directory contains duplicate basenames: #{assets_dir}"
    end

    asset_paths
  end

  defp expected_names({:rust, crate, _output_path, _format}, version) do
    Enum.map(@rust_targets, fn
      "x86_64-pc-windows-gnu" = target ->
        "#{crate}-v#{version}-nif-2.15-#{target}.dll.tar.gz"

      target ->
        "lib#{crate}-v#{version}-nif-2.15-#{target}.so.tar.gz"
    end)
  end

  defp expected_names({:quickbeam, module, _output_path, _format}, version) do
    Enum.map(@quickbeam_targets, &"#{module}-v#{version}-#{&1}.so.tar.gz")
  end

  defp validate_asset_set!(asset_paths, expected_groups) do
    actual = asset_paths |> Map.keys() |> MapSet.new()

    expected =
      expected_groups
      |> Enum.flat_map(&elem(&1, 1))
      |> MapSet.new()

    missing = expected |> MapSet.difference(actual) |> Enum.sort()
    unexpected = actual |> MapSet.difference(expected) |> Enum.sort()

    if missing != [] or unexpected != [] do
      raise """
      native asset set does not match the release contract
      missing: #{inspect(missing)}
      unexpected: #{inspect(unexpected)}
      """
    end
  end

  defp digest(path) do
    hash =
      path
      |> File.stream!([], 1_048_576)
      |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
      |> :crypto.hash_final()
      |> Base.encode16(case: :lower)

    "sha256:#{hash}"
  end

  defp encode(checksums, :map) do
    checksums
    |> Map.new()
    |> inspect(limit: :infinity, pretty: true, width: 100)
    |> Kernel.<>("\n")
  end

  defp encode(checksums, :list) do
    checksums
    |> inspect(limit: :infinity, pretty: true, width: 100)
    |> Kernel.<>("\n")
  end
end

GenerateNativeChecksums.main(System.argv())
