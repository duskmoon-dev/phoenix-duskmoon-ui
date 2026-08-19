defmodule Storybook.Feedback.Dialog do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Dialog.dm_modal/1
  def description, do: "Native HTML dialog modal with Invoker Commands API."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default modal with title, body, and footer actions",
        attributes: %{
          id: "dialog-default"
        },
        slots: [
          """
          <:trigger :let={id}>
            <.dm_btn variant="primary" command="show-modal" commandfor={id}>Open</.dm_btn>
          </:trigger>
          <:title>Confirm Action</:title>
          <:body>
            <p>Are you sure you want to proceed?</p>
          </:body>
          <:footer>
            <.dm_btn variant="ghost" command="close" commandfor="dialog-default">Cancel</.dm_btn>
            <.dm_btn variant="primary" command="close" commandfor="dialog-default">Confirm</.dm_btn>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :hide_close_button,
        description: "Modal without close button",
        attributes: %{
          id: "dialog-no-close",
          hide_close: true
        },
        slots: [
          """
          <:trigger :let={id}>
            <.dm_btn command="show-modal" commandfor={id}>Open</.dm_btn>
          </:trigger>
          <:title>No Close Button</:title>
          <:body><p>The X close button is hidden.</p></:body>
          <:footer>
            <.dm_btn variant="primary" command="close" commandfor="dialog-no-close">OK</.dm_btn>
          </:footer>
          """
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for {size, label} <- [{"sm", "SM"}, {"lg", "LG"}, {"xl", "XL"}] do
            %Variation{
              id: String.to_atom("size_#{size}"),
              attributes: %{id: "dialog-#{size}", size: size},
              slots: [
                """
                <:trigger :let={id}>
                  <.dm_btn command="show-modal" commandfor={id}>#{label}</.dm_btn>
                </:trigger>
                <:title>#{label} Dialog</:title>
                <:body><p>#{label} sized modal.</p></:body>
                """
              ]
            }
          end
      },
      %VariationGroup{
        id: :positions,
        description: "Position variants",
        variations:
          for position <- ~w(top middle bottom) do
            %Variation{
              id: String.to_atom(position),
              attributes: %{id: "dialog-#{position}", position: position},
              slots: [
                """
                <:trigger :let={id}>
                  <.dm_btn command="show-modal" commandfor={id}>#{String.capitalize(position)}</.dm_btn>
                </:trigger>
                <:title>#{String.capitalize(position)} Position</:title>
                <:body><p>Modal anchored to the #{position} of the viewport.</p></:body>
                """
              ]
            }
          end
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"sm", "SM"},
          {"lg", "LG"},
          {"xl", "XL"}
        ],
        default: nil
      },
      %{
        id: :position,
        label: "Position",
        type: :select,
        options: [
          {nil, "Default"},
          {"top", "Top"},
          {"middle", "Middle"},
          {"bottom", "Bottom"}
        ],
        default: nil
      },
      %{
        id: :hide_close,
        label: "Hide Close",
        type: :boolean,
        default: false
      }
    ]
  end
end
