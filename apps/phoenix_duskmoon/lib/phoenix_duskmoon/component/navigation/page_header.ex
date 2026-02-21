defmodule PhoenixDuskmoon.Component.Navigation.PageHeader do
  @moduledoc """
  Duskmoon UI PageHeader Component
  """
  use Phoenix.Component

  @doc """
  Generates a Page header.

  ## Example

      <.dm_page_header>
        <:menu to={~p"/storybook"}>
          Storybook
        </:menu>
        <:user_profile>
          (^_^)
        </:user_profile>
      </.dm_page_header>

  """
  @doc type: :component
  attr(:id, :string,
    default: "wc-page-header-header",
    doc: """
    html attribute id
    """
  )

  attr(:nav_id, :string,
    default: "wc-page-header-nav",
    doc: """
    nav html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:nav_class, :any,
    default: "",
    doc: """
    nav html attribute class
    """
  )

  attr(:nav_label, :string,
    default: "Site navigation",
    doc: "Accessible label for the nav element"
  )

  attr(:toggle_menu_label, :string,
    default: "Toggle mobile menu",
    doc: "Accessible label for the mobile menu toggle button"
  )

  slot(:menu,
    required: false,
    doc: """
    Appbar menus
    """
  ) do
    attr(:class, :any, doc: "menu item CSS classes")
    attr(:to, :string, doc: "navigation path")
  end

  slot(:user_profile,
    required: false,
    doc: """
    Appbar right side user_profile.
    """
  ) do
    attr(:class, :any, doc: "user profile container CSS classes")
  end

  slot(:inner_block,
    required: false,
    doc: "Hero or body content rendered inside the header area"
  )

  attr(:rest, :global, doc: "additional HTML attributes for the header element")

  def dm_page_header(assigns) do
    ~H"""
    <nav
      id={@nav_id}
      aria-label={@nav_label}
      class={[
        "w-full h-12",
        "flex items-center flex-none",
        "transition-all",
        "fixed hidden",
        @nav_class
      ]}
    >
      <div
        class={[
          "container mx-auto",
          "hidden lg:flex flex-row justify-between items-center"
        ]}
      >
        <div class="flex flex-row gap-4">
          <a
            :for={menu <- @menu}
            class={[
              "py-2 px-6",
              "text-lg font-semibold leading-6 text-center",
              "hover:opacity-50",
              Map.get(menu, :class)
            ]}
            href={Map.get(menu, :to, false)}
          >
            {render_slot(menu)}
          </a>
        </div>
        <div
            :for={user_profile <- @user_profile}
            class={["flex", Map.get(user_profile, :class)]}
          >
            {render_slot(user_profile)}
          </div>
      </div>
      <div
        class={[
          "container px-8 h-full relative",
          "flex lg:hidden flex-col justify-center items-center"
        ]}
      >
        <label for="mobile-menu" aria-label={@toggle_menu_label}>
          <PhoenixDuskmoon.Component.Icon.Icons.dm_mdi name="menu" class="w-8 h-8 cursor-pointer" aria-hidden="true" />
        </label>
        <input class="sr-only peer" id="mobile-menu" type="checkbox" />
        <div
          class={[
            "hidden peer-checked:flex flex-col items-center",
            "absolute top-12 left-0 right-0",
            @nav_class
          ]}
        >
          <a
            :for={menu <- @menu}
            class={[
              "py-2 px-12 w-full",
              "text-lg font-semibold leading-6 text-center",
              "hover:opacity-50",
              Map.get(menu, :class)
            ]}
            href={Map.get(menu, :to, false)}
          >
            {render_slot(menu)}
          </a>
          <hr />
          <div
            :for={user_profile <- @user_profile}
            class={[
              "py-2 px-12 w-full",
              "text-lg font-semibold leading-6",
              "hover:opacity-50 flex justify-center",
              Map.get(user_profile, :class)
            ]}
          >
            {render_slot(user_profile)}
          </div>
        </div>
      </div>
    </nav>
    <header
      id={@id}
      class={[
        "w-full min-h-fit",
        "flex flex-col",
        @class
      ]}
      phx-hook="PageHeader"
      data-nav-id={@nav_id}
      {@rest}
    >
      <nav aria-label={@nav_label} class={["w-full h-12", "flex items-center flex-none"]}>
        <div
          class={[
            "container mx-auto",
            "hidden lg:flex flex-row justify-between items-center"
          ]}
        >
          <div class={["flex flex-row gap-4"]}>
            <a
              :for={menu <- @menu}
              class={[
                "py-2 px-6",
                "text-lg font-semibold leading-6 text-center",
                "hover:opacity-50",
                Map.get(menu, :class)
              ]}
              href={Map.get(menu, :to, false)}
            >
              {render_slot(menu)}
            </a>
          </div>
          <div
            :for={user_profile <- @user_profile}
            class={["flex", Map.get(user_profile, :class)]}
          >
            {render_slot(user_profile)}
          </div>
        </div>
        <div
          class={[
            "container px-8 relative",
            "flex lg:hidden flex-row justify-between items-center"
          ]}
        >
          <label for="dm-mobile-menu-control" aria-label={@toggle_menu_label}>
            <PhoenixDuskmoon.Component.Icon.Icons.dm_mdi name="menu" class="w-8 h-8" aria-hidden="true" />
          </label>
          <input class="sr-only peer" id="dm-mobile-menu-control" type="checkbox" />
          <div
            class={[
              "hidden peer-checked:flex flex-col items-start",
              "absolute top-12 left-0 right-0",
              @class
            ]}
          >
            <a
              :for={menu <- @menu}
              class={[
                "py-2 px-12 w-full",
                "text-lg font-semibold leading-6",
                "hover:opacity-50",
                Map.get(menu, :class)
              ]}
              href={Map.get(menu, :to, false)}
            >
              {render_slot(menu)}
            </a>
            <div
              :for={user_profile <- @user_profile}
              class={[
                "py-2 px-12 w-full",
                "text-lg font-semibold leading-6",
                "hover:opacity-50",
                Map.get(user_profile, :class)
              ]}
            >
              {render_slot(user_profile)}
            </div>
          </div>
        </div>
      </nav>
      <div class="flex-1 flex flex-col justify-center items-center">
        {render_slot(@inner_block)}
      </div>
    </header>
    """
  end
end
