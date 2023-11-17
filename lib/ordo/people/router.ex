defmodule Ordo.People.Router do
  use Commanded.Commands.Router

  dispatch([Ordo.People.Commands.CreateOwner],
    to: Ordo.People.Aggregates.Employee,
    identity: :employee_id
  )
end
