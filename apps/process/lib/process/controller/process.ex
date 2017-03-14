defmodule Helix.Process.Controller.Process do

  import Ecto.Query, only: [where: 3]

  alias Helix.Process.Repo
  alias Helix.Process.Model.Process, as: ProcessModel

  def create(process) do
    ProcessModel.create_changeset(process)
    |> Repo.insert()
  end

  def fetch(process_id),
    do: Repo.get(ProcessModel, process_id)

  def delete(process_id) do
    ProcessModel
    |> where([s], s.process_id == ^process_id)
    |> Repo.delete_all()

    :ok
  end
end