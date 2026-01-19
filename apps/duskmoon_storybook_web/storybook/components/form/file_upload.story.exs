defmodule Storybook.Components.Form.FileUpload do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "An enhanced file upload with progress and preview."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "file_upload",
          label: "Upload Document",
          name: "document",
          value: nil
        }
      },
      %Variation{
        id: :multiple_files,
        attributes: %{
          type: "file_upload",
          label: "Upload Images",
          name: "images",
          value: nil,
          multiple: true,
          accept: "image/*"
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "file_upload",
          label: "Import Data",
          name: "data_file",
          value: nil,
          color: "success",
          accept: ".csv,.xlsx,.json"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "file_upload",
          label: "Avatar",
          name: "avatar",
          value: nil,
          size: "sm",
          accept: "image/jpeg,image/png"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "file_upload",
          label: "Resume",
          name: "resume",
          value: nil,
          errors: ["File must be PDF format and under 5MB"]
        }
      }
    ]
  end
end
