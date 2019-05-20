defmodule HomeGateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HomeGateway.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    main_viewport_config = Application.get_env(:home_gateway, :viewport)
    [
      # Starts a worker by calling: HomeGateway.Worker.start_link(arg)
      # {HomeGateway.Worker, arg},
      {Scenic, viewports: [main_viewport_config]}
    ]
  end

  def children(_target) do
    main_viewport_config = Application.get_env(:home_gateway, :viewport)
    [
      # Starts a worker by calling: HomeGateway.Worker.start_link(arg)
      # {HomeGateway.Worker, arg},
      {Scenic, viewports: [main_viewport_config]}
    ]
  end
end
