defmodule DuskmoonStorybook.Hologram.Tasks do
  @moduledoc "A task list whose actions and state stay in the current browser page."

  use Hologram.Page

  route("/hologram/demos/tasks")
  layout(DuskmoonStorybook.Hologram.Layout, title: "Task list")

  @impl true
  def init(_params, component, _server) do
    component
    |> put_state(
      tasks: [
        %{id: 1, title: "Explore the component gallery", completed: false},
        %{id: 2, title: "Try the profile preview", completed: false},
        %{id: 3, title: "Switch between light and dark", completed: true}
      ],
      next_id: 4,
      draft: "",
      filter: "all",
      error: ""
    )
    |> refresh()
  end

  @impl true
  def action(:set_draft, %{event: %{value: value}}, component) when is_binary(value) do
    put_state(component, draft: value, error: "")
  end

  def action(:add, %{event: %{"task" => value}}, component) when is_binary(value) do
    case String.trim(value) do
      "" ->
        put_state(component, draft: value, error: "Write a task before adding it.")

      title ->
        task = %{id: component.state.next_id, title: title, completed: false}

        component
        |> put_state(
          tasks: component.state.tasks ++ [task],
          next_id: component.state.next_id + 1,
          draft: "",
          filter: "all",
          error: ""
        )
        |> refresh()
    end
  end

  def action(:add, _params, component) do
    put_state(component, :error, "Write a task before adding it.")
  end

  def action(:toggle, %{id: id, event: %{value: completed}}, component)
      when is_boolean(completed) do
    tasks =
      Enum.map(component.state.tasks, fn task ->
        if task.id == id, do: %{task | completed: completed}, else: task
      end)

    component |> put_state(:tasks, tasks) |> refresh()
  end

  def action(:set_filter, %{filter: filter}, component)
      when filter in ["all", "active", "completed"] do
    component |> put_state(:filter, filter) |> refresh()
  end

  def action(:set_filter, _params, component), do: component

  def action(:clear_completed, _params, component) do
    tasks = Enum.reject(component.state.tasks, & &1.completed)
    component |> put_state(:tasks, tasks) |> refresh()
  end

  defp refresh(component) do
    tasks = component.state.tasks
    filter = component.state.filter
    completed_count = Enum.count(tasks, & &1.completed)

    visible_tasks =
      case filter do
        "all" -> tasks
        "active" -> Enum.reject(tasks, & &1.completed)
        "completed" -> Enum.filter(tasks, & &1.completed)
      end

    empty_message =
      cond do
        tasks == [] -> "Your list is clear. Add a task to get started."
        filter == "completed" -> "No completed tasks yet."
        true -> "All tasks are complete."
      end

    put_state(component,
      visible_tasks: visible_tasks,
      active_count: length(tasks) - completed_count,
      completed_count: completed_count,
      empty_message: empty_message
    )
  end

  @impl true
  def template do
    ~HOLO"""
    <main id="hologram-tasks" class="mx-auto max-w-3xl space-y-6" aria-labelledby="hologram-task-title">
      <div class="space-y-2">
        <h1 id="hologram-task-title" class="text-2xl font-semibold">Small tasks, visible progress</h1>
        <p class="text-on-surface-variant">Add a task, mark it complete, and focus on what remains.</p>
      </div>

      <div class="card">
        <div class="card-body space-y-6">
          <form id="hologram-task-form" class="space-y-2" $submit="add">
            <label for="hologram-task-input" class="form-label">New task</label>
            <div class="flex flex-col gap-3 sm:flex-row">
              <input id="hologram-task-input" type="text" name="task" class="input w-full"
                placeholder="What would you like to do?" value={@draft} required
                aria-describedby="hologram-task-help" $change="set_draft" />
              <button id="hologram-task-add" type="submit" class="btn btn-primary">Add task</button>
            </div>
            <p id="hologram-task-help" class="text-sm text-on-surface-variant">Press Enter or choose Add task.</p>
            {%if @error != ""}
              <p id="hologram-task-error" class="text-error" role="alert">{@error}</p>
            {/if}
          </form>

          <div class="flex flex-wrap items-center justify-between gap-3">
            <div class="flex flex-wrap gap-2" role="group" aria-label="Filter tasks">
              <button id="hologram-task-filter-all" type="button" class="btn btn-ghost btn-sm"
                aria-pressed={if(@filter == "all", do: "true", else: "false")}
                $click={:set_filter, filter: "all"}>All</button>
              <button id="hologram-task-filter-active" type="button" class="btn btn-ghost btn-sm"
                aria-pressed={if(@filter == "active", do: "true", else: "false")}
                $click={:set_filter, filter: "active"}>Active</button>
              <button id="hologram-task-filter-completed" type="button" class="btn btn-ghost btn-sm"
                aria-pressed={if(@filter == "completed", do: "true", else: "false")}
                $click={:set_filter, filter: "completed"}>Completed</button>
            </div>
            <p id="hologram-task-counts" class="text-sm text-on-surface-variant" role="status">
              <span id="hologram-task-active-count">{@active_count}</span> active ·
              <span id="hologram-task-completed-count">{@completed_count}</span> completed
            </p>
          </div>

          {%if @visible_tasks == []}
            <p id="hologram-task-empty" class="rounded-xl bg-surface-container-high p-6 text-on-surface" role="status">{@empty_message}</p>
          {%else}
            <ul id="hologram-task-list" class="space-y-3" aria-label="Tasks">
              {%for task <- @visible_tasks}
                <li id={"hologram-task-item-#{task.id}"} class="rounded-xl border border-outline-variant p-4">
                  <label for={"hologram-task-toggle-#{task.id}"} class="flex items-center gap-3">
                    <input id={"hologram-task-toggle-#{task.id}"} type="checkbox" class="checkbox checkbox-primary"
                      checked={task.completed} $change={:toggle, id: task.id} />
                    <span class={if(task.completed, do: "line-through text-on-surface-variant", else: "font-medium")}>{task.title}</span>
                  </label>
                </li>
              {/for}
            </ul>
          {/if}

          <div class="flex flex-wrap items-center justify-between gap-3 border-t border-outline-variant pt-4">
            <p class="text-sm text-on-surface-variant">This list resets when you reload the page.</p>
            <button id="hologram-task-clear-completed" type="button" class="btn btn-outline btn-sm"
              disabled={@completed_count == 0} $click="clear_completed">Clear completed</button>
          </div>
        </div>
      </div>
    </main>
    """
  end
end
