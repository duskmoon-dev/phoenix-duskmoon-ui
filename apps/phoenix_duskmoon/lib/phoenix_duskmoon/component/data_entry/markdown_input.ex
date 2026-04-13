defmodule PhoenixDuskmoon.Component.DataEntry.MarkdownInput do
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
  Files can be attached via drag-drop, paste, or the attach button in the
  bottom bar. With `upload_url` files are POSTed immediately; without it
  they are kept locally and submitted as `{name}_files` form fields.

  ## Examples

      <.dm_markdown_input name="body" value={@body} />

      <.dm_markdown_input
        field={@form[:body]}
        placeholder="Write markdown here…"
        upload_url="/api/uploads"
      />

      <.dm_markdown_input name="notes" value="" max_words={500}>
        <:bottom_start>
          <button type="button">Custom Action</button>
        </:bottom_start>
      </.dm_markdown_input>

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

  attr(:no_preview, :boolean,
    default: false,
    doc: "hide the preview tab and toolbar; write-only mode"
  )

  attr(:upload_url, :string,
    default: nil,
    doc: "POST endpoint for file uploads; server must return {url: string}"
  )

  attr(:max_words, :integer,
    default: nil,
    doc: "soft word cap shown in status bar (warning at 80%, error at 100%)"
  )

  attr(:resize, :string,
    default: nil,
    values: [nil, "none", "vertical", "horizontal", "both"],
    doc: "editor resize behavior"
  )

  attr(:live_preview, :boolean,
    default: false,
    doc: "enable live preview rendering"
  )

  attr(:debounce, :integer,
    default: nil,
    doc: "debounce delay (ms) for preview rendering"
  )

  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  slot(:bottom, doc: "replaces the entire bottom status bar") do
    attr(:class, :any, doc: "wrapper CSS classes")
  end

  slot(:bottom_start, doc: "left section of the bottom bar (default: attach files button)") do
    attr(:class, :any, doc: "wrapper CSS classes")
  end

  slot(:bottom_end, doc: "right section of the bottom bar (default: word/char count)") do
    attr(:class, :any, doc: "wrapper CSS classes")
  end

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
      no-preview={@no_preview}
      upload-url={@upload_url}
      max-words={@max_words}
      resize={@resize}
      live-preview={@live_preview}
      debounce={@debounce}
      class={@class}
      {@rest}
    >
      <div
        :for={bottom <- @bottom}
        slot="bottom"
        class={bottom[:class]}
      >
        {render_slot(bottom)}
      </div>
      <div
        :for={bottom_start <- @bottom_start}
        slot="bottom-start"
        class={bottom_start[:class]}
      >
        {render_slot(bottom_start)}
      </div>
      <div
        :for={bottom_end <- @bottom_end}
        slot="bottom-end"
        class={bottom_end[:class]}
      >
        {render_slot(bottom_end)}
      </div>
    </el-dm-markdown-input>
    """
  end
end
