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
      },
      %Variation{
        id: :lifted_variant,
        description: "Lifted tab variant",
        attributes: %{
          active_tab_name: "Overview",
          variant: "lifted"
        },
        slots: [
          ~s(<:tab name="Overview">Overview</:tab>),
          ~s(<:tab name="Details">Details</:tab>),
          ~s(<:tab_content name="Overview">Overview content</:tab_content>),
          ~s(<:tab_content name="Details">Details content</:tab_content>)
        ]
      },
      %Variation{
        id: :bordered_variant,
        description: "Bordered tab variant",
        attributes: %{
          active_tab_name: "Tab A",
          variant: "bordered"
        },
        slots: [
          ~s(<:tab name="Tab A">Tab A</:tab>),
          ~s(<:tab name="Tab B">Tab B</:tab>),
          ~s(<:tab_content name="Tab A">Content for Tab A</:tab_content>),
          ~s(<:tab_content name="Tab B">Content for Tab B</:tab_content>)
        ]
      },
      %Variation{
        id: :size_xs,
        description: "Extra small tabs",
        attributes: %{
          active_tab_name: "Home",
          size: "xs"
        },
        slots: [
          ~s(<:tab name="Home">Home</:tab>),
          ~s(<:tab name="About">About</:tab>),
          ~s(<:tab_content name="Home">Home page</:tab_content>),
          ~s(<:tab_content name="About">About page</:tab_content>)
        ]
      },
      %Variation{
        id: :size_sm,
        description: "Small tabs",
        attributes: %{
          active_tab_name: "Feed",
          size: "sm"
        },
        slots: [
          ~s(<:tab name="Feed">Feed</:tab>),
          ~s(<:tab name="Explore">Explore</:tab>),
          ~s(<:tab_content name="Feed">Feed content</:tab_content>),
          ~s(<:tab_content name="Explore">Explore content</:tab_content>)
        ]
      },
      %Variation{
        id: :size_lg,
        description: "Large tabs",
        attributes: %{
          active_tab_name: "Dashboard",
          size: "lg",
          variant: "boxed"
        },
        slots: [
          ~s(<:tab name="Dashboard">Dashboard</:tab>),
          ~s(<:tab name="Analytics">Analytics</:tab>),
          ~s(<:tab_content name="Dashboard">Dashboard content</:tab_content>),
          ~s(<:tab_content name="Analytics">Analytics content</:tab_content>)
        ]
      }
    ]
  end
end
