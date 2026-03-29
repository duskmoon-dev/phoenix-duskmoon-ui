defmodule Mix.Tasks.Icons.Bundle do
  @moduledoc """
  Bundles individual SVG icon files into compressed ETF files for Hex publishing.

  This reduces thousands of individual SVG files (which blow up Hex metadata)
  into two compact files: `priv/static/mdi_icons.etf.gz` and `priv/static/bsi_icons.etf.gz`.

  ## Usage

      mix icons.bundle

  Run this before `mix hex.publish`. It is included in the `prepublish` alias.
  """
  use Mix.Task

  @shortdoc "Bundle SVG icons into compressed ETF files"

  @impl Mix.Task
  def run(_args) do
    app_dir = Application.app_dir(:phoenix_duskmoon)
    # Source priv/static (used by hex.build for packaging)
    src_static = Path.join(File.cwd!(), "priv/static")
    # Build priv/static (used by Application.app_dir at runtime)
    build_static = Path.join(app_dir, "priv/static")

    for {svg_subdir, filename} <- [
          {"mdi/svg", "mdi_icons.etf.gz"},
          {"bsi/svg", "bsi_icons.etf.gz"}
        ] do
      bundle_icons(
        Path.join(app_dir, "priv/#{svg_subdir}"),
        Path.join(src_static, filename),
        Path.join(build_static, filename)
      )
    end
  end

  defp bundle_icons(svg_dir, src_path, build_path) do
    icon_map =
      svg_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".svg"))
      |> Map.new(fn filename ->
        name = String.trim_trailing(filename, ".svg")
        content = File.read!(Path.join(svg_dir, filename))

        inner =
          content
          |> String.replace(~r/<svg[^>]+>/, "")
          |> String.replace("</svg>", "")

        {name, String.trim(inner)}
      end)

    data = :erlang.term_to_binary(icon_map)
    compressed = :zlib.gzip(data)

    for path <- [src_path, build_path] do
      path |> Path.dirname() |> File.mkdir_p!()
      File.write!(path, compressed)
    end

    Mix.shell().info(
      "Bundled #{map_size(icon_map)} icons into #{src_path} (#{byte_size(compressed)} bytes)"
    )
  end
end
