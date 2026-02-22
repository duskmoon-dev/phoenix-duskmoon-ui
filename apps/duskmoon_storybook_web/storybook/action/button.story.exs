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
        variations: [
          %Variation{
            id: :primary,
            attributes: %{variant: "primary"},
            slots: ["Primary"]
          },
          %Variation{
            id: :secondary,
            attributes: %{variant: "secondary"},
            slots: ["Secondary"]
          },
          %Variation{
            id: :tertiary,
            attributes: %{variant: "tertiary"},
            slots: ["Tertiary"]
          },
          %Variation{
            id: :accent,
            attributes: %{variant: "accent"},
            slots: ["Accent"]
          },
          %Variation{
            id: :info,
            attributes: %{variant: "info"},
            slots: ["Info"]
          },
          %Variation{
            id: :success,
            attributes: %{variant: "success"},
            slots: ["Success"]
          },
          %Variation{
            id: :warning,
            attributes: %{variant: "warning"},
            slots: ["Warning"]
          },
          %Variation{
            id: :error,
            attributes: %{variant: "error"},
            slots: ["Error"]
          }
        ]
      },

      # ── Style Variants ────────────────────────────────────────────────
      %VariationGroup{
        id: :style_variants,
        description: "Ghost, outline, and link style variants",
        variations: [
          %Variation{
            id: :ghost,
            attributes: %{variant: "ghost"},
            slots: ["Ghost"]
          },
          %Variation{
            id: :outline,
            attributes: %{variant: "outline"},
            slots: ["Outline"]
          },
          %Variation{
            id: :link,
            attributes: %{variant: "link"},
            slots: ["Link"]
          }
        ]
      },

      # ── Sizes ─────────────────────────────────────────────────────────
      %VariationGroup{
        id: :sizes,
        description: "All size variants — xs, sm, md, lg",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{variant: "primary", size: "xs"},
            slots: ["Extra Small"]
          },
          %Variation{
            id: :sm,
            attributes: %{variant: "primary", size: "sm"},
            slots: ["Small"]
          },
          %Variation{
            id: :md,
            attributes: %{variant: "primary", size: "md"},
            slots: ["Medium"]
          },
          %Variation{
            id: :lg,
            attributes: %{variant: "primary", size: "lg"},
            slots: ["Large"]
          }
        ]
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
end
