defmodule Helix.Account.Service.Flow.Account do

  alias Helix.Account.Model.Account
  alias Helix.Entity.Service.API.Entity
  alias Helix.Hardware.Service.API.Component
  alias Helix.Hardware.Service.API.ComponentSpec
  alias Helix.Hardware.Service.API.Motherboard
  alias Helix.Server.Service.API.Server

  import HELF.Flow

  # FIXME: move this to a better place
  @initial_bundle %{
    motherboard: "MOBO01",
    components: [
      {:cpu, "CPU01"},
      {:ram, "RAM01"},
      {:hdd, "HDD01"},
      {:nic, "NIC01"}
    ],
    network: [
      {"::", uplink: 100, downlink: 100}
    ]
  }

  @spec setup(Account.id) ::
    :ok
    | :error
  def setup(account_id) do
    # FIXME: currently, there's nothing being done with network
    bundle = @initial_bundle

    # FIXME: this doesn't look right'
    flowing do
      with \
        {:ok, entity} <- Entity.create(:account, account_id),
        on_fail(fn -> Entity.delete(entity) end),

        {:ok, server} <- Server.create(:desktop),
        on_fail(fn -> Server.delete(server) end),

        :ok <- Entity.link_server(entity, server.server_id),
        on_fail(fn -> Entity.unlink_server(server.server_id) end),

        components <- create_components!(bundle),
        on_fail(fn -> Enum.each(components, &Component.delete/1) end),
        [mobo_component | _] = components,

        :ok <- link_components!(components),
        on_fail(fn ->
          mobo_component.component_id
          |> Motherboard.get_slots()
          |> Enum.each(&Motherboard.unlink/1)
        end),

        entity_link_components =
          Enum.map(components, fn component ->
            Entity.link_component(entity, component.component_id)
          end),

        on_fail(fn ->
          Enum.each(components, fn component ->
            Entity.unlink_component(component.component_id)
          end)
        end),

        true <- Enum.all?(entity_link_components, &(match?({:ok, _}, &1))),

        {:ok, _} <- Server.attach(server, mobo_component.motherboard_id)
      do
        :ok
      else
        _ ->
          :error
      end
    end
  end

  # FIXME: this looks like something that could be part of a
  # `Component.create_bundle/1` function on model
  defp create_components!(bundle) do
    # motherboard is the first one to make it easier to fetch
    spec_ids = [bundle.motherboard | Keyword.values(bundle.components)]

    # FIXME: maybe add a spec cache, fetching the database for same specs
    # everytime sounds slow and wrong.
    spec_ids
    |> Enum.map(&ComponentSpec.fetch/1)
    |> Enum.map(&Component.create_from_spec/1)
  end

  # FIXME: this looks like something that could be part of a
  # `Component.create_bundle/1` function on model
  defp link_components!([motherboard | components]) do
    grouped_components = Enum.group_by(components, &(&1.component_type))

    grouped_slots =
      motherboard.component_id
      |> Motherboard.get_slots()
      |> Enum.group_by(&(&1.component_type))

    # there's any easier/better way to catch map key collision?
    Map.merge(grouped_slots, grouped_components, fn _, slots, components ->
      slots_with_components = Enum.zip(slots, components)

      Enum.map(slots_with_components, fn {slot, component} ->
        {:ok, _} = Motherboard.link(slot, component)
      end)
    end)

    :ok
  end
end
