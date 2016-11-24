alias HELM.Entity.Repo
alias HELM.Entity.Model.EntityType

~w(account npc clan)
|> Enum.map(fn entity_type ->
    %{entity_type: entity_type}
    |> EntityType.create_changeset()
  end)
|> Enum.each(&Repo.insert!/1)