defmodule PhoenixDuskmoon.Component.DataDisplay.Card do
  @moduledoc """
  Card component using native markup and `@duskmoon-dev/core` classes.

  Provides card containers with optional header, content, and footer sections.

  ## Examples

      <.dm_card>
        <:title>Star Wars</:title>
        Star Wars is an American epic space opera...
      </.dm_card>

      <.dm_card image="/poster.jpg">
        <:title>Movie Title</:title>
        <:action><.dm_btn>Watch</.dm_btn></:action>
      </.dm_card>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.DataEntry.Form, only: [dm_alert: 1]

  @doc """
  Generates a card container.

  ## Examples

      <.dm_card>
        <:title>Card Title</:title>
        Card content here.
        <:action><.dm_btn>Action</.dm_btn></:action>
      </.dm_card>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:body_class, :any, default: nil, doc: "CSS classes for card body")

  attr(:variant, :string,
    default: nil,
    values: [nil, "compact", "side", "bordered", "glass"],
    doc: "Card layout variant"
  )

  attr(:shadow, :string,
    default: nil,
    values: [nil, "none", "sm", "md", "lg", "xl", "2xl"],
    doc: "Card shadow size"
  )

  attr(:interactive, :boolean,
    default: false,
    doc: "Make card clickable/hoverable"
  )

  attr(:padding, :string,
    default: nil,
    values: [nil, "none", "sm", "md", "lg"],
    doc: "Card padding size"
  )

  attr(:image, :string, default: nil, doc: "Card image URL")
  attr(:image_alt, :string, default: "", doc: "Card image alt text")

  attr(:rest, :global)

  slot(:title,
    required: false,
    doc: "Card title content"
  ) do
    attr(:id, :any, doc: "Title element id")
    attr(:class, :any, doc: "Title CSS classes")
  end

  slot(:action,
    required: false,
    doc: "Card action buttons"
  ) do
    attr(:id, :any, doc: "Action container id")
    attr(:class, :any, doc: "Action container CSS classes")
  end

  slot(:inner_block, required: false, doc: "Card body content")

  def dm_card(assigns) do
    assigns = assign(assigns, loading_image: false, skeleton_class: nil, result: nil)
    card_frame(assigns)
  end

  @doc """
  Renders a card with async value support.

  Shows loading skeleton while data is being fetched, error state on failure,
  and renders content when data is available.

  ## Examples

      <.dm_async_card :let={data} assign={@data}>
        <:title>User Profile</:title>
        {data.name}
      </.dm_async_card>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes for the card")
  attr(:body_class, :any, default: nil, doc: "additional CSS classes for the card body")
  attr(:skeleton_class, :any, default: nil, doc: "CSS classes for skeleton loader")
  attr(:assign, :any, default: nil, doc: "Phoenix.LiveView.AsyncResult assign")

  attr(:variant, :string, default: nil, doc: "card style variant")
  attr(:shadow, :string, default: nil, doc: "card shadow depth")
  attr(:interactive, :boolean, default: false, doc: "make card clickable/hoverable")
  attr(:padding, :string, default: nil, doc: "card padding size")
  attr(:image, :string, default: nil, doc: "card image URL")
  attr(:image_alt, :string, default: "", doc: "alt text for the card image")

  attr(:rest, :global)

  slot(:inner_block, required: true, doc: "card body content")

  slot(:title, required: false, doc: "card title content") do
    attr(:id, :any, doc: "title element id")
    attr(:class, :any, doc: "title CSS classes")
  end

  slot(:action, required: false, doc: "card action buttons") do
    attr(:id, :any, doc: "action container id")
    attr(:class, :any, doc: "action container CSS classes")
  end

  def dm_async_card(assigns) do
    ~H"""
    <.async_result :let={result} assign={@assign}>
      <:loading>
        <.card_frame {assigns} action={[]} image={nil} loading_image={!!@image} result={nil}>
          <div class={["skeleton w-full h-16", @skeleton_class]}></div>
        </.card_frame>
      </:loading>
      <:failed :let={reason}>
        <.card_frame {assigns} action={[]} image={nil} loading_image={false} result={nil}>
          <.dm_alert variant="error">{inspect(reason)}</.dm_alert>
        </.card_frame>
      </:failed>
      <.card_frame {assigns} loading_image={false} result={result}>
        {render_slot(@inner_block, result)}
      </.card_frame>
    </.async_result>
    """
  end

  defp card_frame(assigns) do
    assigns = assign(assigns, :padding_style, padding_style(assigns.padding))

    ~H"""
    <article
      id={@id}
      class={["card", @variant && "card-#{@variant}", shadow_class(@shadow), @interactive && "card-interactive", @class]}
      role={@interactive && "button"}
      tabindex={@interactive && "0"}
      onkeydown={@interactive && "if(event.target===this && (event.key==='Enter' || event.key===' ')){event.preventDefault();this.click()}"}
      {@rest}
    >
      <figure :if={@image} class="card-image"><img src={@image} alt={@image_alt} /></figure>
      <div :if={@loading_image} class={["card-image skeleton skeleton-image h-48", @skeleton_class]}></div>
      <div class={["card-body", @body_class]} style={@padding_style}>
        <div :for={title <- @title} id={title[:id]} class={["card-title", title[:class]]}>
          {render_slot(title)}
        </div>
        {render_slot(@inner_block)}
        <div :for={action <- @action} id={action[:id]} class={["card-actions", action[:class]]}>
          {render_slot(action, @result)}
        </div>
      </div>
    </article>
    """
  end

  # Literal utilities remain discoverable by Tailwind's source scanner.
  defp shadow_class("none"), do: "shadow-none"
  defp shadow_class("sm"), do: "shadow-sm"
  defp shadow_class("md"), do: "shadow-md"
  defp shadow_class("lg"), do: "shadow-lg"
  defp shadow_class("xl"), do: "shadow-xl"
  defp shadow_class("2xl"), do: "shadow-2xl"
  defp shadow_class(_), do: nil

  defp padding_style("none"), do: "--card-p: 0"
  defp padding_style("sm"), do: "--card-p: 1rem"
  defp padding_style("md"), do: "--card-p: 1.5rem"
  defp padding_style("lg"), do: "--card-p: 2rem"
  defp padding_style(_), do: nil
end
