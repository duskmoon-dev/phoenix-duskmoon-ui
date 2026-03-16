defmodule PhoenixDuskmoon.ArtComponent.Moon do
  @moduledoc """
  Moon art component using the `<el-dm-art-moon>` custom element.

  ## Examples

      <.dm_art_moon id="moon-1" />

      <.dm_art_moon id="moon-2" variant="crescent" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated moon using the `<el-dm-art-moon>` custom element.

  ## Examples

      <.dm_art_moon id="moon" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_moon(assigns) do
    ~H"""
    <el-dm-art-moon id={@id} class={@class} {@rest}></el-dm-art-moon>
    """
  end
end
