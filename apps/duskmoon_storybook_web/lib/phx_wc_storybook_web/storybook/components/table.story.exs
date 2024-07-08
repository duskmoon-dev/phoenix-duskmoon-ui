defmodule DuskmoonStorybookWeb.Storybook.Components.Table do
  # :live_component or :page are also available
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Table.dm_table/1
  def description, do: "A table element."

  def variations do
    [
      %Variation{
        id: :default,
        attributes: %{
          class: "w-full",
          border: true,
          data: table_data()
        },
        slots: [
          """
          <:caption class="text-2xl text-slate-700 py-4">Skywalker House</:caption>
          """,
          """
          <:col :let={r} label="Name" label_class="text-sky-600" class="align-top">
            <%= r.name %>
          </:col>
          <:col :let={r} label="Portrayal" class="align-top">
            <%= r.portrayal %>
          </:col>
          <:col :let={r} label="" class="align-top">
            <button class="btn" phx-click={JS.toggle_class("hidden", to: "tr:has(#description-#\{Map.get(r, :id)\})")}>
              Expand
            </button>
          </:col>
          <:expand :let={r} class={["align-top", "hidden"]}>
            <pre id={"description-#\{Map.get(r, :id)\}"} class="p-4 whitespace-break-spaces">
              <%= r.description %>
            </pre>
          </:expand>
          """
        ]
      }
    ]
  end

  defp table_data() do
    [
      %{
        id: "r1",
        name: "Shmi Skywalker",
        portrayal: """
        Pernilla August (Episodes I-II)
        Voice: Pernilla August (The Clone Wars)
        """,
        description: """
        Anakin Skywalker's mother, and Luke and Leia's paternal grandmother.
        Qui-Gon Jinn attempts to bargain for her freedom from slavery but fails.
        Shmi encourages Anakin to leave Tatooine with Qui-Gon to seek his destiny,
        but Anakin finds it hard to leave without her.
        A widowed moisture farmer named Cliegg Lars later falls in love with Shmi,
        and after he purchases her freedom from Watto, they marry.
        Shmi dies in Anakin's arms after being kidnapped and tortured by Tusken Raiders in Attack of the Clones.
        """
      },
      %{
        id: "r2",
        name: "Luke Skywalker",
        portrayal: """
        Mark Hamill (Episodes IV-IX, The Mandalorian, The Book of Boba Fett), Aidan Barton (Episode III), Grant Feely (Obi-Wan Kenobi)
        Body Doubles: Lukaz Leong (Episode IX), Max Lloyd-Jones (The Mandalorian), Graham Hamilton (The Book of Boba Fett)

        Voice: Mark Hamill (Forces of Destiny)
        """,
        description: """
        Former moisture farmer and Jedi Knight whose coming of age and rise as a Jedi are portrayed in the original Star Wars trilogy. He is the son of Anakin Skywalker and Padmé Amidala, Leia Organa's twin brother, and Ben Solo's uncle.[18] After his birth, he was adopted by the Lars family on Tatooine to keep him safe and hidden from the Galactic Empire. After the Empire's defeat, Luke becomes a Jedi Master and attempts to rebuild the Jedi Order, starting with briefly training Grogu,[19] but goes into self-exile on the planet Ahch-To after Ben falls to the dark side, becomes Kylo Ren, and takes part in the murder of his other students. He later reluctantly trains Rey, and dies helping the Resistance escape from the First Order. His Force spirit eventually helps Rey defeat a resurrected Palpatine to end the Sith once and for all, and later gives her his blessing to adopt the Skywalker surname and continue his family's legacy.
        """
      }
    ]
  end
end
