defmodule PhoenixDuskmoon.Component.DataDisplay.Skeleton do
  @moduledoc """
  Duskmoon UI Skeleton Component

  Provides various skeleton loading placeholder formats.
  Perfect for showing content placeholders while data is loading.
  """

  use Phoenix.Component

  @doc """
  Generates a basic skeleton element.

  ## Examples

      <.dm_skeleton />
      <.dm_skeleton class="w-32 h-4" />
      <.dm_skeleton variant="circle" size="md" />
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:variant, :string,
    default: nil,
    doc: "Skeleton variant (circle, square, text, avatar)"
  )

  attr(:size, :string,
    default: nil,
    doc: "Skeleton size (xs, sm, md, lg, xl)"
  )

  attr(:animation, :string,
    default: nil,
    doc: "Animation type (wave, bounce)"
  )

  attr(:width, :string, default: nil, doc: "Custom width (e.g., 'w-32', 'w-full')")
  attr(:height, :string, default: nil, doc: "Custom height (e.g., 'h-4', 'h-8')")
  attr(:loading_label, :string, default: "Loading", doc: "Accessible label for the loading state")
  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton(assigns) do
    ~H"""
    <div
      id={@id}
      aria-busy="true"
      aria-label={@loading_label}
      class={build_skeleton_classes(@variant, @size, @animation, @width, @height, @class)}
      {@rest}
    />
    """
  end

  defp build_skeleton_classes(variant, size, animation, width, height, class) do
    [
      "skeleton",
      if(variant, do: "skeleton-#{variant}", else: nil),
      if(size, do: "skeleton-#{size}", else: nil),
      animation_class(animation),
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
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:lines, :integer, default: 3, doc: "Number of skeleton lines")
  attr(:line_height, :string, default: "h-4", doc: "Height of each line")
  attr(:last_line_width, :string, default: "w-full", doc: "Width of the last line")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading content",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_text(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={build_container_classes(@class)} {@rest}>
      <div :for={_i <- if(@lines > 1, do: 1..(@lines - 1), else: [])} class={build_line_classes(@line_height, "w-full", @animation)}></div>
      <div class={build_line_classes(@line_height, @last_line_width, @animation)}></div>
    </div>
    """
  end

  defp build_container_classes(class) do
    ["skeleton-group", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_line_classes(height, width, animation) do
    [
      "skeleton",
      height,
      width,
      animation_class(animation)
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
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:size, :string, default: "md", doc: "Avatar size (xs, sm, md, lg, xl)")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading avatar",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_avatar(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={build_avatar_classes(@size, @animation, @class)} {@rest} />
    """
  end

  defp build_avatar_classes(size, animation, class) do
    [
      "skeleton",
      "skeleton-avatar",
      skeleton_avatar_size(size),
      animation_class(animation),
      class
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp skeleton_avatar_size("xs"), do: "w-6 h-6"
  defp skeleton_avatar_size("sm"), do: "skeleton-avatar-sm"
  defp skeleton_avatar_size("md"), do: nil
  defp skeleton_avatar_size("lg"), do: "skeleton-avatar-lg"
  defp skeleton_avatar_size("xl"), do: "w-20 h-20"
  defp skeleton_avatar_size(_), do: nil

  @doc """
  Generates a card skeleton placeholder.

  ## Examples

      <.dm_skeleton_card />
      <.dm_skeleton_card show_avatar={true} lines={4} />
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:show_avatar, :boolean, default: false, doc: "Show avatar skeleton")
  attr(:avatar_size, :string, default: "md", doc: "Avatar size")
  attr(:lines, :integer, default: 3, doc: "Number of text lines")
  attr(:show_action, :boolean, default: false, doc: "Show action button skeleton")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading card",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_card(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={build_card_classes(@class)} {@rest}>
      <div class="skeleton-card-content">
        <div class="skeleton-card-header">
          <.dm_skeleton_avatar :if={@show_avatar} size={@avatar_size} animation={@animation} />
          <div class="skeleton-card-body">
            <div class={build_title_classes(@animation)}></div>
            <.dm_skeleton_text lines={@lines} animation={@animation} />
          </div>
        </div>
        <div :if={@show_action} class="skeleton-card-body">
          <div class={build_action_classes(@animation)}></div>
        </div>
      </div>
    </div>
    """
  end

  defp build_card_classes(class) do
    ["skeleton skeleton-card", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_title_classes(animation) do
    [
      "skeleton",
      "h-6",
      "w-3/4",
      "mb-4",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_action_classes(animation) do
    [
      "skeleton",
      "skeleton-button",
      animation_class(animation)
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
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rows, :integer, default: 5, doc: "Number of table rows")
  attr(:columns, :integer, default: 4, doc: "Number of table columns")
  attr(:show_header, :boolean, default: true, doc: "Show table header")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading table",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_table(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={["skeleton-table", @class]} {@rest}>
      <div :if={@show_header} class="skeleton-table-row">
        <div :for={_i <- 1..@columns} class={["skeleton skeleton-table-cell", animation_class(@animation)]}></div>
      </div>
      <div :for={_row <- 1..@rows} class="skeleton-table-row">
        <div :for={_col <- 1..@columns} class={["skeleton skeleton-table-cell", animation_class(@animation)]}></div>
      </div>
    </div>
    """
  end

  @doc """
  Generates a list skeleton placeholder.

  ## Examples

      <.dm_skeleton_list items={5} show_avatar={true} />
      <.dm_skeleton_list items={3} lines_per_item={2} />
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:items, :integer, default: 5, doc: "Number of list items")
  attr(:show_avatar, :boolean, default: false, doc: "Show avatar for each item")
  attr(:avatar_size, :string, default: "sm", doc: "Avatar size")
  attr(:lines_per_item, :integer, default: 1, doc: "Number of text lines per item")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading list",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_list(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={["skeleton-list", @class]} {@rest}>
      <div :for={_i <- 1..@items} class="skeleton-list-item">
        <.dm_skeleton_avatar :if={@show_avatar} size={@avatar_size} animation={@animation} />
        <div class="skeleton-card-body">
          <.dm_skeleton_text lines={@lines_per_item} animation={@animation} />
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Generates a form skeleton placeholder.

  ## Examples

      <.dm_skeleton_form fields={4} show_submit={true} />
      <.dm_skeleton_form fields={3} field_types={["text", "select", "textarea"]} />
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:fields, :integer, default: 4, doc: "Number of form fields")

  attr(:field_types, :list,
    default: nil,
    doc: "List of field types (text, select, textarea, checkbox)"
  )

  attr(:show_submit, :boolean, default: true, doc: "Show submit button skeleton")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading form",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

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
    <form id={@id} aria-busy="true" aria-label={@loading_label} class={build_form_classes(@class)} {@rest}>
      <div :for={field_type <- @field_types} class="form-group">
        <div class="form-label">
          <div class={build_label_classes(@animation)}></div>
        </div>
        <div class={build_field_classes(field_type, @animation)}></div>
      </div>
      <div :if={@show_submit} class="form-group">
        <div class={build_submit_classes(@animation)}></div>
      </div>
    </form>
    """
  end

  @doc """
  Generates a comment skeleton placeholder.

  ## Examples

      <.dm_skeleton_comment />
      <.dm_skeleton_comment show_replies={2} />
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:show_replies, :integer, default: 0, doc: "Number of reply skeletons to show")
  attr(:animation, :string, default: nil, doc: "Animation type")

  attr(:loading_label, :string,
    default: "Loading comments",
    doc: "Accessible label for the loading state"
  )

  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_skeleton_comment(assigns) do
    ~H"""
    <div id={@id} aria-busy="true" aria-label={@loading_label} class={build_comment_container_classes(@class)} {@rest}>
      <!-- Main comment -->
      <div class="skeleton-list-item">
        <.dm_skeleton_avatar size="sm" animation={@animation} />
        <div class="skeleton-card-body">
          <div class="skeleton-card-header">
            <div class={build_comment_name_classes(@animation)}></div>
            <div class={build_comment_meta_classes(@animation)}></div>
          </div>
          <.dm_skeleton_text lines={3} last_line_width="w-4/5" animation={@animation} />
        </div>
      </div>

      <!-- Replies -->
      <div :if={@show_replies > 0} class="ml-12 skeleton-group">
        <div :for={_i <- 1..@show_replies} class="skeleton-list-item">
          <.dm_skeleton_avatar size="xs" animation={@animation} />
          <div class="skeleton-card-body">
            <div class="skeleton-card-header">
              <div class={build_reply_name_classes(@animation)}></div>
              <div class={build_reply_meta_classes(@animation)}></div>
            </div>
            <.dm_skeleton_text lines={2} last_line_width="w-3/4" animation={@animation} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp animation_class("wave"), do: "skeleton-wave"
  defp animation_class("pulse"), do: "animate-pulse"
  defp animation_class("bounce"), do: "animate-bounce"
  defp animation_class(nil), do: nil
  defp animation_class(_), do: nil

  defp build_comment_container_classes(class) do
    ["skeleton-group", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_comment_name_classes(animation) do
    [
      "skeleton",
      "h-4",
      "w-20",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_comment_meta_classes(animation) do
    [
      "skeleton",
      "h-3",
      "w-16",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_reply_name_classes(animation) do
    [
      "skeleton",
      "h-3",
      "w-16",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_reply_meta_classes(animation) do
    [
      "skeleton",
      "h-3",
      "w-12",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_form_classes(class) do
    ["skeleton-group", class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_label_classes(animation) do
    [
      "skeleton",
      "h-4",
      "w-24",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_field_classes(field_type, animation) do
    base_classes =
      case field_type do
        "text" -> "skeleton h-10 w-full"
        "select" -> "skeleton h-10 w-full"
        "textarea" -> "skeleton h-24 w-full"
        "checkbox" -> "skeleton h-4 w-4"
        _ -> "skeleton h-10 w-full"
      end

    animation_class = animation_class(animation)

    [base_classes, animation_class]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp build_submit_classes(animation) do
    [
      "skeleton",
      "skeleton-button",
      animation_class(animation)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end
end
