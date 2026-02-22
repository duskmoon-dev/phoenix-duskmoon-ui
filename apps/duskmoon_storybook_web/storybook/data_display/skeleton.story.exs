defmodule Storybook.DataDisplay.Skeleton do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Skeleton.dm_skeleton/1
  def description, do: "Skeleton loading placeholders for better UX."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Basic skeleton loader",
        attributes: %{size: "lg"}
      },
      %Variation{
        id: :circle,
        description: "Circle skeleton (avatar placeholder)",
        attributes: %{variant: "circle", size: "lg"}
      },
      %Variation{
        id: :text,
        description: "Text skeleton placeholder",
        attributes: %{variant: "text", size: "lg"}
      },
      %Variation{
        id: :rectangle,
        description: "Rectangle skeleton (image placeholder)",
        attributes: %{variant: "square", size: "lg"}
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
          {"circle", "Circle"},
          {"square", "Square"},
          {"text", "Text"},
          {"avatar", "Avatar"}
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
          {"lg", "LG"},
          {"xl", "XL"}
        ],
        default: nil
      },
      %{
        id: :animation,
        label: "Animation",
        type: :select,
        options: [
          {nil, "Default"},
          {"wave", "Wave"},
          {"bounce", "Bounce"}
        ],
        default: nil
      }
    ]
  end
end
