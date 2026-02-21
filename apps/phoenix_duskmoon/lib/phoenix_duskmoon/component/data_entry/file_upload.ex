defmodule PhoenixDuskmoon.Component.DataEntry.FileUpload do
  @moduledoc """
  File upload component using `el-dm-file-upload` custom element.

  Renders a drag-and-drop file upload zone with optional image previews,
  file type restrictions, size limits, and multiple file support.

  ## Examples

      <.dm_file_upload accept="image/*" multiple show_preview />

      <.dm_file_upload
        accept=".pdf,.doc,.docx"
        max_size={5_242_880}
        max_files={3}
      >
        Drop documents here
      </.dm_file_upload>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_error: 1]

  @doc """
  Renders a file upload dropzone using the `el-dm-file-upload` custom element.

  ## Examples

      <.dm_file_upload accept="image/*" multiple />

      <.dm_file_upload accept=".pdf" max_size={10_485_760}>
        Upload PDF files
      </.dm_file_upload>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:accept, :string, default: nil, doc: "accepted file types (e.g. \"image/*,.pdf\")")
  attr(:multiple, :boolean, default: false, doc: "allow multiple files")
  attr(:disabled, :boolean, default: false, doc: "disable the upload")
  attr(:max_size, :integer, default: nil, doc: "maximum file size in bytes")
  attr(:max_files, :integer, default: nil, doc: "maximum number of files")
  attr(:show_preview, :boolean, default: false, doc: "show image previews for selected files")
  attr(:compact, :boolean, default: false, doc: "use compact layout")

  attr(:size, :string,
    default: "md",
    values: ["sm", "md", "lg"],
    doc: "component size"
  )

  attr(:name, :string, default: nil, doc: "form field name")
  attr(:field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form")
  attr(:error, :boolean, default: false, doc: "show error state")
  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the component")
  attr(:rest, :global)
  slot(:inner_block, doc: "Custom dropzone content")

  def dm_file_upload(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:name, field.name)
    |> dm_file_upload()
  end

  def dm_file_upload(assigns) do
    ~H"""
    <div phx-feedback-for={@name}>
      <el-dm-file-upload
        id={@id}
        accept={@accept}
        multiple={@multiple}
        disabled={@disabled}
        max-size={@max_size}
        max-files={@max_files}
        show-preview={@show_preview}
        compact={@compact}
        size={@size}
        class={[(@error || @errors != []) && "file-upload-error", @class]}
        aria-invalid={@errors != [] && "true"}
        aria-describedby={
          (@errors != [] && @id && "#{@id}-errors") ||
            (@helper && @errors == [] && @id && "#{@id}-helper")
        }
        {@rest}
      >
        {render_slot(@inner_block)}
      </el-dm-file-upload>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end
end
