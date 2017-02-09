defmodule Helix.Log.Controller.LogQuery do

  # TODO: after adding find queries to the Controller

  # def handle_query("getLog", %{id: log_id}) do
  # end

  # def handle_query("getLogsOfServer", %{server_id: server_id}) do
  # end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end