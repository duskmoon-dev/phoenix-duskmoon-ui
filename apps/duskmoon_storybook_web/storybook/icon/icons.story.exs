defmodule Storybook.Icon.Icons do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Icon.Icons.dm_mdi/1

  def description, do: "Inline SVG icons from Material Design Icons (7000+) and Bootstrap Icons (2000+)."

  def imports do
    [{PhoenixDuskmoon.Component.Icon.Icons, [dm_bsi: 1]}]
  end

  def variations do
    [
      %Variation{
        id: :default,
        description: "Material Design Icon (MDI)",
        attributes: %{
          name: "home",
          class: "w-8 h-8"
        }
      },
      %Variation{
        id: :sized_small,
        description: "Small icon (16x16)",
        attributes: %{
          name: "account",
          class: "w-4 h-4"
        }
      },
      %Variation{
        id: :sized_large,
        description: "Large icon (64x64)",
        attributes: %{
          name: "star",
          class: "w-16 h-16"
        }
      },
      %Variation{
        id: :colored,
        description: "Icon with custom color",
        attributes: %{
          name: "heart",
          class: "w-8 h-8",
          color: "red"
        }
      },
      %Variation{
        id: :common_icons,
        description: "Common icons showcase",
        template: """
        <div class="flex flex-row gap-4 items-center flex-wrap">
          <.dm_mdi name="home" class="w-8 h-8" />
          <.dm_mdi name="account" class="w-8 h-8" />
          <.dm_mdi name="cog" class="w-8 h-8" />
          <.dm_mdi name="magnify" class="w-8 h-8" />
          <.dm_mdi name="bell" class="w-8 h-8" />
          <.dm_mdi name="heart" class="w-8 h-8" />
          <.dm_mdi name="star" class="w-8 h-8" />
          <.dm_mdi name="check" class="w-8 h-8" />
          <.dm_mdi name="close" class="w-8 h-8" />
          <.dm_mdi name="plus" class="w-8 h-8" />
          <.dm_mdi name="minus" class="w-8 h-8" />
          <.dm_mdi name="pencil" class="w-8 h-8" />
          <.dm_mdi name="delete" class="w-8 h-8" />
          <.dm_mdi name="download" class="w-8 h-8" />
          <.dm_mdi name="upload" class="w-8 h-8" />
        </div>
        """
      },
      %Variation{
        id: :bootstrap_icons,
        description: "Bootstrap Icons (dm_bsi)",
        template: """
        <div class="flex flex-row gap-4 items-center flex-wrap">
          <.dm_bsi name="house" class="w-8 h-8" />
          <.dm_bsi name="person" class="w-8 h-8" />
          <.dm_bsi name="gear" class="w-8 h-8" />
          <.dm_bsi name="search" class="w-8 h-8" />
          <.dm_bsi name="bell" class="w-8 h-8" />
          <.dm_bsi name="heart" class="w-8 h-8" />
          <.dm_bsi name="star" class="w-8 h-8" />
          <.dm_bsi name="check-lg" class="w-8 h-8" />
          <.dm_bsi name="x-lg" class="w-8 h-8" />
          <.dm_bsi name="plus-lg" class="w-8 h-8" />
          <.dm_bsi name="dash-lg" class="w-8 h-8" />
          <.dm_bsi name="pencil" class="w-8 h-8" />
          <.dm_bsi name="trash" class="w-8 h-8" />
          <.dm_bsi name="download" class="w-8 h-8" />
          <.dm_bsi name="upload" class="w-8 h-8" />
        </div>
        """
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :name,
        label: "Icon Name",
        type: :text,
        default: "home"
      },
      %{
        id: :color,
        label: "Color",
        type: :text,
        default: "currentcolor"
      }
    ]
  end
end
