defmodule Storybook.Integrations.Hologram do
  use PhoenixStorybook.Story, :page

  def doc, do: "Duskmoon Hologram demos using the shared Duskmoon Core stylesheet."

  def render(assigns) do
    ~H"""
    <div class="space-y-6 p-4">
      <h1 class="text-2xl font-bold">Duskmoon Hologram</h1>
      <p>
        A native Hologram page using Core CSS directly. The iframe isolates its document
        from LiveView; no Phoenix wrappers, hooks or React mounts are loaded inside it.
      </p>
      <div class="space-y-4">
        <a href="/hologram" target="_blank" rel="noopener" class="btn btn-primary">
          Explore Hologram demos
        </a>
        <iframe
          id="hologram-preview"
          src="/hologram/demos/playground"
          title="Hologram Duskmoon Core interactive example"
          phx-hook="DuskmoonHologramFrame"
          class="min-h-[960px] w-full rounded-xl border border-outline"
        ></iframe>
      </div>
    </div>
    """
  end
end
