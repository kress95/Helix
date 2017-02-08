defmodule Helix.Log.Controller.LogQuery do

  # TODO: after adding find queries to the Controller

  # def handle_query("getLog", %{log_id: id}) do
  # end

  # def handle_query("getLogsOfServer", %{log_id: id}) do
  # end

  def handle_query(_, _),
    do: {:error, :invalid_query}
end