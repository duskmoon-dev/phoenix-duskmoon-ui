defmodule Storybook.Action.Button do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Button.dm_btn/1
  def description, do: "Button component wrapping el-dm-button with color/style variants, sizes, shapes, loading/disabled states, prefix/suffix slots, confirm dialog, and noise effect."

  def variations do
    [
      # ── Color Variants ────────────────────────────────────────────────
      %VariationGroup{
        id: :color_variants,
        description: "All color variants — primary, secondary, tertiary, accent and semantic",
        variations:
          for color <- ~w(primary secondary tertiary accent info success warning error) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{variant: color},
              slots: [String.capitalize(color)]
            }
          end
      },

      # ── Style Variants ────────────────────────────────────────────────
      %VariationGroup{
        id: :style_variants,
        description: "Ghost, outline, and link style variants",
        variations:
          for style <- ~w(ghost outline link) do
            %Variation{
              id: String.to_atom(style),
              attributes: %{variant: style},
              slots: [String.capitalize(style)]
            }
          end
      },

      # ── Sizes ─────────────────────────────────────────────────────────
      %VariationGroup{
        id: :sizes,
        description: "All size variants — xs, sm, md, lg",
        variations:
          for {size, label} <- [{"xs", "Extra Small"}, {"sm", "Small"}, {"md", "Medium"}, {"lg", "Large"}] do
            %Variation{
              id: String.to_atom(size),
              attributes: %{variant: "primary", size: size},
              slots: [label]
            }
          end
      },

      # ── Shapes ────────────────────────────────────────────────────────
      %VariationGroup{
        id: :shapes,
        description: "Square and circle shape variants",
        variations: [
          %Variation{
            id: :square,
            attributes: %{variant: "primary", shape: "square"},
            slots: ["S"]
          },
          %Variation{
            id: :circle,
            attributes: %{variant: "primary", shape: "circle"},
            slots: ["O"]
          }
        ]
      },

      # ── States ────────────────────────────────────────────────────────
      %VariationGroup{
        id: :states,
        description: "Loading and disabled states",
        variations: [
          %Variation{
            id: :loading,
            attributes: %{variant: "primary", loading: true},
            slots: ["Loading..."]
          },
          %Variation{
            id: :disabled,
            attributes: %{variant: "primary", disabled: true},
            slots: ["Disabled"]
          }
        ]
      },

      # ── Slots ─────────────────────────────────────────────────────────
      %VariationGroup{
        id: :slots,
        description: "Prefix and suffix icon slots",
        variations: [
          %Variation{
            id: :with_prefix,
            attributes: %{variant: "primary"},
            slots: [
              """
              <:prefix>→</:prefix>
              Save
              """
            ]
          },
          %Variation{
            id: :with_suffix,
            attributes: %{variant: "secondary"},
            slots: [
              """
              Next
              <:suffix>›</:suffix>
              """
            ]
          }
        ]
      },

      # ── Confirm Dialog ────────────────────────────────────────────────
      %VariationGroup{
        id: :confirm,
        description: "Confirm dialog variants",
        variations: [
          %Variation{
            id: :remove,
            attributes: %{
              variant: "error",
              confirm_title: "Attention!",
              confirm: "Do you really want to remove it?"
            },
            slots: ["Remove"]
          },
          %Variation{
            id: :export,
            attributes: %{
              variant: "info",
              confirm: "Are you sure you want to export?"
            },
            slots: [
              """
              Export
              <:confirm_action>
              <form method="dialog">
                <el-dm-button variant="info" size="sm" phx-click="export">Export CSV</el-dm-button>
              </form>
              </:confirm_action>
              """
            ]
          }
        ]
      },

      # ── Confirm Dialog Customization ───────────────────────────────
      %VariationGroup{
        id: :confirm_customization,
        description: "Confirm dialog with custom button text, classes, and no-cancel option",
        variations: [
          %Variation{
            id: :custom_button_text,
            description: "Custom confirm and cancel button text",
            attributes: %{
              variant: "warning",
              confirm: "This action cannot be undone.",
              confirm_text: "Proceed",
              cancel_text: "Go Back"
            },
            slots: ["Delete Account"]
          },
          %Variation{
            id: :no_cancel_button,
            description: "Confirm dialog without cancel button",
            attributes: %{
              variant: "success",
              confirm: "Your changes have been saved.",
              confirm_text: "OK",
              show_cancel_action: false
            },
            slots: ["Save"]
          },
          %Variation{
            id: :custom_dialog_label,
            description: "Confirm dialog with custom accessible label",
            attributes: %{
              variant: "primary",
              confirm: "Do you want to publish this post?",
              confirm_dialog_label: "Publish confirmation"
            },
            slots: ["Publish"]
          }
        ]
      },

      # ── Noise Effect ──────────────────────────────────────────────────
      %Variation{
        id: :with_noise,
        description: "Noise effect decorative button",
        attributes: %{
          noise: true,
          content: "Waiting for noise"
        },
        slots: ["Primary Action"]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :variant,
        label: "Variant",
        type: :select,
        options: [
          {nil, "Default"},
          {"primary", "Primary"},
          {"secondary", "Secondary"},
          {"accent", "Accent"},
          {"info", "Info"},
          {"success", "Success"},
          {"warning", "Warning"},
          {"error", "Error"},
          {"ghost", "Ghost"},
          {"link", "Link"},
          {"outline", "Outline"}
        ],
        default: nil
      },
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {nil, "Default"},
          {"xs", "XS"},
          {"sm", "SM"},
          {"md", "MD"},
          {"lg", "LG"}
        ],
        default: nil
      },
      %{
        id: :shape,
        label: "Shape",
        type: :select,
        options: [
          {nil, "Default"},
          {"square", "Square"},
          {"circle", "Circle"}
        ],
        default: nil
      },
      %{
        id: :loading,
        label: "Loading",
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
