defmodule PhoenixDuskmoon.Component.DataDisplay.StatTest do
  use ExUnit.Case, async: true

  require Phoenix.LiveViewTest
  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Stat

  test "renders stat with title and value" do
    result = render_component(&dm_stat/1, %{title: "Users", value: "1,234"})

    assert result =~ "Users"
    assert result =~ "1,234"
  end

  test "renders as dl/dt/dd semantic HTML" do
    result = render_component(&dm_stat/1, %{title: "Revenue", value: "$45K"})

    assert result =~ "<dl"
    assert result =~ "<dt"
    assert result =~ "<dd"
  end

  test "renders with description" do
    result =
      render_component(&dm_stat/1, %{
        title: "Growth",
        value: "12%",
        description: "+3% from last month"
      })

    assert result =~ "+3% from last month"
  end

  test "does not render description when nil" do
    result = render_component(&dm_stat/1, %{title: "Count", value: "5"})

    refute result =~ "<p"
  end

  test "renders with color applied to value" do
    result =
      render_component(&dm_stat/1, %{
        title: "Errors",
        value: "3",
        color: "error"
      })

    assert result =~ "text-error"
  end

  test "renders all color options" do
    for color <- ~w(primary secondary tertiary accent info success warning error) do
      result =
        render_component(&dm_stat/1, %{
          title: "Test",
          value: "0",
          color: color
        })

      assert result =~ "text-#{color}"
    end
  end

  test "renders without color by default" do
    result = render_component(&dm_stat/1, %{title: "Test", value: "0"})

    refute result =~ "text-primary"
    refute result =~ "text-error"
  end

  test "renders description with color for success/error/warning" do
    for color <- ~w(success error warning) do
      result =
        render_component(&dm_stat/1, %{
          title: "Test",
          value: "0",
          color: color,
          description: "change"
        })

      # description <p> should also get the color
      assert result =~ "text-#{color}"
    end
  end

  test "renders small size" do
    result =
      render_component(&dm_stat/1, %{
        title: "Test",
        value: "0",
        size: "sm"
      })

    assert result =~ "text-xs"
    assert result =~ "text-lg"
  end

  test "renders medium size by default" do
    result = render_component(&dm_stat/1, %{title: "Test", value: "0"})

    assert result =~ "text-sm"
    assert result =~ "text-2xl"
  end

  test "renders large size" do
    result =
      render_component(&dm_stat/1, %{
        title: "Test",
        value: "0",
        size: "lg"
      })

    assert result =~ "text-base"
    assert result =~ "text-4xl"
  end

  test "renders with id" do
    result =
      render_component(&dm_stat/1, %{
        id: "stat-1",
        title: "Test",
        value: "0"
      })

    assert result =~ ~s[id="stat-1"]
  end

  test "renders with custom class" do
    result =
      render_component(&dm_stat/1, %{
        class: "bg-surface-container rounded-lg",
        title: "Test",
        value: "0"
      })

    assert result =~ "bg-surface-container"
    assert result =~ "rounded-lg"
  end

  test "renders with rest attributes" do
    result =
      render_component(&dm_stat/1, %{
        "data-testid": "my-stat",
        title: "Test",
        value: "0"
      })

    assert result =~ ~s[data-testid="my-stat"]
  end

  test "renders icon slot when provided" do
    result =
      render_component(&dm_stat/1, %{
        title: "Test",
        value: "0",
        icon: %{inner_block: fn _, _ -> "icon-svg" end}
      })

    assert result =~ "icon-svg"
  end

  test "does not render icon wrapper when empty" do
    result = render_component(&dm_stat/1, %{title: "Test", value: "0"})

    # The icon div uses :if={@icon != []} so it should be absent
    refute result =~ "shrink-0"
  end

  test "renders icon with color" do
    result =
      render_component(&dm_stat/1, %{
        title: "Test",
        value: "0",
        color: "success",
        icon: %{inner_block: fn _, _ -> "icon" end}
      })

    assert result =~ "text-success"
  end

  test "description does not get color for primary/secondary/tertiary/accent/info" do
    for color <- ~w(primary secondary tertiary accent info) do
      result =
        render_component(&dm_stat/1, %{
          title: "Test",
          value: "0",
          color: color,
          description: "desc-text"
        })

      # The value <dd> gets text-{color}, but the description <p> should not
      assert result =~ "text-#{color}"
      assert result =~ "desc-text"
      # Extract the <p> tag containing desc-text
      [p_tag] = Regex.scan(~r/<p[^>]*>/, result) |> List.flatten()
      refute p_tag =~ "text-#{color}"
    end
  end

  test "renders all attributes combined" do
    result =
      render_component(&dm_stat/1, %{
        id: "full-stat",
        class: "rounded-lg shadow",
        title: "Revenue",
        value: "$1.2M",
        description: "+15%",
        color: "success",
        size: "lg",
        icon: %{inner_block: fn _, _ -> "icon-svg" end},
        "data-testid": "stat-revenue"
      })

    assert result =~ ~s[id="full-stat"]
    assert result =~ "rounded-lg"
    assert result =~ "Revenue"
    assert result =~ "$1.2M"
    assert result =~ "+15%"
    assert result =~ "text-success"
    assert result =~ "text-4xl"
    assert result =~ "icon-svg"
    assert result =~ ~s[data-testid="stat-revenue"]
  end

  test "renders value with special characters" do
    result = render_component(&dm_stat/1, %{title: "Ratio", value: "3 < 5"})

    assert result =~ "&lt;"
  end
end
