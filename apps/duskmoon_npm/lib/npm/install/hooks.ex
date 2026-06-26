defmodule NPM.Install.Hooks do
  @moduledoc """
  Hooks for integrating npm operations with Mix workflows.

  Provides callbacks that can be triggered before and after
  npm operations, useful for mix compiler integration and
  build pipelines.
  """

  @type hook :: :pre_install | :post_install | :pre_resolve | :post_resolve

  @doc """
  Run a hook callback if configured.

  Hooks are configured via application config:

      config :duskmoon_npm, hooks: %{
        post_install: {MyApp, :on_npm_install, []}
      }
  """
  @spec run(hook(), keyword()) :: :ok
  def run(hook, context \\ []) do
    case get_hook(hook) do
      nil -> :ok
      {mod, fun, extra_args} -> apply(mod, fun, [context | extra_args])
      fun when is_function(fun, 1) -> fun.(context)
    end

    :ok
  end

  @doc """
  List all configured hooks.
  """
  @spec configured :: %{hook() => term()}
  def configured do
    Application.get_env(:duskmoon_npm, :hooks, %{})
  end

  @doc """
  Check if a hook is configured.
  """
  @spec configured?(hook()) :: boolean()
  def configured?(hook) do
    Map.has_key?(configured(), hook)
  end

  @doc """
  Available hook points.
  """
  @spec available :: [hook()]
  def available do
    [:pre_install, :post_install, :pre_resolve, :post_resolve]
  end

  defp get_hook(hook) do
    Map.get(configured(), hook)
  end
end
