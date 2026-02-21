defmodule PhoenixDuskmoon.Component.Navigation.Stepper do
  @moduledoc """
  Stepper component using `@duskmoon-dev/core` CSS classes.

  Renders a multi-step progress indicator for wizards and multi-step forms.
  Each step has a label, optional description, and states for active, completed,
  error, disabled, and optional.

  ## Examples

      <.dm_stepper>
        <:step label="Account" completed />
        <:step label="Profile" active />
        <:step label="Review" />
      </.dm_stepper>

      <.dm_stepper vertical color="secondary">
        <:step label="Step 1" description="Create account" completed />
        <:step label="Step 2" description="Fill details" active />
        <:step label="Step 3" description="Submit" />
      </.dm_stepper>

  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Renders a stepper with step indicators.

  ## Examples

      <.dm_stepper>
        <:step label="Step 1" completed />
        <:step label="Step 2" active />
        <:step label="Step 3" />
      </.dm_stepper>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:vertical, :boolean, default: false, doc: "Vertical layout")

  attr(:variant, :string,
    default: nil,
    values: [nil, "dots", "alt-labels", "icons"],
    doc: "Visual variant"
  )

  attr(:color, :string,
    default: nil,
    values: [nil, "secondary", "tertiary", "accent"],
    doc: "Color variant"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "sm", "lg"],
    doc: "Size variant"
  )

  attr(:clickable, :boolean, default: false, doc: "Make steps clickable")
  attr(:rest, :global)

  slot(:step, required: true, doc: "Step items") do
    attr(:label, :string, required: true, doc: "Step label text")
    attr(:description, :string, doc: "Step description text")
    attr(:active, :boolean, doc: "Whether this step is active")
    attr(:completed, :boolean, doc: "Whether this step is completed")
    attr(:error, :boolean, doc: "Whether this step has an error")
    attr(:disabled, :boolean, doc: "Whether this step is disabled")
    attr(:optional, :boolean, doc: "Whether this step is optional")
  end

  def dm_stepper(assigns) do
    assigns = assign(assigns, :color, css_color(assigns.color))

    ~H"""
    <div
      id={@id}
      class={[
        "stepper",
        @vertical && "stepper-vertical",
        @variant && "stepper-#{@variant}",
        @color && "stepper-#{@color}",
        @size && "stepper-#{@size}",
        @clickable && "stepper-clickable",
        @class
      ]}
      role="list"
      {@rest}
    >
      <%= for {step, idx} <- Enum.with_index(@step) do %>
        <div
          role="listitem"
          class={[
            "stepper-step",
            step[:active] && "stepper-step-active",
            step[:completed] && "stepper-step-completed",
            step[:error] && "stepper-step-error",
            step[:disabled] && "stepper-step-disabled",
            step[:optional] && "stepper-step-optional"
          ]}
          aria-current={step[:active] && "step"}
          aria-disabled={step[:disabled] && "true"}
        >
          <div class="stepper-step-button">
            <span class="stepper-step-icon">{idx + 1}</span>
          </div>
          <span class="stepper-step-label">{step[:label]}</span>
          <span :if={step[:description]} class="stepper-step-description">{step[:description]}</span>
        </div>
        <div :if={idx < length(@step) - 1} class="stepper-step-connector" aria-hidden="true"></div>
      <% end %>
    </div>
    """
  end
end
