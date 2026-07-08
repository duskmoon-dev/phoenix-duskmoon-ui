defmodule Storybook.DataDisplay.GitCloneBox do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_clone_box/1
  def description, do: "Clone URL and command snippets for normal and empty repositories."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Clone existing repository",
        attributes: %{
          clone_url: "https://github.com/duskmoon-dev/phoenix-duskmoon-ui.git",
          ssh_url: "git@github.com:duskmoon-dev/phoenix-duskmoon-ui.git"
        }
      },
      %Variation{
        id: :empty,
        description: "Empty repository setup",
        attributes: %{
          clone_url: "https://github.com/example/empty.git",
          empty: true
        }
      }
    ]
  end
end
