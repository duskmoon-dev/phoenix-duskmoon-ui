defmodule DuskmoonStorybook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the PubSub system
      {Phoenix.PubSub, name: DuskmoonStorybook.PubSub},
      # Start the Telemetry supervisor
      DuskmoonStorybookWeb.Telemetry,
      # Start the Endpoint (http/https)
      DuskmoonStorybookWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: DuskmoonStorybook.Supervisor)
  end

  @impl true
  def config_change(changed, _new, removed) do
    DuskmoonStorybookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
