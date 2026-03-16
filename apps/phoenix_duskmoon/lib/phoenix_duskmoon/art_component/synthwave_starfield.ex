defmodule PhoenixDuskmoon.ArtComponent.SynthwaveStarfield do
  @moduledoc """
  Synthwave starfield art component using the `<el-dm-art-synthwave-starfield>` custom element.

  ## Examples

      <.dm_art_synthwave_starfield id="starfield-1" />

      <.dm_art_synthwave_starfield id="starfield-2" class="w-full h-64" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated synthwave starfield using the `<el-dm-art-synthwave-starfield>` custom element.

  ## Examples

      <.dm_art_synthwave_starfield id="starfield" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_synthwave_starfield(assigns) do
    ~H"""
    <el-dm-art-synthwave-starfield id={@id} class={@class} {@rest}></el-dm-art-synthwave-starfield>
    """
  end
end
