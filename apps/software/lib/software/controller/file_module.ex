defmodule Helix.Software.Controller.FileModule do

  alias Helix.Software.Model.File
  alias Helix.Software.Model.FileModule
  alias Helix.Software.Repo

  @type module_roles :: %{role :: HELL.PK.t => version :: non_neg_integer}

  @spec create(File.t, module_roles) ::
    {:ok, module_roles}
    | {:error, :internal}
  def create(file, roles) do
    r = Enum.map(roles, fn {role, v} ->
      p = %{
        file_id: file.file_id,
        module_role_id: role,
        module_version: v
      }

      FileModule.create_changeset(p)
    end)

    Repo.transaction(fn ->
      if Enum.all?(r, &match?({:ok, _}, Repo.insert(&1))) do
        roles
      else
        Repo.rollback(:internal)
      end
    end)
  end

  @spec find(File.t) :: module_roles
  def find(file) do
    file.file_id
    |> FileModule.Query.from_file()
    |> FileModule.Query.select_module_role_id_and_module_version()
    |> Repo.all()
    |> Enum.into(%{})
  end

  @spec update(File.t, HELL.PK.t, version :: non_neg_integer) ::
    {:ok, FileModule.t}
    | {:error, :notfound | Ecto.Changeset.t}
  def update(file, module_role, version) do
    file_module =
      file.file_id
      |> FileModule.Query.from_file()
      |> FileModule.Query.by_module_role_id(module_role)
      |> Repo.one()

    if file_module do
      file_module
      |> FileModule.update_changeset(%{module_version: version})
      |> Repo.update()
    else
      {:error, :notfound}
    end
  end
end