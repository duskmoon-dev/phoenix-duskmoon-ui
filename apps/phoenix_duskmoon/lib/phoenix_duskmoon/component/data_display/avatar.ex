defmodule PhoenixDuskmoon.Component.DataDisplay.Avatar do
  @moduledoc """
  Avatar component for displaying user images and placeholders.

  ## Examples

      <.dm_avatar src="https://example.com/avatar.jpg" alt="User Avatar" />

      <.dm_avatar
        src="https://example.com/avatar.jpg"
        alt="User Avatar"
        size="lg"
        border
        online
      />

      <.dm_avatar
        name="John Doe"
        size="md"
        color="primary"
        placeholder
      />

      <.dm_avatar
        src="https://example.com/avatar.jpg"
        alt="User Avatar"
        placeholder="/path/to/placeholder.jpg"
        size="xl"
        shape="circle"
      />

  ## Attributes

  * `src` - Image source URL
  * `alt` - Alt text for the image
  * `name` - User name for text-based avatar (used when no src)
  * `placeholder` - Show as placeholder with initials or custom placeholder image
  * `size` - Avatar size: xs, sm, md, lg, xl (default: md)
  * `shape` - Avatar shape: circle, square (default: circle)
  * `color` - Background color for text-based avatars: primary, secondary, accent, info, success, warning, error (default: primary)
  * `border` - Add border to avatar
  * `online` - Show online status indicator
  * `offline` - Show offline status indicator
  * `class` - Additional CSS classes
  * `img_class` - Additional CSS classes for image element
  * `placeholder_class` - Additional CSS classes for placeholder element

  ## Slots

  * `:placeholder` - Custom placeholder content
  """

  use Phoenix.Component

  @doc """
  Renders a user avatar with image, initials, or placeholder.

  ## Examples

      <.dm_avatar src="/images/user.jpg" alt="User" />
      <.dm_avatar name="John Doe" color="primary" />
  """
  @doc type: :component
  attr(:src, :string, default: nil)
  attr(:alt, :string, default: nil)
  attr(:name, :string, default: nil)
  attr(:placeholder_img, :any, default: nil)
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg", "xl"])
  attr(:shape, :string, default: "circle", values: ["circle", "square"])

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"]
  )

  attr(:border, :boolean, default: false)
  attr(:online, :boolean, default: false)
  attr(:offline, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:img_class, :string, default: nil)
  attr(:placeholder_class, :string, default: nil)
  attr(:rest, :global)

  slot(:placeholder, doc: "Custom placeholder content")

  def dm_avatar(assigns) do
    ~H"""
    <div class={[
      "avatar",
      @border && "avatar-border",
      @class
    ]}>
      <div class={[
        "w-#{@size} rounded-#{@shape}",
        color_classes(@color)
      ]}>
        <div class="relative">
          <img
            :if={@src && !@placeholder_img}
            src={@src}
            alt={@alt}
            class={["w-full h-full object-cover", @img_class]}
            {@rest}
          />

          <div
            :if={!@src || @placeholder_img}
            class={[
              "w-full h-full flex items-center justify-center text-#{@color}-content font-medium",
              @placeholder_class
            ]}
          >
            {render_avatar_content(assigns)}
          </div>

          <!-- Online/Offline indicator -->
          <div
            :if={@online || @offline}
            role="status"
            aria-label={if @online, do: "Online", else: "Offline"}
            class={[
              "absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-base-100",
              @online && "bg-success",
              @offline && "bg-base-300"
            ]}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_avatar_content(%{placeholder_img: placeholder_img} = assigns)
       when is_binary(placeholder_img) do
    # Custom placeholder image
    assigns
    |> assign(img_src: placeholder_img)
    |> render_placeholder_image()
  end

  defp render_avatar_content(%{placeholder_img: placeholder_img} = assigns)
       when placeholder_img == true do
    # Show initials when placeholder is true
    render_initials(assigns)
  end

  defp render_avatar_content(assigns) do
    # Show initials when no src provided
    render_initials(assigns)
  end

  defp render_placeholder_image(assigns) do
    ~H"""
    <img
      src={@img_src}
      alt="Placeholder"
      class="w-full h-full object-cover"
    />
    """
  end

  defp render_initials(%{name: name} = assigns) when is_binary(name) and name != "" do
    initials =
      name
      |> String.split(" ")
      |> Enum.take(2)
      |> Enum.map(&String.first/1)
      |> Enum.join("")
      |> String.upcase()

    assigns
    |> assign(initials: initials)
    |> render_initials_content()
  end

  defp render_initials(assigns) do
    # Default user icon when no name provided
    ~H"""
    <svg
      class="w-1/2 h-1/2 opacity-50"
      fill="currentColor"
      viewBox="0 0 20 20"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label="User"
    >
      <path
        fill-rule="evenodd"
        d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
        clip-rule="evenodd"
      />
    </svg>
    """
  end

  defp render_initials_content(assigns) do
    ~H"""
    <span class="text-lg">{@initials}</span>
    """
  end

  defp color_classes("primary"), do: "bg-primary"
  defp color_classes("secondary"), do: "bg-secondary"
  defp color_classes("accent"), do: "bg-accent"
  defp color_classes("info"), do: "bg-info"
  defp color_classes("success"), do: "bg-success"
  defp color_classes("warning"), do: "bg-warning"
  defp color_classes("error"), do: "bg-error"
end
