defmodule Storybook.DataDisplay.Pagination do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Pagination.dm_pagination/1
  def description, do: "Page navigation control with page numbers, size selector, and total count. Uses el-dm-pagination."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Event-driven pagination with update_event callback",
        attributes: %{
          total: 100,
          page_num: 5,
          page_size: 15,
          update_event: nil
        }
      },
      %Variation{
        id: :page_url,
        description: "URL-based navigation mid-range in a large dataset",
        attributes: %{
          total: 1000,
          page_num: 35,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :first_page,
        description: "First page — previous button disabled",
        attributes: %{
          total: 1000,
          page_num: 1,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :last_page,
        description: "Last page — next button disabled",
        attributes: %{
          total: 1000,
          page_num: 67,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :page_with_slot,
        description: "Custom slot with page jumper form",
        attributes: %{
          total: 1000,
          page_num: 67,
          page_size: 15,
          page_url: "/blogs/{page}"
        },
        slots: [
          """
          <form class="w-12 join" action="/blogs/67" method="get">
            <input class="join-item input input-sm" type="number" value={67} placeholder="input page number" />
            <button class="join-item btn btn-sm btn-outline btn-accent"><PhoenixDuskmoon.Component.Icon.Icons.dm_mdi name="arrow-right-top" class="w-4 h-4" /></button>
          </form>
          """
        ]
      }
    ]
  end
end
