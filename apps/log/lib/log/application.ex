defmodule Helix.Log.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Helix.Log.Repo, []),
      worker(Helix.Log.Controller.LogService, [])
    ]

    opts = [strategy: :one_for_one, name: Helix.Log.Supervisor]
    Supervisor.start_link(children, opts)
  end
end