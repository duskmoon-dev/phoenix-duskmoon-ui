defmodule PhoenixDuskmoon.Component.DataEntry.Input do
  @moduledoc """
  Form input components for PhoenixDuskmoon UI.

  This module provides a comprehensive set of input components that support
  various input types including text, checkbox, select, textarea, file, and
  specialized inputs like date pickers, color pickers, range sliders, and more.

  ## Examples

      <.dm_input field={@form[:email]} type="email" label="Email" />
      <.dm_input name="username" label="Username" value="john" />
      <.dm_input type="select" name="country" options={[{"USA", "us"}, {"Canada", "ca"}]} />
      <.dm_input type="rating" name="rating" max={5} value={3} />
      <.dm_input type="password_strength" name="password" label="Password" />
  """

  use PhoenixDuskmoon.Component, :html
  import PhoenixDuskmoon.Component.Icon.Icons
  import PhoenixDuskmoon.Component.DataEntry.Form
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1, format_label: 2]

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.dm_input field={@form[:email]} type="email" />
      <.dm_input name="my-input" errors={["oh no!"]} />
  """
  @doc type: :component
  attr(:field_class, :any, default: nil, doc: "additional CSS classes for the field wrapper")
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the outer wrapper")
  attr(:classic, :boolean, default: false, doc: "use classic input styling instead of modern")
  attr(:name, :any, doc: "HTML name attribute for form submission")
  attr(:label, :string, default: nil, doc: "text label displayed above the input")
  attr(:label_class, :any, default: nil, doc: "additional CSS classes for the label")
  attr(:value, :any, doc: "the input value")

  attr(:color, :string,
    default: nil,
    doc:
      "the color variant of the input (primary, secondary, accent, info, success, warning, error)"
  )

  attr(:size, :string,
    default: nil,
    doc: "the size of the input (xs, sm, lg)"
  )

  attr(:variant, :string,
    default: nil,
    values: ["ghost", "filled", "bordered", nil],
    doc: "the input style variant (ghost, filled, bordered)"
  )

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week checkbox_group
               radio_group toggle range_slider rating datepicker timepicker color_picker switch
               search_with_suggestions file_upload rich_text tags slider_range password_strength),
    doc: "the input type"
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [], doc: "list of error messages to display")
  attr(:helper, :string, default: nil, doc: "helper text displayed below the input")
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")
  attr(:horizontal, :boolean, default: false, doc: "horizontal layout (label beside input)")

  attr(:state, :string,
    default: nil,
    values: [nil, "success", "warning"],
    doc: "validation state (applies form-group-success/warning)"
  )

  attr(:rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)
  )

  attr(:swatches, :list, default: nil, doc: "list of color swatches for color_picker type")

  attr(:suggestions, :list,
    default: [],
    doc: "list of suggestion strings for search_with_suggestions type"
  )

  attr(:phx_target, :any,
    default: nil,
    doc: "the phx-target for events (for use in LiveComponents)"
  )

  attr(:drop_text, :string,
    default: "Drop files here or click to browse",
    doc: "text shown in the file_upload drop zone"
  )

  attr(:choose_files_text, :string,
    default: "Choose Files",
    doc: "text for the file_upload browse button"
  )

  attr(:add_tag_placeholder, :string,
    default: "Add tag...",
    doc: "placeholder for the tags input field"
  )

  attr(:password_hint_weak, :string,
    default: "• Add uppercase letters, numbers, and special characters",
    doc: "hint text shown when password strength is weak"
  )

  attr(:password_hint_medium, :string,
    default: "• Add more special characters or increase length",
    doc: "hint text shown when password strength is medium"
  )

  attr(:password_hint_strong, :string,
    default: "• Strong password!",
    doc: "hint text shown when password strength is strong"
  )

  attr(:password_strength_label, :string,
    default: "Password strength",
    doc: "accessible label for the password strength progressbar (i18n)"
  )

  attr(:remove_file_label, :string,
    default: "Remove file",
    doc: "accessible label for the remove file button in file_upload type"
  )

  attr(:toolbar_label, :string,
    default: "Text formatting",
    doc: "accessible label for the rich_text toolbar"
  )

  attr(:bold_label, :string, default: "Bold", doc: "accessible label for the bold button")
  attr(:italic_label, :string, default: "Italic", doc: "accessible label for the italic button")

  attr(:underline_label, :string,
    default: "Underline",
    doc: "accessible label for the underline button"
  )

  attr(:bulleted_list_label, :string,
    default: "Bulleted list",
    doc: "accessible label for the bulleted list button"
  )

  attr(:numbered_list_label, :string,
    default: "Numbered list",
    doc: "accessible label for the numbered list button"
  )

  attr(:insert_link_label, :string,
    default: "Insert link",
    doc: "accessible label for the insert link button"
  )

  attr(:toggle_password_label, :string,
    default: "Toggle password visibility",
    doc: "accessible label for the password visibility toggle"
  )

  attr(:rating_group_label, :string,
    default: "{label} rating",
    doc: "accessible label template for the rating group (i18n). Use {label} for the field label."
  )

  attr(:rating_item_label, :string,
    default: "Rate {index} out of {max}",
    doc: "accessible label template for each rating item (i18n). Use {index} and {max}."
  )

  attr(:remove_tag_label, :string,
    default: "Remove tag {tag}",
    doc: "accessible label template for tag removal buttons (i18n). Use {tag} for the tag value."
  )

  def dm_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    # |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_input()
  end

  def dm_input(%{color: color} = assigns) when color != nil do
    assigns
    |> assign(:color, css_color(color))
    |> dm_input_by_type()
  end

  def dm_input(assigns), do: dm_input_by_type(assigns)

  defp dm_input_by_type(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-on-surface-variant">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[if(!@classic, do: "checkbox"), @class]}
          {@rest}
        />
        {@label}
      </label>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "toggle", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id}>{@label}</.dm_label>
      <div class="flex flex-col justify-center gap-2">
        <input type="hidden" name={@name} value="false" />
        <label class="switch-label">
          <input
            type="checkbox"
            id={@id}
            class={["switch", @color && "switch-#{@color}", @size && "switch-#{@size}", @class]}
            name={@name}
            value="true"
            checked={@checked}
            role="switch"
            aria-checked={to_string(@checked == true)}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            {@rest}
          />
        </label>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "select"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <select
          id={@id}
          name={@name}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[
            if(!@classic, do: "select"),
            @color && "select-#{@color}",
            @size && "select-#{@size}",
            @class,
            @errors != [] && "select-error"
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value="">{@prompt}</option>
          {Phoenix.HTML.Form.options_for_select(@options, @value)}
        </select>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "checkbox_group"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} id={@id && "#{@id}-label"}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6" role="group" aria-labelledby={@id && "#{@id}-label"}>
          <label
            class="inline-flex items-center gap-2 min-w-max"
            :for={{opt_label, opt_value} <- @options}
          >
            <input
              type="checkbox"
          class={[
            if(!@classic, do: "checkbox"),
            @color && "checkbox-#{@color}",
            @size && "checkbox-#{@size}",
            @class
          ]}
              name={"#{@name}[]"}
              checked={Enum.member?(if(is_list(@value), do: @value, else: []), opt_value)}
              value={opt_value}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            />
            {opt_label}
          </label>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "radio_group"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} id={@id && "#{@id}-label"}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6" role="group" aria-labelledby={@id && "#{@id}-label"}>
          <label class="inline-flex items-center gap-2 min-w-max" :for={{opt_label, opt_value} <- @options}>
            <input
              type="radio"
              class={[
                if(!@classic, do: "radio"),
                @color && "radio-#{@color}",
                @size && "radio-#{@size}",
                @class
              ]}
              name={@name}
              checked={to_string(@value) == to_string(opt_value)}
              value={opt_value}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            />
            {opt_label}
          </label>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <textarea
          id={@id}
          name={@name}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[
            if(!@classic, do: "textarea"),
            @color && "textarea-#{@color}",
            @size && "textarea-#{@size}",
            @class,
            @errors != [] && "textarea-error"
          ]}
          {@rest}
        >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "file"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <input
          id={@id}
          type="file"
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[
            @class,
            if(!@classic, do: "input file-upload"),
            @variant && "input-#{@variant}",
            @color && "input-#{@color}",
            @size && "input-#{@size}",
            @errors != [] && "input-error"
          ]}
          {@rest}
        />
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "range_slider"} = assigns) do
    assigns =
      assign_new(assigns, :min, fn -> assigns.rest[:min] || 0 end)
      |> assign_new(:max, fn -> assigns.rest[:max] || 100 end)
      |> assign_new(:step, fn -> assigns.rest[:step] || 1 end)

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>
        {@label} <span class="text-sm font-normal text-on-surface-variant">({@value || @min})</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-4">
          <span class="text-sm text-on-surface-variant">{@min}</span>
          <input
            type="range"
            id={@id}
            name={@name}
            value={Phoenix.HTML.Form.normalize_value("range", @value)}
            min={@min}
            max={@max}
            step={@step}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            class={[
              @class,
              if(!@classic, do: "slider"),
              @color && "slider-#{@color}",
              @size && "slider-#{@size}"
            ]}
            {@rest}
          />
          <span class="text-sm text-on-surface-variant">{@max}</span>
        </div>
        <div class="slider-labels">
          <span>{@min}</span>
          <span class="font-medium text-on-surface">{@value || @min}</span>
          <span>{@max}</span>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "rating"} = assigns) do
    assigns =
      assign_new(assigns, :max, fn -> assigns.rest[:max] || 5 end)
      |> assign_new(:readonly, fn -> assigns.rest[:readonly] || false end)

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>
        {@label} <span class="rating-count">({@value || 0}/{@max})</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div
          class={[
            "rating",
            @color && "rating-#{@color}",
            @size && "rating-#{@size}",
            @readonly && "rating-readonly"
          ]}
          role="group"
          aria-label={format_label(@rating_group_label, %{"label" => @label})}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
        >
          <input type="hidden" name={@name} id={@id} value={@value || 0} />
          <button
            :for={i <- 1..@max}
            type="button"
            aria-label={format_label(@rating_item_label, %{"index" => i, "max" => @max})}
            aria-pressed={to_string(i <= (@value || 0))}
            class={["rating-item", i <= (@value || 0) && "filled"]}
            disabled={@readonly}
            aria-disabled={@readonly && "true"}
          >
            <.dm_mdi name="star" class="rating-icon" />
          </button>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "datepicker"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="date"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "input"),
              @variant && "input-#{@variant}",
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            {@rest}
          />
          <.dm_mdi name="calendar" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-on-surface-variant pointer-events-none" />
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "timepicker"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="time"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "input"),
              @variant && "input-#{@variant}",
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            {@rest}
          />
          <.dm_mdi name="clock" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-on-surface-variant pointer-events-none" />
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "color_picker"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-2">
          <div class="relative">
            <input
              type="color"
              id={@id}
              name={@name}
              value={@value || "#000000"}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
              class={[
                "w-12 h-12 rounded cursor-pointer",
                @color && "border-2 border-#{@color}",
                @size == "sm" && "w-8 h-8",
                @size == "lg" && "w-16 h-16"
              ]}
              {@rest}
            />
          </div>
          <input
            type="text"
            value={@value || "#000000"}
            class={[
              "input flex-1",
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            readonly
          />
        </div>
        <div :if={@swatches} class="flex flex-wrap gap-2">
          <button
            type="button"
            class="w-8 h-8 rounded border-2 border-surface-container-high hover:border-on-surface transition-colors"
            style={"background-color: #{swatch}"}
            aria-label={"Select color #{swatch}"}
            :for={swatch <- @swatches}
          />
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <label class="flex items-center justify-between gap-4">
        <span class="text-sm leading-6 text-on-surface-variant">{@label}</span>
        <div class="flex items-center">
          <input type="hidden" name={@name} value="false" />
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            role="switch"
            aria-checked={to_string(@checked == true)}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            class={[
              "switch",
              @color && "switch-#{@color}",
              @size && "switch-#{@size}",
              @class
            ]}
            {@rest}
          />
        </div>
      </label>
      <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "search_with_suggestions"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="text"
            id={@id}
            name={@name}
            value={@value}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            class={[
              @class,
              if(!@classic, do: "input"),
              @variant && "input-#{@variant}",
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            {@rest}
          />
          <.dm_mdi name="magnify" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-on-surface-variant pointer-events-none" />
        </div>
        <div :if={@suggestions != []} class="dropdown dropdown-open">
          <ul class="dropdown-content menu w-full">
            <li :for={suggestion <- @suggestions}>
              <button type="button">
                {suggestion}
              </button>
            </li>
          </ul>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "file_upload"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="file-upload">
        <div class="file-upload-dropzone">
          <div class="file-upload-icon">
            <.dm_mdi name="cloud-upload" />
          </div>
          <div class="file-upload-text">
            <p class="file-upload-title">{@drop_text}</p>
          </div>
          <input
            type="file"
            id={@id}
            name={@name}
            class="file-upload-input"
            multiple={@multiple}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            {@rest}
          />
          <button
            type="button"
            class={[
              "file-upload-button",
              @size && "btn-#{@size}"
            ]}
          >
            {@choose_files_text}
          </button>
        </div>
        <div :if={@value} class="file-upload-list">
          <div class="file-upload-item">
            <div class="file-upload-item-icon">
              <.dm_mdi name="file" />
            </div>
            <div class="file-upload-item-info">
              <span class="file-upload-item-name">{@value}</span>
            </div>
            <button type="button" class="file-upload-item-remove" aria-label={@remove_file_label}>
              <.dm_mdi name="close" />
            </button>
          </div>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "rich_text"} = assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="toolbar flex items-center gap-1 p-2 bg-surface-container-low rounded-t-lg" role="toolbar" aria-label={@toolbar_label}>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@bold_label}>
            <.dm_mdi name="format-bold" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@italic_label}>
            <.dm_mdi name="format-italic" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@underline_label}>
            <.dm_mdi name="format-underline" class="w-4 h-4" />
          </button>
          <div class="divider"></div>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@bulleted_list_label}>
            <.dm_mdi name="format-list-bulleted" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@numbered_list_label}>
            <.dm_mdi name="format-list-numbered" class="w-4 h-4" />
          </button>
          <div class="divider"></div>
          <button type="button" class="btn btn-ghost btn-xs" aria-label={@insert_link_label}>
            <.dm_mdi name="link" class="w-4 h-4" />
          </button>
        </div>
        <div
          contenteditable="true"
          role="textbox"
          aria-multiline="true"
          aria-label={@label}
          id={@id}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[
            "min-h-[150px] p-3 border border-surface-container-high rounded-b-lg focus:outline-none focus:border-primary",
            @color && "focus:border-#{@color}",
            @errors != [] && "border-error"
          ]}
          data-name={@name}
        >
          {Phoenix.HTML.raw(@value || "")}
        </div>
        <input type="hidden" name={@name} id={"#{@id}_hidden"} value={@value || ""} />
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "tags"} = assigns) do
    assigns = assign(assigns, :tags, List.wrap(assigns[:value] || []))

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-2 p-2 border border-surface-container-high rounded-lg" role="group" aria-label={"#{@label} tags"} aria-invalid={@errors != [] && "true"} aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}>
          <span
            :for={tag <- @tags}
            class={[
              "badge badge-lg gap-1",
              @color && "badge-#{@color}"
            ]}
          >
            {tag}
            <button
              type="button"
              class="btn btn-ghost btn-xs p-0"
              aria-label={format_label(@remove_tag_label, %{"tag" => tag})}
            >
              <.dm_mdi name="close" class="w-3 h-3" />
            </button>
          </span>
          <input
            type="text"
            id={@id}
            class="input input-sm flex-1 min-w-[100px] border-none focus:outline-none"
            placeholder={@add_tag_placeholder}
          />
        </div>
        <input type="hidden" name={@name} value={inspect(@tags)} />
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "slider_range"} = assigns) do
    assigns =
      assign_new(assigns, :min, fn -> assigns.rest[:min] || 0 end)
      |> assign_new(:max, fn -> assigns.rest[:max] || 100 end)
      |> assign_new(:step, fn -> assigns.rest[:step] || 1 end)

    assigns =
      assign(
        assigns,
        :min_val,
        List.wrap(assigns[:value] || [assigns[:min], assigns[:max]]) |> Enum.at(0)
      )

    assigns =
      assign(
        assigns,
        :max_val,
        List.wrap(assigns[:value] || [assigns[:min], assigns[:max]]) |> Enum.at(1)
      )

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>
        {@label} <span class="text-sm font-normal text-on-surface-variant">({@min_val} - {@max_val})</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-4">
          <span class="text-sm text-on-surface-variant">{@min}</span>
          <div class="flex-1 relative">
            <input
              type="range"
              id={"#{@id}_min"}
              name={"#{@name}_min"}
              value={@min_val}
              min={@min}
              max={@max}
              step={@step}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
              class={[
                "slider slider-sm",
                @color && "slider-#{@color}"
              ]}
            />
            <input
              type="range"
              id={"#{@id}_max"}
              name={"#{@name}_max"}
              value={@max_val}
              min={@min}
              max={@max}
              step={@step}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
              class={[
                "slider slider-sm",
                @color && "slider-#{@color}"
              ]}
              phx-target={@phx_target}
              phx-change="range_max_change"
            />
          </div>
          <span class="text-sm text-on-surface-variant">{@max}</span>
        </div>
        <div class="slider-labels">
          <span>{@min}</span>
          <span class="font-medium text-on-surface">{@min_val} - {@max_val}</span>
          <span>{@max}</span>
        </div>
        <input type="hidden" name={@name} value={inspect([@min_val, @max_val])} />
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp dm_input_by_type(%{type: "password_strength"} = assigns) do
    assigns = assign(assigns, :strength, calculate_password_strength(assigns[:value] || ""))

    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="password"
            id={@id}
            name={@name}
            value={@value}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
            class={[
              @class,
              if(!@classic, do: "input"),
              @variant && "input-#{@variant}",
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}

            {@rest}
          />
          <button
            type="button"
            class="absolute right-3 top-1/2 -translate-y-1/2"
            aria-label={@toggle_password_label}
          >
            <.dm_mdi name="eye" class="w-4 h-4 text-on-surface-variant" />
          </button>
        </div>
        <div class="flex items-center gap-2">
          <div
            class={[
              "progress flex-1",
              @strength == "weak" && "progress-error",
              @strength == "medium" && "progress-warning",
              @strength == "strong" && "progress-success"
            ]}
            role="progressbar"
            aria-valuenow={strength_value(@strength)}
            aria-valuemin="0"
            aria-valuemax="100"
            aria-label={@password_strength_label}
          >
            <div
              class="progress-bar"
              style={
                cond do
                  @strength == "weak" -> "width: 33%"
                  @strength == "medium" -> "width: 67%"
                  @strength == "strong" -> "width: 100%"
                  true -> "width: 0%"
                end
              }
            />
          </div>
          <span class={[
            "text-xs font-medium",
            @strength == "weak" && "text-error",
            @strength == "medium" && "text-warning",
            @strength == "strong" && "text-success"
          ]}>
            {String.capitalize(@strength)}
          </span>
        </div>
        <div class="text-xs text-on-surface-variant">
          <p :if={@strength == "weak"}>{@password_hint_weak}</p>
          <p :if={@strength == "medium"}>{@password_hint_medium}</p>
          <p :if={@strength == "strong"}>{@password_hint_strong}</p>
        </div>
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  defp dm_input_by_type(assigns) do
    ~H"""
    <div class={["form-group", @horizontal && "form-group-horizontal", @errors != [] && "form-group-error", @state && "form-group-#{@state}", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@label_class}>{@label}</.dm_label>
      <div class="flex flex-col gap-2">
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={(@errors != [] && @id && "#{@id}-errors") || (@helper && @errors == [] && @id && "#{@id}-helper")}
          class={[
            @class,
            if(!@classic, do: "input"),
            @variant && "input-#{@variant}",
            @color && "input-#{@color}",
            @size && "input-#{@size}",
            @errors != [] && "input-error"
          ]}
          {@rest}
        />
        <span :if={@helper && @errors == []} id={@id && "#{@id}-helper"} class="helper-text">{@helper}</span>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}>{msg}</.dm_error>
        </div>
      </div>
    </div>
    """
  end

  defp strength_value("weak"), do: 33
  defp strength_value("medium"), do: 66
  defp strength_value("strong"), do: 100
  defp strength_value(_), do: 0

  defp calculate_password_strength(password) do
    cond do
      String.length(password) < 8 ->
        "weak"

      String.match?(password, ~r/[A-Z]/) and String.match?(password, ~r/[a-z]/) and
        String.match?(password, ~r/[0-9]/) and String.match?(password, ~r/[^A-Za-z0-9]/) and
          String.length(password) >= 12 ->
        "strong"

      String.match?(password, ~r/[A-Z]/) or String.match?(password, ~r/[a-z]/) or
        String.match?(password, ~r/[0-9]/) or String.match?(password, ~r/[^A-Za-z0-9]/) ->
        "medium"

      true ->
        "weak"
    end
  end
end
