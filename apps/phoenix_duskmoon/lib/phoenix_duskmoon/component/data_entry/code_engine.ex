defmodule PhoenixDuskmoon.Component.DataEntry.CodeEngine do
  @moduledoc """
  Duskmoon UI Code Engine Component

  Lightweight code editor using `<el-dm-code-engine>` custom element from
  `@duskmoon-dev/el-code-engine`, backed by CodeMirror 6.

  Supports syntax highlighting for 25+ languages, optional topbar/bottombar,
  and integrates with Phoenix forms via the `field` attribute.

  Requires `@duskmoon-dev/el-code-engine` registered in your project:

  ```js
  import '@duskmoon-dev/el-code-engine/register';
  ```

  """
  use Phoenix.Component

  @doc """
  Renders an `<el-dm-code-engine>` custom element for code editing.

  Supports both standalone usage and Phoenix form field integration.
  The element behaves like a native `<textarea>`: the `value` attribute sets
  initial content, and `input`/`change` events fire on edits and blur.

  ## Examples

      <.dm_code_engine language="elixir" value={@code} />

      <.dm_code_engine
        field={@form[:source]}
        language="javascript"
        theme="one-dark"
        show_topbar
        title="app.js"
      />

      <.dm_code_engine language="html" value="" wrap>
        <:bottombar>
          <span>Custom status</span>
        </:bottombar>
      </.dm_code_engine>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:name, :any, default: nil, doc: "HTML name attribute for form submission")
  attr(:value, :any, default: nil, doc: "initial editor content")

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, sets id/name/value automatically"
  )

  attr(:language, :string,
    default: nil,
    doc:
      "syntax highlighting language (e.g. javascript, typescript, elixir, python, rust, go, html, css, json, sql, yaml, markdown)"
  )

  attr(:readonly, :boolean, default: false, doc: "makes the editor read-only")

  attr(:theme, :string,
    default: nil,
    values: [nil, "duskmoon", "sunshine", "moonlight", "one-dark"],
    doc: "editor color theme"
  )

  attr(:wrap, :boolean, default: false, doc: "enable line wrapping")

  attr(:show_topbar, :boolean,
    default: false,
    doc: "show topbar with copy button and title"
  )

  attr(:show_bottombar, :boolean,
    default: false,
    doc: "show bottombar"
  )

  attr(:title, :string, default: nil, doc: "title shown in topbar (e.g. filename)")

  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  slot(:topbar, doc: "custom topbar content (replaces default)") do
    attr(:class, :any, doc: "wrapper CSS classes")
  end

  slot(:bottombar, doc: "custom bottombar content (replaces default)") do
    attr(:class, :any, doc: "wrapper CSS classes")
  end

  def dm_code_engine(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> assign(:value, field.value)
    |> dm_code_engine()
  end

  def dm_code_engine(assigns) do
    ~H"""
    <el-dm-code-engine
      id={@id}
      name={@name}
      value={@value}
      language={@language}
      readonly={@readonly}
      theme={@theme}
      wrap={@wrap}
      show-topbar={@show_topbar}
      show-bottombar={@show_bottombar}
      title={@title}
      class={@class}
      {@rest}
    >
      <div
        :for={topbar <- @topbar}
        slot="topbar"
        class={topbar[:class]}
      >
        {render_slot(topbar)}
      </div>
      <div
        :for={bottombar <- @bottombar}
        slot="bottombar"
        class={bottombar[:class]}
      >
        {render_slot(bottombar)}
      </div>
    </el-dm-code-engine>
    """
  end
end
