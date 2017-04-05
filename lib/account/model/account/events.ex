defmodule Helix.Account.Model.Account.AccountCreationEvent do

  @enforce_keys [:account_id, :email]
  defstruct [:account_id, :email]
end
