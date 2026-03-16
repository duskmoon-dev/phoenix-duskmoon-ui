defmodule PhoenixDuskmoon.ArtComponent.CatStargazer do
  @moduledoc """
  Cat stargazer art component using the `<el-dm-art-cat-stargazer>` custom element.

  ## Examples

      <.dm_art_cat_stargazer id="cat-1" />

      <.dm_art_cat_stargazer id="cat-2" class="mx-auto" />

  """

  use Phoenix.Component

  @doc """
  Renders an animated cat stargazer using the `<el-dm-art-cat-stargazer>` custom element.

  ## Examples

      <.dm_art_cat_stargazer id="cat" />

  """
  @doc type: :component
  attr(:id, :string, required: true)
  attr(:class, :any, default: nil)
  attr(:rest, :global)

  def dm_art_cat_stargazer(assigns) do
    ~H"""
    <el-dm-art-cat-stargazer id={@id} class={@class} {@rest}></el-dm-art-cat-stargazer>
    """
  end
end
