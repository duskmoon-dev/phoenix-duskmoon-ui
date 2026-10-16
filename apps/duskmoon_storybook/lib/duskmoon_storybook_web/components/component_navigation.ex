defmodule DuskmoonStorybookWeb.ComponentNavigation do
  @moduledoc """
  Shared navigation data for the component documentation pages.
  """

  @groups [
    {"overview", "Overview",
     [
       {"index", "All Components", "view-grid"}
     ]},
    {"action", "Action",
     [
       {"button", "Button", "button-pointer"},
       {"link", "Link", "link"},
       {"dropdown", "Dropdown", "menu-down"},
       {"menu", "Menu", "menu"},
       {"toggle", "Toggle", "toggle-switch-off-outline"}
     ]},
    {"data-display", "Data Display",
     [
       {"accordion", "Accordion", "chevron-down"},
       {"avatar", "Avatar", "account-circle"},
       {"badge", "Badge", "label-outline"},
       {"card", "Card", "card-text-outline"},
       {"chat", "Chat", "chat-outline"},
       {"react-chat", "React Chat", "message-processing-outline"},
       {"chip", "Chip", "label"},
       {"datetime", "Datetime", "calendar-clock"},
       {"flash", "Flash", "flash"},
       {"markdown", "Markdown", "language-markdown-outline"},
       {"markdown-body", "Markdown Body", "language-markdown-outline"},
       {"pagination", "Pagination", "book-open-page-variant-outline"},
       {"progress", "Progress", "progress-check"},
       {"skeleton", "Skeleton", "rectangle-outline"},
       {"stat", "Stat", "chart-box-outline"},
       {"table", "Table", "table"},
       {"timeline", "Timeline", "timeline-outline"},
       {"tooltip", "Tooltip", "tooltip-text"},
       {"popover", "Popover", "tooltip-text-outline"},
       {"list", "List", "format-list-bulleted"},
       {"collapse", "Collapse", "arrow-collapse-vertical"}
     ]},
    {"data-entry", "Data Entry",
     [
       {"autocomplete", "Autocomplete", "text-search"},
       {"checkbox", "Checkbox", "checkbox-marked"},
       {"compact-input", "Compact Input", "form-textbox"},
       {"file-upload", "File Upload", "file-upload"},
       {"form", "Form", "format-list-checks"},
       {"react-form", "React Form", "form-textbox-password"},
       {"input", "Input", "form-textbox"},
       {"markdown-input", "Markdown Input", "language-markdown-outline"},
       {"code-engine", "Code Engine", "code-braces"},
       {"otp-input", "OTP Input", "numeric"},
       {"pin-input", "Pin Input", "form-textbox-password"},
       {"multi-select", "Multi Select", "format-list-checks"},
       {"tree-select", "Tree Select", "file-tree"},
       {"cascader", "Cascader", "view-sequential"},
       {"rating", "Rating", "star"},
       {"radio", "Radio", "radiobox-marked"},
       {"segment-control", "Segment Control", "toggle-switch-outline"},
       {"select", "Select", "form-dropdown"},
       {"slider", "Slider", "tune-vertical"},
       {"switch", "Switch", "toggle-switch"},
       {"textarea", "Textarea", "text-box"},
       {"time-input", "Time Input", "clock-outline"}
     ]},
    {"feedback", "Feedback",
     [
       {"dialog", "Dialog", "message-outline"},
       {"loading", "Loading", "loading"},
       {"toast", "Toast", "message-alert"},
       {"snackbar", "Snackbar", "message-text"}
     ]},
    {"navigation", "Navigation",
     [
       {"actionbar", "Actionbar", "tools"},
       {"appbar", "Appbar", "dock-top"},
       {"bottom-nav", "Bottom Nav", "dock-bottom"},
       {"breadcrumb", "Breadcrumb", "chevron-triple-right"},
       {"left-menu", "Left Menu", "page-layout-sidebar-left"},
       {"navbar", "Navbar", "page-layout-header"},
       {"page-footer", "Page Footer", "page-layout-footer"},
       {"page-header", "Page Header", "page-layout-header"},
       {"tab", "Tab", "tab-minus"},
       {"stepper", "Stepper", "progress-check"}
     ]},
    {"layout", "Layout",
     [
       {"bottom-sheet", "Bottom Sheet", "dock-bottom"},
       {"divider", "Divider", "minus"},
       {"drawer", "Drawer", "dock-left"},
       {"theme-switcher", "Theme Switcher", "theme-light-dark"}
     ]},
    {"icon", "Icon",
     [
       {"icons", "Icons", "shape"}
     ]}
  ]

  @doc "Returns the ordered component menu groups and their navigation items."
  def groups do
    for {group_id, group_label, items} <- @groups do
      %{
        id: group_id,
        label: group_label,
        items:
          for {slug, label, icon} <- items do
            {id, to} =
              case {group_id, slug} do
                {"overview", "index"} -> {"components-index", "/components"}
                _ -> {"#{group_id}-#{slug}", "/components/#{group_id}/#{slug}"}
              end

            %{
              id: id,
              label: label,
              to: to,
              icon: icon,
              rest: %{"id" => "components-link-#{id}"}
            }
          end
      }
    end
  end
end
