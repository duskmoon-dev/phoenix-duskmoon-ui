defmodule Storybook.Action.Swap do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Swap.dm_swap/1

  def description,
    do:
      "Native checkbox state swaps decorative indicators. Try Space while the checkbox is focused."

  def variations do
    [
      %Variation{
        id: :sound,
        attributes: %{
          id: "swap-sound",
          name: "sound",
          label: "Enable sound",
          rotate: true,
          class: "btn btn-primary"
        },
        slots: [~s(<:on>Sound on</:on>), ~s(<:off>Sound off</:off>)]
      },
      %Variation{
        id: :disabled,
        attributes: %{label: "Enable notifications", checked: true, disabled: true, class: "btn"},
        slots: [~s(<:on>Enabled</:on>), ~s(<:off>Disabled</:off>)]
      }
    ]
  end
end
