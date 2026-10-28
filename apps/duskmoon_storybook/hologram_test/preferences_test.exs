defmodule DuskmoonStorybook.Hologram.PreferencesTest do
  use ExUnit.Case, async: true

  alias DuskmoonStorybook.Hologram.Preferences
  alias Hologram.Component
  alias Hologram.Server

  setup do
    %{component: Preferences.init(%{}, %Component{}, %Server{})}
  end

  test "initial preview and applied settings share explicit local defaults", %{
    component: component
  } do
    assert %{name: "Duskmoon explorer", mode: "comfortable", notifications: true} =
             component.state.applied

    assert component.state.name == component.state.applied.name
    assert component.state.error == ""
    assert component.next_command == nil
  end

  test "editing updates the live preview without applying settings", %{component: component} do
    updated =
      component
      |> then(&Preferences.action(:set_name, %{event: %{value: "Alex"}}, &1))
      |> then(&Preferences.action(:set_mode, %{event: %{value: "compact"}}, &1))
      |> then(&Preferences.action(:set_notifications, %{event: %{value: false}}, &1))

    assert %{name: "Alex", mode: "compact", notifications: false} = updated.state
    assert updated.state.applied == component.state.applied
    assert updated.state.message == "Preview has unapplied changes."
    assert updated.next_command == nil
  end

  test "applying trims the display name and takes a snapshot of preview settings", %{
    component: component
  } do
    edited = Preferences.action(:set_name, %{event: %{value: "  Alex Moon  "}}, component)
    edited = Preferences.action(:set_mode, %{event: %{value: "compact"}}, edited)
    applied = Preferences.action(:apply, %{}, edited)

    assert applied.state.name == "Alex Moon"
    assert %{name: "Alex Moon", mode: "compact", notifications: true} = applied.state.applied
    assert applied.state.message == "Applied to this preview."
    assert applied.state.error == ""
    assert applied.next_command == nil

    draft = Preferences.action(:set_name, %{event: %{value: "Another name"}}, applied)
    assert draft.state.applied == applied.state.applied
  end

  test "empty names cannot replace applied settings and editing clears the error", %{
    component: component
  } do
    for value <- ["", "  \n\t"] do
      edited = Preferences.action(:set_name, %{event: %{value: value}}, component)
      rejected = Preferences.action(:apply, %{}, edited)
      assert rejected.state.applied == component.state.applied
      assert rejected.state.error == "Enter a display name before applying the preview."

      corrected = Preferences.action(:set_name, %{event: %{value: "Alex"}}, rejected)
      assert corrected.state.error == ""
    end
  end

  test "unsupported density modes leave the preview unchanged", %{component: component} do
    assert Preferences.action(:set_mode, %{event: %{value: "unknown"}}, component) == component
  end

  test "reset restores both draft and applied defaults without a server command", %{
    component: component
  } do
    edited = Preferences.action(:set_name, %{event: %{value: "Alex"}}, component)
    edited = Preferences.action(:set_mode, %{event: %{value: "compact"}}, edited)
    edited = Preferences.action(:set_notifications, %{event: %{value: false}}, edited)
    applied = Preferences.action(:apply, %{}, edited)
    reset = Preferences.action(:reset, %{}, applied)

    assert reset.state.applied == component.state.applied

    assert %{name: "Duskmoon explorer", mode: "comfortable", notifications: true, error: ""} =
             reset.state

    assert reset.state.message == "Defaults restored."
    assert reset.next_command == nil
  end
end
