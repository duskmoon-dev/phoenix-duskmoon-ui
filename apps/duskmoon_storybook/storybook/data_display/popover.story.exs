defmodule Storybook.DataDisplay.Popover do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.DataDisplay.Popover.dm_popover/1

  def description,
    do: "Native HTML popover with command-based triggering and CSS anchor positioning."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Native auto popover opened by an HTML command",
        attributes: %{
          id: "pop-default"
        },
        slots: [
          """
          <:trigger :let={trigger_attrs}>
            <button type="button" class="btn btn-primary" {trigger_attrs}>Click me</button>
          </:trigger>
          Popover content here
          """
        ]
      },
      %Variation{
        id: :top_example,
        description: "Popover with top placement",
        attributes: %{
          id: "pop-top",
          placement: "top"
        },
        slots: [
          """
          <:trigger :let={trigger_attrs}>
            <button type="button" class="btn btn-secondary" {trigger_attrs}>Open above</button>
          </:trigger>
          Anchored above the command invoker.
          """
        ]
      },
      %Variation{
        id: :with_arrow,
        description: "Arrow pointing to trigger element",
        attributes: %{
          id: "pop-arrow",
          placement: "bottom",
          arrow: true
        },
        slots: [
          """
          <:trigger :let={trigger_attrs}>
            <button type="button" class="btn" {trigger_attrs}>With arrow</button>
          </:trigger>
          This popover has an arrow pointing to the trigger.
          """
        ]
      },
      %VariationGroup{
        id: :placements,
        description: "Cardinal placements",
        variations: [
          %Variation{
            id: :top,
            attributes: %{id: "pop-placement-top", placement: "top"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Top</button>
              </:trigger>
              Placed above the trigger.
              """
            ]
          },
          %Variation{
            id: :left,
            attributes: %{id: "pop-left", placement: "left"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Left</button>
              </:trigger>
              Placed to the left.
              """
            ]
          },
          %Variation{
            id: :right,
            attributes: %{id: "pop-right", placement: "right"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Right</button>
              </:trigger>
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
            attributes: %{id: "pop-ts", placement: "top-start"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Top-start</button>
              </:trigger>
              Aligned to start edge, above.
              """
            ]
          },
          %Variation{
            id: :top_end,
            attributes: %{id: "pop-te", placement: "top-end"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Top-end</button>
              </:trigger>
              Aligned to end edge, above.
              """
            ]
          },
          %Variation{
            id: :bottom_start,
            attributes: %{id: "pop-bs", placement: "bottom-start"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Bottom-start</button>
              </:trigger>
              Aligned to start edge, below.
              """
            ]
          },
          %Variation{
            id: :bottom_end,
            attributes: %{id: "pop-be", placement: "bottom-end"},
            slots: [
              """
              <:trigger :let={trigger_attrs}>
                <button type="button" class="btn" {trigger_attrs}>Bottom-end</button>
              </:trigger>
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
      }
    ]
  end
end
