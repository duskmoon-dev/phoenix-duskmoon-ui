defmodule Storybook.Fun.Eclipse do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Fun.Eclipse.dm_fun_eclipse/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "eclipse-default",
          size: "medium"
        }
      },
      %Variation{
        id: :small,
        attributes: %{
          id: "eclipse-small",
          size: "small"
        }
      },
      %Variation{
        id: :large,
        attributes: %{
          id: "eclipse-large",
          size: "large"
        }
      },
      %Variation{
        id: :dark_space,
        attributes: %{
          id: "eclipse-dark",
          size: "medium",
          bg_color: "#000000"
        },
        template: """
        <div class="bg-black p-8 rounded-lg overflow-hidden">
          <.dm_fun_eclipse id="eclipse-dark" size="medium" bg_color="#000000" />
        </div>
        """
      },
      %Variation{
        id: :deep_space,
        attributes: %{
          id: "eclipse-deep",
          size: "medium",
          bg_color: "#030712"
        },
        template: """
        <div class="bg-gray-950 p-8 rounded-lg overflow-hidden">
          <.dm_fun_eclipse id="eclipse-deep" size="medium" bg_color="#030712" />
        </div>
        """
      },
      %Variation{
        id: :purple_nebula,
        attributes: %{
          id: "eclipse-purple",
          size: "medium",
          bg_color: "#1e1b4b"
        },
        template: """
        <div class="bg-indigo-950 p-8 rounded-lg overflow-hidden">
          <.dm_fun_eclipse id="eclipse-purple" size="medium" bg_color="#1e1b4b" />
        </div>
        """
      },
      %Variation{
        id: :slow_animation,
        attributes: %{
          id: "eclipse-slow",
          size: "medium",
          animation_speed: 0.5
        }
      },
      %Variation{
        id: :fast_animation,
        attributes: %{
          id: "eclipse-fast",
          size: "medium",
          animation_speed: 2.0
        }
      },
      %Variation{
        id: :cosmic_showcase,
        template: """
        <div class="bg-gradient-to-br from-slate-950 via-purple-950 to-slate-950 p-8 rounded-lg overflow-hidden">
          <div class="text-center mb-6">
            <h2 class="text-white text-xl font-bold mb-2">Celestial Eclipse Simulation</h2>
            <p class="text-purple-200 text-sm">Multiple rotating layers create a mesmerizing cosmic effect</p>
          </div>
          <div class="flex justify-center">
            <.dm_fun_eclipse id="eclipse-cosmic" size="large" bg_color="#0a0a0f" animation_speed="1.0" />
          </div>
        </div>
        """
      },
      %Variation{
        id: :size_comparison,
        template: """
        <div class="bg-slate-950 p-8 rounded-lg overflow-hidden">
          <div class="space-y-8">
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Small Eclipse</h3>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-comp-small" size="small" bg_color="#0f0f23" />
              </div>
            </div>
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Medium Eclipse</h3>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-comp-medium" size="medium" bg_color="#0f0f23" />
              </div>
            </div>
            <div class="text-center">
              <h3 class="text-white text-sm mb-4">Large Eclipse</h3>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-comp-large" size="large" bg_color="#0f0f23" />
              </div>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :animation_speeds,
        template: """
        <div class="bg-slate-900 p-8 rounded-lg overflow-hidden">
          <div class="text-center mb-6">
            <h3 class="text-white text-lg font-semibold">Animation Speed Variations</h3>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div class="text-center">
              <h4 class="text-cyan-400 text-xs mb-3">Slow Motion</h4>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-slow-demo" size="small" bg_color="#0c1426" animation_speed="0.3" />
              </div>
            </div>
            <div class="text-center">
              <h4 class="text-green-400 text-xs mb-3">Normal Speed</h4>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-normal-demo" size="small" bg_color="#0c1426" animation_speed="1.0" />
              </div>
            </div>
            <div class="text-center">
              <h4 class="text-orange-400 text-xs mb-3">Fast Motion</h4>
              <div class="flex justify-center">
                <.dm_fun_eclipse id="eclipse-fast-demo" size="small" bg_color="#0c1426" animation_speed="3.0" />
              </div>
            </div>
          </div>
        </div>
        """
      }
    ]
  end
end