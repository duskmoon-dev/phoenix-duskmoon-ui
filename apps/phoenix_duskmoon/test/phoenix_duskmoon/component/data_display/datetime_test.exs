defmodule PhoenixDuskmoon.Component.DataDisplay.DatetimeTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import PhoenixDuskmoon.Component.DataDisplay.Datetime

  test "renders the datetime element with formatting and time-zone attributes" do
    result =
      render_component(&dm_datetime/1, %{
        value: "2026-08-11T14:30:45Z",
        format: "DD/MM/YYYY [at] h:mm A",
        time_zone: "Asia/Shanghai"
      })

    assert result =~ "<el-dm-datetime"
    assert result =~ ~s[value="2026-08-11T14:30:45Z"]
    assert result =~ ~s|format="DD/MM/YYYY [at] h:mm A"|
    assert result =~ ~s[time-zone="Asia/Shanghai"]
    assert result =~ "</el-dm-datetime>"
  end

  test "uses the upstream default format" do
    result = render_component(&dm_datetime/1, %{value: "2026-08-11T14:30:45Z"})

    assert result =~ ~s[format="YYYY-MM-DD HH:mm"]
    refute result =~ "time-zone="
  end

  test "forwards class and global attributes" do
    result =
      render_component(&dm_datetime/1, %{
        id: "published-at",
        value: "2026-08-11",
        class: "font-mono",
        "aria-label": "Published at",
        "data-testid": "published-at"
      })

    assert result =~ ~s[id="published-at"]
    assert result =~ ~s[class="font-mono"]
    assert result =~ ~s[aria-label="Published at"]
    assert result =~ ~s[data-testid="published-at"]
  end
end
