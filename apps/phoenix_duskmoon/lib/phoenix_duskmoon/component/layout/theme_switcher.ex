defmodule PhoenixDuskmoon.Component.Layout.ThemeSwitcher do
  @moduledoc """
  Duskmoon UI ThemeSwitcher Component
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  A theme switcher component.
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

  attr(:theme, :string,
    default: "",
    doc: """
    The theme to use.
    """
  )

  attr(:select_theme_label, :string,
    default: "Select theme",
    doc: "Accessible label for the theme selector button"
  )

  attr(:auto_label, :string, default: "Auto", doc: "Label for the auto/default theme option")
  attr(:light_label, :string, default: "Sunshine", doc: "Label for the light theme option")
  attr(:dark_label, :string, default: "Moonlight", doc: "Label for the dark theme option")

  def dm_theme_switcher(assigns) do
    assigns = assigns |> assign_new(:rid, fn -> Enum.random(0..999_999) end)

    ~H"""
    <div
      id={@id || "theme-switcher-#{@rid}"}
      class={["dropdown dropdown-end", @class]}
      phx-hook="ThemeSwitcher"
      data-theme={@theme}
    >
      <div tabindex="0" role="button" class="btn btn-ghost btn-sm" aria-label={@select_theme_label}>
        Theme
        <svg
          width="12px"
          height="12px"
          class="inline-block h-2 w-2 fill-current opacity-60"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 2048 2048"
          aria-hidden="true"
        >
          <path d="M1799 349l242 241-1017 1017L7 590l242-241 775 775 775-775z"></path>
        </svg>
      </div>
      <ul tabindex="0" class="dropdown-content z-50">
        <li>
          <input
            type="radio"
            name="theme-dropdown"
            class="theme-controller w-full btn btn-sm btn-secondary btn-block justify-center"
            aria-label={@auto_label}
            value="default"
            checked={@theme == "default"}
          />
        </li>
        <li>
          <input
            type="radio"
            name="theme-dropdown"
            class="theme-controller w-full btn btn-sm btn-secondary btn-block justify-center"
            aria-label={@light_label}
            value="sunshine"
            checked={@theme == "sunshine"}
          />
        </li>
        <li>
          <input
            type="radio"
            name="theme-dropdown"
            class="theme-controller w-full btn btn-sm btn-secondary btn-block justify-center"
            aria-label={@dark_label}
            value="moonlight"
            checked={@theme == "moonlight"}
          />
        </li>
      </ul>
    </div>
    """
  end
end
