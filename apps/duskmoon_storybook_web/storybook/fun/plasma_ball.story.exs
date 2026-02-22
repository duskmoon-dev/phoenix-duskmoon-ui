defmodule Storybook.Fun.PlasmaBall do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.CssArt.PlasmaBall.dm_art_plasma_ball/1
  def description, do: "CSS art plasma ball with animated electric arcs."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default medium plasma ball",
        attributes: %{
          id: "plasma-default",
          size: "medium"
        }
      },
      %Variation{
        id: :small,
        description: "Small plasma ball",
        attributes: %{
          id: "plasma-small",
          size: "small"
        }
      },
      %Variation{
        id: :large,
        description: "Large plasma ball",
        attributes: %{
          id: "plasma-large",
          size: "large"
        }
      },
      %Variation{
        id: :dark_theme,
        description: "Black base color on dark background",
        attributes: %{
          id: "plasma-dark",
          size: "medium",
          base_color: "#000000"
        },
        template: """
        <div class="bg-black p-8 rounded-lg">
          <.dm_art_plasma_ball id="plasma-dark" size="medium" base_color="#000000" />
        </div>
        """
      },
      %Variation{
        id: :purple_theme,
        description: "Purple base color on deep purple background",
        attributes: %{
          id: "plasma-purple",
          size: "medium",
          base_color: "#2d1b69"
        },
        template: """
        <div class="bg-purple-950 p-8 rounded-lg">
          <.dm_art_plasma_ball id="plasma-purple" size="medium" base_color="#2d1b69" />
        </div>
        """
      },
      %Variation{
        id: :blue_theme,
        description: "Blue base color on deep blue background",
        attributes: %{
          id: "plasma-blue",
          size: "medium",
          base_color: "#0c4a6e"
        },
        template: """
        <div class="bg-blue-950 p-8 rounded-lg">
          <.dm_art_plasma_ball id="plasma-blue" size="medium" base_color="#0c4a6e" />
        </div>
        """
      },
      %Variation{
        id: :no_electrode,
        description: "Plasma ball without center electrode",
        attributes: %{
          id: "plasma-no-electrode",
          size: "medium",
          show_electrode: false
        }
      },
      %Variation{
        id: :interactive_demo,
        description: "Clickable plasma ball with instructional text",
        attributes: %{
          id: "plasma-interactive",
          size: "medium"
        },
        template: """
        <div class="bg-gradient-to-br from-slate-900 to-slate-800 p-8 rounded-lg">
          <div class="text-center mb-4">
            <p class="text-slate-300 text-sm">Click the plasma ball to toggle the electricity effect!</p>
          </div>
          <.dm_art_plasma_ball id="plasma-interactive" size="medium" />
        </div>
        """
      },
      %Variation{
        id: :size_comparison,
        description: "All three sizes side by side",
        template: """
        <div class="bg-slate-900 p-8 rounded-lg">
          <div class="grid grid-cols-3 gap-8 items-center">
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Small</h3>
              <div class="flex justify-center">
                <.dm_art_plasma_ball id="plasma-comp-small" size="small" base_color="#1a1a2e" />
              </div>
            </div>
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Medium</h3>
              <div class="flex justify-center">
                <.dm_art_plasma_ball id="plasma-comp-medium" size="medium" base_color="#1a1a2e" />
              </div>
            </div>
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Large</h3>
              <div class="flex justify-center">
                <.dm_art_plasma_ball id="plasma-comp-large" size="large" base_color="#1a1a2e" />
              </div>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :color_variations,
        description: "Six different base colors showcased",
        template: """
        <div class="p-8 bg-gradient-to-br from-gray-900 to-black rounded-lg">
          <div class="grid grid-cols-2 md:grid-cols-3 gap-6">
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-1" size="small" base_color="#dc2626" />
              <p class="text-red-400 text-xs mt-2">Red Plasma</p>
            </div>
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-2" size="small" base_color="#16a34a" />
              <p class="text-green-400 text-xs mt-2">Green Plasma</p>
            </div>
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-3" size="small" base_color="#2563eb" />
              <p class="text-blue-400 text-xs mt-2">Blue Plasma</p>
            </div>
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-4" size="small" base_color="#9333ea" />
              <p class="text-purple-400 text-xs mt-2">Purple Plasma</p>
            </div>
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-5" size="small" base_color="#ea580c" />
              <p class="text-orange-400 text-xs mt-2">Orange Plasma</p>
            </div>
            <div class="text-center">
              <.dm_art_plasma_ball id="plasma-color-6" size="small" base_color="#0891b2" />
              <p class="text-cyan-400 text-xs mt-2">Cyan Plasma</p>
            </div>
          </div>
        </div>
        """
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :size,
        label: "Size",
        type: :select,
        options: [
          {"small", "Small"},
          {"medium", "Medium"},
          {"large", "Large"}
        ],
        default: "medium"
      },
      %{
        id: :show_electrode,
        label: "Show Electrode",
        type: :boolean,
        default: true
      }
    ]
  end
end
