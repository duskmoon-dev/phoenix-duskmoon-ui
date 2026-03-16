defmodule PhoenixDuskmoon.ArtComponent.Sun do
  @moduledoc """
  Sun art component using the `<el-dm-art-sun>` custom element.

  ## Examples

      <.dm_art_sun id="sun-1" />

      <.dm_art_sun id="sun-2" variant="rays" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated sun using the `<el-dm-art-sun>` custom element.

  ## Examples

      <.dm_art_sun id="sun" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_sun(assigns) do
    ~H"""
    <el-dm-art-sun id={@id} class={@class} {@rest}></el-dm-art-sun>
    """
  end
end
