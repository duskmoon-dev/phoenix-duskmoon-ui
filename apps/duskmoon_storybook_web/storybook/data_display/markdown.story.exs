defmodule Storybook.DataDisplay.Markdown do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Markdown.dm_markdown/1
  def description, do: "Markdown renderer with syntax highlighting, Mermaid diagram support, and theme switching. Uses el-dm-markdown."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic heading and paragraph",
        attributes: %{
          content: """
          # Page title

          This is a paragraph with **bold**, *italic*, and `inline code`.

          - List item one
          - List item two
          - List item three
          """
        }
      },
      %Variation{
        id: :with_code,
        description: "Fenced code block with syntax highlighting",
        attributes: %{
          content: """
          # Code Example

          ```elixir
          defmodule MyApp.Greeter do
            def hello(name) do
              IO.puts(name)
            end
          end
          ```

          ```python
          def greet(name):
              return f'Hello {name}'
          ```
          """
        }
      },
      %Variation{
        id: :with_mermaid,
        description: "Mermaid diagram rendering",
        attributes: %{
          content: """
          ### Mermaid Chart

          ```mermaid
          graph LR;
              A-->B;
              A-->C;
              B-->D;
              C-->D;
          ```
          """
        }
      },
      %Variation{
        id: :no_mermaid,
        description: "Disable mermaid rendering — diagrams display as raw code blocks",
        attributes: %{
          no_mermaid: true,
          content: """
          ### Raw Mermaid (rendering disabled)

          ```mermaid
          graph TD;
              A-->B;
          ```
          """
        }
      },
      %Variation{
        id: :dark_theme,
        description: "Dark syntax highlighting theme",
        attributes: %{
          theme: "dark",
          content: """
          # Dark Theme

          ```python
          def fibonacci(n):
              a, b = 0, 1
              for _ in range(n):
                  a, b = b, a + b
              return a
          ```
          """
        }
      },
      %Variation{
        id: :rich_content,
        description: "Tables, blockquotes, and links",
        attributes: %{
          content: """
          ## Rich Markdown

          > Blockquote: The best way to predict the future is to create it.

          | Feature | Status |
          |---------|--------|
          | Tables  | ✅     |
          | Links   | ✅     |
          | Images  | ✅     |

          Visit [Duskmoon UI](https://github.com/duskmoon-dev) for more.
          """
        }
      }
    ]
  end
end
