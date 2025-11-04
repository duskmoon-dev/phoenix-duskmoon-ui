defmodule PhoenixDuskmoon.Component.Icons do
  @moduledoc """
  Duskmoon UI Icons Component

  Render 7000+ Material Design Icons with [mdi_icons]

  Render 2000+ Bootstrap Icons with [bsi_icons]

  """
  use PhoenixDuskmoon.Component, :html

  @md_icons File.ls!(Application.app_dir(:phoenix_duskmoon, "priv/mdi/svg"))
            |> Enum.map(&String.trim(&1))
            |> Enum.filter(&String.ends_with?(&1, ".svg"))
            |> Enum.map(&String.trim(&1, ".svg"))
            |> Enum.sort(:asc)

  @doc """
  Return all names of available Material Design Icons (from `npm` `@mdi/svg`).

  Can be found at [Material Design Icons](https://duskmoon-storybook.gsmlg.dev/mdi)

      > PhoenixDuskmoon.Component.Icons.mdi_icons()
        #=> [
        #=>   "abacus",
        #=>   "abjad-arabic",
        #=>   ...
        #=> ]
  """
  @spec mdi_icons() :: [binary()]
  def mdi_icons(), do: @md_icons

  @doc """
  Render Material Design Icons

  ## Examples

      <.dm_mdi name="abacus" id="mdi-abjad-arabic" class="w-16 h-16" />
      #=> <svg xmlns="http://www.w3.org/2000/svg" id="mdi-abjad-arabic" class="w-16 h-16" fill="currentcolor" viewBox="0 0 24 24"><path d="M12 4C10.08 4 8.5 5.58 8.5 7.5C8.5 8.43 8.88 9.28 9.5 9.91C7.97 10.91 7 12.62 7 14.5C7 17.53 9.47 20 12.5 20C14.26 20 16 19.54 17.5 18.66L16.5 16.93C15.28 17.63 13.9 18 12.5 18C10.56 18 9 16.45 9 14.5C9 12.91 10.06 11.53 11.59 11.12L16.8 9.72L16.28 7.79L11.83 9C11.08 8.9 10.5 8.28 10.5 7.5C10.5 6.66 11.16 6 12 6C12.26 6 12.5 6.07 12.75 6.2L13.75 4.47C13.22 4.16 12.61 4 12 4Z" /></svg>

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

  attr(:name, :string,
    required: true,
    doc: """
    material icon name, avaliable names are return value of `mdi_icons()`.
    """
  )

  attr(:color, :string,
    default: "currentcolor",
    doc: """
    icon color
    """
  )

  def dm_mdi(assigns) do
    name = assigns.name
    icon_path = Application.app_dir(:phoenix_duskmoon, "priv/mdi/svg/#{name}.svg")

    inner_svg =
      case File.read(icon_path) do
        {:ok, content} ->
          content
          |> String.replace(~r/<svg[^>]+>/, "")
          |> String.replace("</svg>", "")

        {:error, _} ->
          # Return error icon (alert-circle) when icon is not found
          ~s(<path d="M13,13H11V7H13M13,17H11V15H13M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2Z" />)
      end

    assigns = assigns |> assign(:inner_svg, inner_svg)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" id={@id} class={@class} fill={@color} viewBox="0 0 24 24">
      <%= raw(@inner_svg) %>
    </svg>
    """
  end

  @bs_icons File.ls!(Application.app_dir(:phoenix_duskmoon, "priv/bsi/svg"))
            |> Enum.map(&String.trim(&1))
            |> Enum.filter(&String.ends_with?(&1, ".svg"))
            |> Enum.map(&String.trim(&1, ".svg"))
            |> Enum.sort(:asc)

  @doc """
  Return all names of available Bootstrap Icons (from `npm` `bootstrap-icons`).

  Can be found at [Bootstrap Icons](https://duskmoon-storybook.gsmlg.dev/bsi)

      > PhoenixDuskmoon.Component.Icons.bsi_icons()
        #=> [
          "0-circle-fill",
          "0-circle",
          ...
        ]
  """
  @spec bsi_icons() :: [String.t()]
  def bsi_icons(), do: @bs_icons

  @doc """
  Render Bootstrap Icons

  ## Examples

      <.dm_bsi name="0-circle" class="w-16 h-16" />
      #=> <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" class="w-16 h-16" viewBox="0 0 16 16">
      #=>   <path d="M7.988 12.158c-1.851 0-2.941-1.57-2.941-3.99V7.84c0-2.408 1.101-3.996 2.965-3.996 1.857 0 2.935 1.57 2.935 3.996v.328c0 2.408-1.101 3.99-2.959 3.99ZM8 4.951c-1.008 0-1.629 1.09-1.629 2.895v.31c0 1.81.627 2.895 1.629 2.895s1.623-1.09 1.623-2.895v-.31c0-1.8-.621-2.895-1.623-2.895Z"/>
      #=>   <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0ZM1 8a7 7 0 1 0 14 0A7 7 0 0 0 1 8Z"/>
      #=> </svg>

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

  attr(:name, :string,
    required: true,
    doc: """
    bootstrap icon name, avaliable names are return value of `bsi_icons()`.
    """
  )

  attr(:color, :string,
    default: "currentcolor",
    doc: """
    icon color
    """
  )

  def dm_bsi(assigns) do
    name = assigns.name
    icon_path = Application.app_dir(:phoenix_duskmoon, "priv/bsi/svg/#{name}.svg")

    inner_svg =
      case File.read(icon_path) do
        {:ok, content} ->
          content
          |> String.replace(~r/<svg[^>]+>/, "")
          |> String.replace("</svg>", "")

        {:error, _} ->
          # Return error icon (exclamation-circle) when icon is not found
          ~s(<path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/><path d="M7.002 11a1 1 0 1 1 2 0 1 1 0 0 1-2 0zM7.1 4.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0L7.1 4.995z"/>)
      end

    assigns = assigns |> assign(:inner_svg, inner_svg)

    ~H"""
    <svg xmlns="http://www.w3.org/2000/svg" id={@id} class={@class} fill={@color} viewBox="0 0 16 16">
      <%= raw(@inner_svg) %>
    </svg>
    """
  end
end
