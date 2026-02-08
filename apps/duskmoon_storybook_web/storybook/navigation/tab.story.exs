defmodule Storybook.Navigation.Tab do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Navigation.Tab.dm_tab/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          active_tab_name: "Luke"
        },
        slots: [
          ~s(<:tab name="Luke">Luke</:tab>),
          ~s(<:tab name="Anakin">Anakin</:tab>),
          ~s(<:tab_content name="Luke">Luke Skywalker, brother of Prince Leia Organa</:tab_content>),
          ~s(<:tab_content name="Anakin">Anakin Skywalker, aka. Darth Vador</:tab_content>)
        ]
      },
      %Variation{
        id: :vertical,
        attributes: %{
          active_tab_name: "Anakin",
          orientation: "vertical"
        },
        slots: [
          ~s(<:tab name="Luke">Luke</:tab>),
          ~s(<:tab name="Anakin">Anakin</:tab>),
          ~s(<:tab_content name="Luke">Luke Skywalker, brother of Prince Leia Organa</:tab_content>),
          ~s(<:tab_content name="Anakin">Anakin Skywalker, aka. Darth Vador</:tab_content>)
        ]
      }
    ]
  end
end
