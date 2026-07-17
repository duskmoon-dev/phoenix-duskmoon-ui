defmodule Storybook.DataDisplay.MarkdownBody do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Markdown.dm_markdown_body/1

  def description do
    "Server-rendered MDEx Markdown with GFM, color chips, front matter, hard line breaks, and Mermaid enabled by default."
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Heading, paragraph, and inline formatting",
        attributes: %{
          source: """
          # Page title

          This is a paragraph with **bold**, *italic*, and `inline code`.

          - List item one
          - List item two
          """
        }
      },
      %Variation{
        id: :github_flavored_markdown,
        description: "GitHub Flavored Markdown features",
        attributes: %{
          source: """
          ## Project status :rocket:

          | Feature | Status |
          | ------- | ------ |
          | Tables | :white_check_mark: |
          | Task lists | :white_check_mark: |

          - [x] Render on the server
          - [ ] Publish the release

          Visit https://github.com/duskmoon-dev for more.
          """
        }
      },
      %Variation{
        id: :mermaid,
        description: "Mermaid diagram rendered by the default MDExMermaid plugin",
        attributes: %{
          source: """
          ## Request flow

          ```mermaid
          flowchart LR
            Browser --> LiveView
            LiveView --> MDEx
          ```
          """
        }
      },
      %Variation{
        id: :front_matter_and_color_chips,
        description: "Front matter renders as YAML and inline color values render with chips",
        attributes: %{
          source: """
          ---
          title: DmMarkdown feature showcase
          tags:
            - rust
            - yew
          accent: '#4C86FC'
          ---
          # DmMarkdown rendering

          ## Inline color chips

          | Color | Inline code |
          | --- | --- |
          | Brand blue | `#4C86FC` |
          | White | `#fff` |
          | Black | `#000` |
          | Transparent red | `#FF000080` |
          """
        }
      },
      %Variation{
        id: :hard_line_breaks,
        description: "Soft line breaks become HTML line breaks by default",
        attributes: %{
          source: "First line\nSecond line"
        }
      },
      %Variation{
        id: :safe_html,
        description: "Allowed HTML tags preserved while unsafe tags are sanitized",
        attributes: %{
          source: "<article><mark>Safe HTML</mark><script>alert('unsafe')</script></article>",
          plugins: [MDExGFM],
          options: [
            render: [unsafe: true],
            sanitize: MDEx.Document.default_sanitize_options()
          ]
        }
      },
      %Variation{
        id: :custom_class,
        description: "Markdown body with additional layout classes",
        attributes: %{
          class: "max-w-3xl mx-auto",
          source: "# Constrained content\n\nThe component always includes `markdown-body`."
        }
      }
    ]
  end
end
