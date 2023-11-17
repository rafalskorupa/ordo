defmodule Ordo.Corpos do
  alias Ordo.Repo
  alias Ordo.Corpos

  import Ecto.Query

  # Queries

  def list_corpos(%Ordo.Actor{} = actor) do
    Corpos.Projections.Corpo
    |> actor_scope(actor)
    |> Repo.all()
  end

  # Actions

  def create_corpo(actor, attrs) do
    with {:ok, command} <- Corpos.Commands.CreateCorpo.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, Repo.get!(Corpos.Projections.Corpo, command.corpo_id)}
    end
  end

  def create_corpo_changeset(command \\ %Corpos.Commands.CreateCorpo{}, attrs) do
    Corpos.Commands.CreateCorpo.changeset(command, attrs)
  end

  # Scopes

  def actor_scope(query, %{account: %{id: account_id}}) do
    corpo_ids =
      Ordo.People.Projections.Employee
      |> where(account_id: ^account_id)
      |> select([:corpo_id])

    where(query, [c], c.id in subquery(corpo_ids))
  end
end
