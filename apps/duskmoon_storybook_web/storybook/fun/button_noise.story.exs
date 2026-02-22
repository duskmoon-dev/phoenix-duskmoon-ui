defmodule Storybook.Fun.ButtonNoise do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.CssArt.ButtonNoise.dm_art_button_noise/1
  def description, do: "CSS art button with animated noise texture effect."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "noise-default",
          content: "Click Me"
        }
      },
      %Variation{
        id: :submit_button,
        attributes: %{
          id: "noise-submit",
          content: "Submit"
        }
      },
      %Variation{
        id: :electric_theme,
        attributes: %{
          id: "noise-electric",
          content: "Power Up",
          color_scheme: "electric"
        },
        template: """
        <div class="bg-slate-900 p-8 rounded-lg">
          <.dm_art_button_noise id="noise-electric" content="Power Up" color_scheme="electric" />
        </div>
        """
      },
      %Variation{
        id: :neon_theme,
        attributes: %{
          id: "noise-neon",
          content: "Neon Glow",
          color_scheme: "neon"
        },
        template: """
        <div class="bg-purple-950 p-8 rounded-lg">
          <.dm_art_button_noise id="noise-neon" content="Neon Glow" color_scheme="neon" />
        </div>
        """
      },
      %Variation{
        id: :custom_typography,
        attributes: %{
          id: "noise-custom-font",
          content: "Custom Style",
          font_size: "28px",
          font_family: "Arial, sans-serif"
        }
      },
      %Variation{
        id: :large_button,
        attributes: %{
          id: "noise-large",
          content: "Large Button",
          font_size: "32px",
          font_family: "Georgia, serif"
        }
      },
      %Variation{
        id: :small_button,
        attributes: %{
          id: "noise-small",
          content: "Small",
          font_size: "16px",
          font_family: "monospace"
        }
      },
      %Variation{
        id: :action_buttons,
        template: """
        <div class="bg-slate-800 p-8 rounded-lg">
          <div class="space-y-4">
            <div>
              <h3 class="text-white text-sm mb-2">Action Buttons</h3>
              <div class="flex gap-4 flex-wrap">
                <.dm_art_button_noise id="action-download" content="Download" color_scheme="default" />
                <.dm_art_button_noise id="action-upload" content="Upload" color_scheme="electric" />
                <.dm_art_button_noise id="action-share" content="Share" color_scheme="neon" />
              </div>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :interactive_showcase,
        template: """
        <div class="bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 p-8 rounded-lg">
          <div class="text-center mb-6">
            <h2 class="text-white text-xl font-bold mb-2">Interactive Noise Buttons</h2>
            <p class="text-purple-200 text-sm">Hover over the buttons to see the electronic noise effect!</p>
          </div>

          <div class="space-y-4">
            <div class="flex justify-center gap-4 flex-wrap">
              <div class="text-center">
                <.dm_art_button_noise id="showcase-default" content="Default" />
                <p class="text-gray-400 text-xs mt-2">Classic Effect</p>
              </div>
              <div class="text-center">
                <.dm_art_button_noise id="showcase-electric" content="Electric" color_scheme="electric" />
                <p class="text-cyan-400 text-xs mt-2">Blue-Green</p>
              </div>
              <div class="text-center">
                <.dm_art_button_noise id="showcase-neon" content="Neon" color_scheme="neon" />
                <p class="text-pink-400 text-xs mt-2">Pink-Yellow</p>
              </div>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :typography_variations,
        template: """
        <div class="bg-gray-100 p-8 rounded-lg">
          <h3 class="text-gray-800 text-lg font-semibold mb-4">Typography Variations</h3>

          <div class="space-y-4">
            <div class="flex items-center gap-4">
              <span class="text-gray-600 text-sm w-32">Sans-serif:</span>
              <.dm_art_button_noise
                id="typo-sans"
                content="Sans Serif"
                font_size="20px"
                font_family="'Helvetica Neue', sans-serif"
              />
            </div>

            <div class="flex items-center gap-4">
              <span class="text-gray-600 text-sm w-32">Serif:</span>
              <.dm_art_button_noise
                id="typo-serif"
                content="Serif Style"
                font_size="20px"
                font_family="'Times New Roman', serif"
              />
            </div>

            <div class="flex items-center gap-4">
              <span class="text-gray-600 text-sm w-32">Monospace:</span>
              <.dm_art_button_noise
                id="typo-mono"
                content="MONOSPACE"
                font_size="18px"
                font_family="'Courier New', monospace"
              />
            </div>

            <div class="flex items-center gap-4">
              <span class="text-gray-600 text-sm w-32">Display:</span>
              <.dm_art_button_noise
                id="typo-display"
                content="Display"
                font_size="24px"
                font_family="'Impact', sans-serif"
              />
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :size_comparison,
        template: """
        <div class="bg-gray-900 p-8 rounded-lg">
          <h3 class="text-white text-lg font-semibold mb-6">Size Comparison</h3>

          <div class="space-y-6">
            <div class="flex items-center gap-6">
              <span class="text-gray-400 text-sm w-20">X-Small:</span>
              <.dm_art_button_noise
                id="size-xs"
                content="XS"
                font_size="12px"
                font_family="sans-serif"
              />
            </div>

            <div class="flex items-center gap-6">
              <span class="text-gray-400 text-sm w-20">Small:</span>
              <.dm_art_button_noise
                id="size-sm"
                content="Small"
                font_size="16px"
                font_family="sans-serif"
              />
            </div>

            <div class="flex items-center gap-6">
              <span class="text-gray-400 text-sm w-20">Medium:</span>
              <.dm_art_button_noise
                id="size-md"
                content="Medium"
                font_size="24px"
                font_family="sans-serif"
              />
            </div>

            <div class="flex items-center gap-6">
              <span class="text-gray-400 text-sm w-20">Large:</span>
              <.dm_art_button_noise
                id="size-lg"
                content="Large"
                font_size="32px"
                font_family="sans-serif"
              />
            </div>

            <div class="flex items-center gap-6">
              <span class="text-gray-400 text-sm w-20">X-Large:</span>
              <.dm_art_button_noise
                id="size-xl"
                content="X-Large"
                font_size="40px"
                font_family="sans-serif"
              />
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :color_showcase,
        template: """
        <div class="bg-black p-8 rounded-lg">
          <h3 class="text-white text-lg font-semibold mb-6 text-center">Color Scheme Showcase</h3>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="text-center">
              <div class="bg-gray-800 p-6 rounded-lg mb-2">
                <.dm_art_button_noise
                  id="color-default-1"
                  content="Default"
                  color_scheme="default"
                />
              </div>
              <p class="text-gray-400 text-xs">Default Scheme</p>
              <p class="text-gray-500 text-xs">Standard rainbow effect</p>
            </div>

            <div class="text-center">
              <div class="bg-cyan-950 p-6 rounded-lg mb-2">
                <.dm_art_button_noise
                  id="color-electric-1"
                  content="Electric"
                  color_scheme="electric"
                />
              </div>
              <p class="text-cyan-400 text-xs">Electric Scheme</p>
              <p class="text-cyan-500 text-xs">Blue-green tones</p>
            </div>

            <div class="text-center">
              <div class="bg-purple-950 p-6 rounded-lg mb-2">
                <.dm_art_button_noise
                  id="color-neon-1"
                  content="Neon"
                  color_scheme="neon"
                />
              </div>
              <p class="text-purple-400 text-xs">Neon Scheme</p>
              <p class="text-purple-500 text-xs">Pink-yellow tones</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :interactive_demo,
        template: """
        <div class="bg-gradient-to-br from-indigo-900 via-purple-900 to-pink-900 p-8 rounded-lg">
          <div class="text-center mb-8">
            <h2 class="text-white text-2xl font-bold mb-2">Electronic Button Experience</h2>
            <p class="text-purple-200 text-sm">Each button features 72 animated light bars creating unique noise effects</p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="bg-black/30 p-6 rounded-lg">
              <h3 class="text-cyan-400 text-sm font-semibold mb-4">Primary Actions</h3>
              <div class="space-y-3">
                <.dm_art_button_noise id="demo-primary-1" content="Initialize System" />
                <.dm_art_button_noise id="demo-primary-2" content="Execute Command" color_scheme="electric" />
                <.dm_art_button_noise id="demo-primary-3" content="Launch Protocol" color_scheme="neon" />
              </div>
            </div>

            <div class="bg-black/30 p-6 rounded-lg">
              <h3 class="text-pink-400 text-sm font-semibold mb-4">Secondary Actions</h3>
              <div class="space-y-3">
                <.dm_art_button_noise id="demo-secondary-1" content="Scan Network" font_size="18px" />
                <.dm_art_button_noise id="demo-secondary-2" content="Encrypt Data" font_size="18px" color_scheme="electric" />
                <.dm_art_button_noise id="demo-secondary-3" content="Deploy" font_size="18px" color_scheme="neon" />
              </div>
            </div>
          </div>

          <div class="mt-8 text-center">
            <p class="text-purple-300 text-xs">Hover over any button to experience the electronic interference effect</p>
          </div>
        </div>
        """
      }
    ]
  end

  def modifiers do
    [
      %{
        id: :color_scheme,
        label: "Color Scheme",
        type: :select,
        options: [
          {"default", "Default"},
          {"electric", "Electric"},
          {"neon", "Neon"}
        ],
        default: "default"
      }
    ]
  end
end