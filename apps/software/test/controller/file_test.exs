defmodule Helix.Software.Controller.FileTest do

  use ExUnit.Case, async: true

  alias HELL.IPv6
  alias HELL.TestHelper.Random, as: HRand
  alias Helix.Software.Repo
  alias Helix.Software.Model.FileType, as: MdlFileType
  alias Helix.Software.Controller.Storage, as: CtrlStorage
  alias Helix.Software.Controller.File, as: CtrlFile

  setup_all do
    file_type = HRand.string(min: 20)
    %{file_type: file_type, extension: ".test"}
    |> MdlFileType.create_changeset()
    |> Repo.insert!()

    {:ok, file_type: file_type}
  end

  setup %{file_type: file_type} do
    {:ok, s} = CtrlStorage.create()
    payload = create_params(%{file_type: file_type, storage_id: s.storage_id})
    {:ok, payload: payload}
  end

  defp create_params(%{file_type: file_type, storage_id: storage_id}) do
    %{
      name: HRand.digits(min: 20),
      file_path: "/dev/null",
      file_type: file_type,
      file_size: HRand.number(min: 1),
      storage_id: storage_id
    }
  end

  describe "file creation" do
    test "creates the file", %{payload: payload} do
      assert {:ok, _} = CtrlFile.create(payload)
    end

    test "failure when file exists", %{payload: payload} do
      CtrlFile.create(payload)
      assert {:error, :file_exists} == CtrlFile.create(payload)
    end
  end

  describe "find/1" do
    test "success", %{payload: payload} do
      assert {:ok, file} = CtrlFile.create(payload)
      assert {:ok, ^file} = CtrlFile.find(file.file_id)
    end

    test "failure" do
      assert {:error, :notfound} == CtrlFile.find(IPv6.generate([]))
    end
  end

  describe "update/2" do
    test "rename file", %{payload: payload} do
      payload2 = %{name: "null"}

      assert {:ok, file} = CtrlFile.create(payload)
      assert {:ok, file} = CtrlFile.update(file.file_id, payload2)

      assert payload2.name == file.name
    end

    test "move file", %{payload: payload} do
      payload2 = %{file_path: "/dev/urandom"}

      assert {:ok, file} = CtrlFile.create(payload)
      assert {:ok, file} = CtrlFile.update(file.file_id, payload2)

      assert payload2.file_path == file.file_path
    end

    test "change storage", %{payload: payload} do
      {:ok, update_storage} = CtrlStorage.create()

      payload2 = %{storage_id: update_storage.storage_id}

      assert {:ok, file} = CtrlFile.create(payload)
      assert {:ok, file} = CtrlFile.update(file.file_id, payload2)

      assert payload2.storage_id == file.storage_id
    end

    test "not found" do
      assert {:error, :notfound} == CtrlFile.update(IPv6.generate([]), %{})
    end

    test "fails when file exists", %{payload: payload0} do
      CtrlFile.create(payload0)

      p = %{file_type: payload0.file_type, storage_id: payload0.storage_id}
      payload1 = create_params(p)
      {:ok, file1} = CtrlFile.create(payload1)

      assert {:error, :file_exists} == CtrlFile.update(file1.file_id, payload0)
    end
  end

  describe "renaming a file" do
    test "renames the file", %{payload: payload} do
      {:ok, file} = CtrlFile.create(payload)
      new_name = Burette.Color.name()
      {:ok, renamed_file} = CtrlFile.rename(file, new_name)

      assert new_name == renamed_file.name
    end

    test "fails to rename when file exists", %{payload: payload0} do
      {:ok, file0} = CtrlFile.create(payload0)

      payload1 =
        %{file_type: payload0.file_type, storage_id: payload0.storage_id}
        |> create_params()
        |> Map.put(:file_path, payload0.file_path)

      {:ok, file1} = CtrlFile.create(payload1)

      assert {:error, :file_exists} == CtrlFile.rename(file1, file0.name)
    end
  end

  describe "moving a file" do
    test "moves the file", %{payload: payload} do
      {:ok, file} = CtrlFile.create(payload)
      new_path = Burette.Color.name()
      {:ok, moved_file} = CtrlFile.move(file, new_path)

      assert new_path == moved_file.file_path
    end

    test "fails to move when file exists", %{payload: payload0} do
      {:ok, file0} = CtrlFile.create(payload0)

      payload1 =
        %{file_type: payload0.file_type, storage_id: payload0.storage_id}
        |> create_params()
        |> Map.put(:name, payload0.name)
        |> Map.put(:file_path, payload0.name)

      {:ok, file1} = CtrlFile.create(payload1)

      assert {:error, :file_exists} == CtrlFile.move(file1, file0.file_path)
    end
  end

  test "delete/1 idempotency", %{payload: payload} do
    assert {:ok, file} = CtrlFile.create(payload)
    assert :ok = CtrlFile.delete(file.file_id)
    assert :ok = CtrlFile.delete(file.file_id)
    assert {:error, :notfound} == CtrlFile.find(file.file_id)
  end
end