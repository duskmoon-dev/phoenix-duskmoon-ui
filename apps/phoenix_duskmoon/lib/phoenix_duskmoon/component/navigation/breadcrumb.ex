defmodule PhoenixDuskmoon.Component.Navigation.Breadcrumb do
  @moduledoc """
  Breadcrumb navigation component using semantic server-rendered markup.

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
    attr(:id, :any, doc: "breadcrumb item HTML id")
    attr(:class, :any, doc: "breadcrumb item CSS classes")
    attr(:to, :string, doc: "Link destination")
  end

  def dm_breadcrumb(assigns) do
    assigns =
      assigns
      |> assign(:last_index, length(assigns.crumb) - 1)
      |> assign(
        :separator_text,
        if(assigns.separator in [nil, ""], do: "/", else: assigns.separator)
      )

    # WORKAROUND(upstream): duskmoon-dev/duskmoon-elements#67
    ~H"""
    <nav
      id={@id}
      class={@class}
      aria-label={@nav_label}
      {@rest}
    >
      <ol class="m-0 flex list-none flex-wrap items-center gap-2 py-2 text-sm">
        <li
          :for={{crumb, i} <- Enum.with_index(@crumb)}
          id={crumb[:id]}
          class={["breadcrumb-item", crumb[:class]]}
        >
          <a
            :if={crumb[:to]}
            href={crumb[:to]}
            class="breadcrumb-link"
            aria-current={i == @last_index && "page"}
          >
            {render_slot(crumb)}
          </a>
          <span
            :if={!crumb[:to]}
            class={i == @last_index && "breadcrumb-item-active"}
            aria-current={i == @last_index && "page"}
          >
            {render_slot(crumb)}
          </span>
          <span
            :if={i < @last_index}
            class="inline-flex select-none items-center opacity-60"
            aria-hidden="true"
          >
            {@separator_text}
          </span>
        </li>
      </ol>
    </nav>
    """
  end
end
