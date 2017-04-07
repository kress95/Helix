defmodule Helix.Hardware.Service.API.Component do

  alias Helix.Hardware.Controller.Component, as: ComponentController
  alias Helix.Hardware.Model.Component
  alias Helix.Hardware.Model.ComponentSpec
  alias Helix.Hardware.Repo

  @spec create_from_spec(ComponentSpec.t) ::
    {:ok, Component.t}
    | {:error, Ecto.Changeset.t}
  @doc """
  Creates component of given specification
  """
  def create_from_spec(component_spec) do
    ComponentController.create_from_spec(component_spec)
  end

  @spec fetch(HELL.PK.t) :: Component.t | nil
  @doc """
  Fetches a component
  """
  def fetch(component_id) do
    ComponentController.fetch(component_id)
  end

  @spec find([ComponentController.find_param], meta :: []) :: [Component.t]
  @doc """
  Search for components

  ## Params

    * `:id` - search for component ids
    * `:type` - search for components of given component types
  """
  def find(params, meta \\ []) do
    ComponentController.find(params, meta)
  end

  @spec delete(Component.t | HELL.PK.t) :: no_return
  @doc """
  Deletes the component

  This function is idempotent
  """
  def delete(component_id) do
    ComponentController.delete(component_id)
  end

  # FIXME: WIP #109

  def create_initial_bundle do
    # REVIEW: wouldn't it be better if we cached the specs somehow?
    bundle = %{
      motherboard: "MOBO01",
      components:  [
        {:cpu, "CPU01"},
        {:ram, "RAM01"},
        {:hdd, "HDD01"},
        {:nic, "NIC01"}
      ],
      network: [
        {"::", uplink: 100, downlink: 100}
      ]
    }

    create_bundle(bundle)
  end

  # REVIEW: EXTREME WIP this should be simplified, and I'm assuming
  # that create_from_spec will crash when called with nil
  #
  # another thing is that this is fetching specs everytime,
  # caching it may be a good idea.

  def create_bundle(bundle) do
    alias Helix.Hardware.Service.API.Motherboard
    alias Helix.Hardware.Service.API.ComponentSpec

    Repo.transaction(fn ->
      # link grouped components with grouped slots, this is so ugly ç-ç
      link_grouped_components =
        fn components, slots ->
          slots_with_components =
            Enum.map(components, fn {type, components_of_type} ->
              slots
              |> Map.get(type, [])
              |> Enum.zip(components_of_type)
            end)

          Enum.each(slots_with_components, fn {slot, component} ->
            {:ok, _} = Motherboard.link(slot, component)
            :ok
          end)
        end

      # create motherboard
      motherboard =
        bundle.motherboard
        |> ComponentSpec.fetch()
        |> create_from_spec()

      # create components
      components =
        Enum.map(bundle.components, fn {_, spec_id} ->
          spec_id
          |> ComponentSpec.fetch()
          |> create_from_spec()
        end)

      # group slots by component type, to make it easier to link by using zip
      slots =
        motherboard
        |> Motherboard.get_slots()
        |> Enum.group_by(&(&1.link_component_type), &(&1))

      # links grouped components to grouped slots
      components
      |> Enum.group_by(&(&1.component_type), &(&1))
      |> link_grouped_components.(slots)

      component_ids = Enum.map(components, &(&1.component_id))

      result = %{
        motherboard: motherboard.motherboard_id,
        components: [motherboard.motherboard_id | component_ids]
      }

      {:ok, result}
    end)
  end
end
