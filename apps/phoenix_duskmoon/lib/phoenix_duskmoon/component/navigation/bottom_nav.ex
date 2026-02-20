defmodule PhoenixDuskmoon.Component.Navigation.BottomNav do
  @moduledoc """
  Bottom navigation component using `el-dm-bottom-navigation` custom element.

  Displays a fixed (or static/sticky) navigation bar at the bottom of the screen,
  typically for mobile interfaces.

  ## Examples

      <.dm_bottom_nav
        value="home"
        items={[
          %{value: "home", label: "Home", icon: "home"},
          %{value: "search", label: "Search", icon: "magnify"},
          %{value: "profile", label: "Profile", icon: "account"}
        ]}
      />

  """
  use Phoenix.Component

  @doc """
  Renders a bottom navigation bar.

  ## Examples

      <.dm_bottom_nav
        value="home"
        items={[
          %{value: "home", label: "Home", icon: "home"},
          %{value: "search", label: "Search", icon: "magnify"}
        ]}
      />

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "additional CSS classes")
  attr(:value, :string, default: nil, doc: "currently selected item value")

  attr(:color, :string,
    default: "primary",
    values: ["primary", "secondary", "success", "warning", "error"],
    doc: "color for active item"
  )

  attr(:position, :string,
    default: "fixed",
    values: ["fixed", "static", "sticky"],
    doc: "positioning of the navigation bar"
  )

  attr(:items, :list,
    required: true,
    doc: """
    List of navigation item maps. Each item should have:
    - `:value` (required) - unique identifier
    - `:label` (required) - display text
    - `:icon` (optional) - MDI icon name (e.g., "home", "magnify")
    - `:disabled` (optional) - boolean to disable item
    - `:href` (optional) - URL to navigate to (renders as link instead of button)
    """
  )

  attr(:rest, :global)

  def dm_bottom_nav(assigns) do
    items_json =
      assigns.items
      |> Enum.map(fn item ->
        case Map.get(item, :icon) do
          nil -> item
          name when is_binary(name) -> Map.put(item, :icon, icon_svg(name))
          _ -> item
        end
      end)
      |> Jason.encode!()

    assigns = assign(assigns, :items_json, items_json)

    ~H"""
    <el-dm-bottom-navigation
      id={@id}
      items={@items_json}
      value={@value}
      color={@color}
      position={@position}
      class={@class}
      {@rest}
    >
    </el-dm-bottom-navigation>
    """
  end

  defp icon_svg(name) when is_binary(name) do
    icon_path = Application.app_dir(:phoenix_duskmoon, "priv/mdi/svg/#{name}.svg")

    case File.read(icon_path) do
      {:ok, content} ->
        inner =
          content
          |> String.replace(~r/<svg[^>]+>/, "")
          |> String.replace("</svg>", "")

        ~s(<svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">#{inner}</svg>)

      {:error, _} ->
        ""
    end
  end
end
