defmodule Helix.Server.Controller.Server do

  alias HELF.Broker
  alias Helix.Server.Model.Server
  alias Helix.Server.Repo

  import Ecto.Query, only: [where: 3]

  @spec create(Server.creation_params) :: {:ok, Server.t} | {:error, Ecto.Changeset.t}
  def create(params) do
    params
    |> Server.create_changeset()
    |> Repo.insert()
  end

  @spec fetch(HELL.PK.t) :: Server.t | nil
  def fetch(server_id),
    do: Repo.get_by(Server, server_id)

  @spec update(Server.t, Server.update_params) :: {:ok, Server.t} | {:error, Ecto.Changeset.t}
  def update(server, params) do
    server
    |> Server.update_changeset(params)
    |> Repo.update()
  end

  @spec delete(HELL.PK.t) :: no_return
  def delete(server_id) do
    Server
    |> where([s], s.server_id == ^server_id)
    |> Repo.delete_all()

    :ok
  end

  @spec attach(Server.t, motherboard :: HELL.PK.t) :: {:ok, Server.t} | {:error, reason :: term}
  def attach(server, mobo_id) do
    with \
      msg = %{component_type: :motherboard, component_id: mobo_id},
      {_, {:ok, _}} <- Broker.call("hardware.component.get", msg)
    do
      server
      |> Server.update_changeset(%{motherboard_id: mobo_id})
      |> Repo.update()
    end
  end

  @spec detach(Server.t) :: {:ok, Server.t} | {:error, Ecto.Changeset.t}
  def detach(server) do
    server
    |> Server.update_changeset(%{motherboard_id: nil})
    |> Repo.update()
  end
end