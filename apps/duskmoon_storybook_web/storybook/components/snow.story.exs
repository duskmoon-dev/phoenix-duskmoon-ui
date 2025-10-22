defmodule Storybook.Components.Snow do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Fun.Snow.dm_fun_snow/1

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          id: "snow-default",
          count: 30
        }
      },
      %Variation{
        id: :light_snow,
        attributes: %{
          id: "snow-light",
          count: 15
        },
        template: """
        <div class="bg-gradient-to-b from-slate-200 to-slate-100 h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-slate-600 text-sm">Light Snowfall</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :heavy_snow,
        attributes: %{
          id: "snow-heavy",
          count: 100
        },
        template: """
        <div class="bg-gradient-to-b from-slate-300 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-slate-700 text-sm font-medium">Heavy Snowstorm</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :unicode_snowflakes,
        attributes: %{
          id: "snow-unicode",
          count: 25,
          use_unicode: true
        },
        template: """
        <div class="bg-gradient-to-b from-indigo-100 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-indigo-600 text-sm">Unicode Snowflakes ❄️</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :colored_snow,
        attributes: %{
          id: "snow-blue",
          count: 40,
          color: "#60a5fa"
        },
        template: """
        <div class="bg-gradient-to-b from-slate-800 to-slate-900 h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-blue-400 text-sm">Blue Snow on Dark Background</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :golden_snow,
        attributes: %{
          id: "snow-gold",
          count: 35,
          color: "#fbbf24"
        },
        template: """
        <div class="bg-gradient-to-b from-purple-900 to-indigo-900 h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-yellow-400 text-sm">Golden Snowfall</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :small_flakes,
        attributes: %{
          id: "snow-small",
          count: 50,
          size_range: {2, 8}
        },
        template: """
        <div class="bg-gradient-to-b from-gray-100 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-gray-600 text-sm">Small Snowflakes</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :large_flakes,
        attributes: %{
          id: "snow-large",
          count: 20,
          size_range: {15, 30}
        },
        template: """
        <div class="bg-gradient-to-b from-blue-50 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-blue-600 text-sm">Large Snowflakes</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :fast_fall,
        attributes: %{
          id: "snow-fast",
          count: 40,
          animation_duration: {2, 5}
        },
        template: """
        <div class="bg-gradient-to-b from-gray-200 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-gray-700 text-sm">Fast Falling Snow</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :slow_drift,
        attributes: %{
          id: "snow-slow",
          count: 30,
          animation_duration: {15, 30}
        },
        template: """
        <div class="bg-gradient-to-b from-slate-300 to-white h-96 rounded-lg">
          <div class="relative h-full">
            <.variation />
            <div class="absolute bottom-0 left-0 right-0 p-4 text-center">
              <p class="text-slate-600 text-sm">Slow Drifting Snow</p>
            </div>
          </div>
        </div>
        """
      },
      %Variation{
        id: :winter_scene,
        template: """
        <div class="bg-gradient-to-b from-slate-400 via-slate-300 to-white h-96 rounded-lg relative overflow-hidden">
          <!-- Winter trees silhouette -->
          <div class="absolute bottom-0 left-0 right-0">
            <div class="flex justify-around items-end">
              <div class="w-0 h-0 border-l-[30px] border-l-transparent border-b-[80px] border-b-green-800 border-r-[30px] border-r-transparent"></div>
              <div class="w-0 h-0 border-l-[40px] border-l-transparent border-b-[100px] border-b-green-900 border-r-[40px] border-r-transparent"></div>
              <div class="w-0 h-0 border-l-[25px] border-l-transparent border-b-[60px] border-b-green-800 border-r-[25px] border-r-transparent"></div>
              <div class="w-0 h-0 border-l-[35px] border-l-transparent border-b-[90px] border-b-green-900 border-r-[35px] border-r-transparent"></div>
              <div class="w-0 h-0 border-l-[20px] border-l-transparent border-b-[50px] border-b-green-800 border-r-[20px] border-r-transparent"></div>
            </div>
          </div>

          <!-- Snow effect -->
          <div class="relative h-full">
            <.dm_fun_snow id="snow-winter" count="60" size_range={3, 12} color="#ffffff" />
          </div>

          <!-- Ground snow -->
          <div class="absolute bottom-0 left-0 right-0 h-8 bg-white opacity-80"></div>

          <div class="absolute top-4 left-0 right-0 text-center z-10">
            <p class="text-slate-700 text-lg font-semibold">Winter Wonderland</p>
            <p class="text-slate-600 text-sm">A peaceful snow scene</p>
          </div>
        </div>
        """
      },
      %Variation{
        id: :night_snow,
        template: """
        <div class="bg-gradient-to-b from-indigo-950 via-blue-900 to-slate-800 h-96 rounded-lg relative overflow-hidden">
          <!-- Moon -->
          <div class="absolute top-8 right-8 w-12 h-12 bg-yellow-100 rounded-full shadow-lg"></div>

          <!-- Stars -->
          <div class="absolute top-4 left-12 w-1 h-1 bg-white rounded-full"></div>
          <div class="absolute top-12 left-24 w-1 h-1 bg-white rounded-full"></div>
          <div class="absolute top-6 right-24 w-1 h-1 bg-white rounded-full"></div>
          <div class="absolute top-16 right-16 w-1 h-1 bg-white rounded-full"></div>
          <div class="absolute top-20 left-32 w-1 h-1 bg-white rounded-full"></div>

          <!-- Snow effect -->
          <div class="relative h-full">
            <.dm_fun_snow id="snow-night" count="45" size_range={2, 10} color="#e0e7ff" />
          </div>

          <div class="absolute bottom-4 left-0 right-0 text-center">
            <p class="text-blue-200 text-sm">Silent Night Snowfall</p>
          </div>
        </div>
        """
      }
    ]
  end
end