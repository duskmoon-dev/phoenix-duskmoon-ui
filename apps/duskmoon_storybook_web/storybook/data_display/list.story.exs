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
      },
      %Variation{
        id: :interactive,
        description: "Interactive list items with clickable appearance",
        attributes: %{
          id: "list-interactive",
          bordered: true
        },
        slots: [
          """
          <:item title="Dashboard" icon="view-dashboard" interactive={true}>Go to dashboard</:item>
          <:item title="Analytics" icon="chart-bar" interactive={true}>View reports</:item>
          <:item title="Settings" icon="cog" interactive={true}>Configure app</:item>
          """
        ]
      },
      %Variation{
        id: :compact,
        description: "Compact layout with reduced spacing",
        attributes: %{
          id: "list-compact",
          compact: true,
          bordered: true
        },
        slots: [
          """
          <:item title="Item One" icon="chevron-right">First item</:item>
          <:item title="Item Two" icon="chevron-right">Second item</:item>
          <:item title="Item Three" icon="chevron-right">Third item</:item>
          """
        ]
      },
      %Variation{
        id: :dense,
        description: "Dense layout with minimal padding",
        attributes: %{
          id: "list-dense",
          dense: true
        },
        slots: [
          """
          <:item>Dense item one</:item>
          <:item>Dense item two</:item>
          <:item>Dense item three</:item>
          <:item>Dense item four</:item>
          """
        ]
      },
      %Variation{
        id: :two_line,
        description: "Two-line list with title and subtitle",
        attributes: %{
          id: "list-two-line",
          two_line: true,
          bordered: true
        },
        slots: [
          """
          <:item title="John Doe" icon="account">john@example.com</:item>
          <:item title="Jane Smith" icon="account">jane@example.com</:item>
          <:item title="Bob Wilson" icon="account">bob@example.com</:item>
          """
        ]
      },
      %Variation{
        id: :three_line,
        description: "Three-line list with title, subtitle, and body",
        attributes: %{
          id: "list-three-line",
          three_line: true
        },
        slots: [
          """
          <:item title="Meeting Notes" icon="file-document">
            Review action items from today's standup — see full notes in Confluence
          </:item>
          <:item title="Design Review" icon="palette">
            Feedback on the new dashboard UI — mockups ready for final approval
          </:item>
          """
        ]
      }
    ]
  end
end
