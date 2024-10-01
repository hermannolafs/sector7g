defmodule Sector7g.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Sector7gWeb.Telemetry,
      Sector7g.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:sector7g, :ecto_repos)},
      {DNSCluster, query: Application.get_env(:sector7g, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Sector7g.PubSub},
      # Start the Finch HTTP client for sending emails
      # {Finch, name: Sector7g.Finch},
      # Start a worker by calling: Sector7g.Worker.start_link(arg)
      # {Sector7g.Worker, arg},
      # Start to serve requests, typically the last entry
      Sector7g.DaysSince,
      Sector7gWeb.Endpoint
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

end
