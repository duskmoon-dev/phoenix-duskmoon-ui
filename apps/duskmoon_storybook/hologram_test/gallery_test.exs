defmodule DuskmoonStorybook.Hologram.GalleryTest do
  use ExUnit.Case, async: true

  alias DuskmoonStorybook.Hologram.Gallery
  alias Hologram.Component
  alias Hologram.Server

  setup do
    %{component: Gallery.init(%{}, %Component{}, %Server{})}
  end

  test "server state schedules a client readiness action", %{component: component} do
    assert component.state.count == 0
    refute component.state.ready
    assert component.next_action.name == :client_ready
    assert Gallery.action(:client_ready, %{}, component).state.ready
  end

  test "counter actions are local and do not underflow", %{component: component} do
    assert Gallery.action(:decrement, %{}, component).state.count == 0
    updated = Gallery.action(:increment, %{}, component)
    assert updated.state.count == 1
    assert updated.next_command == nil
    assert Gallery.action(:decrement, %{}, updated).state.count == 0
    assert Gallery.action(:reset, %{}, updated).state.count == 0
  end

  test "input and checkbox events update one source of state", %{component: component} do
    named = Gallery.action(:set_name, %{event: %{value: "Jonathan"}}, component)
    assert named.state.name == "Jonathan"

    unchecked = Gallery.action(:set_notifications, %{event: %{value: false}}, named)
    refute unchecked.state.notifications
    assert unchecked.state.name == "Jonathan"
    assert unchecked.next_command == nil
  end
end
