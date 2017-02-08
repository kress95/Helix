defmodule Helix.Software.Controller.SoftwareQuery do

  alias Helix.Software.Model.File
  alias Helix.Software.Repo

  def handle_query("getSoftware", %{file_id: id}) do
    result =
      id
      |> File.Query.by_id()
      |> Repo.one()

    case result do
      nil ->
        {:error, :notfound}
      file ->
        {:ok, file}
    end
  end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end