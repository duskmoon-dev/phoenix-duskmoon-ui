defmodule Storybook.Feedback.Dialog do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Dialog.dm_modal/1
  def description, do: "Modal dialog for alerts, confirmations, and custom content."

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
          <:title>Confirm Action</:title>
          <:body>
            <p>Are you sure you want to proceed?</p>
          </:body>
          <:footer>
            <.dm_btn variant="ghost">Cancel</.dm_btn>
            <.dm_btn variant="primary">Confirm</.dm_btn>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :no_backdrop,
        description: "Modal without backdrop overlay",
        attributes: %{
          id: "dialog-no-backdrop",
          no_backdrop: true
        },
        slots: [
          """
          <:title>No Backdrop</:title>
          <:body><p>This modal has no backdrop overlay.</p></:body>
          """
        ]
      },
      %Variation{
        id: :with_backdrop_blur,
        description: "Modal with backdrop blur effect",
        attributes: %{
          id: "dialog-blur",
          backdrop: true
        },
        slots: [
          """
          <:title>Backdrop Blur</:title>
          <:body><p>Background is blurred behind the modal.</p></:body>
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
          <:title>No Close Button</:title>
          <:body><p>The X close button is hidden.</p></:body>
          <:footer>
            <.dm_btn variant="primary">OK</.dm_btn>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :responsive,
        description: "Responsive modal (full-screen on mobile)",
        attributes: %{
          id: "dialog-responsive",
          responsive: true
        },
        slots: [
          """
          <:title>Responsive Modal</:title>
          <:body><p>This modal is full-screen on small viewports.</p></:body>
          <:footer>
            <.dm_btn variant="ghost">Close</.dm_btn>
          </:footer>
          """
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for {size, label} <- [{"xs", "XS"}, {"sm", "SM"}, {"lg", "LG"}, {"xl", "XL"}] do
            %Variation{
              id: String.to_atom("size_#{size}"),
              attributes: %{id: "dialog-#{size}", size: size},
              slots: [
                """
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
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
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
        id: :backdrop,
        label: "Backdrop",
        type: :boolean,
        default: false
      },
      %{
        id: :no_backdrop,
        label: "No Backdrop",
        type: :boolean,
        default: false
      },
      %{
        id: :responsive,
        label: "Responsive",
        type: :boolean,
        default: false
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
