defmodule PhoenixDuskmoon.Component.Modal do
  @moduledoc """
  Duskmoon UI Modal Component
  """
  use PhoenixDuskmoon.Component, :html

  import PhoenixDuskmoon.Component.Icons

  @doc """
  Open ad dialog modal.

  ## Examples

  ```heex
  <.dm_modal>
    <:trigger :let={dialog_id}>
      <button onclick={"\#{dialog_id}.showModal()"}>Open</button>
    </:trigger>
    <:title>PhoenixDuskmoon</:title>
    <:body>PhoenixDuskmoon Storybook</:body>
  </.dm_modal>
  ```

  """
  @doc type: :component
  attr(:id, :any, doc: "Modal id")

  attr(:class, :any,
    default: "",
    doc: "Modal class"
  )

  attr(:hide_close, :boolean,
    default: false,
    doc: "Hide top right close button"
  )

  attr(:position, :string,
    default: nil,
    doc: "Modal position (top, middle, bottom)"
  )

  attr(:backdrop, :boolean,
    default: false,
    doc: "Apply backdrop blur effect"
  )

  attr(:size, :string,
    default: nil,
    doc: "Modal size (tiny, small, medium, large, huge)"
  )

  attr(:responsive, :boolean,
    default: false,
    doc: "Make modal responsive"
  )

  slot(:trigger, doc: "Modal trigger")

  slot(:title, doc: "Modal title") do
    attr(:class, :any, doc: "html class")
  end

  slot(:body, doc: "Modal content", required: true)

  slot(:footer, doc: "Modal footer, buttons") do
    attr(:class, :any, doc: "html class")
  end

  def dm_modal(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "modal-#{Enum.random(0..999_999)}" end)

    ~H"""
    <%= render_slot(@trigger, @id) %>
     <dialog
       id={@id}
       class={[
         "modal",
         @position && "modal-#{@position}",
         @backdrop && "modal-backdrop-blur",
         @class
       ]}
     >
       <div class={[
         "modal-box",
         @size && "modal-#{@size}",
         @responsive && "modal-responsive"
       ]}>
        <%= unless @hide_close do %>
        <form
          class="absolute right-2 top-2 cursor-pointer"
          method="dialog"
        >
          <button class="btn btn-ghost"><.dm_mdi name={"window-close"} class="w-4 h-4" /></button>
        </form>
        <% end %>
        <section class="flex flex-col min-h-22 min-w-36">
          <header :for={title <- @title} class={[
            "flex flex-row font-bold w-full text-2xl",
            Map.get(title, :class, "")
          ]}>
            <%= render_slot(title) %>
          </header>
          <div :for={body <- @body}
            class={[
              "flex flex-1",
              Map.get(body, :class, "")
            ]}
          >
            <%= render_slot(body) %>
          </div>
          <footer
            :for={footer <- @footer}
            class={[
              "modal-action",
              Map.get(footer, :class, "")
            ]}
          >
            <%= render_slot(footer) %>
          </footer>
        </section>
      </div>
    </dialog>
    """
  end
end
