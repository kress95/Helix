defmodule HELM.Hardware.Controller.ComponentSpec do

  alias HELM.Hardware.Repo
  alias HELM.Hardware.Model.ComponentSpec, as: MdlCompSpec
  import Ecto.Query, only: [where: 3]

  @spec create(MdlCompSpec.creation_params) :: {:ok, MdlCompSpec.t} | {:error, Ecto.Changeset.t}
  def create(params) do
    params
    |> MdlCompSpec.create_changeset()
    |> Repo.insert()
  end

  @spec find(HELL.PK.t) :: {:ok, MdlCompSpec.t} | {:error, :notfound}
  def find(spec_id) do
    case Repo.get_by(MdlCompSpec, spec_id: spec_id) do
      nil ->
        {:error, :notfound}
      res ->
        {:ok, res}
    end
  end

  @spec update(HELL.PK.t, MdlCompSpec.update_params) :: {:ok, MdlCompSpec.t} | {:error, :notfound | Ecto.Changeset.t}
  def update(spec_id, params) do
    with {:ok, comp_spec} <- find(spec_id) do
      comp_spec
      |> MdlCompSpec.update_changeset(params)
      |> Repo.update()
    end
  end

  @spec delete(HELL.PK.t) :: no_return
  def delete(spec_id) do
    MdlCompSpec
    |> where([s], s.spec_id == ^spec_id)
    |> Repo.delete_all()

    :ok
  end
end