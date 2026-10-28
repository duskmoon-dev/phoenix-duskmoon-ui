defmodule DuskmoonStorybookWeb.DemoLayout do
  @moduledoc "Presentation and navigation data for the shared Phoenix demo layout."

  @doc "Returns the common page shell classes."
  def classes do
    %{
      body: "flex flex-col items-center bg-surface text-on-surface",
      appbar: "storybook-appbar appbar-primary appbar-elevated z-50 w-full",
      main: "container flex flex-row justify-start items-start relative",
      content: "flex flex-col flex-auto min-w-0 w-full",
      sidebar: "sticky top-16 h-[calc(100dvh-4rem)] bg-base-300/30",
      footer: "bg-primary text-primary-content"
    }
  end

  @doc "Returns the ordered top-level demo navigation."
  def navigation do
    [
      %{label: "Components", to: "/components"},
      %{label: "Art Components", to: "/art-component"},
      %{label: "Hologram", to: "/hologram"},
      %{label: "Storybook", to: "/storybook"}
    ]
  end

  @doc "Returns the sidebar configuration consumed by the shared dm_left_menu."
  def sidebar(:components) do
    %{
      id: "components-sidebar",
      groups: DuskmoonStorybookWeb.ComponentNavigation.groups(),
      brand: %{label: "Components", icon: "view-grid"},
      label: "Components navigation",
      storage_key: "duskmoon:storybook:components-sidebar-collapsed"
    }
  end

  def sidebar(:hologram) do
    %{
      id: "hologram-sidebar",
      groups: [%{id: "demos", label: "Demos", items: hologram_demos()}],
      brand: %{label: "Hologram", icon: "view-grid"},
      label: "Hologram demos",
      storage_key: "duskmoon:storybook:hologram-sidebar-collapsed"
    }
  end

  @doc "Returns the Hologram demos and their isolated runtime documents."
  def hologram_demos do
    [
      %{
        id: "overview",
        label: "All Hologram demos",
        to: "/hologram",
        source: "/hologram/demos",
        icon: "view-grid"
      },
      %{
        id: "playground",
        label: "Playground",
        to: "/hologram/playground",
        source: "/hologram/demos/playground",
        icon: "button-pointer"
      },
      %{
        id: "tasks",
        label: "Task list",
        to: "/hologram/tasks",
        source: "/hologram/demos/tasks",
        icon: "format-list-checks"
      },
      %{
        id: "preferences",
        label: "Profile preview",
        to: "/hologram/preferences",
        source: "/hologram/demos/preferences",
        icon: "account-cog-outline"
      }
    ]
  end

  @doc "Returns the shared footer sections and links."
  def footer_sections do
    [
      %{
        title: "Web Sites",
        links: [
          %{label: "Github Repos", href: "https://github.com/duskmoon-dev"},
          %{label: "Blog", href: "https://gsmlg.org/blogs"},
          %{label: "Tools", href: "https://gsmlg.org/tools"}
        ]
      },
      %{
        title: "Other Libraries",
        links: [
          %{label: "Yew Duskmoon UI", href: "https://gsmlg-dev.github.io/yew-duskmoon-ui/"},
          %{label: "Web Component", href: "https://gsmlg-dev.github.io/lit"},
          %{label: "React Component", href: "https://gsmlg-dev.github.io/react"},
          %{label: "3D Component", href: "https://gsmlg-dev.github.io/three-fiber"}
        ]
      }
    ]
  end
end
