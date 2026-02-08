defmodule PhoenixDuskmoon.Component.DataDisplay.Markdown do
  @moduledoc """
  Duskmoon UI Markdown Component

  Render markdown in to remark-element.

  The remark-element supported markdown featrues:
    * github flavor
    * auto highlight code with lowlight.js and auto detect system light/dark themes.
    * charts render by mermaid.js

  Require `remark-element` in your project.

  ```js

      import '@gsmlg/lit/remark-element';
  ```

  ```html

      <script type="module" src="https://esm.run/@gsmlg/lit"></script>
      <script type="module">
        import 'https://esm.run/@gsmlg/lit/remark-element';
      </script>
  ```

  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates a html customElement remark-element to preview markdown.

  Docs of remark-element (See https://gsmlg-dev.github.io/lit/?path=/story/gsmlg-remark-element--basic).

  ## Examples

      <.dm_markdown class="dark"># Hello</.dm_markdown>
      #=> <remark-element class="dark"># Hello</remark-element>

      <.dm_markdown class="btn"># Hello</.dm_markdown>
      #=> <remark-element class="btn"># Hello</remark-element>

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
    remark-element attribute, enable debug
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
    <remark-element id={@id} debug={@debug} class={@class}><%= @content %></remark-element>
    """
  end
end
