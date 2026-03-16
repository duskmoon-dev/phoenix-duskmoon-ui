defmodule PhoenixDuskmoon.ArtComponent.Snow do
  @moduledoc """
  Falling snow art component using the `<el-dm-art-snow>` custom element.

  ## Examples

      <.dm_art_snow id="snow-1" />

      <.dm_art_snow id="snow-2" count="50" class="h-screen" />

  """

  use Phoenix.Component

  @doc """
  Renders animated falling snow using the `<el-dm-art-snow>` custom element.

  ## Examples

      <.dm_art_snow id="snow" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_snow(assigns) do
    ~H"""
    <el-dm-art-snow id={@id} class={@class} {@rest}></el-dm-art-snow>
    """
  end
end
