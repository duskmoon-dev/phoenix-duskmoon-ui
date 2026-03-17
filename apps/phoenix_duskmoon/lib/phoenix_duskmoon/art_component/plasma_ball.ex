defmodule PhoenixDuskmoon.ArtComponent.PlasmaBall do
  @moduledoc """
  Interactive plasma ball art component using the `<el-dm-art-plasma-ball>` custom element.

  ## Examples

      <.dm_art_plasma_ball id="plasma-1" />

      <.dm_art_plasma_ball id="plasma-2" size="large" />

  """

  use Phoenix.Component

  @doc """
  Renders an interactive plasma ball using the `<el-dm-art-plasma-ball>` custom element.

  ## Examples

      <.dm_art_plasma_ball id="plasma" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global, include: ~w[no-base])

  def dm_art_plasma_ball(assigns) do
    ~H"""
    <el-dm-art-plasma-ball id={@id} class={@class} {@rest}></el-dm-art-plasma-ball>
    """
  end
end
