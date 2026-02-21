defmodule PhoenixDuskmoon.Component.Feedback.Loading do
  @moduledoc """
  Loading/spinner components for indicating progress.

  This module provides multiple loading indicators:
  - `dm_loading_spinner/1` - Simple spinning loader
  - `dm_loading_ex/1` - Advanced animated particle loader

  ## Examples

      <.dm_loading_spinner />

      <.dm_loading_spinner size="lg" variant="primary" />

      <.dm_loading_spinner variant="success" text="Loading..." />

      <.dm_loading_ex size={44} item_count={99} speed="2s" />
  """

  use Phoenix.Component
  import PhoenixDuskmoon.Component.Helpers, only: [css_color: 1]

  @doc """
  Generates a simple loading spinner.

  ## Examples

      <.dm_loading_spinner />
      <.dm_loading_spinner size="lg" variant="primary" />
      <.dm_loading_spinner variant="success" text="Loading..." />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:size, :string,
    default: "md",
    values: ~w(xs sm md lg),
    doc: "Spinner size"
  )

  attr(:variant, :string,
    default: "primary",
    values: ~w(primary secondary tertiary accent info success warning error),
    doc: "Spinner color variant"
  )

  attr(:text, :string, default: nil, doc: "Optional loading text")
  attr(:loading_label, :string, default: "Loading", doc: "Accessible label for the loading state")
  attr(:rest, :global)

  def dm_loading_spinner(assigns) do
    assigns = assign(assigns, :variant, css_color(assigns.variant))

    ~H"""
    <div
      id={@id}
      class={["inline-flex flex-col items-center gap-2", @class]}
      role="status"
      aria-live="polite"
      aria-label={@text || @loading_label}
      aria-busy="true"
      {@rest}
    >
      <span
        class={[
          "block rounded-full animate-spin border-2 border-current border-t-transparent",
          spinner_size(@size),
          spinner_color(@variant)
        ]}
        aria-hidden="true"
      ></span>
      <span :if={@text} class="text-sm text-on-surface-variant">{@text}</span>
    </div>
    """
  end

  defp spinner_size("xs"), do: "w-4 h-4"
  defp spinner_size("sm"), do: "w-5 h-5"
  defp spinner_size("md"), do: "w-6 h-6"
  defp spinner_size("lg"), do: "w-8 h-8"

  defp spinner_color("primary"), do: "text-primary"
  defp spinner_color("secondary"), do: "text-secondary"
  defp spinner_color("tertiary"), do: "text-tertiary"
  defp spinner_color("info"), do: "text-info"
  defp spinner_color("success"), do: "text-success"
  defp spinner_color("warning"), do: "text-warning"
  defp spinner_color("error"), do: "text-error"

  @doc """
  Generates an advanced animated particle loading effect.

  This creates a visually rich loading animation with multiple particles
  rotating and moving in a circular pattern.

  ## Examples

      <.dm_loading_ex />
      <.dm_loading_ex size={44} item_count={99} speed="2s" />

  ## Attributes

  * `size` - Size of the loader in em units (default: 21)
  * `item_count` - Number of particles (default: 88)
  * `speed` - Animation duration (default: "4s")

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "additional CSS classes")

  attr(:item_count, :integer,
    default: 88,
    doc: "Number of animated particles"
  )

  attr(:speed, :string,
    default: "4s",
    doc: "Animation duration"
  )

  attr(:size, :integer,
    default: 21,
    doc: "Size of the loader in em units"
  )

  attr(:loading_label, :string, default: "Loading", doc: "Accessible label for the loading state")
  attr(:rest, :global)

  def dm_loading_ex(assigns) do
    item_count = max(assigns.item_count, 1)
    size_factor = max(ceil(1000 * assigns.size / 21), 1)

    assigns =
      assigns
      |> assign_new(:random_inner, fn -> Enum.random(10_000..100_000) end)
      |> assign(:item_count, item_count)
      |> assign_new(:item_offsets, fn ->
        Enum.map(0..(item_count - 1), fn _i ->
          {Enum.random(1..size_factor) / 250, Enum.random(1..size_factor) / 125 - 2.5}
        end)
      end)

    ~H"""
    <style data-id={@random_inner}>
    .loader-<%= @random_inner %> {
      --duration: <%= @speed %>;
      --size: <%= @size %>em;
      position: relative;
      width: var(--size, 21em);
      height: var(--size, 21em);
      animation: loaderSpin-<%= @random_inner %> calc(var(--duration) * 4) infinite linear;
    }
    @keyframes loaderSpin-<%= @random_inner %> {
      to { transform: rotate(360deg); }
    }

    .loader-<%= @random_inner %> i {
        position: absolute;
        filter: blur(0.2em) contrast(2);
        left: calc(var(--size, 21em) / 2.1);
        top: calc(var(--size, 21em) / 2.1);
        width: calc(var(--size, 21em) / 21);
        height: calc(var(--size, 21em) / 21);
        background-color: oklch(75% 0.15 var(--hue, 0));
        border-radius: 50%;
        transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 2.1 / 2));
        animation: item-move-<%= @random_inner %> var(--duration) var(--delay, 0s) infinite ease-in-out;
    }

    @keyframes item-move-<%= @random_inner %> {
      0% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(0); }
      2% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(1.25); }
      20% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(1.25); }
      90%, 100% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(var(--tx, 0), var(--ty, 0)) scale(0); }
    }

    <%= for {i, {tx, ty}} <- Enum.zip(0..(@item_count - 1), @item_offsets) do %>
    .loader-<%= @random_inner %> i:nth-child(<%= i + 1 %>) {
      --rz: <%= i * (360 / @item_count) %>deg;
      --delay: calc(var(--duration) / <%= @item_count %> * <%= i %> - var(--duration));
      --tx: <%= tx %>em;
      --ty: <%= ty %>em;
      --hue: <%= i * (360 / @item_count) %>;
    }
    <% end %>
    </style>
    <div
      id={@id}
      class={["loader-#{@random_inner}", @class]}
      role="status"
      aria-live="polite"
      aria-label={@loading_label}
      aria-busy="true"
      {@rest}
    >
      <i :for={_ <- 1..@item_count} />
    </div>
    """
  end
end
