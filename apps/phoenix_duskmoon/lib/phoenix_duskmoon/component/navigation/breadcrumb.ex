defmodule PhoenixDuskmoon.Component.Navigation.Breadcrumb do
  @moduledoc """
  Breadcrumb navigation component using el-dm-breadcrumbs custom element.

  ## Examples

      <.dm_breadcrumb>
        <:crumb>Home</:crumb>
        <:crumb>Products</:crumb>
        <:crumb>Details</:crumb>
      </.dm_breadcrumb>

      <.dm_breadcrumb>
        <:crumb to="/">Home</:crumb>
        <:crumb to="/products">Products</:crumb>
        <:crumb>Current Page</:crumb>
      </.dm_breadcrumb>

  """
  use Phoenix.Component

  @doc """
  Generates breadcrumb navigation.

  ## Examples

      <.dm_breadcrumb>
        <:crumb>Home</:crumb>
        <:crumb>Category</:crumb>
        <:crumb>Item</:crumb>
      </.dm_breadcrumb>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:separator, :string,
    default: nil,
    doc: "Custom separator character"
  )

  attr(:nav_label, :string, default: "Breadcrumb", doc: "Accessible label for the breadcrumb nav")
  attr(:rest, :global)

  slot(:crumb,
    required: true,
    doc: "Breadcrumb item"
  ) do
    attr(:id, :any)
    attr(:class, :any)
    attr(:to, :string, doc: "Link destination")
  end

  def dm_breadcrumb(assigns) do
    ~H"""
    <el-dm-breadcrumbs
      id={@id}
      separator={@separator}
      class={@class}
      aria-label={@nav_label}
      {@rest}
    >
      <span
        :for={{crumb, i} <- Enum.with_index(@crumb)}
        slot="item"
        id={Map.get(crumb, :id)}
        class={Map.get(crumb, :class)}
        data-href={Map.get(crumb, :to)}
        aria-current={if i == length(@crumb) - 1, do: "page", else: nil}
      >
        <a :if={Map.get(crumb, :to)} href={Map.get(crumb, :to)}>{render_slot(crumb)}</a>
        <template :if={!Map.get(crumb, :to)}>{render_slot(crumb)}</template>
      </span>
    </el-dm-breadcrumbs>
    """
  end
end
