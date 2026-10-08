defmodule Storybook.DataDisplay.GitRepositoryHeader do
  use PhoenixStorybook.Story, :component

  def function,
    do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_repository_header/1

  def description do
    "Repository header with optional owner navigation, visibility, default ref, metadata, and action slots."
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Repository identity with metadata and actions",
        attributes: %{
          owner: "duskmoon-dev",
          name: "phoenix-duskmoon-ui",
          visibility: "public",
          default_ref: "main",
          description: "DuskMoon UI component library for Phoenix applications."
        },
        slots: [
          """
          <:meta icon="source-commit">b91d64a</:meta>
          <:meta icon="clock-outline">Updated 2m ago</:meta>
          <:action><a href="#" class="btn btn-sm">Watch</a></:action>
          <:action><a href="#" class="btn btn-sm">Settings</a></:action>
          """
        ]
      },
      %Variation{
        id: :linked_owner,
        description: "Owner label links to its organization or personal namespace",
        attributes: %{
          owner: "duskmoon-dev",
          owner_href: "https://github.com/duskmoon-dev",
          name: "phoenix-duskmoon-ui",
          visibility: "public"
        }
      }
    ]
  end
end
