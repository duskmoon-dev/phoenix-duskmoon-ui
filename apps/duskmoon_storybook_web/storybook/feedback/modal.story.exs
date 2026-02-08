defmodule Storybook.Feedback.Modal do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Feedback.Dialog.dm_modal/1

  def imports do
    [{PhoenixDuskmoon.Modal, dm_show_modal: 0}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{},
        slots: [
          """
          <:trigger :let={f}>
            <button class="btn btn-primary" onclick={"document.getElementById('\#{f}').showModal()"}>Open</button>
          </:trigger>
          """,
          "<:title>PhoenixDuskmoon</:title>",
          "<:body>PhoenixDuskmoon Storybook</:body>"
        ]
      },
      %Variation{
        id: :with_buttons,
        slots: [
          """
          <:trigger :let={f}>
            <button class="btn btn-secondary" onclick={"document.getElementById('\#{f}').showModal()"}>Open</button>
          </:trigger>
          """,
          """
          <:title>
            PhoenixDuskmoon
          </:title>
          """,
          """
          <:body>
            PhoenixDuskmoonb Storybook
            Show Modal
          </:body>
          """,
          """
          <:footer >
            <form method="dialog">
            <button class="btn">
              Cancel
            </button>
            </form>
            <button class="btn">
              OK
            </button>
          </:footer>
          """
        ]
      },
      %Variation{
        id: :without_title_and_close,
        attributes: %{
          hide_close: true
        },
        slots: [
          """
          <:trigger :let={f}>
            <button class="btn btn-accent" onclick={"document.getElementById('\#{f}').showModal()"}>Open</button>
          </:trigger>
          """,
          """
          <:body class="flex justify-center items-center text-4xl text-rose-600">
            <form method="dialog">
              <button>PhoenixDuskmoonb Is Awesome...</button>
            </form>
          </:body>
          """
        ]
      }
    ]
  end
end
