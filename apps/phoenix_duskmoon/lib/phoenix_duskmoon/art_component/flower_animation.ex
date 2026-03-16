defmodule PhoenixDuskmoon.ArtComponent.FlowerAnimation do
  @moduledoc """
  Flower animation art component using the `<el-dm-art-flower-animation>` custom element.

  ## Examples

      <.dm_art_flower_animation id="flower-1" />

      <.dm_art_flower_animation id="flower-2" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated flower using the `<el-dm-art-flower-animation>` custom element.

  ## Examples

      <.dm_art_flower_animation id="flower" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_flower_animation(assigns) do
    ~H"""
    <el-dm-art-flower-animation id={@id} class={@class} {@rest}></el-dm-art-flower-animation>
    """
  end
end
