defmodule PhoenixDuskmoon.Component.Navigation.Appbar do
  @moduledoc """
  Appbar component using `@duskmoon-dev/core` CSS classes.

  Uses CSS classes: `appbar`, `appbar-sticky`, `appbar-primary`, `appbar-elevated`,
  `appbar-brand`, `appbar-title`, `appbar-actions`, `appbar-action`, `appbar-nav`.

  ## Examples

      <.dm_appbar title="MyApp">
        <:menu to="/dashboard">Dashboard</:menu>
        <:logo><img src="/logo.svg" /></:logo>
        <:user_profile>User Menu</:user_profile>
      </.dm_appbar>

  """
  use Phoenix.Component

  import PhoenixDuskmoon.Component.Action.Link
  import PhoenixDuskmoon.Component.Icon.Icons
  import PhoenixDuskmoon.Component.Layout.Divider

  @doc """
  Generates an appbar using `@duskmoon-dev/core` CSS classes.

  ## Example

      <.dm_appbar title="PhoenixDuskmoon" class="appbar-primary appbar-elevated">
        <:menu to={~p"/storybook"}>Component Storybook</:menu>
        <:logo><.dm_mdi name="moon-waning-crescent" class="w-8 h-8" /></:logo>
        <:user_profile>(^_^)</:user_profile>
      </.dm_appbar>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")

  attr(:class, :any,
    default: nil,
    doc: "Additional CSS classes (e.g., appbar-primary, appbar-elevated)"
  )

  attr(:title, :string, default: "", doc: "Appbar title")
  attr(:sticky, :boolean, default: true, doc: "Whether the appbar is sticky")
  attr(:rest, :global)

  slot(:menu, required: false, doc: "Appbar navigation menus") do
    attr(:class, :string)
    attr(:to, :string)
  end

  slot(:logo, required: false, doc: "Appbar Logo (displayed in the brand area)")
  slot(:user_profile, required: false, doc: "Appbar right side user profile / actions")

  def dm_appbar(assigns) do
    assigns =
      assigns
      |> assign_new(:logo, fn -> [] end)
      |> assign_new(:user_profile, fn -> [] end)

    ~H"""
    <header
      id={@id}
      class={["appbar", @sticky && "appbar-sticky", @class]}
      {@rest}
    >
      <div class="appbar-brand">
        {render_slot(@logo)}
      </div>
      <span class="appbar-title">{@title}</span>
      <div class="appbar-trailing">
        <%= for menu <- @menu do %>
          <.dm_link
            navigate={Map.get(menu, :to, "")}
            class={["appbar-action", Map.get(menu, :class, "")]}
          >
            {render_slot(menu)}
          </.dm_link>
        <% end %>
        {render_slot(@user_profile)}
      </div>
    </header>
    """
  end

  @doc """
  Generates a simple responsive HTML appbar with mobile menu toggle.

  ## Example

      <.dm_simple_appbar title="PhoenixDuskmoon">
        <:menu to={~p"/storybook"}>Component Storybook</:menu>
        <:logo><.dm_mdi name="moon-waning-crescent" class="w-8 h-8" /></:logo>
        <:user_profile>(^_^)</:user_profile>
      </.dm_simple_appbar>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:title, :string, default: "", doc: "Appbar title")
  attr(:rest, :global)

  slot(:menu, required: false, doc: "Appbar menus") do
    attr(:class, :string)
    attr(:to, :string)
  end

  slot(:logo, required: false, doc: "Appbar Logo")
  slot(:user_profile, required: false, doc: "Appbar right side user profile")

  def dm_simple_appbar(assigns) do
    ~H"""
    <header
      id={@id}
      class={[
        "appbar appbar-sticky",
        "flex-col md:flex-row",
        @class
      ]}
      {@rest}
    >
      <div class="min-w-full h-14 flex items-center justify-between flex-[0_0_3.5rem] px-4 select-none">
        <div class="appbar-brand">
          {render_slot(@logo)}
          <span class="appbar-title select-none font-bold hidden lg:inline-flex">
            {@title}
          </span>
          <nav class="mx-12 hidden md:flex flex-row items-center gap-4">
            <%= for menu <- @menu do %>
              <a
                class={[
                  "appbar-nav py-2 px-6",
                  "text-lg font-semibold leading-6 text-center",
                  Map.get(menu, :class, "")
                ]}
                href={Map.get(menu, :to)}
              >
                {render_slot(menu)}
              </a>
            <% end %>
          </nav>
        </div>
        <div class="appbar-trailing">
          <div class="hidden md:inline-flex">
            {render_slot(@user_profile)}
          </div>
          <button
            class="appbar-nav md:hidden"
            onclick="document.getElementById('header-md-menu').classList.toggle('hidden')"
            aria-label="Toggle mobile menu"
          >
            <.dm_mdi name="menu" class="w-8 h-8" />
          </button>
        </div>
      </div>
      <div
        id="header-md-menu"
        class={[
          "w-full flex flex-col",
          "md:hidden hidden",
          @class
        ]}
      >
        <a
          :for={menu <- @menu}
          class={[
            "w-full py-2 px-6",
            "font-semibold leading-6",
            "text-lg text-center",
            Map.get(menu, :class, "")
          ]}
          href={Map.get(menu, :to)}
        >
          {render_slot(menu)}
        </a>
        <.dm_divider />
        <div class="w-full text-center flex flex-col justify-start items-center">
          {render_slot(@user_profile)}
        </div>
      </div>
    </header>
    """
  end
end
