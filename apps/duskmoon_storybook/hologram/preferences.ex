defmodule DuskmoonStorybook.Hologram.Preferences do
  @moduledoc "A profile preview with draft and applied settings local to the open page."

  use Hologram.Page

  route("/hologram/demos/preferences")
  layout(DuskmoonStorybook.Hologram.Layout, title: "Profile preview")

  @impl true
  def init(_params, component, _server) do
    reset(component, "Edit the settings to update the preview.")
  end

  @impl true
  def action(:set_name, %{event: %{value: value}}, component) when is_binary(value) do
    put_state(component,
      name: value,
      error: "",
      message: "Preview has unapplied changes."
    )
  end

  def action(:set_mode, %{event: %{value: mode}}, component)
      when mode in ["comfortable", "compact"] do
    put_state(component, mode: mode, message: "Preview has unapplied changes.")
  end

  def action(:set_mode, _params, component), do: component

  def action(:set_notifications, %{event: %{value: value}}, component) when is_boolean(value) do
    put_state(component, notifications: value, message: "Preview has unapplied changes.")
  end

  def action(:apply, _params, component) do
    case String.trim(component.state.name) do
      "" ->
        put_state(component, :error, "Enter a display name before applying the preview.")

      name ->
        settings = %{
          name: name,
          mode: component.state.mode,
          notifications: component.state.notifications
        }

        put_state(component,
          name: name,
          applied: settings,
          error: "",
          message: "Applied to this preview."
        )
    end
  end

  def action(:reset, _params, component), do: reset(component, "Defaults restored.")

  defp reset(component, message) do
    settings = %{name: "Duskmoon explorer", mode: "comfortable", notifications: true}

    put_state(component,
      name: settings.name,
      mode: settings.mode,
      notifications: settings.notifications,
      applied: settings,
      error: "",
      message: message
    )
  end

  @impl true
  def template do
    ~HOLO"""
    <main id="hologram-preferences" class="space-y-6" aria-labelledby="hologram-preferences-title">
      <div class="space-y-2">
        <h1 id="hologram-preferences-title" class="text-2xl font-semibold">Make the preview your own</h1>
        <p class="text-on-surface-variant">Try native controls and see the profile change as you edit.</p>
      </div>

      <div class="grid gap-6 lg:grid-cols-2">
        <section class="card" aria-labelledby="hologram-preferences-settings-title">
          <div class="card-body space-y-6">
            <h3 id="hologram-preferences-settings-title" class="card-title">Preview settings</h3>
            <div class="space-y-2">
              <label for="hologram-preferences-name" class="form-label">Display name</label>
              <input id="hologram-preferences-name" type="text" name="display_name" class="input w-full"
                value={@name} $change="set_name" aria-describedby="hologram-preferences-local-note" />
            </div>
            <div class="space-y-2">
              <label for="hologram-preferences-mode" class="form-label">Display density</label>
              <select id="hologram-preferences-mode" name="density" class="select w-full" $change="set_mode">
                <option value="comfortable" selected={@mode == "comfortable"}>Comfortable</option>
                <option value="compact" selected={@mode == "compact"}>Compact</option>
              </select>
            </div>
            <label for="hologram-preferences-notifications" class="flex items-center gap-3">
              <input id="hologram-preferences-notifications" type="checkbox" class="checkbox checkbox-primary"
                checked={@notifications} $change="set_notifications" />
              Show notification reminders in the preview
            </label>

            {%if @error != ""}
              <p id="hologram-preferences-error" class="text-error" role="alert">{@error}</p>
            {/if}
            <div class="flex flex-wrap gap-3">
              <button id="hologram-preferences-apply" type="button" class="btn btn-primary" $click="apply">Apply to preview</button>
              <button id="hologram-preferences-reset" type="button" class="btn btn-outline" $click="reset">Reset to defaults</button>
            </div>
            <p id="hologram-preferences-message" class="text-sm text-on-surface-variant" role="status">{@message}</p>
          </div>
        </section>

        <section class="card" aria-labelledby="hologram-preferences-preview-title">
          <div class="card-body space-y-6">
            <h3 id="hologram-preferences-preview-title" class="card-title">Live profile preview</h3>
            <div id="hologram-preferences-preview"
              class={if(@mode == "compact", do: "space-y-2 rounded-xl bg-surface-container-high p-4 text-on-surface", else: "space-y-4 rounded-xl bg-surface-container-high p-8 text-on-surface")}
              data-density={@mode}>
              <span class="badge badge-secondary">Community member</span>
              <p id="hologram-preferences-preview-name" class="text-2xl font-semibold">{@name}</p>
              <p class="text-on-surface-variant">A little space to explore, create, and share.</p>
              <p id="hologram-preferences-preview-notifications" class="text-sm">
                {if(@notifications, do: "Notification reminders enabled", else: "Notification reminders hidden")}
              </p>
            </div>

            <div class="space-y-2 border-t border-outline-variant pt-4">
              <h4 class="font-semibold">Applied to this page</h4>
              <p id="hologram-preferences-applied-name">{@applied.name}</p>
              <p id="hologram-preferences-applied-mode" class="text-sm text-on-surface-variant">
                {if(@applied.mode == "compact", do: "Compact density", else: "Comfortable density")}
              </p>
              <p id="hologram-preferences-local-note" class="text-sm text-on-surface-variant">
                Settings stay in this open page only. Nothing is sent or saved; reloading restores the defaults.
              </p>
            </div>
          </div>
        </section>
      </div>
    </main>
    """
  end
end
