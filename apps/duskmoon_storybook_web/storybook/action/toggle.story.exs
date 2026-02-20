defmodule Storybook.Action.Toggle do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Toggle.dm_toggle_group/1
  def description, do: "Toggle button group for selecting between options."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "toggle-default"
        },
        slots: [
          """
          <:item active={true}>Day</:item>
          <:item>Week</:item>
          <:item>Month</:item>
          """
        ]
      },
      %Variation{
        id: :with_icons,
        attributes: %{
          id: "toggle-icons"
        },
        slots: [
          """
          <:item active={true} icon="format-bold" icon_only={true}></:item>
          <:item icon="format-italic" icon_only={true}></:item>
          <:item icon="format-underline" icon_only={true}></:item>
          """
        ]
      },
      %Variation{
        id: :variants,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_toggle_group id="seg" variant="segmented">
              <:item active={true}>Segmented</:item>
              <:item>Style</:item>
            </.dm_toggle_group>
            <.dm_toggle_group id="out" variant="outlined">
              <:item active={true}>Outlined</:item>
              <:item>Style</:item>
            </.dm_toggle_group>
            <.dm_toggle_group id="fill" variant="filled">
              <:item active={true}>Filled</:item>
              <:item>Style</:item>
            </.dm_toggle_group>
            <.dm_toggle_group id="chip" variant="chip">
              <:item active={true}>Chip</:item>
              <:item>Style</:item>
            </.dm_toggle_group>
          </div>
          """
        ]
      }
    ]
  end
end
