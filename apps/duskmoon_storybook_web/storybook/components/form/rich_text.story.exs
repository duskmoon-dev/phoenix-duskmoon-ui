defmodule Storybook.Components.Form.RichText do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "A WYSIWYG rich text editor component."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "rich_text",
          label: "Description",
          name: "description",
          value: nil
        }
      },
      %Variation{
        id: :with_content,
        attributes: %{
          type: "rich_text",
          label: "Article Content",
          name: "article_content",
          value: "<p>This is <strong>rich text</strong> content.</p>"
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "rich_text",
          label: "Notes",
          name: "notes",
          value: nil,
          color: "info"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "rich_text",
          label: "Comment",
          name: "comment",
          value: nil,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "rich_text",
          label: "Bio",
          name: "bio",
          value: nil,
          errors: ["Bio must be at least 50 characters"]
        }
      }
    ]
  end
end
