defmodule PhoenixDuskmoon.Component.DataDisplay.Markdown do
  @moduledoc """
  Duskmoon UI Markdown Component

  Render markdown using `<el-dm-markdown>` custom element from `@duskmoon-dev/el-markdown`.

  Supported markdown features:
    * GitHub Flavored Markdown
    * Syntax highlighting with highlight.js
    * Mermaid diagram rendering (optional)

  Requires `@duskmoon-dev/el-markdown` registered in your project:

  ```js
  import '@duskmoon-dev/el-markdown/register';
  ```

  """
  use Phoenix.Component

  @doc """
  Generates `<el-dm-markdown>` custom element to render markdown content.

  ## Examples

      <.dm_markdown class="dark"># Hello</.dm_markdown>
      #=> <el-dm-markdown class="dark"># Hello</el-dm-markdown>

      <.dm_markdown content="# Hello" />
      #=> <el-dm-markdown># Hello</el-dm-markdown>

  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:debug, :boolean,
    default: false,
    doc: """
    el-dm-markdown attribute, enable debug
    """
  )

  attr(:content, :string,
    default: "",
    doc: """
    markdown content (inline)
    """
  )

  attr(:src, :string,
    default: nil,
    doc: "URL to fetch markdown content from"
  )

  attr(:theme, :string,
    default: nil,
    values: [nil, "github", "atom-one-dark", "atom-one-light", "auto"],
    doc: "Code syntax highlighting theme"
  )

  attr(:no_mermaid, :boolean,
    default: false,
    doc: "Disable mermaid diagram rendering"
  )

  attr(:rest, :global)

  def dm_markdown(assigns) do
    ~H"""
    <el-dm-markdown
      id={@id}
      debug={@debug}
      src={@src}
      theme={@theme}
      no-mermaid={@no_mermaid}
      class={@class}
      {@rest}
    ><%= @content %></el-dm-markdown>
    """
  end
end
