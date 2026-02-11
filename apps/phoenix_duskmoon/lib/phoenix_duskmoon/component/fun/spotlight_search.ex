defmodule PhoenixDuskmoon.Component.Fun.SpotlightSearch do
  @moduledoc """
  Spotlight search component with modal interface and suggestions.

  ## Examples

      # Basic usage in a LiveView
      <.dm_fun_spotlight_search id="global-search">
        <:suggestion icon="search" label="Search users" action="navigate_users" />
        <:suggestion icon="file" label="Search documents" action="navigate_docs" />
        <:suggestion icon="settings" label="Search settings" action="navigate_settings" />
      </.dm_fun_spotlight_search>

      # With phx-target for use within a LiveComponent
      <.dm_fun_spotlight_search
        id="quick-search"
        placeholder="Quick search..."
        shortcut="cmd+k"
        phx-target={@myself}
      />

  ## Attributes

  * `id` - Component ID (required)
  * `placeholder` - Input placeholder text (default: "Search...")
  * `shortcut` - Keyboard shortcut to open (default: "cmd+k")
  * `open` - Whether the modal is open
  * `loading` - Show loading state
  * `class` - Additional CSS classes
  * `phx-target` - LiveView target for events

  ## Slots

  * `:suggestion` - Search suggestions with icon, label, and optional action
  """

  use Phoenix.Component

  @doc type: :component
  attr(:id, :string, required: true)
  attr(:placeholder, :string, default: "Search...")
  attr(:shortcut, :string, default: "cmd+k")
  attr(:open, :boolean, default: false)
  attr(:loading, :boolean, default: false)
  attr(:class, :string, default: nil)
  attr(:phx_target, :any, default: nil)

  attr(:dialog_label, :string,
    default: "Spotlight search",
    doc: "Accessible label for the dialog"
  )

  attr(:close_label, :string,
    default: "Close search",
    doc: "Accessible label for the close button"
  )

  attr(:rest, :global)

  slot :suggestion, required: false do
    attr(:icon, :string)
    attr(:label, :string, required: true)
    attr(:action, :string)
    attr(:description, :string)
  end

  def dm_fun_spotlight_search(assigns) do
    ~H"""
    <dialog
      id={@id}
      open={@open}
      role="dialog"
      aria-label={@dialog_label}
      class={[
        "dm-fun-spotlight-search dm-modal",
        @class
      ]}
      phx-target={@phx_target}
      {@rest}
    >
      <div class="dm-modal__box p-0">
        <div class="dm-fun-spotlight-input">
          <svg class="text-base-content/50 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            type="text"
            placeholder={@placeholder}
            aria-label={@placeholder}
            phx-target={@phx_target}
            phx-keydown="spotlight_keydown"
            phx-change="spotlight_change"
            autocomplete="off"
            class="bg-transparent border-none outline-none w-full"
          />
          <div :if={@loading} class="dm-fun-spotlight-loading"></div>
          <button
            :if={!@loading}
            type="button"
            phx-click="spotlight_close"
            phx-target={@phx_target}
            class="text-base-content/50 hover:text-base-content"
            aria-label={@close_label}
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <div :if={@loading} class="dm-fun-spotlight-loading">
        </div>

        <div :if={!@loading && @suggestion} class="dm-fun-spotlight-suggestion-list" role="listbox">
          <div
            :for={{suggestion, index} <- Enum.with_index(@suggestion)}
            class="dm-fun-spotlight-suggestion-list-item"
            role="option"
            tabindex="0"
            phx-click="spotlight_select"
            phx-value-index={index}
            phx-target={@phx_target}
          >
            <div class="flex items-center gap-3">
              <div class="text-base-content/70">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div class="flex-1">
                <div class="font-medium">{suggestion.label}</div>
                <div :if={suggestion.description} class="text-sm text-base-content/50">
                  {suggestion.description}
                </div>
              </div>
              <div :if={suggestion.action} class="text-base-content/50 text-xs">
                {suggestion.action}
              </div>
            </div>
          </div>
        </div>
      </div>
    </dialog>

    <!-- Keyboard shortcut indicator -->
    <div class="hidden">
      <kbd class="dm-kbd dm-kbd--xs">{@shortcut}</kbd>
    </div>
    """
  end
end
