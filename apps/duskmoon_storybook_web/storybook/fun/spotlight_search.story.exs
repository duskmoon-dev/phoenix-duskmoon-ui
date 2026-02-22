defmodule Storybook.Fun.SpotlightSearch do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.CssArt.SpotlightSearch.dm_art_spotlight_search/1
  def description, do: "CSS art macOS-style spotlight search overlay with animated ring."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "spotlight-default",
          placeholder: "Search for anything..."
        },
        slots: [
          """
          <:suggestion icon="search" label="Search Users" description="Find team members and profiles" action="navigate_users" />
          """,
          """
          <:suggestion icon="file" label="Search Documents" description="Browse files and reports" action="navigate_docs" />
          """,
          """
          <:suggestion icon="settings" label="Search Settings" description="Configure application preferences" action="navigate_settings" />
          """
        ]
      },
      %Variation{
        id: :simple,
        attributes: %{
          id: "spotlight-simple",
          placeholder: "Quick search..."
        },
        slots: []
      },
      %Variation{
        id: :with_shortcut,
        attributes: %{
          id: "spotlight-shortcut",
          placeholder: "Type to search...",
          shortcut: "⌘+K"
        },
        slots: [
          """
          <:suggestion icon="home" label="Dashboard" description="Go to main dashboard" action="navigate_dashboard" />
          """,
          """
          <:suggestion icon="user" label="Profile" description="View your profile" action="navigate_profile" />
          """,
          """
          <:suggestion icon="bell" label="Notifications" description="Check your notifications" action="navigate_notifications" />
          """,
          """
          <:suggestion icon="help-circle" label="Help Center" description="Get help and support" action="navigate_help" />
          """
        ]
      },
      %Variation{
        id: :loading_state,
        attributes: %{
          id: "spotlight-loading",
          placeholder: "Searching...",
          loading: true
        },
        slots: [
          """
          <:suggestion icon="search" label="Loading results..." description="Please wait" />
          """
        ]
      },
      %Variation{
        id: :navigation_focused,
        attributes: %{
          id: "spotlight-nav",
          placeholder: "Navigate to..."
        },
        slots: [
          """
          <:suggestion icon="compass" label="Explore" description="Discover new content" action="navigate_explore" />
          """,
          """
          <:suggestion icon="bookmark" label="Bookmarks" description="Your saved items" action="navigate_bookmarks" />
          """,
          """
          <:suggestion icon="clock" label="Recent" description="Recently viewed items" action="navigate_recent" />
          """,
          """
          <:suggestion icon="tag" label="Tags" description="Browse by tags" action="navigate_tags" />
          """,
          """
          <:suggestion icon="archive" label="Archive" description="View archived content" action="navigate_archive" />
          """
        ]
      },
      %Variation{
        id: :action_oriented,
        attributes: %{
          id: "spotlight-actions",
          placeholder: "What would you like to do?"
        },
        slots: [
          """
          <:suggestion icon="plus" label="New Project" description="Create a new project" action="create_project" />
          """,
          """
          <:suggestion icon="upload" label="Upload File" description="Upload a new file" action="upload_file" />
          """,
          """
          <:suggestion icon="share" label="Share Content" description="Share with your team" action="share_content" />
          """,
          """
          <:suggestion icon="download" label="Export Data" description="Download your data" action="export_data" />
          """,
          """
          <:suggestion icon="trash" label="Delete Items" description="Remove selected items" action="delete_items" />
          """
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :loading,
        label: "Loading",
        type: :boolean,
        default: false
      }
    ]
  end
end