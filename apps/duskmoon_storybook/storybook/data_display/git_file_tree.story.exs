defmodule Storybook.DataDisplay.GitFileTree do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_file_tree/1
  def description, do: "Dense repository file tree rows for folders, files, and submodules."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Repository file rows",
        slots: [
          """
          <:row kind="folder" name="lib" path="lib" href="#" meta="12 files" />
          <:row kind="folder" name="test" path="test" href="#" meta="8 files" />
          <:row kind="file" name="mix.exs" path="mix.exs" href="#" meta="4 KB" />
          <:row kind="submodule" name="vendor/theme" path="vendor/theme" href="#" meta="a13f9c2" />
          """
        ]
      },
      %Variation{
        id: :empty,
        description: "Empty repository tree",
        attributes: %{empty_message: "No files on this branch."}
      }
    ]
  end
end
