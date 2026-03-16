defmodule PhoenixDuskmoon.ArtComponent.Eclipse do
  @moduledoc """
  Solar eclipse art component using the `<el-dm-art-eclipse>` custom element.

  ## Examples

      <.dm_art_eclipse id="eclipse-1" />

      <.dm_art_eclipse id="eclipse-2" size="large" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated eclipse using the `<el-dm-art-eclipse>` custom element.

  ## Examples

      <.dm_art_eclipse id="eclipse" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_eclipse(assigns) do
    ~H"""
    <el-dm-art-eclipse id={@id} class={@class} {@rest}></el-dm-art-eclipse>
    """
  end
end
