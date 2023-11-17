defmodule Ordo.Corpos do
  alias Ordo.Repo
  alias Ordo.Corpos

  # Queries

  # Actions

  def create_corpo(actor, attrs) do
    with {:ok, command} <- Corpos.Commands.CreateCorpo.build(actor, attrs),
         :ok <- Ordo.App.dispatch(command, consistency: :strong) do
      {:ok, Repo.get!(Corpos.Projections.Corpo, command.corpo_id)}
    end
  end
end
