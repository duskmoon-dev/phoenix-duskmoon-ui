defmodule PhoenixDuskmoon.Fun.Spotlight do
  @moduledoc false

  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates a spotlight style search.

  TODO: redesign this module.

  ## Example

  ```heex
      <PhoenixDuskmoon.Fun.Spotlight.dmf_spotlight />
  ```

  """
  @doc type: :component
  attr(:id, :any,
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

  attr(:loading, :boolean,
    default: false,
    doc: """
    Loading state
    """
  )

  slot(:sugguestion,
    required: false,
    doc: """
    Search sugguestion slot
    """
  )

  def dmf_spotlight(assigns) do
    assigns = assigns |> assign_new(:id, fn -> PhoenixDuskmoon.Component.generate_id() end)

    ~H"""
    <dialog
      id={@id}
      class={["modal", "dm-fun-spotlight-search", @class]}
      phx-hook="Spotlight"
    >
      <div class="modal-box">
        <label class="dm-fun-spotlight-input">
          <input
            type="search"
            class="w-full"
            placeholder="Type to search..."
          >
          <kbd class="kbd kbd-sm text-base-content">⌘</kbd>
          <kbd class="kbd kbd-sm text-base-content">↵</kbd>
        </label>
        <div :if={@loading} class="dm-fun-spotlight-loading"></div>
        <div :if={length(assigns[:sugguestion]) > 0} class="dm-fun-spotlight-suggestion-list">
          <div :for={sug <- @sugguestion} class="dm-fun-spotlight-suggestion-list-item">
            {render_slot(sug)}
          </div>
        </div>
      </div>
      <form method="dialog" class="modal-backdrop">
        <button>close</button>
      </form>
    </dialog>
    """
  end
end
