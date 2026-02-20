defmodule PhoenixDuskmoon.Component.DataDisplay.Accordion do
  @moduledoc """
  Accordion component using el-dm-accordion custom element.

  ## Examples

      <.dm_accordion>
        <:item value="section1" header="Section One">
          Content for section one.
        </:item>
        <:item value="section2" header="Section Two">
          Content for section two.
        </:item>
      </.dm_accordion>

      <.dm_accordion multiple value="section1,section3">
        <:item value="section1" header="First">First content</:item>
        <:item value="section2" header="Second">Second content</:item>
        <:item value="section3" header="Third">Third content</:item>
      </.dm_accordion>

  """

  use Phoenix.Component

  @doc """
  Renders an accordion with collapsible sections.

  ## Examples

      <.dm_accordion>
        <:item value="faq1" header="What is this?">
          An accordion component.
        </:item>
      </.dm_accordion>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :string, default: nil, doc: "Additional CSS classes")
  attr(:multiple, :boolean, default: false, doc: "Allow multiple panels open at once")

  attr(:value, :string,
    default: nil,
    doc: "Comma-separated list of initially open item IDs"
  )

  attr(:rest, :global)

  slot(:item, required: true, doc: "Accordion item") do
    attr(:value, :string, required: true, doc: "Unique item identifier")
    attr(:header, :string, required: true, doc: "Header text for this item")
    attr(:disabled, :boolean, doc: "Disable this item")
  end

  def dm_accordion(assigns) do
    ~H"""
    <el-dm-accordion
      id={@id}
      multiple={@multiple}
      value={@value}
      class={@class}
      {@rest}
    >
      <%= for item <- @item do %>
        <el-dm-accordion-item
          value={item[:value]}
          disabled={item[:disabled]}
        >
          <span slot="header">{item[:header]}</span>
          {render_slot(item)}
        </el-dm-accordion-item>
      <% end %>
    </el-dm-accordion>
    """
  end
end
