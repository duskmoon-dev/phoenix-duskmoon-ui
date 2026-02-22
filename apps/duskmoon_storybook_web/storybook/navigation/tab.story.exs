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
      },
      %Variation{
        id: :three_tabs,
        description: "Tabs with three items and variant styling",
        attributes: %{
          active_tab_name: "Settings",
          variant: "boxed"
        },
        slots: [
          ~s(<:tab name="Profile">Profile</:tab>),
          ~s(<:tab name="Settings">Settings</:tab>),
          ~s(<:tab name="Notifications">Notifications</:tab>),
          ~s(<:tab_content name="Profile">Manage your profile information</:tab_content>),
          ~s(<:tab_content name="Settings">Application preferences</:tab_content>),
          ~s(<:tab_content name="Notifications">Notification settings</:tab_content>)
        ]
      }
    ]
  end
end
