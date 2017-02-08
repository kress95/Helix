defmodule Helix.Process.Controller.ProcessQuery do

  def handle_query(_, _),
    do: {:error, :invalid_query}
end