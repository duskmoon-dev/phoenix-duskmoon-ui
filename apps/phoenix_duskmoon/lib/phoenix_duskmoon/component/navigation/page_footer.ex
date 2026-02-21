defmodule PhoenixDuskmoon.Component.Navigation.PageFooter do
  @moduledoc """
  Duskmoon UI PageFooter Component
  """
  use Phoenix.Component

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
    default: nil,
    doc: "HTML id attribute"
  )

  attr(:class, :any,
    default: nil,
    doc: "additional CSS classes"
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

  slot(:inner_block,
    required: false,
    doc: """
    Optional content rendered before the section grid.
    """
  )

  attr(:rest, :global, doc: "additional HTML attributes for the footer element")

  def dm_page_footer(assigns) do
    ~H"""

    <footer class={[
      "w-full min-h-fit",
      "flex flex-col",
      "py-20",
      @class
    ]} {@rest}>
      {render_slot(@inner_block)}
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
              Map.get(section, :class)
            ]}
          >
            <h4 :if={Map.get(section, :title) not in [nil, ""]} class={["font-bold my-2", Map.get(section, :title_class)]}>
              {Map.get(section, :title)}
            </h4>
            <div class={["flex flex-col", Map.get(section, :body_class)]}>
              {render_slot(section)}
            </div>
          </div>
          <div
            :for={copyright <- @copyright}
            class={[
              "flex flex-col self-center",
              Map.get(copyright, :class)
            ]}
          >
            <h4 :if={Map.get(copyright, :title) not in [nil, ""]} class={["font-bold my-2", Map.get(copyright, :title_class)]}>
              {Map.get(copyright, :title)}
            </h4>
            <div class={["flex flex-col", Map.get(copyright, :body_class)]}>
              {render_slot(copyright)}
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
