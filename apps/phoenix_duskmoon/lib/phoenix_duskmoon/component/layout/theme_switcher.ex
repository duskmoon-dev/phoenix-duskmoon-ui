defmodule PhoenixDuskmoon.Component.Layout.ThemeSwitcher do
  @moduledoc """
  Duskmoon UI ThemeSwitcher Component.

  Uses the `theme-controller-dropdown` CSS component from `@duskmoon-dev/core`.
  Renders as a `<details>/<summary>` dropdown with radio inputs for theme selection.
  Requires the `ThemeSwitcher` LiveView hook for localStorage persistence.
  """
  use Phoenix.Component

  @doc """
  A theme switcher dropdown component.

  Renders a `<details>` dropdown with three radio options: auto (default),
  sunshine (light), and moonlight (dark). The built-in chevron and hover/checked
  states come from `@duskmoon-dev/core`'s theme-controller CSS.

  ## Examples

      <.dm_theme_switcher />
      <.dm_theme_switcher theme="moonlight" />
      <.dm_theme_switcher button_text="Thème" auto_label="Auto" light_label="Clair" dark_label="Sombre" />

  """
  @doc type: :component
  attr(:id, :any, default: false, doc: "HTML id attribute")
  attr(:class, :any, default: "", doc: "Additional CSS classes")
  attr(:theme, :string, default: "", doc: "The active theme value")

  attr(:select_theme_label, :string,
    default: "Select theme",
    doc: "Accessible label for the theme selector button"
  )

  attr(:button_text, :string, default: "Theme", doc: "Visible text on the trigger button")
  attr(:auto_label, :string, default: "Auto", doc: "Label for the auto/default theme option")
  attr(:light_label, :string, default: "Sunshine", doc: "Label for the light theme option")
  attr(:dark_label, :string, default: "Moonlight", doc: "Label for the dark theme option")
  attr(:rest, :global, doc: "additional HTML attributes")

  def dm_theme_switcher(assigns) do
    assigns =
      assigns
      |> assign_new(:rid, fn -> Enum.random(0..999_999) end)

    base_id = assigns[:id] || "theme-switcher-#{assigns.rid}"
    assigns = assign(assigns, :base_id, base_id)

    ~H"""
    <details
      id={@base_id}
      class={["theme-controller-dropdown theme-controller-dropdown-end", @class]}
      phx-hook="ThemeSwitcher"
      data-theme={@theme}
      {@rest}
    >
      <summary class="theme-controller-trigger" aria-label={@select_theme_label} aria-haspopup="true">
        {@button_text}
      </summary>
      <div class="theme-controller-menu" role="radiogroup" aria-label={@select_theme_label}>
        <input
          type="radio"
          id={"#{@base_id}-default"}
          name={"theme-#{@base_id}"}
          class="theme-controller-item"
          value="default"
          checked={@theme == "default"}
        />
        <label for={"#{@base_id}-default"} class="theme-controller-label">
          {@auto_label}
        </label>
        <input
          type="radio"
          id={"#{@base_id}-sunshine"}
          name={"theme-#{@base_id}"}
          class="theme-controller-item"
          value="sunshine"
          checked={@theme == "sunshine"}
        />
        <label for={"#{@base_id}-sunshine"} class="theme-controller-label">
          {@light_label}
        </label>
        <input
          type="radio"
          id={"#{@base_id}-moonlight"}
          name={"theme-#{@base_id}"}
          class="theme-controller-item"
          value="moonlight"
          checked={@theme == "moonlight"}
        />
        <label for={"#{@base_id}-moonlight"} class="theme-controller-label">
          {@dark_label}
        </label>
      </div>
    </details>
    """
  end
end
