defmodule DuskmoonStorybook.Hologram.Gallery do
  @moduledoc """
  Direct Core markup with browser-local Hologram state, not Phoenix wrappers.

  The browser owns the dialog and disclosure state. Hologram owns the theme,
  counter and synchronized inputs. No server commands are used in this demo.
  """

  use Hologram.Page

  route "/examples/hologram"
  layout DuskmoonStorybook.Hologram.Layout

  @impl true
  def init(_params, component, _server) do
    component
    |> put_state(
      theme: "sunshine",
      count: 0,
      name: "Duskmoon",
      notifications: true,
      ready: false
    )
    |> put_action(:client_ready)
  end

  @impl true
  def action(:client_ready, _params, component), do: put_state(component, :ready, true)

  def action(:increment, _params, component) do
    put_state(component, :count, component.state.count + 1)
  end

  def action(:decrement, _params, component) do
    put_state(component, :count, max(0, component.state.count - 1))
  end

  def action(:reset, _params, component), do: put_state(component, :count, 0)

  def action(:set_theme, %{theme: theme}, component) when theme in ["sunshine", "moonlight"] do
    put_state(component, :theme, theme)
  end

  def action(:set_theme, _params, component), do: component

  def action(:set_name, %{event: %{value: value}}, component) do
    put_state(component, :name, value)
  end

  def action(:set_notifications, %{event: %{value: value}}, component) do
    put_state(component, :notifications, value)
  end

  @impl true
  def template do
    ~HOLO"""
    <main id="hologram-example" data-theme={@theme} class="min-h-screen w-full bg-surface text-on-surface">
      <div class="mx-auto max-w-6xl space-y-8 p-4 md:p-8">
        <header class="space-y-4">
          <a href="/storybook/integrations/hologram" class="link">Back to Storybook</a>
          <div class="flex flex-wrap items-center gap-3">
            <h1 class="text-3xl font-bold">Hologram + Duskmoon Core</h1>
            <span class="badge badge-secondary">Experimental</span>
            <span id="hologram-runtime" class="badge badge-success" role="status"
              data-ready={if @ready, do: "true", else: "false"}>
              {if @ready, do: "Client ready", else: "Server rendered"}
            </span>
          </div>
          <p>One stylesheet. Native HTML. Elixir actions running in your browser.</p>
          <div class="flex flex-wrap gap-2" aria-label="Preview theme">
            <button id="hologram-sunshine" type="button" class="btn btn-primary"
              aria-pressed={if @theme == "sunshine", do: "true", else: "false"}
              $click={:set_theme, theme: "sunshine"}>Sunshine</button>
            <button id="hologram-moonlight" type="button" class="btn btn-secondary"
              aria-pressed={if @theme == "moonlight", do: "true", else: "false"}
              $click={:set_theme, theme: "moonlight"}>Moonlight</button>
          </div>
        </header>

        <div class="grid gap-6 md:grid-cols-2">
          <section class="card" aria-labelledby="hologram-counter-title">
            <div class="card-body space-y-4">
              <h2 id="hologram-counter-title" class="card-title">Client-side counter</h2>
              <p>These buttons update local Hologram state without a server command.</p>
              <output id="hologram-count" class="text-4xl font-bold" aria-live="polite">{@count}</output>
              <div class="flex flex-wrap gap-2">
                <button id="hologram-decrement" type="button" class="btn btn-outline"
                  disabled={@count == 0} $click="decrement">Decrease</button>
                <button id="hologram-increment" type="button" class="btn btn-primary"
                  $click="increment">Increase</button>
                <button id="hologram-reset" type="button" class="btn btn-ghost"
                  $click="reset">Reset</button>
              </div>
              <div class="flex flex-wrap gap-2">
                <span class="badge badge-primary">Core CSS</span>
                <span class="badge badge-secondary">Hologram actions</span>
                <span class="badge badge-success">No LiveView hooks</span>
              </div>
            </div>
          </section>

          <section class="card" aria-labelledby="hologram-form-title">
            <div class="card-body space-y-4">
              <h2 id="hologram-form-title" class="card-title">Synchronized inputs</h2>
              <label for="hologram-name">Preview name</label>
              <input id="hologram-name" name="preview_name" type="text" class="input w-full"
                value={@name} $change="set_name" />
              <p>Name: <output id="hologram-name-preview">{@name}</output></p>
              <label class="flex items-center gap-3">
                <input id="hologram-notifications" type="checkbox" class="checkbox checkbox-primary"
                  checked={@notifications} $change="set_notifications" />
                Enable notifications
              </label>
              <p id="hologram-notifications-preview" role="status">
                {if @notifications, do: "Notifications enabled", else: "Notifications disabled"}
              </p>
              <p class="text-sm">Input values have one owner: Hologram state.</p>
            </div>
          </section>

          <section class="card" aria-labelledby="hologram-native-title">
            <div class="card-body space-y-4">
              <h2 id="hologram-native-title" class="card-title">Native dialog</h2>
              <p>The browser owns opening, Escape, focus and the backdrop.</p>
              <button id="hologram-open-dialog" type="button" class="btn btn-primary"
                command="show-modal" commandfor="hologram-dialog">Open dialog</button>
              <p class="text-sm">Requires a browser supporting HTML command / commandfor.</p>
            </div>
          </section>

          <section class="card" aria-labelledby="hologram-disclosure-title">
            <div class="card-body space-y-4">
              <h2 id="hologram-disclosure-title" class="card-title">Native disclosure</h2>
              <details class="collapse">
                <summary class="collapse-title">What is shared with Phoenix?</summary>
                <div class="collapse-content">
                  <p>The existing Core styles, themes and asset build are shared. The Hologram document does not load Storybook app.js.</p>
                </div>
              </details>
              <div class="alert alert-info" role="note">
                This is an integration example, not a new component library.
              </div>
            </div>
          </section>
        </div>

        <dialog id="hologram-dialog" class="modal" aria-labelledby="hologram-dialog-title">
          <div class="modal-box space-y-4">
            <h2 id="hologram-dialog-title" class="text-xl font-bold">Browser-owned dialog</h2>
            <p>Updating the counter must not close this dialog or lose its modal state.</p>
            <p>Count: <output id="hologram-dialog-count" aria-live="polite">{@count}</output></p>
            <button id="hologram-dialog-increment" type="button" class="btn btn-secondary"
              $click="increment">Increase inside dialog</button>
            <form method="dialog" class="modal-action">
              <button id="hologram-close-dialog" type="submit" class="btn btn-primary" autofocus>Close dialog</button>
            </form>
          </div>
        </dialog>
      </div>
    </main>
    """
  end
end
