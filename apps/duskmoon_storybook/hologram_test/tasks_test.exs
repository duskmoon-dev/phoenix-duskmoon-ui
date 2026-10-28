defmodule DuskmoonStorybook.Hologram.TasksTest do
  use ExUnit.Case, async: true

  alias DuskmoonStorybook.Hologram.Tasks
  alias Hologram.Component
  alias Hologram.Server

  setup do
    %{component: Tasks.init(%{}, %Component{}, %Server{})}
  end

  test "initial tasks expose active and completed counts", %{component: component} do
    assert %{active_count: 2, completed_count: 1, filter: "all"} = component.state
    assert [_, _, _] = component.state.visible_tasks
    assert component.next_command == nil
  end

  test "empty and whitespace submissions leave the task list intact", %{component: component} do
    for value <- ["", "  \n\t"] do
      updated = Tasks.action(:add, %{event: %{"task" => value}}, component)
      assert updated.state.tasks == component.state.tasks
      assert updated.state.next_id == component.state.next_id
      assert updated.state.error == "Write a task before adding it."
    end

    assert Tasks.action(:add, %{event: %{}}, component).state.tasks == component.state.tasks
  end

  test "adding trims the title, clears the input, and makes the new task visible", %{
    component: component
  } do
    component = Tasks.action(:set_filter, %{filter: "completed"}, component)
    component = Tasks.action(:set_draft, %{event: %{value: "  Read the docs  "}}, component)
    updated = Tasks.action(:add, %{event: %{"task" => "  Read the docs  "}}, component)

    assert [_, _, _, %{id: 4, title: "Read the docs", completed: false}] = updated.state.tasks
    assert updated.state.tasks == updated.state.visible_tasks
    assert %{draft: "", filter: "all", next_id: 5, active_count: 3, error: ""} = updated.state
    assert updated.next_command == nil
  end

  test "checkbox values control completion and update the current filter", %{component: component} do
    active = Tasks.action(:set_filter, %{filter: "active"}, component)
    completed = Tasks.action(:toggle, %{id: 1, event: %{value: true}}, active)
    assert [%{id: 2}] = completed.state.visible_tasks
    assert %{active_count: 1, completed_count: 2} = completed.state

    restored = Tasks.action(:toggle, %{id: 1, event: %{value: false}}, completed)
    assert [%{id: 1}, %{id: 2}] = restored.state.visible_tasks
    assert restored.state.tasks == component.state.tasks
    assert Tasks.action(:toggle, %{id: 999, event: %{value: true}}, component) == component
  end

  test "filters reject unknown values and clearing completed preserves active tasks", %{
    component: component
  } do
    assert Tasks.action(:set_filter, %{filter: "unknown"}, component) == component
    completed = Tasks.action(:set_filter, %{filter: "completed"}, component)
    assert [%{id: 3, completed: true}] = completed.state.visible_tasks

    cleared = Tasks.action(:clear_completed, %{}, completed)
    assert [%{id: 1, completed: false}, %{id: 2, completed: false}] = cleared.state.tasks
    assert cleared.state.visible_tasks == []
    assert cleared.state.empty_message == "No completed tasks yet."
    assert %{active_count: 2, completed_count: 0} = cleared.state
  end

  test "a fully cleared list has a useful empty state", %{component: component} do
    completed =
      Enum.reduce([1, 2], component, fn id, acc ->
        Tasks.action(:toggle, %{id: id, event: %{value: true}}, acc)
      end)

    active = Tasks.action(:set_filter, %{filter: "active"}, completed)
    assert active.state.visible_tasks == []
    assert active.state.empty_message == "All tasks are complete."

    cleared = Tasks.action(:clear_completed, %{}, active)
    assert %{tasks: [], visible_tasks: [], active_count: 0, completed_count: 0} = cleared.state
    assert cleared.state.empty_message == "Your list is clear. Add a task to get started."
  end
end
