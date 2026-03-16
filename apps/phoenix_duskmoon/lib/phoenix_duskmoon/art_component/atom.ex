defmodule PhoenixDuskmoon.ArtComponent.Atom do
  @moduledoc """
  Atom art component using the `<el-dm-art-atom>` custom element.

  ## Examples

      <.dm_art_atom id="atom-1" />

      <.dm_art_atom id="atom-2" size="large" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated atom with orbiting electrons using the `<el-dm-art-atom>` custom element.

  ## Examples

      <.dm_art_atom id="atom" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_atom(assigns) do
    ~H"""
    <el-dm-art-atom id={@id} class={@class} {@rest}></el-dm-art-atom>
    """
  end
end
