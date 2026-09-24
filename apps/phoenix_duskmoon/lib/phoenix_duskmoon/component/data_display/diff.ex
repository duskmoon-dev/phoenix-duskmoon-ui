defmodule PhoenixDuskmoon.Component.DataDisplay.Diff do
  @moduledoc """
  Before/after comparison using Core CSS and a native range slider.
  `position` sets the initial reveal percentage; dragging or keyboard input updates it locally.
  Use `static` for a side-by-side comparison; provide descriptive content in both slots.

      <.dm_diff label="Design comparison" position={60}>
        <:before_content>Original design</:before_content>
        <:after_content>Updated design</:after_content>
      </.dm_diff>
  """
  use Phoenix.Component

  @doc "Renders comparison panels with a native slider, or static side-by-side content."
  @doc type: :component
  attr(:id, :any, default: nil)
  attr(:label, :string, required: true)
  attr(:position, :integer, default: 50, doc: "Initial reveal percentage (0–100)")
  attr(:static, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:style, :string, default: nil, doc: "Additional CSS declarations before the managed value")
  attr(:rest, :global)
  slot(:before_content, required: true)
  slot(:after_content, required: true)

  def dm_diff(assigns) do
    assigns = assign(assigns, :position, min(100, max(0, assigns.position)))

    ~H"""
    <div id={@id} class={["diff", @static && "diff-static", @class]} role="group" aria-label={@label} style={Enum.join(Enum.reject([@style, "--diff-position: #{@position}%"], &is_nil/1), "; ")} {@rest}>
      <div class="diff-before">{render_slot(@before_content)}</div>
      <div class="diff-after">{render_slot(@after_content)}</div>
      <div
        :if={!@static}
        class="pointer-events-none absolute inset-y-0 z-10 w-px bg-on-surface/50"
        style="inset-inline-start: var(--diff-position)"
        aria-hidden="true"
      ></div>
      <input
        :if={!@static}
        type="range"
        min="0"
        max="100"
        step="1"
        value={@position}
        aria-label={@label}
        class="range range-primary absolute bottom-2 inset-x-2 z-20"
        style="width: calc(100% - 1rem)"
        oninput="this.parentElement.style.setProperty('--diff-position', this.value + '%')"
      />
    </div>
    """
  end
end
