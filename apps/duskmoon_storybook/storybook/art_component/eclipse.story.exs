defmodule Storybook.ArtComponent.Eclipse do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.ArtComponent.Eclipse.dm_art_eclipse/1
  def description, do: "Solar eclipse art using the el-dm-art-eclipse custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Default eclipse",
        attributes: %{
          id: "eclipse-default"
        }
      },
      %Variation{
        id: :with_class,
        description: "Centered eclipse",
        attributes: %{
          id: "eclipse-centered",
          class: "mx-auto"
        },
        template: """
        <div class="flex justify-center bg-black p-8 rounded-lg">
          <.dm_art_eclipse id="eclipse-centered" class="mx-auto" />
        </div>
        """
      }
    ]
  end
end
