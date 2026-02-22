defmodule Storybook.Action.Dropdown do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Dropdown.dm_dropdown/1
  def description, do: "Dropdown menu component for action menus and navigation."

  def imports do
    [{PhoenixDuskmoon.Component.Action.Button, [dm_btn: 1]},
     {PhoenixDuskmoon.Component.Icon.Icons, [dm_mdi: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic dropdown with ghost trigger button",
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
        description: "Right-aligned dropdown with primary color",
        attributes: %{
          position: "right",
          color: "primary"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="primary">
              Actions
              <.dm_mdi name="chevron-down" class="ml-1" />
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
        description: "Menu items with leading icons",
        attributes: %{
          position: "right"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="secondary">
              <.dm_mdi name="account-circle" />
              User
            </.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a><.dm_mdi name="account" class="mr-2" />Profile</a></li>
            <li><a><.dm_mdi name="cog" class="mr-2" />Settings</a></li>
            <li><a><.dm_mdi name="logout" class="mr-2" />Logout</a></li>
          </:content>
          """
        ]
      },
      %Variation{
        id: :color_variants,
        description: "Success color theme",
        attributes: %{
          color: "success"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="success">
              <.dm_mdi name="check" class="mr-1" />
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
        description: "Warning color with left-aligned position",
        attributes: %{
          color: "warning",
          position: "left"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="warning">
              <.dm_mdi name="alert" class="mr-1" />
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
        description: "Compact icon-only trigger — kebab menu",
        attributes: %{
          position: "bottom"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="ghost" shape="square" size="sm">
              <.dm_mdi name="dots-vertical" />
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
        description: "Navigation-style dropdown with info color",
        attributes: %{
          color: "info"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="info">
              <.dm_mdi name="navigation" class="mr-1" />
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
      },
      %Variation{
        id: :top_position,
        description: "Top-positioned dropdown — opens upward",
        attributes: %{
          position: "top"
        },
        slots: [
          """
          <:trigger>
            <.dm_btn variant="secondary">Open Up</.dm_btn>
          </:trigger>
          """,
          """
          <:content>
            <li><a>Option 1</a></li>
            <li><a>Option 2</a></li>
            <li><a>Option 3</a></li>
          </:content>
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :position,
        label: "Position",
        type: :select,
        options: [
          {nil, "Default"},
          {"left", "Left"},
          {"right", "Right"},
          {"top", "Top"},
          {"bottom", "Bottom"}
        ],
        default: nil
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"tertiary", "Tertiary"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"info", "Info"}
        ],
        default: nil
      }
    ]
  end
end