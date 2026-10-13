defmodule DuskmoonStorybookWeb.PageController do
  use DuskmoonStorybookWeb, :controller

  @component_catalog [
    {"Action", "Button", "/components/action/button", "dm_btn"},
    {"Action", "Link", "/components/action/link", "dm_link"},
    {"Action", "Dropdown", "/components/action/dropdown", "dm_dropdown"},
    {"Action", "Menu", "/components/action/menu", "dm_menu"},
    {"Action", "Toggle", "/components/action/toggle", "dm_toggle_group"},
    {"Data Display", "Accordion", "/components/data-display/accordion", "dm_accordion"},
    {"Data Display", "Avatar", "/components/data-display/avatar", "dm_avatar"},
    {"Data Display", "Badge", "/components/data-display/badge", "dm_badge"},
    {"Data Display", "Card", "/components/data-display/card", "dm_card"},
    {"Data Display", "Chat", "/components/data-display/chat", "dm_chat"},
    {"Data Display", "React Chat", "/components/data-display/react-chat", "dm_react_chat"},
    {"Data Display", "Chip", "/components/data-display/chip", "dm_chip"},
    {"Data Display", "Datetime", "/components/data-display/datetime", "dm_datetime"},
    {"Data Display", "Flash", "/components/data-display/flash", "dm_flash"},
    {"Data Display", "Markdown", "/components/data-display/markdown", "dm_markdown"},
    {"Data Display", "Markdown Body", "/components/data-display/markdown-body",
     "dm_markdown_body"},
    {"Data Display", "Pagination", "/components/data-display/pagination", "dm_pagination"},
    {"Data Display", "Progress", "/components/data-display/progress", "dm_progress"},
    {"Data Display", "Skeleton", "/components/data-display/skeleton", "dm_skeleton"},
    {"Data Display", "Stat", "/components/data-display/stat", "dm_stat"},
    {"Data Display", "Table", "/components/data-display/table", "dm_table"},
    {"Data Display", "Timeline", "/components/data-display/timeline", "dm_timeline"},
    {"Data Display", "Tooltip", "/components/data-display/tooltip", "dm_tooltip"},
    {"Data Display", "Popover", "/components/data-display/popover", "dm_popover"},
    {"Data Display", "List", "/components/data-display/list", "dm_list"},
    {"Data Display", "Collapse", "/components/data-display/collapse", "dm_collapse"},
    {"Data Entry", "Autocomplete", "/components/data-entry/autocomplete", "dm_autocomplete"},
    {"Data Entry", "Checkbox", "/components/data-entry/checkbox", "dm_checkbox"},
    {"Data Entry", "Compact Input", "/components/data-entry/compact-input", "dm_compact_input"},
    {"Data Entry", "File Upload", "/components/data-entry/file-upload", "dm_file_upload"},
    {"Data Entry", "Form", "/components/data-entry/form", "dm_form"},
    {"Data Entry", "React Form", "/components/data-entry/react-form", "dm_react_form"},
    {"Data Entry", "Input", "/components/data-entry/input", "dm_input"},
    {"Data Entry", "OTP Input", "/components/data-entry/otp-input", "dm_otp_input"},
    {"Data Entry", "Rating", "/components/data-entry/rating", "dm_rating"},
    {"Data Entry", "Radio", "/components/data-entry/radio", "dm_radio"},
    {"Data Entry", "Segment Control", "/components/data-entry/segment-control",
     "dm_segment_control"},
    {"Data Entry", "Select", "/components/data-entry/select", "dm_select"},
    {"Data Entry", "Slider", "/components/data-entry/slider", "dm_slider"},
    {"Data Entry", "Switch", "/components/data-entry/switch", "dm_switch"},
    {"Data Entry", "Textarea", "/components/data-entry/textarea", "dm_textarea"},
    {"Data Entry", "Time Input", "/components/data-entry/time-input", "dm_time_input"},
    {"Data Entry", "PIN Input", "/components/data-entry/pin-input", "dm_pin_input"},
    {"Data Entry", "Multi Select", "/components/data-entry/multi-select", "dm_multi_select"},
    {"Data Entry", "Tree Select", "/components/data-entry/tree-select", "dm_tree_select"},
    {"Data Entry", "Cascader", "/components/data-entry/cascader", "dm_cascader"},
    {"Data Entry", "Markdown Input", "/components/data-entry/markdown-input",
     "dm_markdown_input"},
    {"Data Entry", "Code Engine", "/components/data-entry/code-engine", "dm_code_engine"},
    {"Feedback", "Dialog", "/components/feedback/dialog", "dm_modal"},
    {"Feedback", "Loading", "/components/feedback/loading", "dm_loading_spinner"},
    {"Feedback", "Toast", "/components/feedback/toast", "dm_toast"},
    {"Feedback", "Snackbar", "/components/feedback/snackbar", "dm_snackbar"},
    {"Navigation", "Actionbar", "/components/navigation/actionbar", "dm_actionbar"},
    {"Navigation", "Appbar", "/components/navigation/appbar", "dm_appbar"},
    {"Navigation", "Bottom Nav", "/components/navigation/bottom-nav", "dm_bottom_nav"},
    {"Navigation", "Breadcrumb", "/components/navigation/breadcrumb", "dm_breadcrumb"},
    {"Navigation", "Left Menu", "/components/navigation/left-menu", "dm_left_menu"},
    {"Navigation", "Navbar", "/components/navigation/navbar", "dm_navbar"},
    {"Navigation", "Page Footer", "/components/navigation/page-footer", "dm_page_footer"},
    {"Navigation", "Page Header", "/components/navigation/page-header", "dm_page_header"},
    {"Navigation", "Stepper", "/components/navigation/stepper", "dm_stepper"},
    {"Navigation", "Tab", "/components/navigation/tab", "dm_tab"},
    {"Layout", "Bottom Sheet", "/components/layout/bottom-sheet", "dm_bottom_sheet"},
    {"Layout", "Divider", "/components/layout/divider", "dm_divider"},
    {"Layout", "Drawer", "/components/layout/drawer", "dm_drawer"},
    {"Layout", "Theme Switcher", "/components/layout/theme-switcher", "dm_theme_switcher"},
    {"Icon", "Icons", "/components/icon/icons", "dm_mdi / dm_bsi"}
  ]

  def page(conn, _params) do
    render(conn, :page, layout: false)
  end

  def components(conn, _params) do
    catalog =
      Enum.map(@component_catalog, fn {category, title, path, function} ->
        %{
          category: category,
          title: title,
          path: path,
          function: function,
          description: description(function)
        }
      end)

    render(conn, :components, catalog: catalog, active_menu: "components-index")
  end

  defp description("dm_react_chat"),
    do: "Streaming transcript, Markdown, tool calls, retries, and batched event updates."

  defp description("dm_react_form"),
    do: "Nested typed JSON form with React fields, native controls, validation, and reset events."

  defp description(function), do: "Interactive UI demo for #{function}."
end
