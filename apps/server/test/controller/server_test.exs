defmodule HELM.Server.ControllerTest do
  use ExUnit.Case

  alias HELL.IPv6
  alias HELL.TestHelper.Random, as: HRand
  alias HELM.Server.Repo
  alias HELM.Server.Controller.Server, as: CtrlServer
  alias HELM.Server.Model.ServerType, as: MdlServerType

  @server_type HRand.string(min: 20)

  setup_all do
    %{server_type: @server_type}
    |> MdlServerType.create_changeset()
    |> Repo.insert!()

    :ok
  end

  setup do
    payload = %{server_type: @server_type}
    {:ok, payload: payload}
  end

  test "create/2", %{payload: payload} do
    assert {:ok, _} = CtrlServer.create(payload)
  end

  describe "find/1" do
    test "success", %{payload: payload} do
      {:ok, serv} = CtrlServer.create(payload)
      assert {:ok, serv} == CtrlServer.find(serv.server_id)
    end

    test "failure" do
      assert {:error, :notfound} == CtrlServer.find(IPv6.generate([]))
    end
  end

  describe "update/2" do
    test "change server location", %{payload: payload} do
      assert {:ok, server} = CtrlServer.create(payload)

      poi = IPv6.generate([])
      payload2 = %{poi_id: poi}
      assert {:ok, server} = CtrlServer.update(server.server_id, payload2)

      {:ok, poi} = EctoNetwork.INET.cast(poi)
      assert server.poi_id == poi
    end

    test "change motherboard id", %{payload: payload} do
      assert {:ok, server} = CtrlServer.create(payload)

      mobo = IPv6.generate([])
      payload2 = %{motherboard_id: mobo}
      assert {:ok, server} = CtrlServer.update(server.server_id, payload2)

      {:ok, mobo} = EctoNetwork.INET.cast(mobo)
      assert server.motherboard_id == mobo
    end

    test "server not found" do
      assert {:error, :notfound} = CtrlServer.update(IPv6.generate([]), %{})
    end
  end

  test "delete/1 idempotency", %{payload: payload} do
    {:ok, serv} = CtrlServer.create(payload)
    assert :ok == CtrlServer.delete(serv.server_id)
    assert :ok == CtrlServer.delete(serv.server_id)
    assert {:error, :notfound} = CtrlServer.find(serv.server_id)
  end
end