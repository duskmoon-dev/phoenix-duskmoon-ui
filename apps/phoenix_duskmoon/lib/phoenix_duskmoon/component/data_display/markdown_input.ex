defmodule PhoenixDuskmoon.Component.DataDisplay.MarkdownInput do
  @moduledoc """
  Duskmoon UI Markdown Input Component

  Rich markdown editor using `<el-dm-markdown-input>` custom element from
  `@duskmoon-dev/el-markdown-input`.

  Provides a split-pane editor with live markdown preview, syntax highlighting,
  and optional Mermaid diagram support.

  Requires `@duskmoon-dev/el-markdown-input` registered in your project:

  ```js
  import '@duskmoon-dev/el-markdown-input/register';
  ```

  """
  use Phoenix.Component

  @doc """
  Renders an `<el-dm-markdown-input>` custom element for markdown editing.

  Supports both standalone usage and Phoenix form field integration.

  ## Examples

      <.dm_markdown_input name="body" value={@body} />

      <.dm_markdown_input
        field={@form[:body]}
        label="Content"
        placeholder="Write markdown here…"
        theme="atom-one-dark"
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, default: nil, doc: "HTML name attribute for form submission")
  attr(:value, :any, default: nil, doc: "markdown content value")

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, sets id/name/value automatically"
  )

  attr(:label, :string, default: nil, doc: "text label displayed above the editor")
  attr(:placeholder, :string, default: nil, doc: "placeholder text shown when editor is empty")

  attr(:disabled, :boolean, default: false, doc: "disables the editor")
  attr(:readonly, :boolean, default: false, doc: "makes the editor read-only")

  attr(:theme, :string,
    default: nil,
    values: [nil, "github", "atom-one-dark", "atom-one-light", "auto"],
    doc: "code syntax highlighting theme for the preview pane"
  )

  attr(:no_mermaid, :boolean,
    default: false,
    doc: "disable Mermaid diagram rendering in the preview pane"
  )

  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  def dm_markdown_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> dm_markdown_input()
  end

  def dm_markdown_input(assigns) do
    ~H"""
    <el-dm-markdown-input
      id={@id}
      name={@name}
      value={@value}
      placeholder={@placeholder}
      disabled={@disabled}
      readonly={@readonly}
      theme={@theme}
      no-mermaid={@no_mermaid}
      class={@class}
      {@rest}
    ></el-dm-markdown-input>
    """
  end
end
