defmodule Helix.Software.Controller.File do

  alias Helix.Software.Repo
  alias Helix.Software.Model.File, as: MdlFile
  import Ecto.Query, only: [where: 3]

  @spec create(MdlFile.creation_params) :: {:ok, MdlFile.t} | {:error, Ecto.Changeset.t}
  def create(params) do
    params
    |> MdlFile.create_changeset()
    |> Repo.insert()
  end

  @spec find(HELL.PK.t) :: {:ok, MdlFile.t} | {:error, :notfound}
  def find(file_id) do
    case Repo.get_by(MdlFile, file_id: file_id) do
      nil ->
        {:error, :notfound}
      file ->
        {:ok, file}
    end
  end

  @spec update(HELL.PK.t, MdlFile.update_params) :: {:ok, MdlFile.t} | {:error, :notfound | Ecto.Changeset.t}
  def update(file_id, params) do
    with {:ok, file} <- find(file_id) do
      file
      |> MdlFile.update_changeset(params)
      |> Repo.update()
    end
  end

  @spec move(MdlFile.t, String.t) :: {:ok, MdlFile.t} | {:error, Ecto.Changeset.t}
  def move(file, file_path) do
    file
    |> MdlFile.update_changeset(%{file_path: file_path})
    |> Repo.update()
  end

  @spec rename(MdlFile.t, String.t) :: {:ok, MdlFile.t} | {:error, Ecto.Changeset.t}
  def rename(file, file_name) do
    file
    |> MdlFile.update_changeset(%{name: file_name})
    |> Repo.update()
  end

  @spec delete(HELL.PK.t) :: no_return
  def delete(file_id) do
    MdlFile
    |> where([f], f.file_id == ^file_id)
    |> Repo.delete_all()

    :ok
  end
end