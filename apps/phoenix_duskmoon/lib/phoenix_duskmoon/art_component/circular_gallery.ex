defmodule PhoenixDuskmoon.ArtComponent.CircularGallery do
  @moduledoc """
  Circular gallery art component using the `<el-dm-art-circular-gallery>` custom element.

  ## Examples

      <.dm_art_circular_gallery id="gallery-1" />

      <.dm_art_circular_gallery id="gallery-2" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated circular gallery using the `<el-dm-art-circular-gallery>` custom element.

  ## Examples

      <.dm_art_circular_gallery id="gallery" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_circular_gallery(assigns) do
    ~H"""
    <el-dm-art-circular-gallery id={@id} class={@class} {@rest}></el-dm-art-circular-gallery>
    """
  end
end
