defmodule Storybook.DataEntry.FileUpload do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.FileUpload.dm_file_upload/1
  def description, do: "An enhanced file upload with drag-and-drop, preview, and validation."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default file upload",
        attributes: %{
          id: "file-default",
          name: "document"
        }
      },
      %Variation{
        id: :multiple_files,
        description: "Multiple file upload with image filter",
        attributes: %{
          id: "file-multiple",
          name: "images",
          multiple: true,
          accept: "image/*"
        }
      },
      %Variation{
        id: :with_preview,
        description: "File upload with preview enabled",
        attributes: %{
          id: "file-preview",
          name: "photo",
          show_preview: true,
          accept: "image/jpeg,image/png"
        }
      },
      %Variation{
        id: :compact,
        description: "Compact file upload",
        attributes: %{
          id: "file-compact",
          name: "attachment",
          compact: true,
          size: "sm"
        }
      },
      %Variation{
        id: :with_constraints,
        description: "File upload with size and count limits",
        attributes: %{
          id: "file-constrained",
          name: "resume",
          max_size: 5_000_000,
          max_files: 3,
          accept: ".pdf,.docx"
        }
      },
      %Variation{
        id: :with_errors,
        description: "File upload showing validation errors",
        attributes: %{
          id: "file-errors",
          name: "upload",
          errors: ["File must be PDF format and under 5MB"]
        }
      },
      %Variation{
        id: :disabled,
        description: "Disabled file upload",
        attributes: %{
          id: "file-disabled",
          name: "locked",
          disabled: true
        }
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :multiple,
        label: "Multiple",
        type: :boolean,
        default: false
      },
      %{
        id: :show_preview,
        label: "Show Preview",
        type: :boolean,
        default: false
      },
      %{
        id: :compact,
        label: "Compact",
        type: :boolean,
        default: false
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      }
    ]
  end
end
