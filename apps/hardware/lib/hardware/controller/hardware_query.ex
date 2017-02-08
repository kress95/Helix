defmodule Helix.Hardware.Controller.HardwareQuery do

  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Hardware.Repo

  def handle_query("getComponent", %{component_id: id}) do
    result =
      id
      |> Component.Query.by_id(id)
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component ->
        {:ok, component}
    end
  end

  def handle_query("isComponentLinked", %{component_id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Component.Query.by_id(id)
      |> Component.Query.select_component_slot()
      |> Repo.one()

    case result do
      nil ->
        {:ok, false}
      _ ->
        {:ok, true}
    end
  end

  def handle_query("getSpecOfComponent", %{component_id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Component.Query.by_id(id)
      |> Component.Query.select_component_spec()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component_spec ->
        {:ok, component_spec}
    end
  end

  def handle_query("getSlotsOfMotherboard", %{motherboard_id: id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Motherboard.Query.by_id(id)
      |> Motherboard.Query.select_slots()
      |> Repo.all()

    case result do
      [] ->
        {:error, :notfound}
      slots ->
        {:ok, slots}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end
