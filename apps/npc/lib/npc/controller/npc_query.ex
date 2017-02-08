defmodule Helix.NPC.Controller.NPCQuery do

  def handle_query(_, _),
    do: {:error, :invalid_query}
end