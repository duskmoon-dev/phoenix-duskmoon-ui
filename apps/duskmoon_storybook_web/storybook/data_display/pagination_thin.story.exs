defmodule Storybook.DataDisplay.PaginationThin do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Pagination.dm_pagination_thin/1
  def description, do: "A pagination thin element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          total: 100,
          page_num: 5,
          page_size: 15,
          update_event: "ignore"
        }
      },
      %Variation{
        id: :show_total,
        attributes: %{
          show_total: true,
          total: 1000,
          page_num: 5,
          page_size: 15,
          update_event: "ignore"
        }
      },
      %Variation{
        id: :show_page_jumper,
        attributes: %{
          class: "z-10",
          total: 10000,
          page_num: 5,
          page_size: 15,
          show_page_jumper: true,
          update_event: "ignore"
        }
      }
    ]
  end
end
