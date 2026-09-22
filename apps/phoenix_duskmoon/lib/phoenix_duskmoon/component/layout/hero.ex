defmodule PhoenixDuskmoon.Component.Layout.Hero do
  @moduledoc """
  Hero composition using Core's layered content and decorative overlay.
  Applications supply spacing, backgrounds, headings and actions.
  """
  use Phoenix.Component

  @doc """
  Renders a hero with an optional non-interactive overlay behind its content.

      <.dm_hero align="start" class="p-8" aria-label="Welcome">
        <:overlay><div class="h-full bg-primary/10"></div></:overlay>
        <h1>Build something useful</h1>
      </.dm_hero>
  """
  @doc type: :component
  attr(:id, :string, default: nil)
  attr(:class, :any, default: nil)
  attr(:align, :string, default: "center", values: ["start", "center", "end"])
  attr(:content_class, :any, default: nil)
  attr(:rest, :global)
  slot(:overlay, doc: "Decorative content, hidden from assistive technology")
  slot(:inner_block, required: true)

  def dm_hero(assigns) do
    ~H"""
    <section id={@id} class={["hero", "hero-#{@align}", @class]} {@rest}>
      <div :if={@overlay != []} class="hero-overlay" aria-hidden="true">
        {render_slot(@overlay)}
      </div>
      <div class={["hero-content", @content_class]}>{render_slot(@inner_block)}</div>
    </section>
    """
  end
end
