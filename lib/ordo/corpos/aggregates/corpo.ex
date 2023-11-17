defmodule Ordo.Corpos.Aggregates.Corpo do
  defstruct [:corpo_id, :name]

  alias Ordo.Corpos.Aggregates.Corpo

  alias Ordo.Corpos.Commands.CreateCorpo
  alias Ordo.Corpos.Events.CorpoCreated

  def execute(%Corpo{}, %CreateCorpo{} = command) do
    %{corpo_id: corpo_id, name: name, account_id: account_id} = CreateCorpo.validate!(command)

    %CorpoCreated{
      corpo_id: corpo_id,
      name: name,
      account_id: account_id
    }
  end

  def apply(%Corpo{}, %CorpoCreated{} = event) do
    %Corpo{
      corpo_id: event.corpo_id,
      name: event.name
    }
  end
end
