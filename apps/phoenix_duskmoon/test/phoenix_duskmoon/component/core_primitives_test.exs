defmodule PhoenixDuskmoon.Component.CorePrimitivesTest do
  use ExUnit.Case, async: true
  use Phoenix.Component

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.Action.Fab
  import PhoenixDuskmoon.Component.Action.Swap
  import PhoenixDuskmoon.Component.DataDisplay.Carousel
  import PhoenixDuskmoon.Component.DataDisplay.Countdown
  import PhoenixDuskmoon.Component.DataDisplay.Diff
  import PhoenixDuskmoon.Component.DataDisplay.Kbd
  import PhoenixDuskmoon.Component.DataDisplay.RadialProgress
  import PhoenixDuskmoon.Component.DataEntry.FilterGroup
  import PhoenixDuskmoon.Component.Layout.Indicator
  import PhoenixDuskmoon.Component.Layout.Join
  import PhoenixDuskmoon.Component.Layout.Mask
  import PhoenixDuskmoon.Component.Layout.Stack

  test "carousel keeps slide targets directly inside a named keyboard scroll region" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_carousel id="projects" label="Projects" orientation="vertical" align="center">
        <:item id="project-one" label="First project"><a href="/one">First</a></:item>
        <:item id="project-two" label="Second project">Second</:item>
      </.dm_carousel>
      """)
      |> LazyHTML.from_fragment()

    assert attribute(html, "#projects[role=region][tabindex='0']", "aria-label") == [
             "Projects"
           ]

    assert Enum.count(
             LazyHTML.query(html, "#projects.carousel-vertical.carousel-center > .carousel-item")
           ) == 2

    assert attribute(html, "#project-one", "aria-roledescription") == ["slide"]
    assert attribute(html, "#project-one a", "href") == ["/one"]
  end

  test "countdown displays the supplied value without a timer hook or live tick announcement" do
    html =
      render_component(&dm_countdown/1, %{value: 42, label: "Seconds remaining"})
      |> LazyHTML.from_fragment()

    assert LazyHTML.text(LazyHTML.query(html, ".countdown-value")) == "42"
    assert attribute(html, "[role=timer]", "aria-live") == ["off"]
    assert attribute(html, "[role=timer]", "aria-label") == ["Seconds remaining"]
    assert Enum.empty?(LazyHTML.query(html, "[phx-hook]"))
  end

  test "diff preserves both panels and bounds the application-supplied reveal percentage" do
    for {position, expected} <- [{-20, 0}, {40, 40}, {150, 100}] do
      assigns = %{position: position}

      html =
        rendered_to_string(~H"""
        <.dm_diff label="Comparison" position={@position}>
          <:before_content><img src="/before.png" alt="Original design" /></:before_content>
          <:after_content><img src="/after.png" alt="Updated design" /></:after_content>
        </.dm_diff>
        """)
        |> LazyHTML.from_fragment()

      assert attribute(html, ".diff", "style") == ["--diff-position: #{expected}%"]
      assert attribute(html, ".diff > .diff-before > img", "alt") == ["Original design"]
      assert attribute(html, ".diff > .diff-after > img", "alt") == ["Updated design"]
      assert Enum.empty?(LazyHTML.query(html, "[role=slider]"))
    end
  end

  test "static diff selects the side-by-side contract" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_diff label="Versions" static>
        <:before_content>Before</:before_content>
        <:after_content>After</:after_content>
      </.dm_diff>
      """)
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(html, ".diff-static > div")) == 2
  end

  test "indicator puts logical positions on each item without hiding meaningful content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_indicator dir="rtl">
        <button type="button">Inbox</button>
        <:indicator vertical="bottom" horizontal="start"><span aria-label="3 unread messages">3</span></:indicator>
      </.dm_indicator>
      """)
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(html, ".indicator[dir=rtl] > button")) == 1

    assert LazyHTML.text(
             LazyHTML.query(html, ".indicator > .indicator-item.indicator-bottom.indicator-start")
           )
           |> String.trim() == "3"

    assert Enum.empty?(LazyHTML.query(html, "[aria-hidden]"))
  end

  test "join preserves direct native controls and submission attributes" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_join label="Search tools">
        <input class="input join-item" name="q" value="moon" aria-label="Search" />
        <button class="btn join-item" type="submit">Search</button>
      </.dm_join>
      """)
      |> LazyHTML.from_fragment()

    assert attribute(html, ".join-horizontal[role=group]", "aria-label") == ["Search tools"]
    assert attribute(html, ".join > input.join-item", "name") == ["q"]
    assert attribute(html, ".join > button.join-item", "type") == ["submit"]
  end

  test "kbd uses native semantics and escapes supplied content" do
    assigns = %{key: "<Enter>"}

    html =
      rendered_to_string(~H"""
      <.dm_kbd size="lg">{@key}</.dm_kbd>
      """)
      |> LazyHTML.from_fragment()

    assert LazyHTML.text(LazyHTML.query(html, "kbd.kbd-lg")) == "<Enter>"
    assert Enum.empty?(LazyHTML.query(html, "enter"))
  end

  test "mask preserves an image's alternative text" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_mask shape="hexagon"><img src="/avatar.png" alt="Team avatar" /></.dm_mask>
      """)
      |> LazyHTML.from_fragment()

    assert attribute(html, ".mask-hexagon > img", "alt") == ["Team avatar"]
    assert Enum.empty?(LazyHTML.query(html, "[aria-hidden]"))
  end

  test "stack preserves foreground order and caller-owned decorative semantics" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_stack direction="end">
        <article>Current</article>
        <article aria-hidden="true" inert>Decorative</article>
      </.dm_stack>
      """)
      |> LazyHTML.from_fragment()

    assert LazyHTML.text(LazyHTML.query(html, ".stack-end > :first-child")) == "Current"
    assert Enum.count(LazyHTML.query(html, ".stack > article[aria-hidden=true][inert]")) == 1
  end

  test "fab connects a native command trigger to an initially closed named popover" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_fab id="create" label="Create a resource" position="start">
        <:trigger>+</:trigger>
        <a class="btn" href="/new">New document</a>
      </.dm_fab>
      """)
      |> LazyHTML.from_fragment()

    assert attribute(html, ".fab-start > button[type=button]", "command") == [
             "toggle-popover"
           ]

    assert attribute(html, "button", "commandfor") == ["create"]

    assert attribute(html, "#create.fab-actions[popover=auto]", "aria-label") == [
             "Create a resource"
           ]

    assert attribute(html, "#create > a", "href") == ["/new"]
    assert Enum.empty?(LazyHTML.query(html, "[aria-expanded], .fab-open"))
  end

  test "swap uses a named checked checkbox and hides only its visual labels" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_swap id="sound" name="sound" value="enabled" label="Enable sound" checked rotate>
        <:on>On</:on>
        <:off>Off</:off>
      </.dm_swap>
      """)
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(html, "label.swap-rotate > input[type=checkbox][checked]")) ==
             1

    assert attribute(html, "input", "name") == ["sound"]
    assert attribute(html, "input", "value") == ["enabled"]
    assert attribute(html, "input", "aria-label") == ["Enable sound"]
    assert Enum.count(LazyHTML.query(html, "input ~ span[aria-hidden=true]")) == 2
    assert Enum.empty?(LazyHTML.query(html, "[aria-pressed], [phx-hook]"))
  end

  test "disabled unchecked swap remains a native disabled control" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_swap label="Enable sound" disabled><:on>On</:on><:off>Off</:off></.dm_swap>
      """)
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(html, "input[type=checkbox][disabled]")) == 1
    assert Enum.empty?(LazyHTML.query(html, "input[checked]"))
  end

  test "filter group uses named native radio choices inside labeled chips" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_filter_group name="status" label="Project status" multiple={false}>
        <:option value="active" checked>Active</:option>
        <:option value="done">Done</:option>
        <:option value="archived" disabled>Archived</:option>
      </.dm_filter_group>
      """)
      |> LazyHTML.from_fragment()

    assert LazyHTML.text(LazyHTML.query(html, "fieldset > legend")) == "Project status"

    assert Enum.count(
             LazyHTML.query(
               html,
               "fieldset.filter-group > label.chip > input[type=radio][name=status]"
             )
           ) == 3

    assert attribute(html, "input[checked]", "value") == ["active"]
    assert attribute(html, "input[disabled]", "value") == ["archived"]
    assert Enum.empty?(LazyHTML.query(html, "[role=checkbox], [aria-checked]"))
  end

  test "multiple filters preserve list submission names and fieldset disabling" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.dm_filter_group name="tags[]" label="Tags" disabled>
        <:option value="design" checked>Design</:option>
        <:option value="code">Code</:option>
      </.dm_filter_group>
      """)
      |> LazyHTML.from_fragment()

    assert Enum.count(LazyHTML.query(html, "fieldset[disabled] input[type=checkbox]")) == 2
    assert attribute(html, "input", "name") == ["tags[]", "tags[]"]
  end

  test "radial progress keeps clamped visual and accessible percentages synchronized" do
    for {value, expected} <- [{-10, 0}, {72, 72}, {120, 100}] do
      html =
        render_component(&dm_radial_progress/1, %{value: value, label: "Upload progress"})
        |> LazyHTML.from_fragment()

      assert attribute(html, "[role=progressbar]", "aria-valuenow") == [to_string(expected)]

      assert attribute(html, "[role=progressbar]", "style") == [
               "--radial-progress-value: #{expected}"
             ]

      assert attribute(html, "[role=progressbar]", "aria-label") == ["Upload progress"]
      assert LazyHTML.text(LazyHTML.query(html, "span[aria-hidden=true]")) == "#{expected}%"
    end
  end

  test "radial progress without a visual label retains its accessible value" do
    html =
      render_component(&dm_radial_progress/1, %{value: 30, label: "Processing", show_label: false})
      |> LazyHTML.from_fragment()

    assert Enum.empty?(LazyHTML.query(html, "span"))
    assert attribute(html, "[role=progressbar]", "aria-valuenow") == ["30"]
  end

  test "custom presentation styles compose with managed comparison and progress values" do
    assigns = %{}

    diff =
      rendered_to_string(~H"""
      <.dm_diff label="Comparison" position={60} style="--diff-ratio: 1 / 1">
        <:before_content>Before</:before_content><:after_content>After</:after_content>
      </.dm_diff>
      """)

    assert length(Regex.scan(~r/ style=/, diff)) == 1

    assert attribute(LazyHTML.from_fragment(diff), ".diff", "style") == [
             "--diff-ratio: 1 / 1; --diff-position: 60%"
           ]

    radial =
      render_component(&dm_radial_progress/1, %{
        value: 72,
        label: "Upload",
        style: "--radial-progress-thickness: 1rem; --radial-progress-value: 0"
      })

    assert length(Regex.scan(~r/ style=/, radial)) == 1

    assert attribute(LazyHTML.from_fragment(radial), ".radial-progress", "style") == [
             "--radial-progress-thickness: 1rem; --radial-progress-value: 0; --radial-progress-value: 72"
           ]
  end

  defp attribute(html, selector, name) do
    html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
  end
end
