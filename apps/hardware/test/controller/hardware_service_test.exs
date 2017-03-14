defmodule Helix.Hardware.Controller.HardwareServiceTest do

  use ExUnit.Case, async: false

  alias HELF.Broker
  alias HELL.TestHelper.Random
  alias Helix.Entity.Controller.EntityServer, as: EntityServerController
  alias Helix.Hardware.Controller.Motherboard, as: MotherboardController
  alias Helix.Server.Controller.Server, as: ServerController
  alias Helix.Hardware.Model.Motherboard
  alias Helix.Hardware.Model.MotherboardSlot

  @moduletag :umbrella

  defp create_account do
    name = Random.username()
    email = Burette.Internet.email()
    password = Burette.Internet.password()

    params = %{
      username: name,
      email: email,
      password: password
    }

    case Broker.call("account.create", params) do
      {_, {:ok, account}} ->
        {:ok, account}
      {_, {:error, error}} ->
        {:error, error}
    end
  end

  # HACK: this method is calling methods from another domain instead of Broker
  defp motherboard_of_account(id) do
    # entity has a list of servers
    with \
      [entity_server] <- EntityServerController.find(id),
      {:ok, server} <- ServerController.find(entity_server.server_id)
    do
      MotherboardController.fetch(server.motherboard_id)
    else
      _ ->
        nil
    end
  end

  describe "after account creation" do
    test "motherboard is created" do
      {:ok, account} = create_account()

      # TODO: removing this sleep depends on T412
      :timer.sleep(200)

      assert %Motherboard{} = motherboard_of_account(account.account_id)
    end

    test "motherboard slots are created" do
      {:ok, account} = create_account()

      # TODO: removing this sleep depends on T412
      :timer.sleep(200)

      motherboard = motherboard_of_account(account.account_id)
      slots = MotherboardController.get_slots(motherboard)

      refute Enum.empty?(slots)
    end

    test "motherboard linked at least a single of each slot type" do
      {:ok, account} = create_account()

      # TODO: removing this sleep depends on T412
      :timer.sleep(200)

      motherboard = motherboard_of_account(account.account_id)
      slots = MotherboardController.get_slots(motherboard)

       possible_types = MapSet.new(slots, &(&1.link_component_type))
       linked_types =
         slots
         |> Enum.filter(&MotherboardSlot.linked?/1)
         |> MapSet.new(&(&1.link_component_type))

       assert MapSet.equal?(possible_types, linked_types)
    end
  end
end