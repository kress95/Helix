defmodule Helix.Hardware.Controller.Component do

  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Hardware.Repo

  @spec create_from_spec(ComponentSpec.t) :: {:ok, Component.t} | {:error, Ecto.Changeset.t}
  def create_from_spec(component_spec) do
    module = case component_spec.component_type do
      "mobo" ->
        Motherboard
      "hdd" ->
        Component.HDD
      "cpu" ->
        Component.CPU
      "ram" ->
        Component.RAM
      "nic" ->
        Component.NIC
    end

    component_spec
    |> module.create_from_spec()
    |> Repo.insert()
    |> case do
      {:ok, %{component: c}} ->
        {:ok, c}
      e ->
        e
    end
  end

  @spec fetch(HELL.PK.t) :: Component.t | nil
  def fetch(component_id),
    do: Repo.get(Component, component_id)

  @spec delete(HELL.PK.t) :: no_return
  def delete(component_id) do
    component_id
    |> Component.Query.by_id()
    |> Repo.delete_all()

    :ok
  end
end