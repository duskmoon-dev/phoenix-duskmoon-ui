defmodule PhoenixDuskmoon.Component.DataDisplay.ProgressTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Progress

  test "renders basic progress bar with progress element" do
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

  test "renders progress with default color primary" do
    result = render_component(&dm_progress/1, %{value: 30})

    assert result =~ "dm-progress--primary"
  end

  test "renders progress with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_progress/1, %{value: 50, color: color})
      assert result =~ "dm-progress--#{color}"
    end
  end

  test "renders progress with default size md" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ "dm-progress--md"
  end

  test "renders progress with all size options" do
    for size <- ~w(xs sm md lg) do
      result = render_component(&dm_progress/1, %{value: 50, size: size})
      assert result =~ "dm-progress--#{size}"
    end
  end

  test "renders progress with show_label displaying percentage" do
    result = render_component(&dm_progress/1, %{value: 60, max: 100, show_label: true})

    assert result =~ "60.0%"
    assert result =~ "Complete"
    assert result =~ "Progress"
  end

  test "renders progress without label by default" do
    result = render_component(&dm_progress/1, %{value: 60})

    refute result =~ "Complete"
    refute result =~ "Progress"
  end

  test "renders progress with animated class" do
    result = render_component(&dm_progress/1, %{value: 50, animated: true})

    assert result =~ "dm-progress--animated"
  end

  test "renders progress element without animated class by default" do
    result = render_component(&dm_progress/1, %{value: 50})

    # The style block always contains .dm-progress--animated, so check the progress element itself
    [_, progress_tag] = String.split(result, "<progress", parts: 2)
    [progress_attrs, _] = String.split(progress_tag, ">", parts: 2)
    refute progress_attrs =~ "dm-progress--animated"
  end

  test "renders indeterminate progress with class" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    assert result =~ "dm-progress--indeterminate"
  end

  test "renders progress with custom class" do
    result = render_component(&dm_progress/1, %{value: 40, class: "my-progress"})

    assert result =~ "my-progress"
  end

  test "renders progress with progress_class" do
    result =
      render_component(&dm_progress/1, %{value: 40, progress_class: "custom-bar"})

    assert result =~ "custom-bar"
  end

  test "renders progress with label_class" do
    result =
      render_component(&dm_progress/1, %{
        value: 40,
        show_label: true,
        label_class: "custom-label"
      })

    assert result =~ "custom-label"
  end

  test "renders progress with style block for animations" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ "<style>"
    assert result =~ "@keyframes progress-bar-stripes"
    assert result =~ "@keyframes progress-indeterminate"
  end

  test "renders progress with rest attributes" do
    result =
      render_component(&dm_progress/1, %{
        value: 50,
        "data-testid": "upload-progress"
      })

    assert result =~ "data-testid=\"upload-progress\""
  end

  test "calculates correct percentage" do
    result = render_component(&dm_progress/1, %{value: 30, max: 200, show_label: true})

    assert result =~ "15.0%"
  end

  test "renders 100% when value equals max" do
    result = render_component(&dm_progress/1, %{value: 100, max: 100, show_label: true})

    assert result =~ "100.0%"
  end

  test "renders 0% when value is 0" do
    result = render_component(&dm_progress/1, %{value: 0, max: 100, show_label: true})

    assert result =~ "0.0%"
  end

  test "renders indeterminate progress without value attribute" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    assert result =~ "dm-progress--indeterminate"
    assert result =~ "<progress"
  end

  test "renders animated and indeterminate combined" do
    result =
      render_component(&dm_progress/1, %{
        value: 50,
        animated: true,
        indeterminate: true
      })

    assert result =~ "dm-progress--animated"
    assert result =~ "dm-progress--indeterminate"
  end

  test "renders progress wrapper div always present" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ "<div"
  end

  test "renders progress with default value 0" do
    result = render_component(&dm_progress/1, %{})

    assert result =~ ~s[value="0"]
    assert result =~ ~s[max="100"]
  end

  test "renders aria-compatible progress element" do
    result =
      render_component(&dm_progress/1, %{
        value: 75,
        "aria-label": "Upload progress"
      })

    assert result =~ "aria-label=\"Upload progress\""
  end

  test "renders progress with aria-valuenow, aria-valuemin, aria-valuemax" do
    result = render_component(&dm_progress/1, %{value: 42, max: 200})

    assert result =~ ~s[aria-valuenow="42"]
    assert result =~ ~s[aria-valuemin="0"]
    assert result =~ ~s[aria-valuemax="200"]
  end

  test "renders indeterminate progress without aria-valuenow" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    refute result =~ "aria-valuenow"
    assert result =~ ~s[aria-valuemin="0"]
    assert result =~ ~s[aria-valuemax="100"]
  end
end
