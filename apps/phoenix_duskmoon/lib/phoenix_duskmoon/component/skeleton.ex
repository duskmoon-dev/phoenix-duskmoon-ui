defmodule PhoenixDuskmoon.Component.Skeleton do
  @moduledoc """
  Backwards-compatible re-export module.

  This module delegates to `PhoenixDuskmoon.Component.DataDisplay.Skeleton`.
  Use the new module path for new code.
  """

  defdelegate dm_skeleton(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_text(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_avatar(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_card(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_table(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_list(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_form(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
  defdelegate dm_skeleton_comment(assigns), to: PhoenixDuskmoon.Component.DataDisplay.Skeleton
end
