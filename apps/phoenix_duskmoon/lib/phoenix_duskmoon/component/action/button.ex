defmodule PhoenixDuskmoon.Component.Action.Button do
  @moduledoc """
  Button component using el-dm-button custom element.

  Provides three button modes:
  - Standard button with variants and sizes
  - Button with confirmation popover (Invoker Commands API)
  - Noise effect button (decorative)

  When `command` / `commandfor` are set, renders a native `<button>` so the
  Invoker Commands API works (custom element hosts are not valid invokers).

  ## Examples

      <.dm_btn>Click me</.dm_btn>

      <.dm_btn variant="primary" size="lg">Primary</.dm_btn>

      <.dm_btn variant="error" confirm="Are you sure?">Delete</.dm_btn>

      <.dm_btn command="show-modal" commandfor="my-modal">Open</.dm_btn>

      <.dm_btn noise content="SUBMIT">Submit</.dm_btn>

  """
  use Phoenix.Component

  # The el-dm-button custom element only supports: primary, secondary, tertiary,
  # ghost, outline. For other variants (info, success, warning, error, accent, link)
  # we map to a supported variant and override colors via inline CSS custom properties.
  @variant_map %{
    "accent" => "tertiary",
    "link" => "ghost"
  }
  @color_override_variants ~w(info success warning error)
  @submit_onclick [
                    "if (!this.hasAttribute('disabled')) {",
                    "const formId = this.getAttribute('form');",
                    "const form = formId ? document.getElementById(formId) : this.closest('form');",
                    "if (form) {",
                    "const submitter = document.createElement('button');",
                    "submitter.type = 'submit';",
                    "submitter.hidden = true;",
                    "if (this.hasAttribute('name')) submitter.name = this.getAttribute('name');",
                    "if (this.hasAttribute('value')) submitter.value = this.getAttribute('value');",
                    "form.appendChild(submitter);",
                    "form.requestSubmit(submitter);",
                    "submitter.remove();",
                    "}",
                    "}"
                  ]
                  |> Enum.join(" ")

  defp map_variant(nil), do: nil
  defp map_variant(v) when is_map_key(@variant_map, v), do: @variant_map[v]
  defp map_variant(v) when v in @color_override_variants, do: "primary"
  defp map_variant(v), do: v

  defp variant_style(v) when v in @color_override_variants do
    "--color-primary: var(--color-#{v}); --color-primary-content: var(--color-#{v}-content);"
  end

  defp variant_style(_), do: nil

  @doc """
  Generates a button.

  ## Examples

      <.dm_btn id="show-btn">Show</.dm_btn>

      <.dm_btn variant="primary" size="lg">Primary Button</.dm_btn>

      <.dm_btn navigate="/dashboard" variant="ghost">Dashboard</.dm_btn>

      <.dm_btn confirm="Are you sure?" confirm_title="Confirm Action">Delete</.dm_btn>

  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:class, :any, default: nil, doc: "Additional CSS classes")

  attr(:variant, :string,
    default: nil,
    values: [
      nil,
      "primary",
      "secondary",
      "accent",
      "info",
      "success",
      "warning",
      "error",
      "ghost",
      "link",
      "outline"
    ],
    doc: "Button color variant"
  )

  attr(:size, :string,
    default: nil,
    values: [nil, "xs", "sm", "md", "lg"],
    doc: "Button size"
  )

  attr(:shape, :string,
    default: nil,
    values: [nil, "square", "circle"],
    doc: "Button shape"
  )

  attr(:loading, :boolean, default: false, doc: "Show loading state")
  attr(:disabled, :boolean, default: false, doc: "Disable the button")

  attr(:navigate, :string,
    default: nil,
    doc: "Navigates from a LiveView to a new LiveView"
  )

  attr(:patch, :string,
    default: nil,
    doc: "Patches the current LiveView"
  )

  attr(:href, :any,
    default: nil,
    doc: "Uses traditional browser navigation to the new location"
  )

  attr(:replace, :boolean,
    default: false,
    doc: "Replace browser history when using navigate or patch"
  )

  # Noise button attributes
  attr(:noise, :boolean, default: false, doc: "Use noise effect button style")
  attr(:content, :string, default: "", doc: "Content text for noise button")

  # Confirm popover attributes
  attr(:confirm, :string, default: "", doc: "Confirmation message (enables confirm popover)")
  attr(:confirm_title, :string, default: "", doc: "Title for confirmation popover")
  attr(:confirm_text, :string, default: "Yes", doc: "Text for the confirm button in popover")
  attr(:cancel_text, :string, default: "Cancel", doc: "Text for the cancel button in popover")
  attr(:confirm_class, :any, default: nil, doc: "CSS class for confirm button")
  attr(:cancel_class, :any, default: nil, doc: "CSS class for cancel button")
  attr(:show_cancel_action, :boolean, default: true, doc: "Show cancel button in popover")

  attr(:confirm_label, :string,
    default: "Confirmation",
    doc: "Accessible fallback label for confirm popover when no title is set (i18n)"
  )

  attr(:rest, :global,
    include:
      ~w(phx-click phx-target phx-value-id phx-disable-with name value type form command commandfor),
    doc: "Additional HTML attributes"
  )

  slot(:inner_block,
    required: true,
    doc: "Button content"
  )

  slot(:prefix,
    required: false,
    doc: "Content before button text (e.g., icon)"
  )

  slot(:suffix,
    required: false,
    doc: "Content after button text (e.g., icon)"
  )

  slot(:confirm_action,
    required: false,
    doc: "Custom confirm action button content"
  )

  @spec dm_btn(map()) :: Phoenix.LiveView.Rendered.t()
  def dm_btn(%{confirm: confirm} = assigns) when confirm != "" do
    id = assigns.id || "btn-#{System.unique_integer([:positive])}"
    popover_id = "confirm-popover-#{id}"
    anchor_name = "--anchor-#{popover_id}"

    assigns =
      assigns
      |> assign(:id, id)
      |> assign(:popover_id, popover_id)
      |> assign(:anchor_name, anchor_name)
      |> assign(:confirm_rest, Map.put_new(assigns.rest, "type", "button"))
      |> assign_button_style()
      |> then(fn assigns ->
        assigns
        |> assign(:button_class, btn_class_list(assigns))
        |> assign(
          :trigger_style,
          merge_styles(assigns.el_style, "anchor-name: #{anchor_name}")
        )
      end)

    ~H"""
    <button
      type="button"
      id={@id}
      class={@button_class}
      style={@trigger_style}
      command="show-popover"
      commandfor={@popover_id}
      disabled={@disabled || @loading}
      aria-disabled={(@disabled || @loading) && "true"}
      aria-busy={@loading && "true"}
      aria-haspopup="dialog"
      aria-expanded="false"
      aria-controls={@popover_id}
    >
      <span :for={prefix <- @prefix} class="inline-flex items-center">{render_slot(prefix)}</span>
      {render_slot(@inner_block)}
      <span :for={suffix <- @suffix} class="inline-flex items-center">{render_slot(suffix)}</span>
    </button>
    <div
      id={@popover_id}
      popover
      class="popover popover-bottom"
      style={"position-anchor: #{@anchor_name}"}
      role="dialog"
      aria-labelledby={@confirm_title != "" && "#{@popover_id}-title"}
      aria-label={@confirm_title == "" && @confirm_label}
      ontoggle="this.classList.toggle('popover-show', this.matches(':popover-open')); var b=this.previousElementSibling; if(b) b.setAttribute('aria-expanded', this.matches(':popover-open'))"
    >
      <p :if={@confirm_title != ""} id={"#{@popover_id}-title"} class="font-semibold mb-1">
        {@confirm_title}
      </p>
      <p>{@confirm}</p>
      <div class="flex justify-end gap-2 mt-3">
        {render_slot(@confirm_action)}
        <button
          :if={@confirm_action == []}
          type="button"
          class={["btn", "btn-primary", @confirm_class]}
          {@confirm_rest}
        >
          {@confirm_text}
        </button>
        <button
          :if={@show_cancel_action}
          type="button"
          class={["btn", "btn-ghost", @cancel_class]}
          command="hide-popover"
          commandfor={@popover_id}
        >
          {@cancel_text}
        </button>
      </div>
    </div>
    """
  end

  def dm_btn(%{noise: true} = assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> nil end)
      |> assign_new(:inner_block, fn -> [] end)

    ~H"""
    <button
      type="button"
      id={@id}
      class={["btn-noise", @class]}
      data-content={@content}
      aria-label={@content}
      {@rest}
    >
      <span aria-hidden="true"><i :for={_ <- 1..72} /></span>
      <span :if={@inner_block != []} class="sr-only">{render_slot(@inner_block)}</span>
    </button>
    """
  end

  def dm_btn(%{} = assigns) do
    link? =
      is_binary(assigns.navigate) || is_binary(assigns.patch) ||
        (!is_nil(assigns.href) && assigns.href != "#")

    command? = has_command?(assigns.rest)

    assigns =
      assigns
      |> then(fn assigns ->
        cond do
          link? -> assign_button_style(assigns)
          command? -> assign_native_button(assigns)
          true -> assign_button_element(assigns)
        end
      end)
      |> assign(:link?, link?)
      |> assign(:command?, command?)

    ~H"""
    <.button_link :if={@link?} {assigns} />
    <.button_native :if={!@link? && @command?} {assigns} />
    <.button_element :if={!@link? && !@command?} {assigns} />
    """
  end

  defp assign_button_style(assigns) do
    assigns
    |> assign_new(:id, fn -> nil end)
    |> assign(:el_variant, map_variant(assigns.variant))
    |> assign(:el_style, variant_style(assigns.variant))
  end

  defp assign_button_element(assigns) do
    submit_onclick = submit_onclick(assigns.rest)

    assigns
    |> assign(:rest, rest_without_onclick(assigns.rest, submit_onclick))
    |> assign(:submit_onclick, submit_onclick)
    |> assign_button_style()
  end

  defp assign_native_button(assigns) do
    submit_onclick = submit_onclick(assigns.rest)

    assigns
    |> assign(:rest, rest_without_onclick(assigns.rest, submit_onclick))
    |> assign(:submit_onclick, submit_onclick)
    |> assign_button_style()
    |> then(fn assigns ->
      assign(assigns, :button_class, btn_class_list(assigns))
    end)
  end

  defp btn_class_list(assigns) do
    el_variant = Map.get(assigns, :el_variant) || map_variant(Map.get(assigns, :variant))

    [
      "btn",
      "btn-#{el_variant || "primary"}",
      assigns.size && "btn-#{assigns.size}",
      assigns.shape && "btn-#{assigns.shape}",
      assigns.loading && "btn-loading",
      assigns.disabled && "opacity-50",
      assigns.disabled && "cursor-not-allowed",
      assigns.disabled && "pointer-events-none",
      assigns.class
    ]
  end

  defp has_command?(rest) do
    Map.has_key?(rest, "command") || Map.has_key?(rest, :command)
  end

  defp merge_styles(nil, other), do: other
  defp merge_styles("", other), do: other
  defp merge_styles(first, second), do: "#{first}; #{second}"

  attr(:id, :any, default: nil)
  attr(:el_variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:shape, :string, default: nil)
  attr(:loading, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:el_style, :string, default: nil)
  attr(:submit_onclick, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:prefix)
  slot(:suffix)

  defp button_element(assigns) do
    ~H"""
    <el-dm-button
      id={@id}
      variant={@el_variant}
      size={@size}
      shape={@shape}
      loading={@loading}
      disabled={@disabled}
      aria-disabled={@disabled && "true"}
      aria-busy={@loading && "true"}
      class={@class}
      style={@el_style}
      phx-hook={if @rest["phx-click"], do: "WebComponentHook"}
      onclick={@submit_onclick}
      {@rest}
    >
      <span :for={prefix <- @prefix} slot="prefix">{render_slot(prefix)}</span>
      {render_slot(@inner_block)}
      <span :for={suffix <- @suffix} slot="suffix">{render_slot(suffix)}</span>
    </el-dm-button>
    """
  end

  attr(:id, :any, default: nil)
  attr(:button_class, :any, default: nil)
  attr(:el_style, :string, default: nil)
  attr(:loading, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:submit_onclick, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:prefix)
  slot(:suffix)

  defp button_native(assigns) do
    assigns =
      assign(assigns, :rest, Map.put_new(assigns.rest, "type", "button"))

    ~H"""
    <button
      id={@id}
      class={@button_class}
      style={@el_style}
      disabled={@disabled || @loading}
      aria-disabled={(@disabled || @loading) && "true"}
      aria-busy={@loading && "true"}
      onclick={@submit_onclick}
      {@rest}
    >
      <span :for={prefix <- @prefix} class="inline-flex items-center">{render_slot(prefix)}</span>
      {render_slot(@inner_block)}
      <span :for={suffix <- @suffix} class="inline-flex items-center">{render_slot(suffix)}</span>
    </button>
    """
  end

  attr(:navigate, :string, default: nil)
  attr(:patch, :string, default: nil)
  attr(:href, :any, default: nil)
  attr(:replace, :boolean, default: false)
  attr(:id, :any, default: nil)
  attr(:el_variant, :string, default: nil)
  attr(:size, :string, default: nil)
  attr(:shape, :string, default: nil)
  attr(:loading, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:class, :any, default: nil)
  attr(:el_style, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)
  slot(:prefix)
  slot(:suffix)

  defp button_link(assigns) do
    assigns =
      assigns
      |> assign(:button_class, btn_class_list(assigns))
      |> assign(:inert_rest, inert_link_rest(assigns.rest))

    ~H"""
    <.link
      :if={!@disabled && !@loading}
      navigate={@navigate}
      patch={@patch}
      href={@href}
      replace={@replace}
      id={@id}
      class={@button_class}
      style={@el_style}
      {@rest}
    >
      <span :for={prefix <- @prefix} class="inline-flex items-center">{render_slot(prefix)}</span>
      {render_slot(@inner_block)}
      <span :for={suffix <- @suffix} class="inline-flex items-center">{render_slot(suffix)}</span>
    </.link>
    <a
      :if={@disabled || @loading}
      id={@id}
      role="link"
      class={@button_class}
      style={@el_style}
      aria-disabled="true"
      aria-busy={@loading && "true"}
      {@inert_rest}
    >
      <span :for={prefix <- @prefix} class="inline-flex items-center">{render_slot(prefix)}</span>
      {render_slot(@inner_block)}
      <span :for={suffix <- @suffix} class="inline-flex items-center">{render_slot(suffix)}</span>
    </a>
    """
  end

  defp inert_link_rest(rest) do
    Map.reject(rest, fn {key, _value} ->
      key = to_string(key)
      key == "tabindex" || String.starts_with?(key, ["on", "phx-"])
    end)
  end

  # WORKAROUND(upstream): duskmoon-dev/duskmoon-elements#66
  defp submit_onclick(rest) do
    if rest_attr(rest, "type") == "submit" do
      merge_onclick(rest_attr(rest, "onclick"), @submit_onclick)
    end
  end

  defp rest_attr(rest, "type"), do: Map.get(rest, "type") || Map.get(rest, :type)
  defp rest_attr(rest, "onclick"), do: Map.get(rest, "onclick") || Map.get(rest, :onclick)

  defp merge_onclick(nil, submit_onclick), do: submit_onclick
  defp merge_onclick("", submit_onclick), do: submit_onclick
  defp merge_onclick(onclick, submit_onclick), do: "#{onclick}; #{submit_onclick}"

  defp rest_without_onclick(rest, nil), do: rest

  defp rest_without_onclick(rest, _submit_onclick) do
    rest
    |> Map.delete("onclick")
    |> Map.delete(:onclick)
  end
end
