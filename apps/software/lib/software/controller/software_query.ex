defmodule Helix.Software.Controller.SoftwareQuery do

  # TODO: when software concept is defined

  # def handle_query("getSoftware", %{id: software_id}) do
  # end

  # def handle_query("listSoftware", %{storage_id: storage_id}) do
  # end

  # def handle_query("listSoftware", %{server_id: server_id}) do
  # end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end