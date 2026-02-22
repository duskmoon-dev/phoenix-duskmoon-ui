defmodule Storybook.DataEntry.Textarea do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Textarea.dm_textarea/1
  def description, do: "Textarea component for multi-line text input with customizable sizing and resize behavior."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default textarea with placeholder",
        attributes: %{
          id: "textarea-default",
          name: "description",
          label: "Description",
          placeholder: "Enter a description...",
          rows: 4
        }
      },
      %Variation{
        id: :with_value,
        description: "Textarea with pre-filled content",
        attributes: %{
          id: "textarea-value",
          name: "notes",
          label: "Notes",
          value: "These are some pre-filled notes that demonstrate how the textarea looks with content.",
          rows: 3
        }
      },
      %Variation{
        id: :no_label,
        description: "Textarea without a label",
        attributes: %{
          id: "textarea-no-label",
          name: "comment",
          placeholder: "Leave a comment...",
          rows: 5
        }
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations:
          for size <- ~w(xs sm md lg) do
            %Variation{
              id: String.to_atom(size),
              attributes: %{
                id: size,
                name: size,
                label: "#{String.upcase(size)} Textarea",
                size: size,
                rows: "2",
                placeholder: "#{String.upcase(size)} textarea"
              }
            }
          end
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations:
          for color <- ~w(primary secondary accent success warning error tertiary info) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{
                id: color,
                name: color,
                label: String.capitalize(color),
                color: color,
                rows: "2",
                placeholder: "#{String.capitalize(color)} textarea"
              }
            }
          end
      },
      %VariationGroup{
        id: :variants,
        description: "Style variants",
        variations:
          for variant <- ~w(ghost filled bordered) do
            %Variation{
              id: String.to_atom(variant),
              attributes: %{
                id: "variant-#{variant}",
                name: "variant_#{variant}",
                label: "#{String.capitalize(variant)} Variant",
                variant: variant,
                rows: "3",
                placeholder: "#{String.capitalize(variant)} style"
              }
            }
          end
      },
      %VariationGroup{
        id: :resize_options,
        description: "Resize behavior options",
        variations: [
          %Variation{
            id: :no_resize,
            attributes: %{
              id: "no-resize",
              name: "no-resize",
              label: "Fixed Size",
              resize: "none",
              rows: "3",
              placeholder: "This textarea cannot be resized"
            }
          },
          %Variation{
            id: :vertical_resize,
            attributes: %{
              id: "vertical-resize",
              name: "vertical-resize",
              label: "Vertical Only",
              resize: "vertical",
              rows: "3",
              placeholder: "This textarea can only be resized vertically"
            }
          },
          %Variation{
            id: :horizontal_resize,
            attributes: %{
              id: "horizontal-resize",
              name: "horizontal-resize",
              label: "Horizontal Only",
              resize: "horizontal",
              rows: "3",
              placeholder: "This textarea can only be resized horizontally"
            }
          },
          %Variation{
            id: :both_resize,
            attributes: %{
              id: "both-resize",
              name: "both-resize",
              label: "Free Resize",
              resize: "both",
              rows: "3",
              placeholder: "This textarea can be resized in both directions"
            }
          }
        ]
      },
      %VariationGroup{
        id: :states,
        description: "Input states",
        variations: [
          %Variation{
            id: :disabled_state,
            attributes: %{
              id: "disabled",
              name: "disabled",
              label: "Disabled Textarea",
              disabled: true,
              rows: "3",
              value: "This textarea is disabled and cannot be edited"
            }
          },
          %Variation{
            id: :readonly_state,
            attributes: %{
              id: "readonly",
              name: "readonly",
              label: "Readonly Textarea",
              readonly: true,
              rows: "3",
              value: "This textarea is readonly but can be focused"
            }
          },
          %Variation{
            id: :required_state,
            attributes: %{
              id: "required",
              name: "required",
              label: "Required Textarea",
              required: true,
              rows: "3",
              placeholder: "This field is required"
            }
          }
        ]
      },
      %Variation{
        id: :with_constraints,
        description: "Textarea with maxlength constraint",
        attributes: %{
          id: "textarea-constraints",
          name: "bio",
          label: "Bio (Max 200 characters)",
          placeholder: "Tell us about yourself...",
          rows: 4,
          maxlength: 200
        }
      },
      %VariationGroup{
        id: :different_rows,
        description: "Different row counts",
        variations: [
          %Variation{
            id: :rows_2,
            attributes: %{
              id: "rows-2",
              name: "rows2",
              label: "Short Text",
              rows: "2",
              placeholder: "Short input area"
            }
          },
          %Variation{
            id: :rows_5,
            attributes: %{
              id: "rows-5",
              name: "rows5",
              label: "Medium Text",
              rows: "5",
              placeholder: "Medium input area with more space"
            }
          },
          %Variation{
            id: :rows_10,
            attributes: %{
              id: "rows-10",
              name: "rows10",
              label: "Long Text",
              rows: "10",
              placeholder: "Large input area for long content"
            }
          }
        ]
      },
      %VariationGroup{
        id: :validation_states,
        description: "Validation states (success / warning)",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              id: "ta-vs-success",
              name: "ta_vs_success",
              label: "Valid Content",
              state: "success",
              rows: "3",
              placeholder: "Looks good!"
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              id: "ta-vs-warning",
              name: "ta_vs_warning",
              label: "Review Required",
              state: "warning",
              rows: "3",
              placeholder: "Please review your input"
            }
          }
        ]
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside textarea",
        attributes: %{
          id: "ta-horizontal",
          name: "ta_horizontal",
          label: "Notes",
          horizontal: true,
          rows: "3",
          placeholder: "Enter notes here"
        }
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below textarea",
        attributes: %{
          id: "ta-helper",
          name: "ta_helper",
          label: "Bio",
          helper: "Tell us a bit about yourself (up to 200 characters).",
          rows: "3",
          placeholder: "Your bio..."
        }
      },
      %Variation{
        id: :with_errors,
        description: "Textarea with error messages",
        attributes: %{
          id: "ta-errors",
          name: "ta_errors",
          label: "Description",
          errors: ["This field is required.", "Must be at least 20 characters."],
          rows: "3",
          placeholder: "Enter a description"
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
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: "md"
      },
      %{
        id: :color,
        label: "Color",
        type: :select,
        options: [
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"}
        ],
        default: "primary"
      },
      %{
        id: :resize,
        label: "Resize",
        type: :select,
        options: [
          {"none", "None"},
          {"vertical", "Vertical"},
          {"horizontal", "Horizontal"},
          {"both", "Both"}
        ],
        default: "vertical"
      },
      %{
        id: :disabled,
        label: "Disabled",
        type: :boolean,
        default: false
      },
      %{
        id: :readonly,
        label: "Readonly",
        type: :boolean,
        default: false
      },
      %{
        id: :required,
        label: "Required",
        type: :boolean,
        default: false
      },
      %{
        id: :rows,
        label: "Rows",
        type: :number,
        default: 3
      }
    ]
  end
end
