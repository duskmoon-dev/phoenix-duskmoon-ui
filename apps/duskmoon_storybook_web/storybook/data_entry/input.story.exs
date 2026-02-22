defmodule Storybook.DataEntry.Input do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Input.dm_input/1
  def description, do: "Form input supporting text, email, password, number, select, and other HTML input types with validation states."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "text",
          label: "Username",
          name: "name",
          value: nil
        }
      },
      %Variation{
        id: :password,
        attributes: %{
          type: "password",
          label: "Password",
          name: "password",
          value: nil
        }
      },
      %Variation{
        id: :email,
        attributes: %{
          type: "email",
          label: "Email",
          name: "email",
          value: nil,
          class: "input-sm"
        }
      },
      %Variation{
        id: :input_error,
        attributes: %{
          type: "search",
          label: "Search",
          name: "search",
          value: nil,
          errors: ["Search is required"]
        }
      },
      %Variation{
        id: :checkbox,
        attributes: %{
          type: "checkbox",
          label: "Checkbox",
          name: "checkbox"
        }
      },
      %Variation{
        id: :toggle,
        attributes: %{
          type: "toggle",
          label: "Auto",
          name: "auto",
          value: nil
        }
      },
      %Variation{
        id: :select,
        attributes: %{
          type: "select",
          label: "Location",
          name: "location",
          value: nil,
          options: [
            {"New York", "new_york"},
            {"California",
             [
               {"San Diego", "san_diego"},
               {"San Francisco", "san_francisco"},
               {"Los Angeles", "los_angeles"}
             ]}
          ]
        }
      },
      %Variation{
        id: :select_multiple,
        attributes: %{
          type: "select",
          label: "Favorite Cities",
          name: "favorite_cities",
          value: nil,
          multiple: true,
          options: [
            {"New York", "new_york"},
            {"California",
             [
               {"San Diego", "san_diego"},
               {"San Francisco", "san_francisco"},
               {"Los Angeles", "los_angeles"}
             ]}
          ]
        }
      },
      %Variation{
        id: :checkbox_group,
        attributes: %{
          type: "checkbox_group",
          label: "Favorite countries",
          name: "favorite_countries",
          value: nil,
          multiple: true,
          options: [
            {"United States", "us"},
            {"United Kingdom", "uk"},
            {"France", "fr"},
            {"Germany", "de"}
          ]
        }
      },
      %Variation{
        id: :radio_group,
        attributes: %{
          type: "radio_group",
          label: "Most visited country",
          name: "most_visited_country",
          value: nil,
          options: [
            {"United States", "us"},
            {"United Kingdom", "uk"},
            {"France", "fr"},
            {"Germany", "de"}
          ]
        }
      },
      %Variation{
        id: :ghost,
        attributes: %{
          type: "text",
          label: "Ghost Input",
          name: "ghost_input",
          value: nil,
          variant: "ghost"
        }
      },
      %Variation{
        id: :filled,
        attributes: %{
          type: "text",
          label: "Filled Input",
          name: "filled_input",
          value: nil,
          variant: "filled"
        }
      },
      %Variation{
        id: :bordered,
        attributes: %{
          type: "text",
          label: "Bordered Input",
          name: "bordered_input",
          value: nil,
          variant: "bordered"
        }
      },
      %Variation{
        id: :textarea,
        attributes: %{
          type: "textarea",
          label: "Story",
          name: "story",
          value: nil
        }
      },
      %Variation{
        id: :file,
        attributes: %{
          type: "file",
          label: "Attachment",
          name: "attachment",
          value: nil
        }
      },
      %Variation{
        id: :number,
        attributes: %{type: "number", label: "Quantity", name: "quantity", value: nil}
      },
      %Variation{
        id: :date,
        attributes: %{type: "date", label: "Birth Date", name: "birth_date", value: nil}
      },
      %Variation{
        id: :range,
        attributes: %{type: "range", label: "Volume", name: "volume", value: nil}
      },
      %Variation{
        id: :color_picker,
        attributes: %{type: "color_picker", label: "Brand Color", name: "brand_color", value: nil}
      },
      %Variation{
        id: :range_slider,
        attributes: %{
          type: "range_slider",
          label: "Price Range",
          name: "price_range",
          value: nil,
          min: 0,
          max: 100
        }
      },
      %Variation{
        id: :rating,
        attributes: %{type: "rating", label: "Rate this item", name: "rating", value: 3}
      },
      %Variation{
        id: :tags,
        attributes: %{type: "tags", label: "Add Tags", name: "tags", value: nil}
      },
      %Variation{
        id: :password_strength,
        attributes: %{type: "password_strength", label: "New Password", name: "new_password", value: nil}
      },
      %Variation{
        id: :search_with_suggestions,
        attributes: %{
          type: "search_with_suggestions",
          label: "Search Users",
          name: "user_search",
          value: nil,
          suggestions: ["Alice", "Bob", "Carol", "Dave"]
        }
      },
      %VariationGroup{
        id: :colors,
        description: "Color variants",
        variations: [
          %Variation{
            id: :primary,
            attributes: %{type: "text", label: "Primary", name: "c_primary", value: nil, color: "primary"}
          },
          %Variation{
            id: :secondary,
            attributes: %{type: "text", label: "Secondary", name: "c_secondary", value: nil, color: "secondary"}
          },
          %Variation{
            id: :tertiary,
            attributes: %{type: "text", label: "Tertiary", name: "c_tertiary", value: nil, color: "tertiary"}
          },
          %Variation{
            id: :accent,
            attributes: %{type: "text", label: "Accent", name: "c_accent", value: nil, color: "accent"}
          },
          %Variation{
            id: :info,
            attributes: %{type: "text", label: "Info", name: "c_info", value: nil, color: "info"}
          },
          %Variation{
            id: :success,
            attributes: %{type: "text", label: "Success", name: "c_success", value: nil, color: "success"}
          },
          %Variation{
            id: :warning,
            attributes: %{type: "text", label: "Warning", name: "c_warning", value: nil, color: "warning"}
          },
          %Variation{
            id: :error,
            attributes: %{type: "text", label: "Error", name: "c_error", value: nil, color: "error"}
          }
        ]
      },
      %VariationGroup{
        id: :sizes,
        description: "Size variants",
        variations: [
          %Variation{
            id: :xs,
            attributes: %{type: "text", label: "XS Input", name: "s_xs", value: nil, size: "xs"}
          },
          %Variation{
            id: :sm,
            attributes: %{type: "text", label: "SM Input", name: "s_sm", value: nil, size: "sm"}
          },
          %Variation{
            id: :lg,
            attributes: %{type: "text", label: "LG Input", name: "s_lg", value: nil, size: "lg"}
          }
        ]
      },
      %VariationGroup{
        id: :states,
        description: "Validation states",
        variations: [
          %Variation{
            id: :success_state,
            attributes: %{
              type: "text",
              label: "Valid Email",
              name: "state_success",
              value: nil,
              state: "success"
            }
          },
          %Variation{
            id: :warning_state,
            attributes: %{
              type: "text",
              label: "Weak Password",
              name: "state_warning",
              value: nil,
              state: "warning"
            }
          }
        ]
      },
      %Variation{
        id: :horizontal,
        description: "Horizontal layout — label beside input",
        attributes: %{type: "text", label: "Username", name: "h_username", value: nil, horizontal: true}
      },
      %Variation{
        id: :with_helper,
        description: "Helper text below input",
        attributes: %{
          type: "email",
          label: "Email Address",
          name: "email_helper",
          value: nil,
          helper: "We'll never share your email with anyone."
        }
      },
      %Variation{
        id: :with_errors,
        description: "Input with error messages",
        attributes: %{
          type: "email",
          label: "Email",
          name: "email_errors",
          value: nil,
          errors: ["is not a valid email address", "is required"]
        }
      }
    ]
  end
end
