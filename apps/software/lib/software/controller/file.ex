defmodule Helix.Software.Controller.File do

  alias Helix.Software.Repo
  alias Helix.Software.Model.File, as: File
  import Ecto.Query, only: [where: 3]

  @spec create(File.creation_params) ::
    {:ok, File.t}
    | {:error, :file_exists | Ecto.Changeset.t}
  def create(params) do
    params
    |> File.create_changeset()
    |> Repo.insert()
    |> parse_errors()
  end

  @spec find(HELL.PK.t) :: {:ok, File.t} | {:error, :notfound}
  def find(file_id) do
    case Repo.get_by(File, file_id: file_id) do
      nil ->
        {:error, :notfound}
      file ->
        {:ok, file}
    end
  end

  @spec update(HELL.PK.t, File.update_params) ::
    {:ok, File.t}
    | {:error, :file_exists | :notfound | Ecto.Changeset.t}
  def update(file_id, params) do
    with {:ok, file} <- find(file_id) do
      file
      |> File.update_changeset(params)
      |> Repo.update()
      |> parse_errors()
    end
  end

  @spec move(File.t, String.t) ::
    {:ok, File.t}
    | {:error, :file_exists | Ecto.Changeset.t}
  def move(file, file_path) do
    file
    |> File.update_changeset(%{file_path: file_path})
    |> Repo.update()
    |> parse_errors()
  end

  @spec rename(File.t, String.t) ::
    {:ok, File.t}
    | {:error, :file_exists | Ecto.Changeset.t}
  def rename(file, file_name) do
    file
    |> File.update_changeset(%{name: file_name})
    |> Repo.update()
    |> parse_errors()
  end

  @spec copy(File.t,
    %{
      name: String.t,
      file_path: String.t,
      storage_id: PK.t}) ::
        {:ok, File.t}
        | {:error, :file_exists | Ecto.Changeset.t}
  def copy(file, params) do
    %{
      name: params.name,
      file_path: params.file_path,
      storage_id: params.storage_id,
      file_size: file.file_size,
      file_type: file.file_type}
    |> File.create_changeset()
    |> Repo.insert()
    |> parse_errors()
  end

  @spec delete(File.t) :: no_return
  def delete(file = %File{}),
    do: delete(file.file_id)

  @spec delete(HELL.PK.t) :: no_return
  def delete(file_id) do
    File
    |> where([f], f.file_id == ^file_id)
    |> Repo.delete_all()

    :ok
  end

  @spec parse_errors(Ecto.Changeset.t) ::
    {:ok, Ecto.Changeset.t}
    | {:error, :file_exists | Ecto.Changeset.t}
  defp parse_errors(changeset) do
    case changeset do
      {:ok, file} ->
        {:ok, file}
      {:error, changeset} ->
        if Keyword.get(changeset.errors, :file_path) do
          {:error, :file_exists}
        else
          {:error, changeset}
        end
    end
  end
end