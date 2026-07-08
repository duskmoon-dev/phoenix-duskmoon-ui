defmodule Storybook.DataDisplay.GitCommitDiff do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.GitRepository.dm_git_commit_diff/1
  def description, do: "Commit metadata with changed-file summaries and unified diff lines."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Commit with one diff",
        attributes: %{
          title: "Add repository components",
          sha: "b91d64a5f5a2c7e6d9a6",
          author: "Jonathan",
          committed_at: "2 minutes ago",
          changed_files: 1,
          additions: 2,
          deletions: 1
        },
        slots: [
          """
          <:file
            path="lib/repo_view.ex"
            status="modified"
            additions={2}
            deletions={1}
            lines={[
              %{type: :hunk, old_line: nil, new_line: nil, content: "@@ -1,3 +1,4 @@"},
              %{type: :context, old_line: 1, new_line: 1, content: "defmodule RepoView do"},
              %{type: :delete, old_line: 2, new_line: nil, content: "  def old, do: :ok"},
              %{type: :add, old_line: nil, new_line: 2, content: "  def new, do: :ok"}
            ]}
          />
          """
        ]
      }
    ]
  end
end
