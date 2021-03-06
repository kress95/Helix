defmodule Helix.Software.Factory do

  use ExMachina.Ecto, repo: Helix.Software.Repo

  alias HELL.TestHelper.Random
  alias Helix.Software.Model.StorageDrive
  alias Helix.Software.Model.SoftwareType

  def file_factory do
    :file
    |> prepare()
    |> Map.put(:storage, build(:storage))
  end

  def text_file_factory do
    %Helix.Software.Model.TextFile{
      file: build(:file),
      contents: Burette.Color.name()
    }
  end

  def storage_drive_factory do
    :storage_drive
    |> prepare()
    |> Map.put(:storage, build(:storage))
  end

  def storage_factory do
    files = Random.repeat(1..3, fn -> prepare(:file) end)
    drives = Random.repeat(1..3, fn -> prepare(:storage_drive) end)

    %Helix.Software.Model.Storage{
      files: files,
      drives: drives
    }
  end

  defp prepare(:file) do
    # Maybe i need to add a generator for this in Burette
    path =
      1..5
      |> Random.repeat(fn -> Burette.Internet.username() end)
      |> Enum.join("/")

    size = Burette.Number.number(1024..1_048_576)
    name = Burette.Color.name()

    {software_type, type_meta} = Enum.random(SoftwareType.possible_types())
    extension = type_meta.extension

    %Helix.Software.Model.File{
      name: name,
      path: "/" <> path,
      full_path: "/" <> path <> "/" <> name <> "." <> extension,
      file_size: size,
      # FIXME: Think about a better way than hardcoding or fetching every time
      #   maybe have a genserver that holds all possibilities be started with
      #   the test suite, that way simply fetching it is faster (and allows
      #   hacks) than fetching from DB every time
      software_type: software_type
    }
  end

  defp prepare(:storage_drive),
    do: %StorageDrive{drive_id: Random.pk()}
end
