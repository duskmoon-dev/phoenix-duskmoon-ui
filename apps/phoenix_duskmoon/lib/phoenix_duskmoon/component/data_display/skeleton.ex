defmodule PhoenixDuskmoon.Component.DataDisplay.Skeleton do
  @moduledoc """
  Duskmoon UI Skeleton Component

  Provides various skeleton loading placeholder formats using daisyui classes.
  Perfect for showing content placeholders while data is loading.
  """

  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates a basic skeleton element.

  ## Examples

      <.dm_skeleton />
      <.dm_skeleton class="w-32 h-4" />
      <.dm_skeleton variant="circle" size="md" />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)

  attr(:variant, :string,
    default: nil,
    doc: "Skeleton variant (default, circle, square, text, avatar)"
  )

  attr(:size, :string,
    default: nil,
    doc: "Skeleton size (xs, sm, md, lg, xl)"
  )

  attr(:animation, :string,
    default: nil,
    doc: "Animation type (pulse, wave, bounce)"
  )

  attr(:width, :string, default: nil, doc: "Custom width (e.g., 'w-32', 'w-full')")
  attr(:height, :string, default: nil, doc: "Custom height (e.g., 'h-4', 'h-8')")

  def dm_skeleton(assigns) do
    ~H"""
    <div
      id={@id}
      class={build_skeleton_classes(@variant, @size, @animation, @width, @height, @class)}
    />
    """
  end

  defp build_skeleton_classes(variant, size, animation, width, height, class) do
    [
      "dm-skeleton",
      if(variant, do: "dm-skeleton--#{variant}", else: nil),
      if(size, do: "dm-skeleton--#{size}", else: nil),
      if(animation, do: "animate-#{animation}", else: nil),
      width,
      height,
      class
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Generates a text skeleton with multiple lines.

  ## Examples

      <.dm_skeleton_text lines={3} />
      <.dm_skeleton_text lines={2} last_line_width="w-3/4" />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:lines, :integer, default: 3, doc: "Number of skeleton lines")
  attr(:line_height, :string, default: "h-4", doc: "Height of each line")
  attr(:line_spacing, :string, default: "mb-2", doc: "Spacing between lines")
  attr(:last_line_width, :string, default: "w-full", doc: "Width of the last line")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_text(assigns) do
    ~H"""
    <div id={@id} class={build_container_classes(@class)}>
      <%= if @lines > 1 do %>
        <%= for i <- 1..(@lines - 1) do %>
        <div class={build_line_classes(@line_height, "w-full", @animation)}></div>
        <% end %>
      <% end %>
      <div class={build_line_classes(@line_height, @last_line_width, @animation)}></div>
    </div>
    """
  end

  defp build_container_classes(class) do
    ["space-y-2", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_line_classes(height, width, animation) do
    [
      "dm-skeleton",
      height,
      width,
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Generates an avatar skeleton.

  ## Examples

      <.dm_skeleton_avatar size="md" />
      <.dm_skeleton_avatar size="lg" class="ring ring-primary" />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:size, :string, default: "md", doc: "Avatar size (xs, sm, md, lg, xl)")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_avatar(assigns) do
    ~H"""
    <div id={@id} class={build_avatar_classes(@animation, @class)}>
      <div class={build_avatar_inner_classes(@size)}>
        <span class="text-xs"></span>
      </div>
    </div>
    """
  end

  defp build_avatar_classes(animation, class) do
    [
      "dm-avatar",
      "dm-avatar--placeholder",
      if(animation, do: "animate-#{animation}", else: nil),
      class
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_avatar_inner_classes(size) do
    [
      "bg-neutral text-neutral-content rounded-full",
      "w-#{size}",
      "h-#{size}"
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Generates a card skeleton placeholder.

  ## Examples

      <.dm_skeleton_card />
      <.dm_skeleton_card show_avatar={true} lines={4} />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:show_avatar, :boolean, default: false, doc: "Show avatar skeleton")
  attr(:avatar_size, :string, default: "md", doc: "Avatar size")
  attr(:lines, :integer, default: 3, doc: "Number of text lines")
  attr(:show_action, :boolean, default: false, doc: "Show action button skeleton")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_card(assigns) do
    ~H"""
    <div id={@id} class={build_card_classes(@class)}>
      <div class="dm-card__body">
        <div class="flex items-start gap-4">
          <%= if @show_avatar do %>
            <.dm_skeleton_avatar size={@avatar_size} animation={@animation} />
          <% end %>
          <div class="flex-1">
            <div class={build_title_classes(@animation)}></div>
            <.dm_skeleton_text lines={@lines} animation={@animation} />
          </div>
        </div>
        <%= if @show_action do %>
          <div class="dm-card__actions justify-end mt-4">
            <div class={build_action_classes(@animation)}></div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp build_card_classes(class) do
    ["dm-card", "bg-base-100", "shadow-xl", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_title_classes(animation) do
    [
      "dm-skeleton",
      "h-6",
      "w-3/4",
      "mb-4",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_action_classes(animation) do
    [
      "dm-skeleton",
      "h-10",
      "w-20",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Generates a table skeleton placeholder.

  ## Examples

      <.dm_skeleton_table rows={5} columns={4} />
      <.dm_skeleton_table rows={3} columns={2} show_header={true} />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:rows, :integer, default: 5, doc: "Number of table rows")
  attr(:columns, :integer, default: 4, doc: "Number of table columns")
  attr(:show_header, :boolean, default: true, doc: "Show table header")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_table(assigns) do
    ~H"""
    <div id={@id} class={["overflow-x-auto", @class]}>
      <table class="dm-table">
        <%= if @show_header do %>
          <thead>
            <tr>
              <%= for _i <- 1..@columns do %>
                <th>
                  <div class={["dm-skeleton", "h-4", "w-full", @animation && "animate-#{@animation}"]}></div>
                </th>
              <% end %>
            </tr>
          </thead>
        <% end %>
        <tbody>
          <%= for _row <- 1..@rows do %>
            <tr>
              <%= for _col <- 1..@columns do %>
                <td>
                  <div class={["dm-skeleton", "h-4", "w-full", @animation && "animate-#{@animation}"]}></div>
                </td>
              <% end %>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Generates a list skeleton placeholder.

  ## Examples

      <.dm_skeleton_list items={5} show_avatar={true} />
      <.dm_skeleton_list items={3} lines_per_item={2} />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:items, :integer, default: 5, doc: "Number of list items")
  attr(:show_avatar, :boolean, default: false, doc: "Show avatar for each item")
  attr(:avatar_size, :string, default: "sm", doc: "Avatar size")
  attr(:lines_per_item, :integer, default: 1, doc: "Number of text lines per item")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_list(assigns) do
    ~H"""
    <div id={@id} class={build_list_container_classes(@class)}>
      <%= for _i <- 1..@items do %>
        <div class="flex items-start gap-3">
          <%= if @show_avatar do %>
            <.dm_skeleton_avatar size={@avatar_size} animation={@animation} />
          <% end %>
          <div class="flex-1">
            <.dm_skeleton_text lines={@lines_per_item} animation={@animation} />
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp build_list_container_classes(class) do
    ["space-y-4", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  @doc """
  Generates a form skeleton placeholder.

  ## Examples

      <.dm_skeleton_form fields={4} show_submit={true} />
      <.dm_skeleton_form fields={3} field_types={["text", "select", "textarea"]} />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:fields, :integer, default: 4, doc: "Number of form fields")

  attr(:field_types, :list,
    default: nil,
    doc: "List of field types (text, select, textarea, checkbox)"
  )

  attr(:show_submit, :boolean, default: true, doc: "Show submit button skeleton")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_form(assigns) do
    # Always ensure field_types is a valid list
    field_types =
      cond do
        is_list(assigns[:field_types]) ->
          assigns[:field_types]

        assigns[:fields] ->
          fields = assigns[:fields]

          ["text", "select", "textarea", "checkbox"]
          |> Enum.take(fields)
          |> then(fn types ->
            if length(types) < fields do
              types ++ List.duplicate("text", fields - length(types))
            else
              types
            end
          end)

        true ->
          ["text", "select", "textarea", "checkbox"]
      end

    assigns = assign(assigns, :field_types, field_types)

    ~H"""
    <form id={@id} class={build_form_classes(@class)}>
      <%= for {field_type, index} <- Enum.with_index(@field_types) do %>
        <div class="dm-form-group">
          <div class="dm-label">
            <div class={build_label_classes(@animation)}></div>
          </div>
          <div class={build_field_classes(field_type, @animation)}></div>
        </div>
      <% end %>
      <%= if @show_submit do %>
        <div class="dm-form-group">
          <div class={build_submit_classes(@animation)}></div>
        </div>
      <% end %>
    </form>
    """
  end

  @doc """
  Generates a comment skeleton placeholder.

  ## Examples

      <.dm_skeleton_comment />
      <.dm_skeleton_comment show_replies={2} />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:show_replies, :integer, default: 0, doc: "Number of reply skeletons to show")
  attr(:animation, :string, default: nil, doc: "Animation type")

  def dm_skeleton_comment(assigns) do
    ~H"""
    <div id={@id} class={build_comment_container_classes(@class)}>
      <!-- Main comment -->
      <div class="flex gap-4">
        <.dm_skeleton_avatar size="sm" animation={@animation} />
        <div class="flex-1 space-y-2">
          <div class="flex items-center gap-2">
            <div class={build_comment_name_classes(@animation)}></div>
            <div class={build_comment_meta_classes(@animation)}></div>
          </div>
          <.dm_skeleton_text lines={3} last_line_width="w-4/5" animation={@animation} />
        </div>
      </div>
      
      <!-- Replies -->
      <%= if @show_replies > 0 do %>
        <div class="ml-12 space-y-4">
          <%= for _i <- 1..@show_replies do %>
            <div class="flex gap-3">
              <.dm_skeleton_avatar size="xs" animation={@animation} />
              <div class="flex-1 space-y-2">
                <div class="flex items-center gap-2">
                  <div class={build_reply_name_classes(@animation)}></div>
                  <div class={build_reply_meta_classes(@animation)}></div>
                </div>
                <.dm_skeleton_text lines={2} last_line_width="w-3/4" animation={@animation} />
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp build_comment_container_classes(class) do
    ["space-y-4", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_comment_name_classes(animation) do
    [
      "dm-skeleton",
      "h-4",
      "w-20",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_comment_meta_classes(animation) do
    [
      "dm-skeleton",
      "h-3",
      "w-16",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_reply_name_classes(animation) do
    [
      "dm-skeleton",
      "h-3",
      "w-16",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_reply_meta_classes(animation) do
    [
      "dm-skeleton",
      "h-3",
      "w-12",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_form_classes(class) do
    ["space-y-6", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_label_classes(animation) do
    [
      "dm-skeleton",
      "h-4",
      "w-24",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_field_classes(field_type, animation) do
    base_classes =
      case field_type do
        "text" -> "dm-skeleton h-10 w-full"
        "select" -> "dm-skeleton h-10 w-full"
        "textarea" -> "dm-skeleton h-24 w-full"
        "checkbox" -> "dm-skeleton h-4 w-4"
        _ -> "dm-skeleton h-10 w-full"
      end

    animation_class = if(animation, do: "animate-#{animation}", else: nil)

    [base_classes, animation_class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_submit_classes(animation) do
    [
      "dm-skeleton",
      "h-10",
      "w-24",
      if(animation, do: "animate-#{animation}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
