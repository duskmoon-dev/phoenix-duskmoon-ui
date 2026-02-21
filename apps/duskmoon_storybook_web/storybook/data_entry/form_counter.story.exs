defmodule Storybook.DataEntry.FormCounter do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataEntry.Form.dm_form_counter/1
  def description, do: "Character counter showing current vs maximum count."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          current: 42,
          max: 200
        }
      },
      %Variation{
        id: :near_limit,
        attributes: %{
          current: 195,
          max: 200
        }
      },
      %Variation{
        id: :over_limit,
        attributes: %{
          current: 215,
          max: 200,
          error: true
        }
      },
      %Variation{
        id: :with_field,
        attributes: %{},
        template: """
        <div class="form-group">
          <label class="form-label">Bio</label>
          <textarea class="textarea" placeholder="Tell us about yourself..."></textarea>
          <.dm_form_counter current={85} max={300} />
        </div>
        """
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :error,
        label: "Error",
        type: :boolean,
        default: false
      }
    ]
  end
end
