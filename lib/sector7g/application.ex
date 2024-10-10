defmodule Sector7g.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, []) do
    children = [
      Sector7gWeb.Endpoint,
    ] ++ telemetry_children?() ++ [
      Sector7g.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:sector7g, :ecto_repos)},
      {DNSCluster, query: Application.get_env(:sector7g, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sector7g.PubSub},
      Sector7g.DaysSince,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sector7g.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Sector7gWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def telemetry_children? do
    if telemetry_enabled?() do
      Logger.info("Telemetry enabled")
      [Sector7g.PromEx, Sector7gWeb.Telemetry]
    else
      Logger.warning("Telemtry disabled")
      []
    end
  end

  def telemetry_enabled? do
    Application.get_env(:sector7g, :telemetry_enabled)
  end
end
