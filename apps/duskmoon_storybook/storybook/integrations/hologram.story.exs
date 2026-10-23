defmodule Storybook.Integrations.Hologram do
  use PhoenixStorybook.Story, :page

  def doc, do: "Experimental Hologram integration using the existing Duskmoon Core stylesheet."

  def render(assigns) do
    enabled =
      Application.get_env(:duskmoon_storybook, :hologram_examples, false) and
        Code.ensure_loaded?(Hologram) and apply(Hologram, :enabled?, [])

    assigns = Phoenix.Component.assign(assigns, :hologram_enabled, enabled)

    ~H"""
    <div class="space-y-6 p-4">
      <h1 class="text-2xl font-bold">Hologram + Duskmoon Core</h1>
      <p>
        A native Hologram page using Core CSS directly. The iframe isolates its document
        from LiveView; no Phoenix wrappers, hooks or React mounts are loaded inside it.
      </p>
      <div :if={@hologram_enabled} class="space-y-4">
        <a href="/examples/hologram" target="_blank" rel="noopener" class="btn btn-primary">
          Open standalone example
        </a>
        <iframe
          id="hologram-preview"
          src="/examples/hologram"
          title="Hologram Duskmoon Core interactive example"
          class="min-h-[960px] w-full rounded-xl border border-outline"
        ></iframe>
      </div>
      <div :if={!@hologram_enabled} class="space-y-3">
        <p class="alert alert-info" role="status">
          The Hologram example is opt-in. Existing Storybook builds do not depend on Hologram.
        </p>
        <p>Use Elixir 1.19+, OTP 28.1+, Node.js 20+ and Bun, then run from the repository root:</p>
        <pre class="overflow-x-auto rounded-xl bg-surface-container p-4"><code>scripts/with-hologram-example.sh deps.get
    bun install --frozen-lockfile
    scripts/with-hologram-example.sh duskmoon_bundler.build duskmoon_storybook
    scripts/with-hologram-example.sh</code></pre>
        <p>Setup and verification: <code>docs/hologram-example.md</code>.</p>
      </div>
    </div>
    """
  end
end
