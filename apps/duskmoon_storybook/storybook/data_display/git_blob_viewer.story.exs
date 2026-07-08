defmodule Storybook.DataDisplay.GitBlobViewer do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_blob_viewer/1
  def description, do: "Read-only source blob panel with raw, copy, and file state affordances."

  def variations do
    [
      %Variation{
        id: :source,
        description: "Text source file",
        attributes: %{
          filename: "lib/app.ex",
          size: "238 B",
          language: "elixir",
          content: "defmodule App do\\n  def hello, do: :world\\nend\\n",
          raw_href: "#"
        }
      },
      %Variation{
        id: :binary,
        description: "Binary file state",
        attributes: %{
          filename: "priv/static/logo.png",
          size: "24 KB",
          binary: true
        }
      }
    ]
  end
end
