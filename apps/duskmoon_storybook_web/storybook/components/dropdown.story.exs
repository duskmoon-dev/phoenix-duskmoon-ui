defmodule Storybook.Components.Dropdown do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Dropdown.dm_dropdown/1
  def description, do: "Dropdown menu component for action menus and navigation."

  def variations do
    [
      %Variation{
        id: :default,
        slots: [
          """
          <:trigger>
            <.dm_btn variant="ghost">Menu</.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a>Profile</a></li>
            <li><a>Settings</a></li>
            <li><a>Logout</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :right_position,
        attributes: %{
          position: "right",
          color: "primary"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="primary">
              Actions
              <.dm_mdi class="ml-1">chevron-down</.dm_mdi>
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a phx-click="edit">Edit</a></li>
            <li><a phx-click="duplicate">Duplicate</a></li>
            <li><a phx-click="delete" class="text-error">Delete</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :with_icons,
        attributes: %{
          position: "right"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="secondary">
              <.dm_mdi>account-circle</.dm_mdi>
              User
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a><.dm_mdi class="mr-2">account</.dm_mdi>Profile</a></li>
            <li><a><.dm_mdi class="mr-2">cog</.dm_mdi>Settings</a></li>
            <li><a><.dm_mdi class="mr-2">logout</.dm_mdi>Logout</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :color_variants,
        attributes: %{
          color: "success"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="success">
              <.dm_mdi class="mr-1">check</.dm_mdi>
              Complete
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a>Mark as done</a></li>
            <li><a>Approve</a></li>
            <li><a>Send notification</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :warning_dropdown,
        attributes: %{
          color: "warning",
          position: "left"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="warning">
              <.dm_mdi class="mr-1">alert</.dm_mdi>
              Warnings
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a class="text-warning">View warnings</a></li>
            <li><a class="text-warning">Ignore warnings</a></li>
            <li><a class="text-error">Delete items</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :compact_menu,
        attributes: %{
          position: "bottom"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="ghost" shape="square" size="sm">
              <.dm_mdi>dots-vertical</.dm_mdi>
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a class="text-sm">Edit</a></li>
            <li><a class="text-sm">Duplicate</a></li>
            <li><a class="text-sm text-error">Remove</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :navigation_menu,
        attributes: %{
          color: "info"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="info">
              <.dm_mdi class="mr-1">navigation</.dm_mdi>
              Navigate
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a>Dashboard</a></li>
            <li><a>Analytics</a></li>
            <li><a>Reports</a></li>
            <li><a>Help</a></li>
          </:content>
          """
        ]
      }
    ]
  end
end