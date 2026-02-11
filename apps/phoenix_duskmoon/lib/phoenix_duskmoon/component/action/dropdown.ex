defmodule PhoenixDuskmoon.Component.Action.Dropdown do
  @moduledoc """
  Dropdown menu component for action menus and navigation.

  ## Examples

      <.dm_dropdown>
        <:trigger>
          <.dm_btn variant="ghost">Menu</.dm_btn>
        </:trigger>
        <:content>
          <li><a>Profile</a></li>
          <li><a>Settings</a></li>
          <li><a>Logout</a></li>
        </:content>
      </.dm_dropdown>

      <.dm_dropdown position="right" color="primary">
        <:trigger>
          <.dm_btn variant="primary">
            Actions
            <.dm_mdi class="ml-1">chevron-down</.dm_mdi>
          </.dm_btn>
        </:trigger>
        <:content>
          <li><a phx-click="edit">Edit</a></li>
          <li><a phx-click="duplicate">Duplicate</a></li>
          <li><a phx-click="delete" class="text-error">Delete</a></li>
        </:content>
      </.dm_dropdown>

  ## Attributes

  * `position` - Dropdown position: left, right, top, bottom (default: left)
  * `color` - Dropdown color: primary, secondary, accent, info, success, warning, error (default: primary)
  * `open` - Force dropdown to be open
  * `class` - Additional CSS classes
  * `dropdown_class` - Additional CSS classes for dropdown element

  ## Slots

  * `:trigger` - Element that triggers the dropdown (required)
  * `:content` - Dropdown menu content (required)
  """

  use Phoenix.Component

  @doc """
  Renders a dropdown menu triggered by a button or element.

  ## Examples

      <.dm_dropdown>
        <:trigger><.dm_btn>Menu</.dm_btn></:trigger>
        <:content><li><a>Item</a></li></:content>
      </.dm_dropdown>
  """
  @doc type: :component
  attr(:position, :string, default: "left", values: ["left", "right", "top", "bottom"], doc: "Dropdown position")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "accent", "info", "success", "warning", "error"],
    doc: "Dropdown color variant"
  )

  attr(:open, :boolean, default: false, doc: "Whether the dropdown is open")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:dropdown_class, :string, default: nil, doc: "CSS classes for the dropdown menu")
  attr(:rest, :global)

  slot :trigger, required: true, doc: "Element that toggles the dropdown" do
    attr(:class, :string)
  end

  slot :content, required: true, doc: "Dropdown menu content" do
    attr(:class, :string)
  end

  def dm_dropdown(assigns) do
    ~H"""
    <div
      class={[
        "dm-dropdown",
        "dm-dropdown--#{@position}",
        @open && "dm-dropdown--open",
        @class
      ]}
      {@rest}
    >
      <div
        :for={trigger <- @trigger}
        class={["dm-dropdown__toggle", trigger[:class]]}
        tabindex="0"
        role="button"
        aria-haspopup="true"
        aria-expanded={to_string(@open)}
      >
        {render_slot(trigger)}
      </div>

      <ul
        :for={content <- @content}
        class={[
          "dm-dropdown__content dm-menu p-2 shadow bg-base-100 rounded-box w-52",
          "dm-dropdown__content--#{@color}",
          content[:class],
          @dropdown_class
        ]}
        tabindex="0"
        role="menu"
      >
        {render_slot(content)}
      </ul>
    </div>
    """
  end
end
