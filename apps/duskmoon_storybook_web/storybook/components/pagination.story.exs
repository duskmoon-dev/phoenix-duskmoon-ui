defmodule Storybook.Components.Pagination do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Pagination.dm_pagination/1
  def description, do: "A pagination element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          total: 100,
          page_num: 5,
          page_size: 15,
          update_event: nil
        }
      },
      %Variation{
        id: :page_url,
        attributes: %{
          total: 1000,
          page_num: 35,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :first_page,
        attributes: %{
          total: 1000,
          page_num: 1,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :last_page,
        attributes: %{
          total: 1000,
          page_num: 67,
          page_size: 15,
          page_url: "/blogs/{page}"
        }
      },
      %Variation{
        id: :page_with_slot,
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
            <button class="join-item btn btn-sm btn-outline btn-accent"><PhoenixDuskmoon.Component.Icons.dm_mdi name="arrow-right-top" class="w-4 h-4" /></button>
          </form>
          """
        ]
      }
    ]
  end
end
