defmodule PhoenixDuskmoon.Component.DataDisplay.Avatar do
  @moduledoc """
  Avatar component for displaying user images and placeholders.

  Uses `@duskmoon-dev/core` avatar CSS classes for styling.

  ## Examples

      <.dm_avatar src="https://example.com/avatar.jpg" alt="User Avatar" />

      <.dm_avatar
        src="https://example.com/avatar.jpg"
        alt="User Avatar"
        size="lg"
        ring
        online
      />

      <.dm_avatar
        name="John Doe"
        size="md"
        color="primary"
      />

  """

  use Phoenix.Component

  @doc """
  Renders a user avatar with image, initials, or placeholder.

  ## Examples

      <.dm_avatar src="/images/user.jpg" alt="User" />
      <.dm_avatar name="John Doe" color="primary" />
  """
  @doc type: :component
  attr(:src, :string, default: nil, doc: "image source URL")
  attr(:alt, :string, default: nil, doc: "alt text for the image")
  attr(:name, :string, default: nil, doc: "user name for text-based avatar initials")
  attr(:placeholder_img, :any, default: nil, doc: "placeholder image URL or true for initials")
  attr(:size, :string, default: "md", values: ["xs", "sm", "md", "lg", "xl"], doc: "avatar size")

  attr(:shape, :string,
    default: "circle",
    values: ["circle", "square", "rounded"],
    doc: "avatar shape"
  )

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "tertiary", "accent", "info", "success", "warning", "error"],
    doc: "background color for text-based avatars"
  )

  attr(:ring, :boolean, default: false, doc: "add ring outline to avatar")

  attr(:ring_color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary"],
    doc: "ring outline color"
  )

  attr(:online, :boolean, default: false, doc: "show online status indicator")
  attr(:offline, :boolean, default: false, doc: "show offline status indicator")
  attr(:class, :string, default: nil, doc: "additional CSS classes for the wrapper")
  attr(:img_class, :string, default: nil, doc: "additional CSS classes for the image element")

  attr(:placeholder_class, :string,
    default: nil,
    doc: "additional CSS classes for the placeholder"
  )

  attr(:online_label, :string,
    default: "Online",
    doc: "Accessible label for the online indicator"
  )

  attr(:offline_label, :string,
    default: "Offline",
    doc: "Accessible label for the offline indicator"
  )

  attr(:default_icon_label, :string,
    default: "User",
    doc: "Accessible label for the default user icon"
  )

  attr(:placeholder_alt, :string,
    default: "Placeholder",
    doc: "Alt text for the placeholder image"
  )

  attr(:rest, :global)

  slot(:placeholder, doc: "Custom placeholder content")

  def dm_avatar(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div class={[
      "avatar",
      "avatar-#{@size}",
      shape_class(@shape),
      color_class(@color),
      @ring && "avatar-ring",
      @ring && @ring_color && "avatar-ring-#{@ring_color}",
      @class
    ]} {@rest}>
      <img
        :if={@src && !@placeholder_img}
        src={@src}
        alt={@alt}
        class={@img_class}
      />

      <div
        :if={!@src || @placeholder_img}
        class={["avatar-placeholder", @placeholder_class]}
      >
        {render_avatar_content(assigns)}
      </div>

      <div
        :if={@online || @offline}
        role="status"
        aria-label={if @online, do: @online_label, else: @offline_label}
        class={[
          "absolute bottom-0 right-0 w-3 h-3 rounded-full border-2 border-[var(--color-surface)]",
          @online && "bg-[var(--color-success)]",
          @offline && "bg-[var(--color-surface-variant)]"
        ]}
      >
      </div>
    </div>
    """
  end

  defp render_avatar_content(%{placeholder_img: placeholder_img} = assigns)
       when is_binary(placeholder_img) do
    assigns
    |> assign(img_src: placeholder_img)
    |> render_placeholder_image()
  end

  defp render_avatar_content(%{placeholder_img: placeholder_img} = assigns)
       when placeholder_img == true do
    render_initials(assigns)
  end

  defp render_avatar_content(assigns) do
    render_initials(assigns)
  end

  defp render_placeholder_image(assigns) do
    ~H"""
    <img
      src={@img_src}
      alt={@placeholder_alt}
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
    ~H"""
    <svg
      class="w-1/2 h-1/2 opacity-50"
      fill="currentColor"
      viewBox="0 0 20 20"
      xmlns="http://www.w3.org/2000/svg"
      role="img"
      aria-label={@default_icon_label}
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

  defp shape_class("circle"), do: nil
  defp shape_class("square"), do: "avatar-square"
  defp shape_class("rounded"), do: "avatar-rounded"

  defp color_class("primary"), do: "avatar-primary"
  defp color_class("secondary"), do: "avatar-secondary"
  defp color_class("tertiary"), do: "avatar-tertiary"
  defp color_class("info"), do: "bg-[var(--color-info)] text-[var(--color-on-info,#fff)]"
  defp color_class("success"), do: "bg-[var(--color-success)] text-[var(--color-on-success,#fff)]"
  defp color_class("warning"), do: "bg-[var(--color-warning)] text-[var(--color-on-warning,#fff)]"
  defp color_class("error"), do: "bg-[var(--color-error)] text-[var(--color-on-error,#fff)]"

  defp css_color("accent"), do: "tertiary"
  defp css_color(color), do: color
end
