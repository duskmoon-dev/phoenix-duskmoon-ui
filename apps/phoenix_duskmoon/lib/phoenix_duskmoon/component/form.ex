defmodule PhoenixDuskmoon.Component.Form do
  @moduledoc """
  Duskmoon UI Form Component

  """
  use PhoenixDuskmoon.Component, :html

  import PhoenixDuskmoon.Component.Icons

  @doc """
  Renders a simple form.

  Generate default `for` attribute for the form.

  ## Examples

      <.dm_form :let={f} for={@form} phx-change="validate" phx-submit="save">
        <.dm_input field={f[:email]} label="Email"/>
        <.dm_input field={f[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.dm_form>
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:for, :any, doc: "the datastructure for the form")
  attr(:as, :any, default: nil, doc: "the server side parameter to collect all input under")

  attr(:rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"
  )

  slot(:inner_block, required: true)
  slot(:actions, doc: "the slot for form actions, such as a submit button")

  def dm_form(assigns) do
    assigns = assigns |> assign_new(:for, fn -> to_form(%{}) end)

    ~H"""
    <.form
      id={@id}
      class={["dm-form", @class]}
      :let={f}
      for={@for}
      as={@as}
      {@rest}
    >
      <%= render_slot(@inner_block, f) %>
      <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
        <%= render_slot(action, f) %>
      </div>
    </.form>
    """
  end

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
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class={[if(!@classic, do: "checkbox"), @class]}
          {@rest}
        />
        <%= @label %>
      </label>
      <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    </div>
    """
  end

  def dm_input(%{type: "toggle", value: value} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id}><%= @label %></.dm_label>
      <div class="flex flex-col justify-center gap-2">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          class={[
            if(!@classic, do: "toggle"),
            @color && "toggle-#{@color}",
            @size && "toggle-#{@size}",
            @class
          ]}
          name={@name}
          value="true"
          checked={@checked}
          {@rest}
        />
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <select
          id={@id}
          name={@name}
          class={[
            if(!@classic, do: "textarea textarea-bordered"),
            @color && "textarea-#{@color}",
            @size && "textarea-#{@size}",
            @class,
            @errors != [] && "textarea-error"
          ]}
          multiple={@multiple}
          {@rest}
        >
          <option :if={@prompt} value=""><%= @prompt %></option>
          <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
        </select>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "checkbox_group"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6">
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
            />
            <%= opt_label %>
          </label>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "radio_group"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-6">
          <label class="inline-flex items-center gap-2 min-w-max" :for={{opt_label, opt_value} <- @options}>
            <input
              type="radio"
              class={[
                if(!@classic, do: "checkbox"),
                @color && "checkbox-#{@color}",
                @size && "checkbox-#{@size}",
                @class
              ]}
              name={@name}
              checked={to_string(@value) == to_string(opt_value)}
              value={opt_value}
            />
            <%= opt_label %>
          </label>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <textarea
          id={@id}
          name={@name}
              class={[
                if(!@classic, do: "radio"),
                @color && "radio-#{@color}",
                @size && "radio-#{@size}",
                @class
              ]}
          {@rest}
        ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "file"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <input
          id={@id}
          type="file"
          name={@name}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class,
            if(!@classic, do: "file-input file-input-bordered"),
            @color && "file-input-#{@color}",
            @size && "file-input-#{@size}",
            @errors != [] && "file-input-error"
          ]}
          {@rest}
        />
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "range_slider"} = assigns) do
    assigns =
      assign_new(assigns, :min, fn -> 0 end)
      |> assign_new(:max, fn -> 100 end)
      |> assign_new(:step, fn -> 1 end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
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
            class={[
              @class,
              if(!@classic, do: "range"),
              @color && "range-#{@color}",
              @size && "range-#{@size}"
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
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "rating"} = assigns) do
    assigns =
      assign_new(assigns, :max, fn -> 5 end)
      |> assign_new(:readonly, fn -> false end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}>
        <%= @label %> <span class="text-sm font-normal text-base-content/70">(<%= @value || 0 %>/<%= @max %>)</span>
      </.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-1">
          <input type="hidden" name={@name} id={@id} value={@value || 0} />
          <%= for i <- 1..@max do %>
            <button
              type="button"
              class={[
                "btn btn-ghost btn-sm p-1",
                i <= (@value || 0) && "text-warning",
                @color && i <= (@value || 0) && "text-#{@color}",
                @size == "xs" && "btn-xs",
                @size == "sm" && "btn-sm",
                @size == "lg" && "btn-lg"
              ]}
              disabled={@readonly}
            >
              <.dm_mdi name="star" class="w-4 h-4" />
            </button>
          <% end %>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "datepicker"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
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
              if(!@classic, do: "input input-bordered"),
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            {@rest}
          />
          <.dm_mdi name="calendar" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "timepicker"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
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
              if(!@classic, do: "input input-bordered"),
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            {@rest}
          />
          <.dm_mdi name="clock" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "color_picker"} = assigns) do
    assigns = assign_new(assigns, :swatches, fn -> nil end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex items-center gap-2">
          <div class="relative">
            <input
              type="color"
              id={@id}
              name={@name}
              value={@value || "#000000"}
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
              "input input-bordered flex-1",
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
            class="w-8 h-8 rounded border-2 border-base-300 hover:border-base-content transition-colors"
            style={"background-color: #{swatch}"}
            :for={swatch <- @swatches}
          />
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
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
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
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
            class={[
              "toggle toggle-lg",
              @color && "toggle-#{@color}",
              @size && "toggle-#{@size}",
              @class
            ]}
            {@rest}
          />
        </div>
      </label>
      <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    </div>
    """
  end

  def dm_input(%{type: "search_with_suggestions"} = assigns) do
    assigns = assign_new(assigns, :suggestions, fn -> [] end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="text"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "input input-bordered"),
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}
            {@rest}
          />
          <.dm_mdi name="magnify" class="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-base-content/50 pointer-events-none" />
        </div>
        <div :if={length(@suggestions) > 0} class="dropdown dropdown-open">
          <ul class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-full">
            <li :for={suggestion <- @suggestions}>
              <button type="button">
                <%= suggestion %>
              </button>
            </li>
          </ul>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "file_upload"} = assigns) do
    assigns = assign_new(assigns, :accept, fn -> nil end)

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="border-2 border-dashed border-base-300 rounded-lg p-6 text-center hover:border-base-content transition-colors">
          <.dm_mdi name="cloud-upload" class="w-12 h-12 mx-auto text-base-content/50 mb-2" />
          <p class="text-sm text-base-content/70 mb-2">Drop files here or click to browse</p>
          <input
            type="file"
            id={@id}
            name={@name}
            class="hidden"
            multiple={@multiple}
            accept={@accept}
            {@rest}
          />
          <button
            type="button"
            class={[
              "btn btn-sm",
              @color && "btn-#{@color}",
              @size && "btn-#{@size}"
            ]}
          >
            Choose Files
          </button>
        </div>
        <div :if={@value} class="flex items-center gap-2 p-2 bg-base-200 rounded">
          <.dm_mdi name="file" class="w-4 h-4" />
          <span class="text-sm flex-1"><%= @value %></span>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="close" class="w-3 h-3" />
          </button>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "rich_text"} = assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="toolbar flex items-center gap-1 p-2 bg-base-200 rounded-t-lg">
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="format-bold" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="format-italic" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="format-underline" class="w-4 h-4" />
          </button>
          <div class="divider divider-horizontal"></div>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="format-list-bulleted" class="w-4 h-4" />
          </button>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="format-list-numbered" class="w-4 h-4" />
          </button>
          <div class="divider divider-horizontal"></div>
          <button type="button" class="btn btn-ghost btn-xs">
            <.dm_mdi name="link" class="w-4 h-4" />
          </button>
        </div>
        <div
          contenteditable="true"
          id={@id}
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
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "tags"} = assigns) do
    assigns = assign(assigns, :tags, List.wrap(assigns[:value] || []))

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="flex flex-wrap gap-2 p-2 border border-base-300 rounded-lg">
          <%= for tag <- @tags do %>
            <span class={[
              "badge badge-lg gap-1",
              @color && "badge-#{@color}"
            ]}>
              <%= tag %>
              <button
                type="button"
                class="btn btn-ghost btn-xs p-0"
              >
                <.dm_mdi name="close" class="w-3 h-3" />
              </button>
            </span>
          <% end %>
          <input
            type="text"
            id={@id}
            class="input input-sm flex-1 min-w-[100px] border-none focus:outline-none"
            placeholder="Add tag..."
          />
        </div>
        <input type="hidden" name={@name} value={Jason.encode!(@tags)} />
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "slider_range"} = assigns) do
    assigns =
      assign_new(assigns, :min, fn -> 0 end)
      |> assign_new(:max, fn -> 100 end)
      |> assign_new(:step, fn -> 1 end)

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
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
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
              class={[
                "range range-sm",
                @color && "range-#{@color}"
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
              class={[
                "range range-sm",
                @color && "range-#{@color}"
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
              class={[
                "range range-sm",
                @color && "range-#{@color}"
              ]}
              phx-target={@myself}
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
        <input type="hidden" name={@name} value={Jason.encode!([@min_val, @max_val])} />
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  def dm_input(%{type: "password_strength"} = assigns) do
    assigns = assign(assigns, :strength, calculate_password_strength(assigns[:value] || ""))

    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <div class="relative">
          <input
            type="password"
            id={@id}
            name={@name}
            value={@value}
            class={[
              @class,
              if(!@classic, do: "input input-bordered"),
              @color && "input-#{@color}",
              @size && "input-#{@size}",
              @errors != [] && "input-error"
            ]}

            {@rest}
          />
          <button
            type="button"
            class="absolute right-3 top-1/2 -translate-y-1/2"
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
          <p :if={@strength == "weak"}>• Add uppercase letters, numbers, and special characters</p>
          <p :if={@strength == "medium"}>• Add more special characters or increase length</p>
          <p :if={@strength == "strong"}>• Strong password!</p>
        </div>
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
      </div>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def dm_input(assigns) do
    ~H"""
    <div class={["input-field", @field_class]} phx-feedback-for={@name}>
      <.dm_label for={@id} class={@errors != [] && "text-error"}><%= @label %></.dm_label>
      <div class="flex flex-col gap-2">
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            @class,
            if(!@classic, do: "input input-bordered"),
            @color && "input-#{@color}",
            @size && "input-#{@size}",
            @errors != [] && "input-error"
          ]}
          {@rest}
        />
        <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
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

  @doc """
  Renders a label.
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:for, :string, default: nil)
  slot(:inner_block, required: true)

  def dm_label(assigns) do
    ~H"""
    <label for={@for} id={@id} class={["label", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  slot(:inner_block, required: true)

  def dm_error(assigns) do
    ~H"""
    <span class="flex items-center gap-1 text-sm leading-6 text-error">
      <.dm_bsi name="exclamation-circle" class="h-3 w-3 flex-none" />
      <%= render_slot(@inner_block) %>
    </span>
    """
  end

  @doc """
  Generates an alert component using daisyui classes.

  ## Examples

      <.dm_alert variant="info">
        This is an informational message.
      </.dm_alert>
      
      <.dm_alert variant="error" icon="exclamation-triangle">
        Something went wrong!
      </.dm_alert>
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)

  attr(:variant, :string,
    default: "info",
    values: ~w(info success warning error),
    doc: "the alert variant"
  )

  attr(:icon, :string, default: nil, doc: "override default icon")
  attr(:title, :string, default: nil, doc: "alert title")
  slot(:inner_block, required: true)

  def dm_alert(assigns) do
    assigns =
      assign_new(assigns, :icon, fn ->
        case assigns.variant do
          "info" -> "information-circle"
          "success" -> "check-circle"
          "warning" -> "exclamation-triangle"
          "error" -> "exclamation-circle"
          _ -> "information-circle"
        end
      end)

    ~H"""
    <div id={@id} class={["alert", "alert-#{@variant}", @class]}>
      <.dm_mdi name={@icon} class="h-5 w-5 flex-none" />
      <div>
        <h3 :if={@title} class="font-bold"><%= @title %></h3>
        <div class="text-sm"><%= render_slot(@inner_block) %></div>
      </div>
    </div>
    """
  end

  @doc """
  Renders an compact input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  Only input and select are supported.

  ## Examples

      <.dm_compact_input field={@form[:email]} type="email" />
      <.dm_compact_input name="my-input" errors={["oh no!"]} />
  """
  attr(:field_class, :any, default: nil)
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:name, :any)
  attr(:label, :string, default: nil)
  attr(:value, :any)

  attr(:type, :string,
    default: "text",
    values: ~w(color date datetime-local email file month number password
               search select tel text time url week)
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

  slot(:inner_block)

  def dm_compact_input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    # |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> dm_compact_input()
  end

  def dm_compact_input(%{type: "select"} = assigns) do
    ~H"""
    <div
      class={[
        "select select-bordered",
        @errors != [] && "select-error",
        @class
      ]}
    >
      <label for={@id} class={["label", @errors != [] && "text-error"]}>
        <%= @label %>
      </label>
      <select
        id={@id}
        name={@name}
        class={[
          "compact-select",
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
    </div>
    <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    """
  end

  def dm_compact_input(assigns) do
    ~H"""
    <div
      class={[
        "input input-bordered",
        @errors != [] && "input-error",
        @class
      ]}
      phx-feedback-for={@name}
    >
      <label for={@id} class={["label", @errors != [] && "text-error"]}>
        <%= @label %>
      </label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "compact-input",
        ]}
        {@rest}
      />
      <%= render_slot(@inner_block) %>
    </div>
    <.dm_error :for={msg <- @errors}><%= msg %></.dm_error>
    """
  end
end
