defmodule HELM.Account.App do
  use Application

  alias HELM.Account
  alias HELF.Router

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(HeBroker, []),
      worker(Router, [], function: :run),
      worker(Account.Repo, []),
      worker(Account.Service, [])
    ]

    opts = [strategy: :one_for_one, name: Account.Supervisor]
    Supervisor.start_link(children, opts)
  end
end