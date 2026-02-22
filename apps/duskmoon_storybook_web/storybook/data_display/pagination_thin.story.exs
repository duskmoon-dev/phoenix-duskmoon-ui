defmodule Storybook.DataDisplay.PaginationThin do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Pagination.dm_pagination_thin/1
  def description, do: "Compact pagination variant with minimal footprint — prev/next buttons with optional total and page jumper."

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

  def modifiers do
    [
      %{
        id: :show_total,
        label: "Show Total",
        type: :boolean,
        default: false
      },
      %{
        id: :show_page_jumper,
        label: "Show Page Jumper",
        type: :boolean,
        default: false
      },
      %{
        id: :loading,
        label: "Loading",
        type: :boolean,
        default: false
      }
    ]
  end
end
