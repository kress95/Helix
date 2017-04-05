defmodule Helix.Account.Service.Flow.AccountTest do

  use ExUnit.Case, async: true

  alias Helix.Account.Service.Flow.Account, as: Flow

  alias Helix.Account.Factory

  test "wip" do
    :account
    |> Factory.insert()
    |> Flow.create()
    |> IO.inspect()
  end
end
