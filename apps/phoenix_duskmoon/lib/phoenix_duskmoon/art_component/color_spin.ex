defmodule PhoenixDuskmoon.ArtComponent.ColorSpin do
  @moduledoc """
  Color spin art component using the `<el-dm-art-color-spin>` custom element.

  ## Examples

      <.dm_art_color_spin id="spin-1" />

      <.dm_art_color_spin id="spin-2" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated color spin using the `<el-dm-art-color-spin>` custom element.

  ## Examples

      <.dm_art_color_spin id="spin" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_color_spin(assigns) do
    ~H"""
    <el-dm-art-color-spin id={@id} class={@class} {@rest}></el-dm-art-color-spin>
    """
  end
end
