defmodule Helix.Hardware.Controller.HardwareQuery do

  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Hardware.Model.MotherboardSlot
  alias Helix.Hardware.Repo

  def handle_query("getComponentType", %{"id" => id}) do
    result =
      id
      |> Component.Query.by_id(id)
      |> Component.Query.select_component_type()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component_type ->
        {:ok, component_type}
    end
  end

  def handle_query("getComponentSpec", %{"id" => id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> Component.Query.by_id(id)
      |> Component.Query.select_component_spec()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component_type ->
        {:ok, component_type}
    end
  end

  def handle_query("getMotherboardSlots", %{"id" => id}) do
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

  def handle_query("getSlotType", %{"id" => id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> MotherboardSlot.Query.by_id(id)
      |> MotherboardSlot.Query.select_component_type()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component_type ->
        {:ok, component_type}
    end
  end

  def handle_query("getSlotLinkedComponent", %{"id" => id}) do
    # FIXME: add changeset validations T420
    result =
      id
      |> MotherboardSlot.Query.by_id(id)
      |> MotherboardSlot.Query.select_component_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component_id ->
        {:ok, component_id}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end
