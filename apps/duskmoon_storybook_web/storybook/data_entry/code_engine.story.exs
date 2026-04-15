defmodule Storybook.DataEntry.CodeEngine do
  use PhoenixStorybook.Story, :component

  def function,
    do: &PhoenixDuskmoon.Component.DataEntry.CodeEngine.dm_code_engine/1

  def description,
    do:
      "Lightweight code editor with syntax highlighting for 25+ languages. Uses el-dm-code-engine backed by CodeMirror 6."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic code editor",
        attributes: %{
          name: "source",
          language: "rust",
          value: "fn main() {\n    println!(\"hello world\");\n}"
        }
      },
      %Variation{
        id: :elixir,
        description: "Elixir syntax highlighting",
        attributes: %{
          name: "source",
          language: "elixir",
          value: "defmodule Example do\n  def hello, do: :world\nend"
        }
      },
      %Variation{
        id: :with_topbar,
        description: "With topbar showing filename",
        attributes: %{
          name: "source",
          language: "go",
          show_topbar: true,
          title: "main.go",
          value: "package main\n\nimport \"fmt\"\n\nfunc greet(name string) string {\n\treturn fmt.Sprintf(\"Hello, %s!\", name)\n}"
        }
      },
      %Variation{
        id: :one_dark_theme,
        description: "One Dark theme",
        attributes: %{
          name: "source",
          language: "python",
          theme: "one-dark",
          value: "def fibonacci(n: int) -> int:\n    if n <= 1:\n        return n\n    return fibonacci(n - 1) + fibonacci(n - 2)"
        }
      },
      %Variation{
        id: :readonly,
        description: "Read-only editor",
        attributes: %{
          name: "source",
          language: "yaml",
          readonly: true,
          value: "name: phoenix_duskmoon\nversion: 9.1.4\ndescription: Duskmoon UI for Phoenix"
        }
      },
      %Variation{
        id: :line_wrap,
        description: "Line wrapping enabled",
        attributes: %{
          name: "source",
          language: "markdown",
          wrap: true,
          value: "# Phoenix Duskmoon UI\n\nA comprehensive component library for Phoenix LiveView applications providing Material Design 3 inspired components with full theme support."
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :language,
        label: "Language",
        type: :select,
        options: [
          {"elixir", "Elixir"},
          {"python", "Python"},
          {"rust", "Rust"},
          {"go", "Go"},
          {"sql", "SQL"},
          {"yaml", "YAML"},
          {"markdown", "Markdown"},
          {"xml", "XML"}
        ],
        default: "elixir"
      },
      %{
        id: :theme,
        label: "Theme",
        type: :select,
        options: [
          {nil, "Default"},
          {"duskmoon", "Duskmoon"},
          {"sunshine", "Sunshine"},
          {"moonlight", "Moonlight"},
          {"one-dark", "One Dark"}
        ],
        default: nil
      },
      %{
        id: :wrap,
        label: "Line Wrap",
        type: :boolean,
        default: false
      },
      %{
        id: :readonly,
        label: "Read-only",
        type: :boolean,
        default: false
      },
      %{
        id: :show_topbar,
        label: "Show Topbar",
        type: :boolean,
        default: false
      },
      %{
        id: :show_bottombar,
        label: "Show Bottombar",
        type: :boolean,
        default: false
      }
    ]
  end
end
