defmodule PhoenixDuskmoon.Component.DataDisplay.ProgressTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Progress

  test "renders basic progress bar" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ "<progress"
    assert result =~ "dm-progress"
    assert result =~ ~s[value="50"]
    assert result =~ ~s[max="100"]
  end

  test "renders progress with custom max" do
    result = render_component(&dm_progress/1, %{value: 25, max: 50})

    assert result =~ ~s[value="25"]
    assert result =~ ~s[max="50"]
  end

  test "renders progress with color" do
    result = render_component(&dm_progress/1, %{value: 70, color: "success"})

    assert result =~ "dm-progress--success"
  end

  test "renders progress with size" do
    result = render_component(&dm_progress/1, %{value: 30, size: "lg"})

    assert result =~ "dm-progress--lg"
  end

  test "renders progress with label" do
    result = render_component(&dm_progress/1, %{value: 60, show_label: true})

    assert result =~ "60%"
  end

  test "renders indeterminate progress" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    assert result =~ "dm-progress"
  end

  test "renders progress with custom class" do
    result = render_component(&dm_progress/1, %{value: 40, class: "my-progress"})

    assert result =~ "my-progress"
  end
end
