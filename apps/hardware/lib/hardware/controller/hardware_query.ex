defmodule Helix.Hardware.Controller.HardwareQuery do

  alias HELF.Broker
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.MotherboardSlot
  alias Helix.Hardware.Repo

  def handle_query("getComponent", %{id: component_id}) do
    # FIXME: add changeset validations T420
    result =
      component_id
      |> Component.Query.by_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      component ->
        {:ok, component}
    end
  end

  def handle_query("listComponents", %{entity_id: entity_id}) do
    # FIXME: add changeset validations T420
    {_, result} = Broker.call("entity.list.components", entity_id)

    case result do
      {:ok, component_list} ->
        {:ok, %{list: component_list}}
      {:error, error} ->
        {:error, error}
      error ->
        {:error, error}
    end
  end

  # FIXME: impossible to do performatically without adding
  # component_type # to EntityComponent and indexing by
  # [component_type, component_id].
  #
  # alternative method: adding EntityMotherboard
  # def handle_query("listMotherboards", %{id: entity_id}) do
  # end

  def handle_query("listMotherboardSlots", %{id: motherboard_id}) do
    # FIXME: add changeset validations T420
    slots =
      motherboard_id
      |> MotherboardSlot.Query.by_motherboard_id()
      |> Repo.all()
      |> Enum.map(fn slot ->
        %{
          slot_id: slot.slot_id,
          link_component_id: slot.link_component_id,
          link_component_type: slot.link_component_type,
          slot_internal_id: slot.slot_internal_id
        }
      end)

    {:ok, %{list: slots}}
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end
