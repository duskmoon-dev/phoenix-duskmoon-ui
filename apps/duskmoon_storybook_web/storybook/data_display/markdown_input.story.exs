defmodule Storybook.DataDisplay.MarkdownInput do
  use PhoenixStorybook.Story, :component

  def function,
    do: &PhoenixDuskmoon.Component.DataDisplay.MarkdownInput.dm_markdown_input/1

  def description,
    do:
      "Rich markdown editor with live preview, syntax highlighting, and optional Mermaid support. Uses el-dm-markdown-input."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic markdown editor",
        attributes: %{
          name: "body",
          value: "# Hello\n\nStart writing **markdown** here."
        }
      },
      %Variation{
        id: :placeholder,
        description: "With placeholder text",
        attributes: %{
          name: "content",
          placeholder: "Write your markdown here…"
        }
      },
      %Variation{
        id: :with_theme,
        description: "Dark syntax highlighting theme",
        attributes: %{
          name: "body",
          theme: "atom-one-dark",
          value: "# Dark Theme\n\n```elixir\ndefmodule Example do\n  def hello, do: :world\nend\n```"
        }
      },
      %Variation{
        id: :no_mermaid,
        description: "Mermaid rendering disabled",
        attributes: %{
          name: "body",
          no_mermaid: true,
          value: "### Raw Mermaid\n\n```mermaid\ngraph TD;\n  A-->B;\n```"
        }
      },
      %Variation{
        id: :disabled,
        description: "Disabled state",
        attributes: %{
          name: "body",
          disabled: true,
          value: "This editor is disabled."
        }
      },
      %Variation{
        id: :readonly,
        description: "Read-only state",
        attributes: %{
          name: "body",
          readonly: true,
          value: "# Read-only content\n\nThis editor is read-only."
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :theme,
        label: "Theme",
        type: :select,
        options: [
          {nil, "Default"},
          {"github", "GitHub"},
          {"atom-one-dark", "Atom One Dark"},
          {"atom-one-light", "Atom One Light"},
          {"auto", "Auto"}
        ],
        default: nil
      },
      %{
        id: :no_mermaid,
        label: "No Mermaid",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :readonly,
        label: "Read-only",
        type: :boolean,
        default: false
      }
    ]
  end
end
