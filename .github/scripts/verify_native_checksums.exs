defmodule VerifyNativeChecksums do
  @moduledoc false

  def main([tag | checksum_files]) when checksum_files != [] do
    asset_digests = release_asset_digests!(tag)

    checksum_files
    |> Enum.flat_map(&mismatches(&1, asset_digests))
    |> report!()
  end

  def main(_args) do
    IO.puts(
      :stderr,
      "usage: elixir verify_native_checksums.exs <release-tag> <checksum-file> [...]"
    )

    System.halt(2)
  end

  defp release_asset_digests!(tag) do
    case System.cmd("gh", ["release", "view", tag, "--json", "assets"], stderr_to_stdout: true) do
      {json, 0} ->
        json
        |> JSON.decode!()
        |> Map.fetch!("assets")
        |> Map.new(fn %{"name" => name, "digest" => digest} -> {name, digest} end)

      {output, status} ->
        IO.puts(:stderr, "failed to read GitHub release #{tag} assets (exit #{status})")
        IO.puts(:stderr, output)
        System.halt(status)
    end
  end

  defp mismatches(checksum_file, asset_digests) do
    {checksums, _binding} = Code.eval_file(checksum_file)

    Enum.flat_map(checksums, fn {name, expected_digest} ->
      case Map.fetch(asset_digests, name) do
        {:ok, ^expected_digest} ->
          []

        {:ok, actual_digest} ->
          [
            """
            #{checksum_file}: #{name}
              expected #{expected_digest}
              release  #{actual_digest}
            """
          ]

        :error ->
          ["#{checksum_file}: #{name}\n  missing from GitHub release assets\n"]
      end
    end)
  end

  defp report!([]) do
    IO.puts("Native checksum files match GitHub release assets")
  end

  defp report!(mismatches) do
    IO.puts(:stderr, "Native checksum files do not match GitHub release assets:")
    Enum.each(mismatches, &IO.puts(:stderr, &1))
    System.halt(1)
  end
end

VerifyNativeChecksums.main(System.argv())