defmodule DuskmoonBundler.HTMLEntry do
  @moduledoc """
  Extract entry points from HTML files.

  Parses `<script src="...">` and `<link rel="stylesheet" href="...">` tags
  using LazyHTML to discover JS and CSS entry files.

  ## Example

      # index.html
      <script type="module" src="js/app.ts"></script>
      <link rel="stylesheet" href="css/app.css">

      {:ok, entries} = DuskmoonBundler.HTMLEntry.extract("index.html")
      entries.scripts  #=> ["js/app.ts"]
      entries.styles   #=> ["css/app.css"]
  """

  @doc """
  Extract script and stylesheet entries from an HTML file.

  Paths are resolved relative to the HTML file's directory.
  """
  @spec extract(String.t()) :: {:ok, %{scripts: [String.t()], styles: [String.t()]}}
  def extract(html_path) do
    html_path = Path.expand(html_path)
    html = File.read!(html_path)
    doc = LazyHTML.from_document(html)

    scripts =
      doc
      |> LazyHTML.query("script[src]")
      |> LazyHTML.attribute("src")
      |> Enum.map(&resolve_path(&1, html_path))

    styles =
      doc
      |> LazyHTML.query(~s(link[rel="stylesheet"][href]))
      |> LazyHTML.attribute("href")
      |> Enum.map(&resolve_path(&1, html_path))

    {:ok, %{scripts: scripts, styles: styles}}
  end

  @doc "Check if a path is an HTML file."
  @spec html?(String.t()) :: boolean()
  def html?(path), do: Path.extname(path) in ~w(.html .htm)

  defp resolve_path(src, html_path) do
    if String.starts_with?(src, "/") do
      src
    else
      html_path |> Path.dirname() |> Path.join(src) |> Path.expand()
    end
  end
end
