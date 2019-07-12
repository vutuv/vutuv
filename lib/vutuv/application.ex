defmodule Vutuv.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Vutuv.Repo,
      Vutuv.Accounts.EmailManager,
      {Task.Supervisor, name: Vutuv.Downloads.TaskSupervisor},
      Vutuv.Downloads.GravatarWorker,
      VutuvWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Vutuv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    VutuvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
