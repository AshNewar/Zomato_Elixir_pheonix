defmodule Zomato.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZomatoWeb.Telemetry,
      Zomato.Repo,
      {DNSCluster, query: Application.get_env(:zomato, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zomato.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Zomato.Finch},
      # Start a worker by calling: Zomato.Worker.start_link(arg)
      # {Zomato.Worker, arg},
      # Start to serve requests, typically the last entry
      ZomatoWeb.Endpoint,
      Zomato.RabbitMQ
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zomato.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZomatoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
