defmodule PhoenixDuskmoon.Component.Navigation.PageFooter do
  @moduledoc """
  Page footer component for site-wide footer navigation.

  Renders a footer with multiple content sections using named slots.

  ## Examples

      <.dm_page_footer>
        <:section>Copyright 2024</:section>
        <:section>Links</:section>
      </.dm_page_footer>

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
    attr(:class, :any, doc: "section container CSS classes")
    attr(:title, :string, doc: "section heading text")
    attr(:title_class, :any, doc: "section heading CSS classes")
    attr(:body_class, :any, doc: "section body CSS classes")
  end

  slot(:copyright,
    required: false,
    doc: """
    Page footer right side copyright.
    """
  ) do
    attr(:class, :any, doc: "copyright container CSS classes")
    attr(:title, :string, doc: "copyright heading text")
    attr(:title_class, :any, doc: "copyright heading CSS classes")
    attr(:body_class, :any, doc: "copyright body CSS classes")
  end

  slot(:inner_block,
    required: false,
    doc: """
    Optional content rendered before the section grid.
    """
  )

  attr(:label, :string, default: nil, doc: "Accessible label for the footer (aria-label)")
  attr(:rest, :global, doc: "additional HTML attributes for the footer element")

  def dm_page_footer(assigns) do
    ~H"""

    <footer class={[
      "w-full min-h-fit",
      "flex flex-col",
      "py-20",
      @class
    ]} aria-label={@label} {@rest}>
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
              section[:class]
            ]}
          >
            <h4 :if={section[:title] not in [nil, ""]} class={["font-bold my-2", section[:title_class]]}>
              {section[:title]}
            </h4>
            <div class={["flex flex-col", section[:body_class]]}>
              {render_slot(section)}
            </div>
          </div>
          <div
            :for={copyright <- @copyright}
            class={[
              "flex flex-col self-center",
              copyright[:class]
            ]}
          >
            <h4 :if={copyright[:title] not in [nil, ""]} class={["font-bold my-2", copyright[:title_class]]}>
              {copyright[:title]}
            </h4>
            <div class={["flex flex-col", copyright[:body_class]]}>
              {render_slot(copyright)}
            </div>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
