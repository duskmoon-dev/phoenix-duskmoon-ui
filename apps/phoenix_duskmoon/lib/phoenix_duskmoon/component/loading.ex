defmodule PhoenixDuskmoon.Component.Loading do
  @moduledoc """
  Duskmoon UI Loading Component
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates Loading.

  ## Examples

  ```heex
  <.dm_loading_ex size={44} item_count={99} speed={"2s"} />
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:item_count, :integer,
    default: 88,
    doc: """
    html attribute class
    """
  )

  attr(:speed, :string,
    default: "4s",
    doc: """
    html attribute class
    """
  )

  attr(:size, :integer,
    default: 21,
    doc: """
    html attribute class
    """
  )

  attr(:spinner_size, :string,
    default: "md",
    values: ~w(xs sm md lg),
    doc: "daisyui loading spinner size"
  )

  attr(:spinner_color, :string,
    default: "primary",
    values: ~w(primary secondary accent info success warning error),
    doc: "daisyui loading spinner color"
  )

  attr(:use_spinner, :boolean,
    default: false,
    doc: "use daisyui loading spinner instead of custom animation"
  )

  def dm_loading_ex(assigns) do
    if assigns.use_spinner do
      ~H"""
      <div id={@id} class={["flex justify-center items-center", @class]}>
        <span class={["loading loading-spinner", "loading-#{@spinner_size}", "text-#{@spinner_color}"]}></span>
      </div>
      """
    else
      assigns = assigns |> assign(:random_inner, Enum.random(10_000..100_000))

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
          background-color: hsl(var(--hue, 0), 75%, 75%);
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

      <%= for i <- 0..(@item_count - 1) do %>
      .loader-<%= @random_inner %> i:nth-child(<%= i + 1 %>) {
        --rz: <%= i * (360 / @item_count) %>deg;
        --delay: calc(var(--duration) / <%= @item_count %> * <%= i %> - var(--duration));
        --tx: <%= Enum.random(1..ceil(1000 * @size / 21)) / 250 %>em;
        --ty: <%= Enum.random(1..ceil(1000 * @size / 21)) / 125 - 2.5 %>em;
        --hue: <%= i * (360 / @item_count) %>;
      }
      <% end %>
      </style>
      <div id={@id} class={["loader-#{@random_inner}", @class]}>
        <i :for={_ <- 1..@item_count} />
      </div>
      """
    end
  end

  @doc """
  Generates a simple daisyui loading spinner.

  ## Examples

      <.dm_loading_spinner size="lg" color="primary" />
  """
  attr(:id, :any, default: nil)
  attr(:class, :any, default: "")

  attr(:size, :string,
    default: "md",
    values: ~w(xs sm md lg),
    doc: "loading spinner size"
  )

  attr(:color, :string,
    default: "primary",
    values: ~w(primary secondary accent info success warning error),
    doc: "loading spinner color"
  )

  attr(:text, :string, default: nil, doc: "optional loading text")

  def dm_loading_spinner(assigns) do
    ~H"""
    <div id={@id} class={["flex flex-col justify-center items-center gap-2", @class]}>
      <span class={["loading loading-spinner", "loading-#{@size}", "text-#{@color}"]}></span>
      <span :if={@text} class="text-sm text-#{@color}"><%= @text %></span>
    </div>
    """
  end
end
