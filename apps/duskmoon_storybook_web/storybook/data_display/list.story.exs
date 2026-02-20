defmodule Storybook.DataDisplay.List do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.List.dm_list/1
  def description, do: "Structured list component with items, icons, and subheaders."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "list-default"
        },
        slots: [
          """
          <:item title="Inbox" icon="email">12 unread messages</:item>
          <:item title="Drafts" icon="file-document-edit">3 drafts</:item>
          <:item title="Sent" icon="send">Last sent 2h ago</:item>
          """
        ]
      },
      %Variation{
        id: :bordered,
        attributes: %{
          id: "list-bordered",
          bordered: true
        },
        slots: [
          """
          <:subheader>Settings</:subheader>
          <:item title="Profile" icon="account">Edit your profile</:item>
          <:item title="Notifications" icon="bell">Manage alerts</:item>
          <:item title="Security" icon="shield-lock">Password & 2FA</:item>
          """
        ]
      },
      %Variation{
        id: :states,
        attributes: %{
          id: "list-states",
          hoverable: true
        },
        slots: [
          """
          <:item title="Active item" active={true}>Currently selected</:item>
          <:item title="Normal item">Regular item</:item>
          <:item title="Disabled item" disabled={true}>Cannot interact</:item>
          """
        ]
      }
    ]
  end
end
