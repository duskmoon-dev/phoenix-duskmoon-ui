defmodule PhoenixDuskmoon.Component.Button do
  @moduledoc """
  Duskmoon UI Button Component

  """
  use PhoenixDuskmoon.Component, :html
  import PhoenixDuskmoon.Component.Icons

  @doc """
  Generates a button.
  [INSERT LVATTRDOCS]
  ## Examples
  ```heex
  <.dm_btn id="show-btn">Show</.dm_btn>
  ```
  ```heex
  <.dm_btn id="remove-btn" confirm_action={JS.push("remove", value: %{"id" => @id})}>Remove</.dm_btn>
  ```
  """
  @doc type: :component
  attr(:id, :any, required: false)
  attr(:class, :any, default: nil, doc: "the class of the button")

  attr(:variant, :string,
    default: nil,
    doc:
      "the color variant of the button (primary, secondary, accent, info, success, warning, error, ghost, link, outline)"
  )

  attr(:size, :string,
    default: nil,
    doc: "the size of the button (xs, sm, md, lg)"
  )

  attr(:shape, :string,
    default: nil,
    doc: "the shape of the button (square, circle)"
  )

  attr(:glass, :boolean, default: false, doc: "apply glass effect to the button")
  attr(:loading, :boolean, default: false, doc: "show loading state")
  attr(:disabled, :boolean, default: false, doc: "disable the button")

  attr(:noise, :boolean, default: false, doc: "the noise of the button")
  attr(:content, :string, default: "", doc: "the content of noise button")

  attr(:confirm_class, :any,
    default: nil,
    doc: "the class of the confirm action button in dialog"
  )

  attr(:cancel_class, :any, default: nil, doc: "the class of the cancel action button in dialog")
  attr(:show_cancel_action, :boolean, default: true)

  attr(:confirm_title, :string, default: "")
  attr(:confirm, :string, default: "")

  attr(:rest, :global,
    doc: """
    Additional attributes to confirm action button.
    """
  )

  slot(:inner_block,
    required: true,
    doc: """
    The content rendered inside of the `button` tag.
    """
  )

  slot(:confirm_action,
    required: false,
    doc: "the action of the confirm action button in dialog"
  )

  @spec dm_btn(map()) :: Phoenix.LiveView.Rendered.t()
  def dm_btn(%{confirm: confirm} = assigns) when confirm != "" do
    assigns =
      assigns
      |> assign_new(:id, fn -> "btn-#{Enum.random(0..999_999)}" end)

    ~H"""
    <button
      id={@id}
      class={[
        "btn",
        @variant && "btn-#{@variant}",
        @size && "btn-#{@size}",
        @shape && "btn-#{@shape}",
        @glass && "glass",
        @loading && "loading",
        @disabled && "btn-disabled",
        @class
      ]}
      onclick={"document.getElementById('confirm-dialog-#{@id}').showModal()"}
      {@rest}
    ><%= render_slot(@inner_block) %></button>
    <dialog id={"confirm-dialog-#{@id}"} class="modal">
      <div class="modal-box">
        <form method="dialog">
          <button class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2">
            <.dm_mdi class="w-4 h-4" name="close" />
          </button>
        </form>
        <h3
          :if={String.length(@confirm_title) > 0}
          class="font-bold text-lg text-primary"
        >
          <%= @confirm_title %>
        </h3>
        <p class="py-4">
          <%= @confirm %>
        </p>
        <div class="modal-action">
          <%= if length(@confirm_action) > 0 do %>
            <%= render_slot(@confirm_action) %>
          <% else %>
            <form method="dialog">
              <button class={["btn", @confirm_class]} {@rest}>
                Yes
              </button>
            </form>
          <% end %>
          <form :if={@show_cancel_action} method="dialog">
            <button class={["btn", @cancel_class]}>
              Cancel
            </button>
          </form>
        </div>
      </div>
    </dialog>
    """
  end

  def dm_btn(%{noise: true} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)

    ~H"""
    <button
      id={@id}
      class={["btn-noise", @class]}
      data-content={@content}
      style={"--aps: running"}
      {@rest}
    ><i :for={_ <- 0..72} /></button>
    """
  end

  def dm_btn(%{} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)

    ~H"""
    <button
      id={@id}
      class={[
        "btn",
        @variant && "btn-#{@variant}",
        @size && "btn-#{@size}",
        @shape && "btn-#{@shape}",
        @glass && "glass",
        @loading && "loading",
        @disabled && "btn-disabled",
        @class
      ]}
      {@rest}
    ><%= render_slot(@inner_block) %></button>
    """
  end
end
