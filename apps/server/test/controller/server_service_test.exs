defmodule Helix.Server.Controller.ServerServiceTest do

  use ExUnit.Case, async: true

  alias HELF.Broker, warn: false
  alias Helix.Server.Controller.ServerService, warn: false
  alias Burette.Internet, as: Random

  @moduletag :umbrella

  test "creating an account creates a server" do
    IO.puts "working"
    params = %{

    }

    Broker.call("account:create", )
  end
end