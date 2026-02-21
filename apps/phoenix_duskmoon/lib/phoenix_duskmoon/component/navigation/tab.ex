defmodule PhoenixDuskmoon.Component.Navigation.Tab do
  @moduledoc """
  Tab component using el-dm-tabs custom element.

  ## Examples

      <.dm_tab active_tab_index={0}>
        <:tab>Menu1</:tab>
        <:tab>Menu2</:tab>
        <:tab_content>Menu1 Content</:tab_content>
        <:tab_content>Menu2 Content</:tab_content>
      </.dm_tab>

  """
  use Phoenix.Component

  @doc """
  Generates a tabbed interface.

  ## Examples

      <.dm_tab active_tab_index={0}>
        <:tab>Tab 1</:tab>
        <:tab>Tab 2</:tab>
        <:tab_content>Content for Tab 1</:tab_content>
        <:tab_content>Content for Tab 2</:tab_content>
      </.dm_tab>

      <.dm_tab active_tab_name="settings">
        <:tab name="profile">Profile</:tab>
        <:tab name="settings">Settings</:tab>
        <:tab_content name="profile">Profile content</:tab_content>
        <:tab_content name="settings">Settings content</:tab_content>
      </.dm_tab>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")
  attr(:header_class, :any, default: nil, doc: "CSS classes for tab header")

  attr(:orientation, :string,
    default: "horizontal",
    values: ["horizontal", "vertical"],
    doc: "Tab orientation"
  )

  attr(:active_tab_index, :integer,
    default: 0,
    doc: "Index of active tab (when not using named tabs)"
  )

  attr(:active_tab_name, :string,
    default: "",
    doc: "Name of active tab (for named tab matching)"
  )

  attr(:variant, :string,
    default: nil,
    values: [nil, "lifted", "bordered", "boxed"],
    doc: "Tab style variant"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "md", "lg"],
    doc: "Tab size"
  )

  attr(:content_class, :any, default: nil, doc: "CSS classes for tab content")

  attr(:rest, :global)

  slot(:tab,
    required: false,
    doc: "Tab button"
  ) do
    attr(:id, :any, doc: "tab button HTML id")
    attr(:class, :any, doc: "tab button CSS classes")
    attr(:name, :string, doc: "Tab name for matching with tab_content")
    attr(:phx_click, :any, doc: "Phoenix click event")
  end

  slot(:tab_content,
    required: false,
    doc: "Tab content panel"
  ) do
    attr(:id, :any, doc: "tab content panel HTML id")
    attr(:class, :any, doc: "tab content panel CSS classes")
    attr(:name, :string, doc: "Content name for matching with tab")
  end

  def dm_tab(assigns) do
    ~H"""
    <el-dm-tabs
      id={@id}
      orientation={@orientation}
      variant={@variant}
      size={@size}
      active-index={if @active_tab_name == "", do: @active_tab_index, else: nil}
      active-name={if @active_tab_name != "", do: @active_tab_name, else: nil}
      class={@class}
      {@rest}
    >
      <div slot="tabs" class={@header_class} role="tablist" aria-orientation={@orientation}>
        <button
          :for={{tab, i} <- Enum.with_index(@tab)}
          type="button"
          slot="tab"
          id={tab[:id] || (@id && "#{@id}-tab-#{i}")}
          class={tab[:class]}
          role="tab"
          data-tab-name={tab[:name]}
          data-tab-index={i}
          aria-selected={tab_active?(@active_tab_name, @active_tab_index, tab, i)}
          aria-controls={@id && "#{@id}-panel-#{i}"}
          phx-click={tab[:phx_click]}
        >
          {render_slot(tab)}
        </button>
      </div>
      <div
        :for={{tab_content, i} <- Enum.with_index(@tab_content)}
        :if={content_active?(@active_tab_name, @active_tab_index, tab_content, i)}
        slot="panel"
        role="tabpanel"
        id={tab_content[:id] || (@id && "#{@id}-panel-#{i}")}
        class={[@content_class, tab_content[:class]]}
        data-panel-name={tab_content[:name]}
        data-panel-index={i}
        aria-labelledby={@id && "#{@id}-tab-#{i}"}
      >
        {render_slot(tab_content)}
      </div>
    </el-dm-tabs>
    """
  end

  defp tab_active?(active_name, active_index, tab, index) do
    if active_name != "" do
      active_name == (tab[:name] || "")
    else
      active_index == index
    end
  end

  defp content_active?(active_name, active_index, content, index) do
    if active_name != "" do
      active_name == (content[:name] || "")
    else
      active_index == index
    end
  end
end
