defmodule PhoenixDuskmoon.Component.Navigation.PageFooter do
  @moduledoc """
  Duskmoon UI PageFooter Component
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates a Page footer.

  ## Example

      <.dm_page_footer>
        <:section class="">
          ABC
        </:section>
        <:copyright>
          (^_^)
        </:copyright>
      </.dm_page_footer>

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

  slot(:section,
    required: false,
    doc: """
    Page footer section
    """
  ) do
    attr(:class, :string)
    attr(:title, :string)
    attr(:title_class, :string)
    attr(:body_class, :string)
  end

  slot(:copyright,
    required: false,
    doc: """
    Page footer right side copyright.
    """
  ) do
    attr(:class, :string)
    attr(:title, :string)
    attr(:title_class, :string)
    attr(:body_class, :string)
  end

  def dm_page_footer(assigns) do
    ~H"""

    <footer class={[
      "w-full min-h-fit",
      "flex flex-col",
      "py-20",
      @class
    ]}>
      <%= render_slot(@inner_block) %>
      <div class={[
        "container mx-auto px-4",
        "flex flex-col",
      ]}>
        <div class={[
          "grid grid-cols-2 md:grid-cols-3 gap-4",
          "w-full"
        ]}>
          <div
            :for={section <- @section}
            class={[
              "flex flex-col",
              Map.get(section, :class, "")
            ]}
          >
            <%= if Map.get(section, :title, "") != "" do %>
            <h4 class={["font-bold my-2", Map.get(section, :title_class, "")]}>
              <%= Map.get(section, :title, "") %>
            </h4>
            <% end %>
            <div class={["flex flex-col", Map.get(section, :body_class, "")]}>
              <%= render_slot(section) %>
            </div>
          </div>
          <div
            :for={copyright <- @copyright}
            class={[
              "flex flex-col self-center",
              Map.get(copyright, :class, "")
            ]}
          >
            <%= if Map.get(copyright, :title, "") != "" do %>
            <h4 class={["font-bold my-2", Map.get(copyright, :title_class, "")]}>
              <%= Map.get(copyright, :title, "") %>
            </h4>
            <% end %>
            <div class={["flex flex-col", Map.get(copyright, :body_class, "")]}>
              <%= render_slot(copyright) %>
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
