defmodule Helix.Account.Service.Flow.Account do

  alias Helix.Entity.Service.API.Entity
  alias Helix.Hardware.Service.API.Component
  alias Helix.Hardware.Service.API.Motherboard
  alias Helix.Server.Service.API.Server

  import HELF.Flow

  def create(account) do
    # not that bad from here, but still I'm nowhere near happy with this'
    entity_params = %{
      entity_type: :account,
      entity_id: account.account_id
    }

    flowing do
      with \
        {:ok, entity} <- Entity.create(entity_params),
        on_fail(fn -> Entity.delete(entity) end),

        {:ok, server} <- Server.create(:desktop),
        on_fail(fn -> Server.delete(server) end),

        :ok <- Entity.link_server(entity, server.server_id),

        {:ok, bundle} <- Component.create_initial_bundle(),
        on_fail(fn ->
          Server.detach(server)
          Motherboard.delete(bundle.motherboard)

          Enum.each(bundle.components, fn id ->
            Entity.unlink_component(id)
            Component.delete(id)
          end)
        end),

        {:ok, _} <- Server.attach(server, bundle.motherboard),

        :ok <- Enum.each(
          bundle.components,
          &Entity.link_component(entity, &1))
      do
        # actually I dont have idea if this is okay
        :ok
      end
    end
  end
end
