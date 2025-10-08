defmodule Storybook.Components.LeftMenu do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.LeftMenu.dm_left_menu/1
  def description, do: "A left menu element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "shadow-xl",
          active: "left_menu",
          menus: [
            {"Components",
             [
               {"actionbar", "Actionbar", "/storybook/components/actionbar"},
               {"card", "Card", "/storybook/components/card"},
               {"left_menu", "Left Menu", "/storybook/components/left_menu"},
               {"markdown", "Markdown", "/storybook/components/markdown"},
               {"pagination", "Pagination", "/storybook/components/pagination"},
               {"table", "Table", "/storybook/components/table"}
             ]}
          ]
        },
        slots: [
          "<:title>Menu Demo Components</:title>",
          "<:menu><a>Dashboard</a></:menu>",
          """
          <:menu>
            <h2 class="menu-title">Title</h2>
            <ul>
              <li><a>Submenu 1</a></li>
              <li><a>Submenu 2</a></li>
            </ul>
          </:menu>
          <:menu>
          <a>Parent</a>
          <ul>
            <li><a>Submenu 1</a></li>
            <li><a>Submenu 2</a></li>
          </ul>
          </:menu>
          <:menu>
          <details open>
            <summary>Parent</summary>
            <ul>
              <li><a>Submenu 1</a></li>
              <li><a>Submenu 2</a></li>
            </ul>
          </details>
          </:menu>
          """
        ]
      }
    ]
  end
end
