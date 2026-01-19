defmodule Storybook.Components.Form.PasswordStrength do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Form.Input.dm_input/1
  def description, do: "A password input with strength indicator."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          type: "password_strength",
          label: "Password",
          name: "password",
          value: nil
        }
      },
      %Variation{
        id: :weak_password,
        attributes: %{
          type: "password_strength",
          label: "Password",
          name: "password",
          value: "123"
        }
      },
      %Variation{
        id: :strong_password,
        attributes: %{
          type: "password_strength",
          label: "Password",
          name: "password",
          value: "MyStr0ng!P@ssw0rd"
        }
      },
      %Variation{
        id: :with_color,
        attributes: %{
          type: "password_strength",
          label: "Master Password",
          name: "master_password",
          value: nil,
          color: "warning"
        }
      },
      %Variation{
        id: :small_size,
        attributes: %{
          type: "password_strength",
          label: "PIN",
          name: "pin",
          value: nil,
          size: "sm"
        }
      },
      %Variation{
        id: :with_errors,
        attributes: %{
          type: "password_strength",
          label: "New Password",
          name: "new_password",
          value: nil,
          errors: [
            "Password must be at least 8 characters with uppercase, lowercase, and numbers"
          ]
        }
      }
    ]
  end
end
