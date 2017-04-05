defmodule Helix.Software.Service.Event.Account do

  alias HELF.Mailer
  alias Helix.Account.Model.Account.AccountCreationEvent
  alias Helix.Account.Service.Flow.Account, as: AccountFlow

  @spec send_email(%AccountCreationEvent{}) :: any
  def send_email(event = %AccountCreationEvent{}) do
    # FIXME: write this email properly
    Mailer.new()
    |> Mailer.from("no-reply@hackerexperience.comp")
    |> Mailer.to(event.email)
    |> Mailer.subject("Welcome to Hacker Experience")
    |> Mailer.html("Lorem ipsum.")
    |> Mailer.text("Lorem ipsum.")
    |> Mailer.send()
  end

  @spec setup_account(%AccountCreationEvent{}) :: any
  def setup_account(event),
    do: AccountFlow.setup(event.account_id)
end
