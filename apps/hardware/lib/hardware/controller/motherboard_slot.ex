defmodule Helix.Hardware.Controller.MotherboardSlot do

  alias Helix.Hardware.Model.MotherboardSlot
  alias Helix.Hardware.Repo

  @spec fetch(HELL.PK.t) :: MotherboardSlot.t | nil
  def fetch(slot_id),
    do: Repo.get(MotherboardSlot, slot_id)

  @spec update(MotherboardSlot.t, MotherboardSlot.update_params) :: {:ok, MotherboardSlot.t} | {:error, Ecto.Changeset.t}
  def update(slot, params) do
    slot
    |> MotherboardSlot.update_changeset(params)
    |> Repo.update()
  end

  @spec link(MotherboardSlot.t, Component.t) ::
    {:ok, MotherboardSlot.t}
    | {:error, :component_already_linked | :slot_already_linked, Ecto.Changeset.t}
  def link(slot, component) do
    slot_linked? = fn slot ->
      MotherboardSlot.linked?(slot) && {:error, :slot_already_linked}
    end

    component_used? = fn component ->
      component_used?(component) && {:error, :component_already_linked}
    end

    with \
      false <- slot_linked?.(slot),
      false <- component_used?.(component)
    do
      slot
      |> MotherboardSlot.update_changeset(%{link_component_id: component.component_id})
      |> Repo.update()
    end
  end

  @spec unlink(MotherboardSlot.t) :: {:ok, MotherboardSlot.t} | {:error, Ecto.Changeset.t}
  def unlink(slot) do
    update(slot, %{link_component_id: nil})
  end

  @spec component_used?(Component.t) :: boolean
  defp component_used?(component) do
    component
    |> Repo.preload(:slot)
    |> Map.fetch!(:slot)
    |> to_boolean()
  end

  @spec to_boolean(term) :: boolean
  defp to_boolean(v),
    do: !!v
end