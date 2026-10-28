defmodule DuskmoonStorybook.Hologram.Index do
  @moduledoc "The entry point to the interactive Duskmoon Hologram demos."

  use Hologram.Page

  route "/hologram/demos"
  layout DuskmoonStorybook.Hologram.Layout, title: "Hologram"

  @impl true
  def template do
    ~HOLO"""
    <main id="hologram-index" class="space-y-8">
      <section class="rounded-2xl bg-primary-container p-6 text-on-primary-container md:p-10">
        <p class="mb-3 text-sm font-semibold uppercase tracking-widest">Duskmoon Hologram</p>
        <h1 class="mb-4 text-4xl font-bold">Interactive Elixir demos</h1>
        <p class="max-w-2xl text-lg">Explore Duskmoon controls, build a task list and preview a profile. Choose a demo and try its interactions in Sunshine or Moonlight.</p>
      </section>

      <section aria-label="Choose a Hologram demo" class="grid gap-6 md:grid-cols-3">
        <article class="card flex flex-col">
          <div class="card-body flex-1 gap-4">
            <span class="text-sm font-semibold text-on-surface-variant">01 / COMPONENTS</span>
            <h2 class="card-title">Component playground</h2>
            <p class="text-on-surface-variant">Try counters, synchronized inputs, checkboxes and a native dialog in one place.</p>
            <div class="card-actions mt-auto pt-4">
              <a href="/hologram/playground" target="_top" class="btn btn-primary">Open playground</a>
            </div>
          </div>
        </article>

        <article class="card flex flex-col">
          <div class="card-body flex-1 gap-4">
            <span class="text-sm font-semibold text-on-surface-variant">02 / COLLECTIONS</span>
            <h2 class="card-title">Task list</h2>
            <p class="text-on-surface-variant">Add tasks, mark them complete and switch between filtered views of your list.</p>
            <div class="card-actions mt-auto pt-4">
              <a href="/hologram/tasks" target="_top" class="btn btn-secondary">Open task list</a>
            </div>
          </div>
        </article>

        <article class="card flex flex-col">
          <div class="card-body flex-1 gap-4">
            <span class="text-sm font-semibold text-on-surface-variant">03 / FORMS</span>
            <h2 class="card-title">Profile preview</h2>
            <p class="text-on-surface-variant">Edit your display preferences, see a live preview and apply or reset your choices.</p>
            <div class="card-actions mt-auto pt-4">
              <a href="/hologram/preferences" target="_top" class="btn btn-secondary">Open profile preview</a>
            </div>
          </div>
        </article>
      </section>
      <p class="text-sm text-on-surface-variant">These demos keep changes in the current page. Reloading starts a fresh example.</p>
    </main>
    """
  end
end
