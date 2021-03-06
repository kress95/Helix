defmodule Helix.Software.Controller.FileTest do

  use Helix.Test.IntegrationCase

  alias HELL.TestHelper.Random
  alias Helix.Software.Controller.File, as: FileController
  alias Helix.Software.Model.File
  alias Helix.Software.Model.SoftwareModule
  alias Helix.Software.Repo

  alias Helix.Software.Factory

  def generate_params do
    storage = Factory.insert(:storage)
    file = Factory.build(:file)

    file
    |> Map.take([:path, :file_size, :name, :software_type])
    |> Map.put(:storage_id, storage.storage_id)
  end

  defp generate_software_modules(software_type) do
    software_type
    |> SoftwareModule.Query.by_software_type()
    |> Repo.all()
    |> Enum.into(%{}, &{&1.software_module, Burette.Number.number(1..1024)})
  end

  describe "creating" do
    test "succeeds with valid params" do
      params = generate_params()
      {:ok, file} = FileController.create(params)

      got = Map.take(file, Map.keys(params))
      assert params == got
    end

    test "fails on path identity conflict" do
      params = generate_params()
      collision = Map.take(params, [:name, :path, :software_type, :storage_id])

      {:ok, _} = FileController.create(params)

      params = Map.merge(generate_params(), collision)

      {:error, result} = FileController.create(params)
      assert :full_path in Keyword.keys(result.errors)
    end
  end

  describe "fetching" do
    test "returns a record based on its identification" do
      file = Factory.insert(:file)
      assert %File{} = FileController.fetch(file.file_id)
    end

    test "returns nil if file doesn't exist" do
      refute FileController.fetch(Random.pk())
    end
  end

  describe "get_files_on_target_storage/1" do
    test "returns non-encrypted files" do
      target_storage = Factory.insert(:storage, %{files: []})
      Factory.insert_list(5, :file, storage: target_storage)

      files = FileController.get_files_on_target_storage(target_storage)

      assert 5 == Enum.count(files)
      assert Enum.all?(files, &(is_nil(&1.crypto_version)))
    end

    test "returns encrypted files" do
      target_storage = Factory.insert(:storage, %{files: []})
      Factory.insert_list(5, :file, storage: target_storage, crypto_version: 1)

      files = FileController.get_files_on_target_storage(target_storage)

      assert 5 == Enum.count(files)
      assert Enum.all?(files, &(not is_nil(&1.crypto_version)))
    end
  end

  describe "updating" do
    # TODO: Chop the things that are tested here in three different tests
    test "succeeds with valid params" do
      file = Factory.insert(:file)

      # update name
      params = %{name: "some very random name"}
      {:ok, updated} = FileController.update(file, params)

      refute file.name == updated.name
      assert params.name == updated.name

      # update path
      params = Map.take(Factory.params_for(:file), [:path])
      {:ok, updated} = FileController.update(file, params)

      refute file.path == updated.path
      assert params.path == updated.path
    end

    test "fails on file path identity conflict" do
      file0 = Factory.insert(:file)
      intersection = Map.take(file0, [:storage, :software_type])
      file1 = Factory.insert(:file, intersection)
      params = Map.take(file0, [:path, :name])

      {:error, result} =  FileController.update(file1, params)
      assert :full_path in Keyword.keys(result.errors)
    end
  end

  describe "copying" do
    test "to another path in the same storage" do
      path = Factory.params_for(:file).path
      origin = Factory.insert(:file)

      {:ok, copy} = FileController.copy(origin, origin.storage, path)

      assert FileController.fetch(origin.file_id)
      assert FileController.fetch(copy.file_id)
      assert path == copy.path
    end

    test "to another storage" do
      storage = Factory.insert(:storage)
      origin = Factory.insert(:file)

      {:ok, copy} =
        FileController.copy(origin, storage, origin.path)

      assert FileController.fetch(origin.file_id)
      assert FileController.fetch(copy.file_id)
      assert storage.storage_id == copy.storage_id
    end

    test "fails on path identity conflict" do
      origin = Factory.insert(:file)

      {:error, result} = FileController.copy(
        origin,
        origin.storage,
        origin.path)
      assert :full_path in Keyword.keys(result.errors)
    end
  end

  describe "moving" do
    test "to another path" do
      file = Factory.insert(:file)
      path = Factory.params_for(:file).path

      {:ok, file} = FileController.move(file, path)

      assert path == file.path
    end

    test "fails on path identity conflict" do
      file0 = Factory.insert(:file)
      similarities = Map.take(file0, [:name, :storage, :software_type])
      file1 = Factory.insert(:file, similarities)

      {:error, result} = FileController.move(file1, file0.path)
      assert :full_path in Keyword.keys(result.errors)
    end
  end

  describe "renaming" do
    test "succeeds with a valid non-conflicting name" do
      file = Factory.insert(:file)
      name = Factory.params_for(:file).name

      {:ok, file} = FileController.rename(file, name)

      assert name == file.name
    end

    test "fails on path identity conflict" do
      file0 = Factory.insert(:file)
      similarities = Map.take(file0, [:path, :software_type, :storage])
      file1 = Factory.insert(:file, similarities)

      # FIXME: this is thanks to how ExMachina works
      file1 = Repo.update! File.update_changeset(file1, similarities)

      {:error, result} = FileController.rename(file1, file0.name)
      assert :full_path in Keyword.keys(result.errors)
    end
  end

  test "setting modules" do
    file = Factory.insert(:file)
    modules = generate_software_modules(file.software_type)

    {:ok, file_modules} = FileController.set_modules(file, modules)

    # created modules from `modules`
    assert modules == file_modules
  end

  describe "getting modules" do
    test "returns file modules as a map" do
      file = Factory.insert(:file)
      modules = generate_software_modules(file.software_type)

      FileController.set_modules(file, modules)

      file_modules = FileController.get_modules(file)
      assert modules == file_modules
    end

    test "returns empty map when nothing is found" do
      file = Factory.insert(:file)
      file_modules = FileController.get_modules(file)

      assert Enum.empty?(file_modules)
    end
  end

  describe "deleting" do
    test "is idempotent" do
      file = Factory.insert(:file)

      assert FileController.fetch(file.file_id)
      FileController.delete(file.file_id)
      FileController.delete(file.file_id)
      refute FileController.fetch(file.file_id)
    end

    test "can be done by its id" do
      file = Factory.insert(:file)

      assert FileController.fetch(file.file_id)
      FileController.delete(file.file_id)
      refute FileController.fetch(file.file_id)
    end

    test "can be done by its struct" do
      file = Factory.insert(:file)

      assert FileController.fetch(file.file_id)
      FileController.delete(file.file_id)
      refute FileController.fetch(file.file_id)
    end

    test "deletes every module" do
      file = Factory.insert(:file)
      software_module = generate_software_modules(file.software_type)

      {:ok, _} = FileController.set_modules(file, software_module)

      Repo.delete(file)

      file_modules = FileController.get_modules(file)
      assert Enum.empty?(file_modules)
    end
  end
end
