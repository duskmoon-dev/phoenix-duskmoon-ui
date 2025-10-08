defmodule Storybook.Components.Markdown do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Markdown.dm_markdown/1
  def description, do: "A markdown render element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          content: """
          # Page title
          """
        }
      },
      %Variation{
        id: :with_code,
        attributes: %{
          content: """
          # Code
          ```elixir
          n2_4 = :math.pow(2, 4)
          ```
          """
        }
      },
      %Variation{
        id: :with_mermaid,
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

          ```mermaid
          graph TD;
              A-->B;
              A-->C;
              B-->D;
              C-->D;
          ```
          """
        }
      }
    ]
  end
end
