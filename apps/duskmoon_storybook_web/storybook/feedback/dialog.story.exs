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
        id: :small,
        description: "Small sized modal",
        attributes: %{
          id: "dialog-small",
          size: "sm"
        },
        slots: [
          """
          <:title>Small Dialog</:title>
          <:body>
            <p>This is a small modal.</p>
          </:body>
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
          <:body>
            <p>This modal has no backdrop overlay.</p>
          </:body>
          """
        ]
      },
      %Variation{
        id: :size_xs,
        description: "Extra small modal",
        attributes: %{
          id: "dialog-xs",
          size: "xs"
        },
        slots: [
          """
          <:title>XS Dialog</:title>
          <:body><p>Extra small modal.</p></:body>
          """
        ]
      },
      %Variation{
        id: :size_lg,
        description: "Large modal",
        attributes: %{
          id: "dialog-lg",
          size: "lg"
        },
        slots: [
          """
          <:title>Large Dialog</:title>
          <:body>
            <p>This large modal provides more space for complex content.</p>
          </:body>
          <:footer>
            <.dm_btn variant="ghost">Cancel</.dm_btn>
            <.dm_btn variant="primary">Save</.dm_btn>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :size_xl,
        description: "Extra large modal",
        attributes: %{
          id: "dialog-xl",
          size: "xl"
        },
        slots: [
          """
          <:title>XL Dialog</:title>
          <:body><p>Extra large modal for wide content.</p></:body>
          """
        ]
      },
      %Variation{
        id: :position_top,
        description: "Top-positioned modal",
        attributes: %{
          id: "dialog-top",
          position: "top"
        },
        slots: [
          """
          <:title>Top Position</:title>
          <:body><p>Modal anchored to the top of the viewport.</p></:body>
          """
        ]
      },
      %Variation{
        id: :position_middle,
        description: "Middle-positioned modal (explicit)",
        attributes: %{
          id: "dialog-middle",
          position: "middle"
        },
        slots: [
          """
          <:title>Middle Position</:title>
          <:body><p>Modal centered vertically in the viewport.</p></:body>
          """
        ]
      },
      %Variation{
        id: :position_bottom,
        description: "Bottom-positioned modal",
        attributes: %{
          id: "dialog-bottom",
          position: "bottom"
        },
        slots: [
          """
          <:title>Bottom Position</:title>
          <:body><p>Modal anchored to the bottom of the viewport.</p></:body>
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
      }
    ]
  end
end
