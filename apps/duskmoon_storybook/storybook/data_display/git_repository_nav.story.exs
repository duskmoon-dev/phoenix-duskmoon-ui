defmodule Storybook.DataDisplay.GitRepositoryNav do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_repository_nav/1
  def description, do: "Server-rendered repository navigation for forge pages."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Repository section links",
        slots: [
          """
          <:item label="Code" href="#" icon="code-tags" active={true} />
          <:item label="Commits" href="#" icon="source-commit" count={42} />
          <:item label="Branches" href="#" icon="source-branch" count={3} />
          <:item label="Tags" href="#" icon="tag-outline" />
          <:item label="Settings" href="#" icon="cog-outline" />
          """
        ]
      }
    ]
  end
end
