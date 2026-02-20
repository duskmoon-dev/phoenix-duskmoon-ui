defmodule Storybook.DataEntry.OtpInput do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.OtpInput.dm_otp_input/1
  def description, do: "OTP/verification code input with single-character fields."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          length: 6
        }
      },
      %Variation{
        id: :with_label,
        attributes: %{
          length: 6,
          color: "primary",
          label: "Verification Code",
          helper: "We sent a 6-digit code to your email"
        }
      },
      %Variation{
        id: :masked,
        attributes: %{
          length: 4,
          masked: true,
          label: "Enter PIN"
        }
      },
      %Variation{
        id: :sizes,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_otp_input length={4} size="sm" label="Small" />
            <.dm_otp_input length={4} label="Default" />
            <.dm_otp_input length={4} size="lg" label="Large" />
          </div>
          """
        ]
      },
      %Variation{
        id: :states,
        attributes: %{},
        slots: [
          """
          <div class="space-y-4">
            <.dm_otp_input length={4} error={true} error_message="Invalid code" label="Error" />
            <.dm_otp_input length={4} success={true} label="Success" helper="Verified!" />
            <.dm_otp_input length={4} disabled={true} label="Disabled" />
          </div>
          """
        ]
      }
    ]
  end
end
