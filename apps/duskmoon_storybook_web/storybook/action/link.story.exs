defmodule Storybook.Action.Link do
  use PhoenixStorybook.Story, :component

  def function, do: &PhoenixDuskmoon.Component.Action.Link.dm_link/1
  def description, do: "Recreate Phoenix.Component.link with custom element."

  def variations do
    [
      %Variation{
        id: :default,
        description: "Standard href link",
        attributes: %{
          href: "/"
        },
        slots: ["Back to home"]
      },
      %VariationGroup{
        id: :colors,
        description: "Link color variants via CSS utility classes",
        variations:
          for color <- ~w(primary secondary accent info success warning error) do
            %Variation{
              id: String.to_atom(color),
              attributes: %{href: "/", class: "link-#{color}"},
              slots: ["#{String.capitalize(color)} link"]
            }
          end
      },
      %Variation{
        id: :navigate,
        description: "LiveView client-side navigation (no full page reload)",
        attributes: %{
          navigate: "/storybook"
        },
        slots: ["Navigate to storybook"]
      },
      %Variation{
        id: :patch,
        description: "LiveView patch (same live view, updated params)",
        attributes: %{
          patch: "/storybook/action/link"
        },
        slots: ["Patch current page"]
      },
      %Variation{
        id: :replace,
        description: "Replace current history entry instead of pushing",
        attributes: %{
          href: "/",
          replace: true
        },
        slots: ["Replace navigation"]
      },
      %Variation{
        id: :method_delete,
        description: "Non-GET method link (e.g., DELETE for logout)",
        attributes: %{
          href: "#",
          method: "delete"
        },
        slots: ["Delete action"]
      },
      %Variation{
        id: :external,
        description: "External link with target blank",
        attributes: %{
          href: "https://github.com/duskmoon-dev/phoenix-duskmoon-ui",
          target: "_blank",
          rel: "noopener noreferrer"
        },
        slots: ["GitHub repository"]
      }
    ]
  end
end
