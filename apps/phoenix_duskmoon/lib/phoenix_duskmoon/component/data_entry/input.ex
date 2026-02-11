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
  attr(:field_class, :any, default: nil)
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:classic, :boolean, default: false)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:color, :string,
    default: nil,
    doc:
      "the color variant of the input (primary, secondary, accent, info, success, warning, error)"
  )

  attr(:size, :string,
    default: nil,
    doc: "the size of the input (xs, sm, lg)"
  )

  attr(:type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week checkbox_group
               radio_group toggle range_slider rating datepicker timepicker color_picker switch
               search_with_suggestions file_upload rich_text tags slider_range password_strength)
  )

  attr(:field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"
  )

  attr(:errors, :list, default: [])
  attr(:checked, :boolean, doc: "the checked flag for checkbox inputs")
  attr(:prompt, :string, default: nil, doc: "the prompt for select inputs")
  attr(:options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2")
  attr(:multiple, :boolean, default: false, doc: "the multiple flag for select inputs")

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

  slot(:inner_block)

  def dm_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    # |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_input()
  end

  def dm_input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[if(!@classic, do: "dm-checkbox"), @class]}
          {@rest}
        />
        <%= @label %>
      </label>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "toggle", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id}><%= @label %></.dm_label>
      <div class="flex flex-col justify-center gap-2">
        <input type="hidden" name={@name} value="false" />
        <label class={[
          "dm-switch",
          @color && "dm-switch--#{@color}",
          @size && "dm-switch--#{@size}"
        ]}>
          <input
            type="checkbox"
            id={@id}
            class={["dm-switch__input", @class]}
            name={@name}
            value="true"
            checked={@checked}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            {@rest}
          />
          <span class="dm-switch__track"></span>
        </label>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <select
          id={@id}
          name={@name}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            if(!@classic, do: "dm-select"),
            @color && "dm-select--#{@color}",
            @size && "dm-select--#{@size}",
            @class,
            @errors != [] && "dm-select--error"
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "checkbox_group"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} id={@id && "#{@id}-label"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6" role="group" aria-labelledby={@id && "#{@id}-label"}>
          <label
            class="inline-flex items-center gap-2 min-w-max"
            :for={{opt_label, opt_value} <- @options}
          >
            <input
              type="checkbox"
          class={[
            if(!@classic, do: "dm-checkbox"),
            @color && "dm-checkbox--#{@color}",
            @size && "dm-checkbox--#{@size}",
            @class
          ]}
              name={"#{@name}[]"}
              checked={Enum.member?(if(is_list(@value), do: @value, else: []), opt_value)}
              value={opt_value}
              aria-invalid={@errors != [] && "true"}
            />
            <%= opt_label %>
          </label>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "radio_group"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} id={@id && "#{@id}-label"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6" role="group" aria-labelledby={@id && "#{@id}-label"}>
          <label class="inline-flex items-center gap-2 min-w-max" :for={{opt_label, opt_value} <- @options}>
            <input
              type="radio"
              class={[
                if(!@classic, do: "dm-radio"),
                @color && "dm-radio--#{@color}",
                @size && "dm-radio--#{@size}",
                @class
              ]}
              name={@name}
              checked={to_string(@value) == to_string(opt_value)}
              value={opt_value}
              aria-invalid={@errors != [] && "true"}
            />
            <%= opt_label %>
          </label>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <textarea
          id={@id}
          name={@name}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            if(!@classic, do: "dm-textarea"),
            @color && "dm-textarea--#{@color}",
            @size && "dm-textarea--#{@size}",
            @class,
            @errors != [] && "dm-textarea--error"
          ]}
          {@rest}
        ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "file"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <input
          id={@id}
          type="file"
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            @class,
            if(!@classic, do: "dm-input dm-input--file"),
            @color && "dm-input--#{@color}",
            @size && "dm-input--#{@size}",
            @errors != [] && "dm-input--error"
          ]}
          {@rest}
        />
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "range_slider"} = assigns) do
    assigns =
      assign_new(assigns, :min, fn -> assigns.rest[:min] || 0 end)
      |> assign_new(:max, fn -> assigns.rest[:max] || 100 end)
      |> assign_new(:step, fn -> assigns.rest[:step] || 1 end)

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}>
        <%= @label %> <span class="text-sm font-normal text-base-content/70">(<%= @value || @min %>)</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-4">
          <span class="text-sm text-base-content/70"><%= @min %></span>
          <input
            type="range"
            id={@id}
            name={@name}
            value={Phoenix.HTML.Form.normalize_value("range", @value)}
            min={@min}
            max={@max}
            step={@step}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            class={[
              @class,
              if(!@classic, do: "dm-range"),
              @color && "dm-range--#{@color}",
              @size && "dm-range--#{@size}"
            ]}
            {@rest}
          />
          <span class="text-sm text-base-content/70"><%= @max %></span>
        </div>
        <div class="flex justify-between text-xs text-base-content/50">
          <span><%= @min %></span>
          <span class="font-medium text-base-content"><%= @value || @min %></span>
          <span><%= @max %></span>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "rating"} = assigns) do
    assigns =
      assign_new(assigns, :max, fn -> assigns.rest[:max] || 5 end)
      |> assign_new(:readonly, fn -> assigns.rest[:readonly] || false end)

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}>
        <%= @label %> <span class="text-sm font-normal text-base-content/70">(<%= @value || 0 %>/<%= @max %>)</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-1" role="group" aria-label={"#{@label} rating"} aria-invalid={@errors != [] && "true"} aria-describedby={@errors != [] && @id && "#{@id}-errors"}>
          <input type="hidden" name={@name} id={@id} value={@value || 0} />
          <%= for i <- 1..@max do %>
            <button
              type="button"
              aria-label={"Rate #{i} out of #{@max}"}
              class={[
                "dm-btn dm-btn--ghost dm-btn--sm p-1",
                i <= (@value || 0) && "text-warning",
                @color && i <= (@value || 0) && "text-#{@color}",
                @size == "xs" && "dm-btn--xs",
                @size == "sm" && "dm-btn--sm",
                @size == "lg" && "dm-btn--lg"
              ]}
              disabled={@readonly}
            >
              <.dm_mdi name="star" class="w-4 h-4" />
            </button>
          <% end %>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "datepicker"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="date"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "dm-input"),
              @color && "dm-input--#{@color}",
              @size && "dm-input--#{@size}",
              @errors != [] && "dm-input--error"
            ]}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            {@rest}
          />
          <.dm_mdi name="calendar" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "timepicker"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="time"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "dm-input"),
              @color && "dm-input--#{@color}",
              @size && "dm-input--#{@size}",
              @errors != [] && "dm-input--error"
            ]}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            {@rest}
          />
          <.dm_mdi name="clock" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "color_picker"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-2">
          <div class="relative">
            <input
              type="color"
              id={@id}
              name={@name}
              value={@value || "#000000"}
              aria-invalid={@errors != [] && "true"}
              aria-describedby={@errors != [] && @id && "#{@id}-errors"}
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
              "dm-input flex-1",
              @color && "dm-input--#{@color}",
              @size && "dm-input--#{@size}",
              @errors != [] && "dm-input--error"
            ]}
            readonly
          />
        </div>
        <div :if={@swatches} class="flex flex-wrap gap-2">
          <button
            type="button"
            class="w-8 h-8 rounded border-2 border-base-300 hover:border-base-content transition-colors"
            style={"background-color: #{swatch}"}
            aria-label={"Select color #{swatch}"}
            :for={swatch <- @swatches}
          />
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "switch"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <label class="flex items-center justify-between gap-4">
        <span class="text-sm leading-6 text-zinc-600"><%= @label %></span>
        <div class="flex items-center">
          <input type="hidden" name={@name} value="false" />
          <input
            type="checkbox"
            id={@id}
            name={@name}
            value="true"
            checked={@checked}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            class={[
              "dm-switch dm-switch--lg",
              @color && "dm-switch--#{@color}",
              @size && "dm-switch--#{@size}",
              @class
            ]}
            {@rest}
          />
        </div>
      </label>
      <div :if={@errors != []} id={@id && "#{@id}-errors"}>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "search_with_suggestions"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="text"
            id={@id}
            name={@name}
            value={@value}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            class={[
              @class,
              if(!@classic, do: "dm-input"),
              @color && "dm-input--#{@color}",
              @size && "dm-input--#{@size}",
              @errors != [] && "dm-input--error"
            ]}
            {@rest}
          />
          <.dm_mdi name="magnify" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <div :if={length(@suggestions) > 0} class="dm-dropdown dm-dropdown--open">
          <ul class="dm-dropdown__content dm-menu p-2 shadow bg-base-100 rounded-box w-full">
            <li :for={suggestion <- @suggestions}>
              <button type="button">
                <%= suggestion %>
              </button>
            </li>
          </ul>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "file_upload"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="border-2 border-dashed border-base-300 rounded-lg p-6 text-center hover:border-base-content transition-colors">
          <.dm_mdi name="cloud-upload" class="w-12 h-12 mx-auto text-base-content/50 mb-2" />
          <p class="text-sm text-base-content/70 mb-2">{@drop_text}</p>
          <input
            type="file"
            id={@id}
            name={@name}
            class="hidden"
            multiple={@multiple}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            {@rest}
          />
          <button
            type="button"
            class={[
              "dm-btn dm-btn--sm",
              @color && "dm-btn--#{@color}",
              @size && "dm-btn--#{@size}"
            ]}
          >
            {@choose_files_text}
          </button>
        </div>
        <div :if={@value} class="flex items-center gap-2 p-2 bg-base-200 rounded">
          <.dm_mdi name="file" class="w-4 h-4" />
          <span class="text-sm flex-1"><%= @value %></span>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@remove_file_label}>
            <.dm_mdi name="close" class="w-3 h-3" />
          </button>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "rich_text"} = assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="toolbar flex items-center gap-1 p-2 bg-base-200 rounded-t-lg" role="toolbar" aria-label={@toolbar_label}>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@bold_label}>
            <.dm_mdi name="format-bold" class="w-4 h-4" />
          </button>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@italic_label}>
            <.dm_mdi name="format-italic" class="w-4 h-4" />
          </button>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@underline_label}>
            <.dm_mdi name="format-underline" class="w-4 h-4" />
          </button>
          <div class="dm-divider dm-divider--horizontal"></div>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@bulleted_list_label}>
            <.dm_mdi name="format-list-bulleted" class="w-4 h-4" />
          </button>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@numbered_list_label}>
            <.dm_mdi name="format-list-numbered" class="w-4 h-4" />
          </button>
          <div class="dm-divider dm-divider--horizontal"></div>
          <button type="button" class="dm-btn dm-btn--ghost dm-btn--xs" aria-label={@insert_link_label}>
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
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            "min-h-[150px] p-3 border border-base-300 rounded-b-lg focus:outline-none focus:border-primary",
            @color && "focus:border-#{@color}",
            @errors != [] && "border-error"
          ]}
          data-name={@name}
        >
          <%= Phoenix.HTML.raw(@value || "") %>
        </div>
        <input type="hidden" name={@name} id={"#{@id}_hidden"} value={@value || ""} />
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "tags"} = assigns) do
    assigns = assign(assigns, :tags, List.wrap(assigns[:value] || []))

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-2 p-2 border border-base-300 rounded-lg" role="group" aria-label={"#{@label} tags"} aria-invalid={@errors != [] && "true"} aria-describedby={@errors != [] && @id && "#{@id}-errors"}>
          <%= for tag <- @tags do %>
            <span class={[
              "dm-badge dm-badge--lg gap-1",
              @color && "dm-badge--#{@color}"
            ]}>
              <%= tag %>
              <button
                type="button"
                class="dm-btn dm-btn--ghost dm-btn--xs p-0"
                aria-label={"Remove tag #{tag}"}
              >
                <.dm_mdi name="close" class="w-3 h-3" />
              </button>
            </span>
          <% end %>
          <input
            type="text"
            id={@id}
            class="dm-input dm-input--sm flex-1 min-w-[100px] border-none focus:outline-none"
            placeholder={@add_tag_placeholder}
          />
        </div>
        <input type="hidden" name={@name} value={inspect(@tags)} />
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "slider_range"} = assigns) do
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
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}>
        <%= @label %> <span class="text-sm font-normal text-base-content/70">(<%= @min_val %> - <%= @max_val %>)</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-4">
          <span class="text-sm text-base-content/70"><%= @min %></span>
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
              class={[
                "dm-range dm-range--sm",
                @color && "dm-range--#{@color}"
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
              aria-describedby={@errors != [] && @id && "#{@id}-errors"}
              class={[
                "dm-range dm-range--sm",
                @color && "dm-range--#{@color}"
              ]}
              phx-target={@phx_target}
              phx-change="range_max_change"
            />
          </div>
          <span class="text-sm text-base-content/70"><%= @max %></span>
        </div>
        <div class="flex justify-between text-xs text-base-content/50">
          <span><%= @min %></span>
          <span class="font-medium text-base-content"><%= @min_val %> - <%= @max_val %></span>
          <span><%= @max %></span>
        </div>
        <input type="hidden" name={@name} value={inspect([@min_val, @max_val])} />
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "password_strength"} = assigns) do
    assigns = assign(assigns, :strength, calculate_password_strength(assigns[:value] || ""))

    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="password"
            id={@id}
            name={@name}
            value={@value}
            aria-invalid={@errors != [] && "true"}
            aria-describedby={@errors != [] && @id && "#{@id}-errors"}
            class={[
              @class,
              if(!@classic, do: "dm-input"),
              @color && "dm-input--#{@color}",
              @size && "dm-input--#{@size}",
              @errors != [] && "dm-input--error"
            ]}

            {@rest}
          />
          <button
            type="button"
            class="absolute right-3 top-1/2 -translate-y-1/2"
            aria-label={@toggle_password_label}
          >
            <.dm_mdi name="eye" class="w-4 h-4 text-base-content/50" />
          </button>
        </div>
        <div class="flex items-center gap-2">
          <div class="flex-1 h-2 bg-base-200 rounded-full overflow-hidden">
            <div
              class={[
                "h-full transition-all duration-300",
                @strength == "weak" && "bg-error w-1/3",
                @strength == "medium" && "bg-warning w-2/3",
                @strength == "strong" && "bg-success w-full"
              ]}
            />
          </div>
          <span class={[
            "text-xs font-medium",
            @strength == "weak" && "text-error",
            @strength == "medium" && "text-warning",
            @strength == "strong" && "text-success"
          ]}>
            <%= String.capitalize(@strength) %>
          </span>
        </div>
        <div class="text-xs text-base-content/60">
          <p :if={@strength == "weak"}>{@password_hint_weak}</p>
          <p :if={@strength == "medium"}>{@password_hint_medium}</p>
          <p :if={@strength == "strong"}>{@password_hint_strong}</p>
        </div>
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def dm_input(assigns) do
    ~H"""
    <div class={["dm-form-group", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          aria-invalid={@errors != [] && "true"}
          aria-describedby={@errors != [] && @id && "#{@id}-errors"}
          class={[
            @class,
            if(!@classic, do: "dm-input"),
            @color && "dm-input--#{@color}",
            @size && "dm-input--#{@size}",
            @errors != [] && "dm-input--error"
          ]}
          {@rest}
        />
        <div :if={@errors != []} id={@id && "#{@id}-errors"}>
          <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
        </div>
      </div>
    </div>
    """
  end

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
