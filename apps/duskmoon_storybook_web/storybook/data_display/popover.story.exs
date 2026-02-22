defmodule Storybook.DataDisplay.Popover do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Popover.dm_popover/1
  def description, do: "Popover component for contextual overlays."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Click-triggered popover",
        attributes: %{
          id: "pop-default",
          trigger_mode: "click"
        },
        slots: [
          """
          <:trigger>Click me</:trigger>
          Popover content here
          """
        ]
      },
      %Variation{
        id: :hover,
        description: "Hover-triggered with top placement",
        attributes: %{
          id: "pop-hover",
          trigger_mode: "hover",
          placement: "top"
        },
        slots: [
          """
          <:trigger>Hover me</:trigger>
          Appears on hover
          """
        ]
      },
      %Variation{
        id: :with_arrow,
        description: "Arrow pointing to trigger element",
        attributes: %{
          id: "pop-arrow",
          trigger_mode: "click",
          placement: "bottom",
          arrow: true
        },
        slots: [
          """
          <:trigger>With arrow</:trigger>
          This popover has an arrow pointing to the trigger.
          """
        ]
      },
      %Variation{
        id: :focus_trigger,
        description: "Focus-triggered from an input element",
        attributes: %{
          id: "pop-focus",
          trigger_mode: "focus"
        },
        slots: [
          """
          <:trigger><input type="text" placeholder="Focus me" class="input" /></:trigger>
          Shown when the input is focused.
          """
        ]
      },
      %Variation{
        id: :open_by_default,
        description: "Initially open popover",
        attributes: %{
          id: "pop-open",
          trigger_mode: "click",
          open: true
        },
        slots: [
          """
          <:trigger>Always open</:trigger>
          This popover starts open.
          """
        ]
      },
      %VariationGroup{
        id: :placements,
        description: "Cardinal placements",
        variations: [
          %Variation{
            id: :top,
            attributes: %{id: "pop-top", trigger_mode: "click", placement: "top"},
            slots: [
              """
              <:trigger>Top</:trigger>
              Placed above the trigger.
              """
            ]
          },
          %Variation{
            id: :left,
            attributes: %{id: "pop-left", trigger_mode: "click", placement: "left"},
            slots: [
              """
              <:trigger>Left</:trigger>
              Placed to the left.
              """
            ]
          },
          %Variation{
            id: :right,
            attributes: %{id: "pop-right", trigger_mode: "click", placement: "right"},
            slots: [
              """
              <:trigger>Right</:trigger>
              Placed to the right.
              """
            ]
          }
        ]
      },
      %VariationGroup{
        id: :aligned_placements,
        description: "Start/end aligned placements",
        variations: [
          %Variation{
            id: :top_start,
            attributes: %{id: "pop-ts", trigger_mode: "click", placement: "top-start"},
            slots: [
              """
              <:trigger>Top-start</:trigger>
              Aligned to start edge, above.
              """
            ]
          },
          %Variation{
            id: :top_end,
            attributes: %{id: "pop-te", trigger_mode: "click", placement: "top-end"},
            slots: [
              """
              <:trigger>Top-end</:trigger>
              Aligned to end edge, above.
              """
            ]
          },
          %Variation{
            id: :bottom_start,
            attributes: %{id: "pop-bs", trigger_mode: "click", placement: "bottom-start"},
            slots: [
              """
              <:trigger>Bottom-start</:trigger>
              Aligned to start edge, below.
              """
            ]
          },
          %Variation{
            id: :bottom_end,
            attributes: %{id: "pop-be", trigger_mode: "click", placement: "bottom-end"},
            slots: [
              """
              <:trigger>Bottom-end</:trigger>
              Aligned to end edge, below.
              """
            ]
          }
        ]
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :trigger_mode,
        label: "Trigger Mode",
        type: :select,
        options: [
          {"click", "Click"},
          {"hover", "Hover"},
          {"focus", "Focus"}
        ],
        default: "click"
      },
      %{
        id: :placement,
        label: "Placement",
        type: :select,
        options: [
          {"bottom", "Bottom"},
          {"top", "Top"},
          {"left", "Left"},
          {"right", "Right"},
          {"top-start", "Top Start"},
          {"top-end", "Top End"},
          {"bottom-start", "Bottom Start"},
          {"bottom-end", "Bottom End"}
        ],
        default: "bottom"
      },
      %{
        id: :arrow,
        label: "Arrow",
        type: :boolean,
        default: true
      },
      %{
        id: :open,
        label: "Open",
        type: :boolean,
        default: false
      }
    ]
  end
end
