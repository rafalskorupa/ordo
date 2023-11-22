defmodule Ordo.People.Router do
  use Commanded.Commands.Router

  dispatch(
    [
      Ordo.People.Commands.CreateOwner,
      Ordo.People.Commands.CreateEmployee,
      Ordo.People.Commands.UpdateEmployee,
      Ordo.People.Commands.DeleteEmployee,
      Ordo.People.Commands.LinkEmployee
    ],
    to: Ordo.People.Aggregates.Employee,
    identity: :employee_id
  )
end
