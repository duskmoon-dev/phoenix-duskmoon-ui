[
  %{
    kind: :folder,
    name: "Action",
    path: "/action",
    entries: [
      %{
        kind: :story,
        name: "Button",
        path: "/action/button",
        module: Storybook.Action.Button
      },
      %{
        kind: :story,
        name: "Link",
        path: "/action/link",
        module: Storybook.Action.Link
      },
      %{
        kind: :story,
        name: "Dropdown",
        path: "/action/dropdown",
        module: Storybook.Action.Dropdown
      }
    ]
  },
  %{
    kind: :folder,
    name: "Data Display",
    path: "/data_display",
    entries: [
      %{
        kind: :story,
        name: "Accordion",
        path: "/data_display/accordion",
        module: Storybook.DataDisplay.Accordion
      },
      %{
        kind: :story,
        name: "Avatar",
        path: "/data_display/avatar",
        module: Storybook.DataDisplay.Avatar
      },
      %{
        kind: :story,
        name: "Badge",
        path: "/data_display/badge",
        module: Storybook.DataDisplay.Badge
      },
      %{
        kind: :story,
        name: "Card",
        path: "/data_display/card",
        module: Storybook.DataDisplay.Card
      },
      %{
        kind: :story,
        name: "Flash",
        path: "/data_display/flash",
        module: Storybook.DataDisplay.Flash
      },
      %{
        kind: :story,
        name: "Markdown",
        path: "/data_display/markdown",
        module: Storybook.DataDisplay.Markdown
      },
      %{
        kind: :story,
        name: "Pagination",
        path: "/data_display/pagination",
        module: Storybook.DataDisplay.Pagination
      },
      %{
        kind: :story,
        name: "Pagination Thin",
        path: "/data_display/pagination_thin",
        module: Storybook.DataDisplay.PaginationThin
      },
      %{
        kind: :story,
        name: "Progress",
        path: "/data_display/progress",
        module: Storybook.DataDisplay.Progress
      },
      %{
        kind: :story,
        name: "Skeleton",
        path: "/data_display/skeleton",
        module: Storybook.DataDisplay.Skeleton
      },
      %{
        kind: :story,
        name: "Table",
        path: "/data_display/table",
        module: Storybook.DataDisplay.Table
      },
      %{
        kind: :story,
        name: "Tooltip",
        path: "/data_display/tooltip",
        module: Storybook.DataDisplay.Tooltip
      }
    ]
  },
  %{
    kind: :folder,
    name: "Data Entry",
    path: "/data_entry",
    entries: [
      %{
        kind: :story,
        name: "Form",
        path: "/data_entry/form",
        module: Storybook.DataEntry.Form
      },
      %{
        kind: :story,
        name: "Input",
        path: "/data_entry/input",
        module: Storybook.DataEntry.Input
      },
      %{
        kind: :story,
        name: "Compact Input",
        path: "/data_entry/compact_input",
        module: Storybook.DataEntry.CompactInput
      },
      %{
        kind: :story,
        name: "Checkbox",
        path: "/data_entry/checkbox",
        module: Storybook.DataEntry.Checkbox
      },
      %{
        kind: :story,
        name: "Radio",
        path: "/data_entry/radio",
        module: Storybook.DataEntry.Radio
      },
      %{
        kind: :story,
        name: "Select",
        path: "/data_entry/select",
        module: Storybook.DataEntry.Select
      },
      %{
        kind: :story,
        name: "Slider",
        path: "/data_entry/slider",
        module: Storybook.DataEntry.Slider
      },
      %{
        kind: :story,
        name: "Switch",
        path: "/data_entry/switch",
        module: Storybook.DataEntry.Switch
      },
      %{
        kind: :story,
        name: "Textarea",
        path: "/data_entry/textarea",
        module: Storybook.DataEntry.Textarea
      }
    ]
  },
  %{
    kind: :folder,
    name: "Feedback",
    path: "/feedback",
    entries: [
      %{
        kind: :story,
        name: "Modal / Dialog",
        path: "/feedback/modal",
        module: Storybook.Feedback.Modal
      },
      %{
        kind: :story,
        name: "Loading",
        path: "/feedback/loading",
        module: Storybook.Feedback.Loading
      }
    ]
  },
  %{
    kind: :folder,
    name: "Navigation",
    path: "/navigation",
    entries: [
      %{
        kind: :story,
        name: "Appbar",
        path: "/navigation/appbar",
        module: Storybook.Navigation.Appbar
      },
      %{
        kind: :story,
        name: "Action Bar",
        path: "/navigation/actionbar",
        module: Storybook.Navigation.Actionbar
      },
      %{
        kind: :story,
        name: "Breadcrumb",
        path: "/navigation/breadcrumb",
        module: Storybook.Navigation.Breadcrumb
      },
      %{
        kind: :story,
        name: "Left Menu",
        path: "/navigation/left_menu",
        module: Storybook.Navigation.LeftMenu
      },
      %{
        kind: :story,
        name: "Left Menu Group",
        path: "/navigation/left_menu_group",
        module: Storybook.Navigation.LeftMenuGroup
      },
      %{
        kind: :story,
        name: "Navbar",
        path: "/navigation/navbar",
        module: Storybook.Navigation.Navbar
      },
      %{
        kind: :story,
        name: "Page Header",
        path: "/navigation/page_header",
        module: Storybook.Navigation.PageHeader
      },
      %{
        kind: :story,
        name: "Page Footer",
        path: "/navigation/page_footer",
        module: Storybook.Navigation.PageFooter
      },
      %{
        kind: :story,
        name: "Steps",
        path: "/navigation/steps",
        module: Storybook.Navigation.Steps
      },
      %{
        kind: :story,
        name: "Tab",
        path: "/navigation/tab",
        module: Storybook.Navigation.Tab
      }
    ]
  },
  %{
    kind: :folder,
    name: "Layout",
    path: "/layout",
    entries: [
      %{
        kind: :story,
        name: "Divider",
        path: "/layout/divider",
        module: Storybook.Layout.Divider
      },
      %{
        kind: :story,
        name: "Drawer",
        path: "/layout/drawer",
        module: Storybook.Layout.Drawer
      },
      %{
        kind: :story,
        name: "Theme Switcher",
        path: "/layout/theme_switcher",
        module: Storybook.Layout.ThemeSwitcher
      }
    ]
  },
  %{
    kind: :folder,
    name: "Icon",
    path: "/icon",
    entries: [
      %{
        kind: :story,
        name: "Icons",
        path: "/icon/icons",
        module: Storybook.Icon.Icons
      }
    ]
  },
  %{
    kind: :folder,
    name: "Fun",
    path: "/fun",
    entries: [
      %{
        kind: :story,
        name: "Button Noise",
        path: "/fun/button_noise",
        module: Storybook.Fun.ButtonNoise
      },
      %{
        kind: :story,
        name: "Eclipse",
        path: "/fun/eclipse",
        module: Storybook.Fun.Eclipse
      },
      %{
        kind: :story,
        name: "Plasma Ball",
        path: "/fun/plasma_ball",
        module: Storybook.Fun.PlasmaBall
      },
      %{
        kind: :story,
        name: "Signature",
        path: "/fun/signature",
        module: Storybook.Fun.Signature
      },
      %{
        kind: :story,
        name: "Snow",
        path: "/fun/snow",
        module: Storybook.Fun.Snow
      },
      %{
        kind: :story,
        name: "Spotlight Search",
        path: "/fun/spotlight_search",
        module: Storybook.Fun.SpotlightSearch
      }
    ]
  }
]
