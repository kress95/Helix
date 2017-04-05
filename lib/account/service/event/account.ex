defmodule Helix.Software.Service.Event.Account do

  alias HELF.Mailer
  alias Helix.Account.Model.Account.AccountCreationEvent

  @spec create(%AccountCreationEvent{}) :: any
  def create(event = %AccountCreationEvent{}) do
    # FIXME: write this email properly
    Mailer.new()
    |> Mailer.from("no-reply@hackerexperience.comp")
    |> Mailer.to(event.email)
    |> Mailer.subject("Welcome to Hacker Experience")
    |> Mailer.html("Lorem ipsum.")
    |> Mailer.text("Lorem ipsum.")
    |> Mailer.send()
  end
end
