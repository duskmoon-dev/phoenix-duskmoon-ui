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
  use PhoenixDuskmoon.Component, :html

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
    markdown content
    """
  )

  def dm_markdown(assigns) do
    ~H"""
    <el-dm-markdown id={@id} debug={@debug} class={@class}><%= @content %></el-dm-markdown>
    """
  end
end
