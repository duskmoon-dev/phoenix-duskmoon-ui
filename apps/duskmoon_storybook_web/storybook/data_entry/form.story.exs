defmodule Storybook.DataEntry.Form do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form/1
  def description, do: "A form container with optional actions slot."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default form with content",
        attributes: %{
          class: "shadow p-4",
          for: %{},
          as: "user"
        },
        slots: [
          """
          <h3 class="text-lg font-bold mb-4">User Registration</h3>
          <div class="flex flex-col gap-3">
            <input type="text" placeholder="Name" class="input" />
            <input type="email" placeholder="Email" class="input" />
          </div>
          """
        ]
      },
      %Variation{
        id: :with_actions,
        description: "Form with actions slot showing submit/cancel buttons",
        attributes: %{
          class: "shadow p-4",
          for: %{},
          as: "profile"
        },
        slots: [
          """
          <div class="flex flex-col gap-3">
            <input type="text" placeholder="Username" class="input" />
            <input type="email" placeholder="Email" class="input" />
          </div>
          <:actions>
            <.dm_btn variant="ghost" type="button">Cancel</.dm_btn>
            <.dm_btn variant="primary" type="submit">Save</.dm_btn>
          </:actions>
          """
        ]
      },
      %Variation{
        id: :actions_right,
        description: "Form with right-aligned actions",
        attributes: %{
          class: "shadow p-4",
          for: %{},
          as: "settings",
          actions_align: "right"
        },
        slots: [
          """
          <div class="flex flex-col gap-3">
            <input type="text" placeholder="Setting value" class="input" />
          </div>
          <:actions>
            <.dm_btn variant="primary" type="submit">Apply</.dm_btn>
          </:actions>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :actions_align,
        label: "Actions Align",
        type: :select,
        options: [
          {"between", "Between"},
          {"right", "Right"},
          {"center", "Center"}
        ],
        default: "between"
      }
    ]
  end
end
