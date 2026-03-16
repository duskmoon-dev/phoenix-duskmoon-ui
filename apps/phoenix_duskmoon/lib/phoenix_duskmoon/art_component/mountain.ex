defmodule PhoenixDuskmoon.ArtComponent.Mountain do
  @moduledoc """
  Mountain landscape art component using the `<el-dm-art-mountain>` custom element.

  ## Examples

      <.dm_art_mountain id="mountain-1" />

      <.dm_art_mountain id="mountain-2" variant="range" class="w-full" />

  """

  use Phoenix.Component

  @doc """
  Renders a mountain landscape using the `<el-dm-art-mountain>` custom element.

  ## Examples

      <.dm_art_mountain id="mountain" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_mountain(assigns) do
    ~H"""
    <el-dm-art-mountain id={@id} class={@class} {@rest}></el-dm-art-mountain>
    """
  end
end
