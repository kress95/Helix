defmodule Helix.Hardware.Controller.HardwareQuery do

  alias HELF.Broker
  alias Helix.Hardware.Controller.HardwareService

  def handle_query("getComponent", %{id: component_id}) do
    # FIXME: add changeset validations T420
    case HardwareService.find_component(component_id) do
      {:ok, component} ->
        msg = %{
          component_id: component.component_id,
          component_spec: component.component_spec,
          component_type: component.component_type,
          spec_id: component.spec_id
        }

        {:ok, msg}
      error ->
        error
    end
  end

  def handle_query("listComponents", %{entity_id: entity_id}) do
    # FIXME: add changeset validations T420
    {_, result} = Broker.call("entity.component.find", entity_id)

    case result do
      {:ok, component_list} ->
        {:ok, %{list: component_list}}
      {:error, error} ->
        {:error, error}
      error ->
        {:error, error}
    end
  end

  # TODO:
  # def handle_query("getMotherboard", %{server_id: server_id}) do
  # end

  # TODO: implement after adding EntityMotherboard
  #
  # def handle_query("listMotherboards", %{id: entity_id}) do
  # end

  def handle_query("listMotherboardSlots", %{id: motherboard_id}) do
    # FIXME: add changeset validations T420
    slots =
      motherboard_id
      |> HardwareService.get_motherboard_slots()
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
