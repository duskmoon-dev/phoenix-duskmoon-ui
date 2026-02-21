defmodule PhoenixDuskmoon.Component.DataDisplay.Collapse do
  @moduledoc """
  Collapse component using `@duskmoon-dev/core` CSS classes.

  A single collapsible panel with trigger and content areas.
  Unlike `dm_accordion` (which manages multiple panels),
  `dm_collapse` is a standalone toggle for showing/hiding content.

  ## Examples

      <.dm_collapse>
        <:trigger>Click to expand</:trigger>
        <:content>Hidden content revealed on click.</:content>
      </.dm_collapse>

      <.dm_collapse variant="card" color="primary" open>
        <:trigger>Details</:trigger>
        <:content>Expanded by default.</:content>
      </.dm_collapse>

  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a collapsible panel with trigger and content.

  ## Examples

      <.dm_collapse>
        <:trigger>Show more</:trigger>
        <:content>Extra details here.</:content>
      </.dm_collapse>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:open, :boolean, default: false, doc: "Whether the collapse is initially open")
  attr(:disabled, :boolean, default: false, doc: "Whether the collapse is disabled")

  attr(:variant, :string,
    default: nil,
    values: [nil, "card", "bordered", "ghost", "divider"],
    doc: "Visual style variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "primary", "secondary", "tertiary", "accent"],
    doc: "Color variant for the trigger"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "Size variant"
  )

  attr(:animation, :string,
    default: nil,
    values: [nil, "fade", "slide"],
    doc: "Animation style for the content"
  )

  attr(:speed, :string,
    default: nil,
    values: [nil, "fast", "slow"],
    doc: "Transition speed"
  )

  attr(:nested, :boolean, default: false, doc: "Nested collapse with indent and left border")

  attr(:rest, :global)

  slot(:trigger, required: true, doc: "Trigger element that toggles the collapse")
  slot(:content, required: true, doc: "Collapsible content area")

  def dm_collapse(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      id={@id}
      class={[
        "collapse",
        @open && "collapse-open",
        @disabled && "collapse-disabled",
        @variant && "collapse-#{@variant}",
        @color && "collapse-#{@color}",
        @size && "collapse-#{@size}",
        @animation && "collapse-#{@animation}",
        @speed && "collapse-#{@speed}",
        @nested && "collapse-nested",
        @class
      ]}
      {@rest}
    >
      <button
        type="button"
        class="collapse-trigger"
        disabled={@disabled}
        aria-disabled={@disabled && "true"}
        aria-expanded={to_string(@open)}
        aria-controls={@id && "#{@id}-content"}
      >
        {render_slot(@trigger)}
        <span class="collapse-icon" aria-hidden="true"></span>
      </button>
      <div id={@id && "#{@id}-content"} class="collapse-content">
        <div class="collapse-inner">
          {render_slot(@content)}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a collapse group container for grouping multiple collapses.

  ## Examples

      <.dm_collapse_group>
        <.dm_collapse>
          <:trigger>First</:trigger>
          <:content>Content 1</:content>
        </.dm_collapse>
        <.dm_collapse>
          <:trigger>Second</:trigger>
          <:content>Content 2</:content>
        </.dm_collapse>
      </.dm_collapse_group>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:rest, :global)
  slot(:inner_block, required: true)

  def dm_collapse_group(assigns) do
    ~H"""
    <div id={@id} class={["collapse-group", @class]} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
