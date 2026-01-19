defmodule PhoenixDuskmoon.Component.Card do
  @moduledoc """
  Card component using el-dm-card custom element.

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

  import PhoenixDuskmoon.Component.Form

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
    ~H"""
    <el-dm-card
      id={@id}
      variant={@variant}
      shadow={@shadow}
      class={@class}
      {@rest}
    >
      <img :if={@image} slot="image" src={@image} alt={@image_alt} />
      <span
        :for={title <- @title}
        slot="header"
        id={Map.get(title, :id)}
        class={Map.get(title, :class)}
      >
        {render_slot(title)}
      </span>
      <div :if={@body_class} class={@body_class}>
        {render_slot(@inner_block)}
      </div>
      <template :if={!@body_class}>
        {render_slot(@inner_block)}
      </template>
      <span
        :for={action <- @action}
        slot="footer"
        id={Map.get(action, :id)}
        class={Map.get(action, :class)}
      >
        {render_slot(action)}
      </span>
    </el-dm-card>
    """
  end

  @doc """
  Renders a card with async value support.

  Shows loading skeleton while data is being fetched, error state on failure,
  and renders content when data is available.

  ## Examples

      <.dm_async_card :let={data} assign={@data}>
        <:title>User Profile</:title>
        <%= data.name %>
      </.dm_async_card>

  """
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:class, :any, default: nil)
  attr(:body_class, :any, default: nil)
  attr(:skeleton_class, :any, default: nil, doc: "CSS classes for skeleton loader")
  attr(:assign, :any, default: nil, doc: "Phoenix.LiveView.AsyncResult assign")

  attr(:variant, :string, default: nil)
  attr(:shadow, :string, default: nil)
  attr(:image, :string, default: nil)
  attr(:image_alt, :string, default: "")

  attr(:rest, :global)

  slot(:inner_block, required: true)

  slot(:title, required: false) do
    attr(:id, :any)
    attr(:class, :any)
  end

  slot(:action, required: false) do
    attr(:id, :any)
    attr(:class, :any)
  end

  def dm_async_card(assigns) do
    ~H"""
    <.async_result assign={@assign}>
      <:loading>
        <el-dm-card
          id={@id}
          variant={@variant}
          shadow={@shadow}
          class={@class}
          {@rest}
        >
          <div :if={@image} slot="image" class={["dm-skeleton", @skeleton_class]} style="width: 100%; height: 200px;"></div>
          <span :for={title <- @title} slot="header" id={Map.get(title, :id)} class={Map.get(title, :class)}>
            {render_slot(title)}
          </span>
          <div class={["dm-skeleton", @skeleton_class]} style="width: 100%; height: 4rem;"></div>
        </el-dm-card>
      </:loading>
      <:failed :let={reason}>
        <el-dm-card
          id={@id}
          variant={@variant}
          shadow={@shadow}
          class={@class}
          {@rest}
        >
          <span :for={title <- @title} slot="header" id={Map.get(title, :id)} class={Map.get(title, :class)}>
            {render_slot(title)}
          </span>
          <.dm_alert variant="error">
            {reason |> inspect()}
          </.dm_alert>
        </el-dm-card>
      </:failed>
      <el-dm-card
        id={@id}
        variant={@variant}
        shadow={@shadow}
        class={@class}
        {@rest}
      >
        <img :if={@image} slot="image" src={@image} alt={@image_alt} />
        <span :for={title <- @title} slot="header" id={Map.get(title, :id)} class={Map.get(title, :class)}>
          {render_slot(title)}
        </span>
        <div :if={@body_class} class={@body_class}>
          {render_slot(@inner_block, Map.get(@assign, :result))}
        </div>
        <template :if={!@body_class}>
          {render_slot(@inner_block, Map.get(@assign, :result))}
        </template>
        <span :for={action <- @action} slot="footer" id={Map.get(action, :id)} class={Map.get(action, :class)}>
          {render_slot(action, Map.get(@assign, :result))}
        </span>
      </el-dm-card>
    </.async_result>
    """
  end
end
