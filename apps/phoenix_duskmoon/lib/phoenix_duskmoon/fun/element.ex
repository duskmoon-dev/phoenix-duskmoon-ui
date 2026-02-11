defmodule PhoenixDuskmoon.Fun.Element do
  @moduledoc """
  Duskmoon UI Fun Element components
  """
  use PhoenixDuskmoon.Component, :html

  @doc """
  Generates a eclipse effect

  ## Example

  ```heex
  <PhoenixDuskmoon.Fun.Element.dmf_eclipse
  />
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:background, :string,
    default: "#09090b",
    doc: """
    Background color
    """
  )

  attr(:size, :string,
    default: "400px",
    doc: """
    size
    """
  )

  def dmf_eclipse(assigns) do
    ~H"""
    <div
      id={@id}
      class={["dm-fun-eclipse", @class]}
      style={"--bg-color: #{@background}; --size: #{@size};"}
    >
      <div class="layer layer-1"></div>
      <div class="layer layer-2"></div>
      <div class="layer layer-3"></div>
      <div class="layer layer-4"></div>
      <div class="layer layer-5"></div>
      <div class="layer layer-6"></div>
    </div>
    """
  end

  @doc """
  Generates a plasma ball effect

  ## Example

  ```heex
  <PhoenixDuskmoon.Fun.Element.dmf_plasma_ball />
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:size, :string,
    default: "350px",
    doc: """
    size
    """
  )

  attr(:show_base, :boolean,
    default: false,
    doc: """
    show base of plasma ball
    """
  )

  attr(:show_electrode, :boolean,
    default: true,
    doc: """
    show electrode of plasma ball
    """
  )

  def dmf_plasma_ball(assigns) do
    ~H"""
    <div class="dm-fun-plasma-ball" style={"--size: #{@size};"}>
      <input type="checkbox" class={["switcher", if(@show_base, do: "", else: "hidden")]} checked="checked" />
      <div class="glassball">
        <div class={["electrode", if(!@show_electrode, do: "hide-electrode")]}></div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray bigwave"><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
        </div>
        <div class="rays">
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
          <div class="ray"><span></span><span></span><span></span></div>
        </div>

      </div>
      <div :if={@show_base} class="base">
        <div></div>
        <div></div>
        <span></span>
      </div>
      <div :if={@show_base} class="switch"></div>
    </div>
    """
  end

  @doc """
  Generates a atom effect

  ## Example

  ```heex
  <PhoenixDuskmoon.Fun.Element.dmf_atom />
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:size, :string,
    default: "200px",
    doc: """
    size
    """
  )

  attr(:atom_color, :string,
    default: "#00d8ff",
    doc: """
    atom color
    """
  )

  attr(:electron_color, :string,
    default: "#99f8ff",
    doc: """
    electron color
    """
  )

  def dmf_atom(assigns) do
    ~H"""
    <div
      id={@id}
      class={["dm-fun-atom", @class]}
      style={[
        "--atom-size: #{@size}",
        "--atom-color: #{@atom_color}",
        "--electron-color: #{@electron_color};"
      ] |> Enum.join(";")}
    >
      <div class="electron"></div>
      <div class="electron-alpha"></div>
      <div class="electron-omega"></div>
    </div>
    """
  end

  @doc """
  Generates snowflakes, bubbles or unicode `❆`.

  ## Example

  ```heex
  <PhoenixDuskmoon.Fun.Element.dmf_snow />
  ```

  """
  @doc type: :component
  attr(:class, :any,
    default: "",
    doc: """
    html attribute class for each snowflake
    """
  )

  attr(:count, :integer,
    default: 200,
    doc: """
    snowflake count
    """
  )

  attr(:color, :string,
    default: "#fff",
    doc: """
    snowflake color
    """
  )

  attr(:size, :string,
    default: "10px",
    doc: """
    snowflake size
    """
  )

  attr(:unicode, :boolean,
    default: false,
    doc: """
    show snowflake by using unicode character [❆]
    """
  )

  def dmf_snow(assigns) do
    ~H"""
    <style>
    <%= for n <- 0..@count do %>
      <% random_x = Enum.random(1..1000000) * 0.0001 %>
      <% random_offset = Enum.random(-100000..100000) * 0.0001 %>
      .dm-fun-snowflake-<%= n %> {
        opacity: <%= Enum.random(1..10000) * 0.0001 %>;
        transform: translate(<%= random_x %>vw, -10px) scale(<%= Enum.random(1..10000) * 0.0001 %>);
        animation: dm-fun-snowflake-fall-<%= n %> <%= Enum.random(10..30) * 1 %>s <%= Enum.random(0..30) * -1 %>s linear infinite;
      }

      @keyframes dm-fun-snowflake-fall-<%= n %> {
        <%= Enum.random(30000..80000) / 1000 %>% {
          transform: translate(<%= if(random_x + random_offset > 100, do: random_x - random_offset, else: random_x + random_offset) %>vw, <%= Enum.random(30000..80000) / 1000 %>vh) scale(<%= Enum.random(1..10000) * 0.0001 %>);
        }

        to {
          transform: translate(<%= if(random_x + random_offset / 2 > 100, do: random_x - random_offset / 2, else: random_x + random_offset / 2) %>vw, 100vh) scale(<%= Enum.random(1..10000) * 0.0001 %>);
        }
      }
    <% end %>
    </style>
    <div
      :for={n <- 0..@count}
      class={["dm-fun-snowflake", "dm-fun-snowflake-#{n}", @class, if(@unicode, do: "snowflake-unicode")]}
      style={"--snowflake-color: #{@color}; --snowflake-size: #{@size};"}
    />
    """
  end

  @doc """
  Generates bubbles fly up from this element.

  ## Example

  ```heex
  <PhoenixDuskmoon.Fun.Element.dmf_footer_bubbles />
  ```

  """

  @doc type: :component
  attr(:id, :any,
    default: nil,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class for bubbles container
    """
  )

  attr(:color, :string,
    default: "#fff",
    doc: """
    bubble color
    """
  )

  attr(:count, :integer,
    default: 128,
    doc: """
    snowflake count
    """
  )

  def dmf_footer_bubbles(assigns) do
    assigns =
      assigns
      |> assign_new(:blob_id, fn ->
        "footer-bubbles-blob-#{Enum.random(0..999_999_999_999)}"
      end)

    ~H"""
    <div
      id={@id}
      class={["dm-fun-footer-bubbles", @class]}
      style={"--footer-bg-color: #{@color}; filter: url(\"##{@blob_id}\");"}
    >
      <div
        :for={_n <- 1..@count}
        class="dm-fun-footer-bubble"
        style={[
          "--size: #{2 + Enum.random(0..999_999_999_999) * 1.0e-12 * 4}rem",
          "--distance: #{6 + Enum.random(0..999_999_999_999) * 1.0e-12  * 4}rem",
          "--position: min(calc(100% - var(--size) / 2), #{-5 + Enum.random(0..999_999_999_999) * 1.0e-12  * 110}%)",
          "--time: #{2 + Enum.random(0..999_999_999_999) * 1.0e-12  * 2}s",
          "--delay: #{-1 * (2 + Enum.random(0..999_999_999_999) * 1.0e-12  * 2)}s"
          ] |> Enum.join(";")}
      ></div>
    </div>
    <svg style="position: fixed; top: 100vh">
      <defs>
        <filter id={@blob_id}>
          <feGaussianBlur in="SourceGraphic" stdDeviation="10" result="blur"></feGaussianBlur>
          <feColorMatrix in="blur" mode="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 19 -9" result="blob"></feColorMatrix>
        </filter>
      </defs>
    </svg>
    """
  end

  @doc """
  Generates Loading.

  ## Examples

  ```heex
  <.dmf_loading_ex size={44} item_count={99} speed={"2s"} />
  ```

  """
  @doc type: :component
  attr(:id, :any,
    default: false,
    doc: """
    html attribute id
    """
  )

  attr(:class, :any,
    default: "",
    doc: """
    html attribute class
    """
  )

  attr(:item_count, :integer,
    default: 88,
    doc: """
    loading effect bubble count
    """
  )

  attr(:speed, :string,
    default: "4s",
    doc: """
    loading effect speed
    """
  )

  attr(:size, :string,
    default: "20rem",
    doc: """
    loading size, css value
    """
  )

  def dmf_loading_ex(assigns) do
    assigns =
      assigns
      |> assign(:random_inner, Enum.random(10_000..100_000))
      |> assign(:item_count, max(assigns.item_count, 1))

    ~H"""
    <style data-id={@random_inner}>
    .dm-fun-loader-<%= @random_inner %> {
      --duration: <%= @speed %>;
      --size: <%= @size %>;
      position: relative;
      width: var(--size, 20rem);
      height: var(--size, 20rem);
    }

    .dm-fun-loader-<%= @random_inner %> i {
      position: absolute;
      filter: blur(0.2em) contrast(2);
      left: calc(var(--size, 21em) / 2.1);
      top: calc(var(--size, 21em) / 2.1);
      width: calc(var(--size, 21em) / 21);
      height: calc(var(--size, 21em) / 21);
      background-color: hsl(var(--hue, 0), 75%, 75%);
      border-radius: 50%;
      transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 2.1 / 2));
      animation: dm-fun-item-move-<%= @random_inner %> var(--duration) var(--delay, 0s) infinite ease-in-out;
    }

    @keyframes dm-fun-item-move-<%= @random_inner %> {
      0% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(0); }
      2% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(1.25); }
      20% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(0, 0) scale(1.25); }
      90%, 100% { transform: rotateZ(var(--rz, 0)) translateY(calc(var(--size, 21em) / 21 * 4)) translate(var(--tx, 0), var(--ty, 0)) scale(0); }
    }

    <%= for i <- 0..(@item_count - 1) do %>
    .dm-fun-loader-<%= @random_inner %> i:nth-child(<%= i + 1 %>) {
      --rz: <%= i * (360 / @item_count) %>deg;
      --delay: calc(var(--duration) / <%= @item_count %> * <%= i %> - var(--duration));
      --tx: <%= Enum.random(1..1000) / 250 %>em;
      --ty: <%= Enum.random(1..1000) / 125 - 2.5 %>em;
      --hue: <%= i * (360 / @item_count) %>;
    }
    <% end %>
    </style>
    <div id={@id} class={["dm-fun-loader-#{@random_inner}", @class]}>
      <i :for={_ <- 1..@item_count} />
    </div>
    """
  end
end
