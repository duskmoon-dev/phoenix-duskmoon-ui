defmodule PhoenixDuskmoon.Component.DataDisplay.Datetime do
  @moduledoc """
  Display-only date and datetime formatting with time-zone support.

  Uses the `el-dm-datetime` custom element from
  `@duskmoon-dev/el-datetime`.

  Register the element in your application's JavaScript entry point:

  ```js
  import "@duskmoon-dev/el-datetime/register";
  ```

  ## Examples

      <.dm_datetime value="2026-08-11T14:30:45Z" />

      <.dm_datetime
        value="2026-08-11T14:30:45Z"
        format="DD/MM/YYYY [at] h:mm A"
        time_zone="Asia/Shanghai"
      />

  Values with `Z` or an explicit offset are converted to `time_zone`.
  Date-only and offsetless values remain wall-clock values.
  """

  use Phoenix.Component

  @doc """
  Renders an `el-dm-datetime` custom element.

  The format supports year, month, day, hour, minute, second, millisecond,
  and meridiem tokens. Text inside square brackets is rendered literally.
  """
  @doc type: :component
  attr(:id, :any, default: nil, doc: "HTML id attribute")
  attr(:value, :string, default: "", doc: "ISO date or datetime to display")

  attr(:format, :string,
    default: "YYYY-MM-DD HH:mm",
    doc: "token-based output format"
  )

  attr(:time_zone, :string,
    default: nil,
    doc: "IANA time zone used for values with Z or an explicit offset"
  )

  attr(:class, :any, default: nil, doc: "additional CSS classes")
  attr(:rest, :global)

  def dm_datetime(assigns) do
    ~H"""
    <el-dm-datetime
      id={@id}
      value={@value}
      format={@format}
      time-zone={@time_zone}
      class={@class}
      {@rest}
    >
    </el-dm-datetime>
    """
  end
end
