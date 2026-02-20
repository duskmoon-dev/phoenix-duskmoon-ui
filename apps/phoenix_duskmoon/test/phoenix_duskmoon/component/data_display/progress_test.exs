defmodule PhoenixDuskmoon.Component.DataDisplay.ProgressTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Progress

  test "renders basic progress bar with div role=progressbar" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ ~s[role="progressbar"]
    assert result =~ "progress"
    assert result =~ "progress-bar"
  end

  test "renders progress bar with correct width percentage" do
    result = render_component(&dm_progress/1, %{value: 50, max: 100})

    assert result =~ "width: 50.0%"
  end

  test "renders progress with custom max" do
    result = render_component(&dm_progress/1, %{value: 25, max: 50})

    assert result =~ ~s[aria-valuenow="25"]
    assert result =~ ~s[aria-valuemax="50"]
  end

  test "renders progress with default color primary" do
    result = render_component(&dm_progress/1, %{value: 30})

    assert result =~ "progress-primary"
  end

  test "renders progress with all color options" do
    for color <- ~w(primary secondary accent info success warning error) do
      result = render_component(&dm_progress/1, %{value: 50, color: color})
      assert result =~ "progress-#{color}"
    end
  end

  test "renders progress with default size md (no size class)" do
    result = render_component(&dm_progress/1, %{value: 50})

    refute result =~ "progress-md"
  end

  test "renders progress with xs size class" do
    result = render_component(&dm_progress/1, %{value: 50, size: "xs"})

    assert result =~ "progress-xs"
  end

  test "renders progress with sm size class" do
    result = render_component(&dm_progress/1, %{value: 50, size: "sm"})

    assert result =~ "progress-sm"
  end

  test "renders progress with lg size class" do
    result = render_component(&dm_progress/1, %{value: 50, size: "lg"})

    assert result =~ "progress-lg"
  end

  test "renders progress with xl size class" do
    result = render_component(&dm_progress/1, %{value: 50, size: "xl"})

    assert result =~ "progress-xl"
  end

  test "renders progress with show_label displaying percentage" do
    result = render_component(&dm_progress/1, %{value: 60, max: 100, show_label: true})

    assert result =~ "60.0%"
    assert result =~ "Complete"
    assert result =~ "Progress"
  end

  test "renders progress without visible label by default" do
    result = render_component(&dm_progress/1, %{value: 60})

    refute result =~ "Complete"
    refute result =~ ">Progress<"
  end

  test "renders progress with animated class" do
    result = render_component(&dm_progress/1, %{value: 50, animated: true})

    assert result =~ "progress-striped"
    assert result =~ "progress-animated"
  end

  test "renders progress without animated class by default" do
    result = render_component(&dm_progress/1, %{value: 50})

    refute result =~ "progress-animated"
    refute result =~ "progress-striped"
  end

  test "renders indeterminate progress with class" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    assert result =~ "progress-indeterminate"
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

  test "renders indeterminate progress without width style" do
    result = render_component(&dm_progress/1, %{indeterminate: true})

    assert result =~ "progress-indeterminate"
    refute result =~ "width:"
  end

  test "renders animated and indeterminate combined" do
    result =
      render_component(&dm_progress/1, %{
        value: 50,
        animated: true,
        indeterminate: true
      })

    assert result =~ "progress-striped"
    assert result =~ "progress-animated"
    assert result =~ "progress-indeterminate"
  end

  test "renders progress wrapper div always present" do
    result = render_component(&dm_progress/1, %{value: 50})

    assert result =~ "<div"
  end

  test "renders progress with default value 0" do
    result = render_component(&dm_progress/1, %{})

    assert result =~ ~s[aria-valuenow="0"]
    assert result =~ ~s[aria-valuemax="100"]
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

  test "renders progress with value exceeding max" do
    result = render_component(&dm_progress/1, %{value: 150, max: 100, show_label: true})

    assert result =~ "150.0%"
  end

  test "renders progress with max 0 shows 0 percent" do
    result = render_component(&dm_progress/1, %{value: 50, max: 0, show_label: true})

    assert result =~ "0%"
  end

  test "renders progress with fractional percentage" do
    result = render_component(&dm_progress/1, %{value: 1, max: 3, show_label: true})

    assert result =~ "33.3%"
  end

  test "renders progress with all options combined" do
    result =
      render_component(&dm_progress/1, %{
        value: 75,
        max: 100,
        color: "success",
        size: "lg",
        show_label: true,
        animated: true,
        class: "my-wrapper",
        label_class: "my-label",
        progress_class: "my-bar"
      })

    assert result =~ "progress-success"
    assert result =~ "progress-lg"
    assert result =~ "75.0%"
    assert result =~ "progress-striped"
    assert result =~ "progress-animated"
    assert result =~ "my-wrapper"
    assert result =~ "my-label"
    assert result =~ "my-bar"
  end

  describe "aria-label accessibility" do
    test "renders aria-label when show_label is false" do
      result = render_component(&dm_progress/1, %{value: 50})

      assert result =~ ~s[aria-label="Progress"]
    end

    test "does not render aria-label when show_label is true" do
      result = render_component(&dm_progress/1, %{value: 50, show_label: true})

      refute result =~ ~s[aria-label="Progress"]
    end

    test "uses custom label_text for aria-label when show_label is false" do
      result =
        render_component(&dm_progress/1, %{value: 50, label_text: "Upload"})

      assert result =~ ~s[aria-label="Upload"]
    end

    test "explicit aria-label in rest attrs overrides auto-generated one" do
      result =
        render_component(&dm_progress/1, %{
          value: 50,
          "aria-label": "File upload progress"
        })

      assert result =~ ~s[aria-label="File upload progress"]
    end
  end

  describe "configurable label text" do
    test "renders progress with custom label_text" do
      result =
        render_component(&dm_progress/1, %{
          value: 50,
          show_label: true,
          label_text: "Upload"
        })

      assert result =~ "Upload"
      refute result =~ "Progress"
    end

    test "renders progress with custom complete_text" do
      result =
        render_component(&dm_progress/1, %{
          value: 50,
          show_label: true,
          complete_text: "Done"
        })

      assert result =~ "Done"
      refute result =~ "Complete"
    end

    test "renders progress with both custom label_text and complete_text" do
      result =
        render_component(&dm_progress/1, %{
          value: 75,
          max: 100,
          show_label: true,
          label_text: "Loading",
          complete_text: "Loaded"
        })

      assert result =~ "Loading"
      assert result =~ "Loaded"
      assert result =~ "75.0%"
      refute result =~ "Progress"
      refute result =~ "Complete"
    end

    test "renders default label_text and complete_text" do
      result =
        render_component(&dm_progress/1, %{
          value: 50,
          show_label: true
        })

      assert result =~ "Progress"
      assert result =~ "Complete"
    end
  end

  describe "circular progress" do
    test "renders circular progress with SVG" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, max: 100})

      assert result =~ "progress-circular"
      assert result =~ "<svg"
      assert result =~ "progress-circular-track"
      assert result =~ "progress-circular-bar"
    end

    test "renders circular progress with role=progressbar" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      assert result =~ ~s[role="progressbar"]
    end

    test "renders circular progress with aria attributes" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 42, max: 200})

      assert result =~ ~s[aria-valuenow="42"]
      assert result =~ ~s[aria-valuemin="0"]
      assert result =~ ~s[aria-valuemax="200"]
    end

    test "renders circular progress with stroke-dasharray and stroke-dashoffset" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, max: 100})

      assert result =~ "stroke-dasharray"
      assert result =~ "stroke-dashoffset"
    end

    test "renders circular progress with color via inline stroke style" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, color: "success"})

      assert result =~ "stroke: var(--color-success)"
    end

    test "renders circular progress with default primary color" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      assert result =~ "stroke: var(--color-primary)"
    end

    test "renders circular progress with show_label" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 75,
          max: 100,
          show_label: true
        })

      assert result =~ "progress-circular-label"
      assert result =~ "75.0%"
    end

    test "does not render label by default" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 75})

      refute result =~ "progress-circular-label"
    end

    test "renders circular with sm size class" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, size: "sm"})

      assert result =~ "progress-circular-sm"
    end

    test "renders circular with xs size mapping to sm" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, size: "xs"})

      assert result =~ "progress-circular-sm"
    end

    test "renders circular with md size (no size class)" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, size: "md"})

      refute result =~ "progress-circular-sm"
      refute result =~ "progress-circular-lg"
    end

    test "renders circular with lg size class" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, size: "lg"})

      assert result =~ "progress-circular-lg"
    end

    test "renders circular with xl size class" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50, size: "xl"})

      assert result =~ "progress-circular-xl"
    end

    test "renders circular indeterminate with class" do
      result =
        render_component(&dm_progress/1, %{type: "circular", indeterminate: true})

      assert result =~ "progress-circular-indeterminate"
    end

    test "renders circular indeterminate without stroke-dasharray" do
      result =
        render_component(&dm_progress/1, %{type: "circular", indeterminate: true})

      refute result =~ "stroke-dasharray"
      refute result =~ "stroke-dashoffset"
    end

    test "renders circular indeterminate without aria-valuenow" do
      result =
        render_component(&dm_progress/1, %{type: "circular", indeterminate: true})

      refute result =~ "aria-valuenow"
      assert result =~ ~s[aria-valuemin="0"]
    end

    test "renders circular progress with custom class" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 50,
          class: "my-circular"
        })

      assert result =~ "my-circular"
    end

    test "renders circular progress with progress_class" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 50,
          progress_class: "custom-ring"
        })

      assert result =~ "custom-ring"
    end

    test "renders circular progress with rest attributes" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 50,
          "data-testid": "circular-progress"
        })

      assert result =~ ~s[data-testid="circular-progress"]
    end

    test "renders circular progress at 100% with full circle" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 100,
          max: 100,
          show_label: true
        })

      assert result =~ "100.0%"
      assert result =~ ~s[stroke-dashoffset="0.0"]
    end

    test "renders circular progress at 0% with empty circle" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 0,
          max: 100,
          show_label: true
        })

      assert result =~ "0.0%"
      assert result =~ "stroke-dashoffset=\"100.53\""
    end

    test "renders circular progress with aria-label when show_label is false" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      assert result =~ ~s[aria-label="Progress"]
    end

    test "omits aria-label when show_label is true" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 50,
          show_label: true
        })

      refute result =~ ~s[aria-label="Progress"]
    end

    test "renders circular with all options combined" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 75,
          max: 100,
          color: "warning",
          size: "lg",
          show_label: true,
          class: "my-wrapper",
          progress_class: "my-ring"
        })

      assert result =~ "progress-circular"
      assert result =~ "progress-circular-lg"
      assert result =~ "stroke: var(--color-warning)"
      assert result =~ "progress-circular-label"
      assert result =~ "75.0%"
      assert result =~ "my-wrapper"
      assert result =~ "my-ring"
    end

    test "does not render linear progress elements" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      refute result =~ "progress-bar"
      refute result =~ "width:"
    end

    test "renders circular viewBox 0 0 36 36" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      assert result =~ ~s[viewBox="0 0 36 36"]
    end

    test "value exceeding max caps at full circle" do
      result =
        render_component(&dm_progress/1, %{
          type: "circular",
          value: 150,
          max: 100,
          show_label: true
        })

      # Label shows actual percentage (150%)
      assert result =~ "150.0%"
      # But the dash_offset is capped at 0 (full circle)
      assert result =~ ~s[stroke-dashoffset="0.0"]
    end
  end

  describe "type attribute" do
    test "defaults to linear type" do
      result = render_component(&dm_progress/1, %{value: 50})

      assert result =~ "progress-bar"
      refute result =~ "progress-circular"
    end

    test "explicit linear type renders bar" do
      result =
        render_component(&dm_progress/1, %{type: "linear", value: 50})

      assert result =~ "progress-bar"
      refute result =~ "<svg"
    end

    test "circular type renders SVG ring" do
      result =
        render_component(&dm_progress/1, %{type: "circular", value: 50})

      assert result =~ "<svg"
      refute result =~ "progress-bar"
    end
  end
end
