defmodule Ordo.People.Handlers.CreateOwnerEmployee do
  use Commanded.Event.Handler,
    application: Ordo.App,
    name: "CreateOwnerEmployee",
    consistency: :strong

  def handle(
        %Ordo.Corpos.Events.CorpoCreated{corpo_id: corpo_id, account_id: account_id},
        _metadata
      ) do
    Ordo.App.dispatch(
      %Ordo.People.Commands.CreateOwner{
        employee_id: Ecto.UUID.generate(),
        corpo_id: corpo_id,
        account_id: account_id
      },
      consistency: :strong
    )
  end
end
